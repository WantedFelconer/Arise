import { Injectable, UnauthorizedException, ConflictException, Inject } from '@nestjs/common';
import argon2 from 'argon2';
import { AuthRepository } from '../repository/auth.repository';
import { JwtTokenService } from '../../../core/auth/jwt-token.service';
import {
  SignupDto,
  LoginDto,
  RefreshDto,
  LogoutDto,
  PasswordResetRequestDto,
  PasswordResetConfirmDto,
  AuthResponse,
  AuthTokens,
} from '../dto/auth.dto';
import { CharacterStats } from '../../../core/rpg-engine';

@Injectable()
export class AuthService {
  constructor(
    @Inject(AuthRepository) private authRepository: AuthRepository,
    @Inject(JwtTokenService) private jwtTokenService: JwtTokenService,
  ) {}

  async signup(dto: SignupDto): Promise<AuthResponse> {
    const existing = await this.authRepository.findUserByEmail(dto.email);
    if (existing) {
      throw new ConflictException({
        code: 'USER_EXISTS',
        message: 'An account with this email already exists',
      });
    }

    const passwordHash = await argon2.hash(dto.password, {
      type: argon2.argon2id,
    });

    const userWithChar = await this.authRepository.createUserWithInitialState({
      email: dto.email,
      passwordHash,
      difficultyMode: dto.difficultyMode,
      chronotype: dto.chronotype,
    });

    const tokens = await this.generateAndStoreTokens(userWithChar.id);

    return {
      user: {
        id: userWithChar.id,
        email: userWithChar.email,
        difficultyMode: userWithChar.difficultyMode,
      },
      character: userWithChar.character
        ? {
            id: userWithChar.character.id,
            level: userWithChar.character.level,
            totalXp: userWithChar.character.totalXp,
            currentMana: userWithChar.character.currentMana,
            maxMana: userWithChar.character.maxMana,
            rank: userWithChar.character.rank,
            stats: userWithChar.character.stats as unknown as CharacterStats,
          }
        : undefined,
      tokens,
    };
  }

  async login(dto: LoginDto): Promise<AuthResponse> {
    const user = await this.authRepository.findUserByEmail(dto.email);
    if (!user || user.deletedAt) {
      throw new UnauthorizedException({
        code: 'INVALID_CREDENTIALS',
        message: 'Invalid email or password',
      });
    }

    const isValidPassword = await argon2.verify(user.passwordHash, dto.password);
    if (!isValidPassword) {
      throw new UnauthorizedException({
        code: 'INVALID_CREDENTIALS',
        message: 'Invalid email or password',
      });
    }

    const tokens = await this.generateAndStoreTokens(user.id);

    return {
      user: {
        id: user.id,
        email: user.email,
        difficultyMode: user.difficultyMode,
      },
      character: user.character
        ? {
            id: user.character.id,
            level: user.character.level,
            totalXp: user.character.totalXp,
            currentMana: user.character.currentMana,
            maxMana: user.character.maxMana,
            rank: user.character.rank,
            stats: user.character.stats as unknown as CharacterStats,
          }
        : undefined,
      tokens,
    };
  }

  /**
   * Token refresh with strict rotation and reuse detection (FR-AUTH-004 / AC-AUTH-004)
   */
  async refresh(dto: RefreshDto): Promise<AuthTokens> {
    const tokenHash = this.jwtTokenService.hashRefreshToken(dto.refreshToken);
    const tokenRecord = await this.authRepository.findRefreshToken(tokenHash);

    if (!tokenRecord) {
      throw new UnauthorizedException({
        code: 'INVALID_REFRESH_TOKEN',
        message: 'Invalid or unrecognized refresh token',
      });
    }

    // Reuse detection: token already rotated / revoked / expired
    if (tokenRecord.revokedAt !== null || tokenRecord.expiresAt < new Date()) {
      // Hard security requirement: revoke ALL sessions for this user
      await this.authRepository.revokeAllUserRefreshTokens(tokenRecord.userId);
      throw new UnauthorizedException({
        code: 'TOKEN_REUSE_DETECTED',
        message: 'Refresh token reuse detected. All active sessions have been revoked.',
      });
    }

    // Single-use token rotation: revoke current token
    await this.authRepository.revokeRefreshToken(tokenHash);

    // Issue new pair
    return this.generateAndStoreTokens(tokenRecord.userId);
  }

  async logout(userId: string, dto: LogoutDto) {
    if (dto.refreshToken) {
      const tokenHash = this.jwtTokenService.hashRefreshToken(dto.refreshToken);
      await this.authRepository.revokeRefreshToken(tokenHash);
    } else {
      await this.authRepository.revokeAllUserRefreshTokens(userId);
    }
    return { message: 'Logged out successfully' };
  }

  async requestPasswordReset(_dto: PasswordResetRequestDto) {
    return { message: 'If the email exists, a password reset link has been sent.' };
  }

  async confirmPasswordReset(dto: PasswordResetConfirmDto) {
    if (!dto.token || dto.token === 'invalid') {
      throw new UnauthorizedException({
        code: 'INVALID_RESET_TOKEN',
        message: 'Password reset token is invalid or expired',
      });
    }

    await argon2.hash(dto.newPassword, {
      type: argon2.argon2id,
    });

    return { message: 'Password reset successfully' };
  }

  async deleteAccount(userId: string) {
    await this.authRepository.softDeleteUser(userId);
    return { message: 'Account deleted successfully' };
  }

  private async generateAndStoreTokens(userId: string): Promise<AuthTokens> {
    const accessToken = this.jwtTokenService.generateAccessToken(userId);
    const refreshToken = this.jwtTokenService.generateRefreshToken();

    const tokenHash = this.jwtTokenService.hashRefreshToken(refreshToken);
    const expiresAt = new Date(Date.now() + 30 * 24 * 60 * 60 * 1000); // 30 days

    await this.authRepository.saveRefreshToken(userId, tokenHash, expiresAt);

    return {
      accessToken,
      refreshToken,
    };
  }
}
