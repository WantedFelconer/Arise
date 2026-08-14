import { describe, it, expect, beforeEach } from 'vitest';
import { AuthService } from '../service/auth.service';
import { AuthRepository } from '../repository/auth.repository';
import { JwtTokenService } from '../../../core/auth/jwt-token.service';

describe('Auth Module & Security Lifecycle', () => {
  let authService: AuthService;
  let authRepository: AuthRepository;
  let jwtTokenService: JwtTokenService;

  beforeEach(() => {
    jwtTokenService = new JwtTokenService();
    authRepository = new AuthRepository();
    authRepository.clearMemoryStore();
    authService = new AuthService(authRepository, jwtTokenService);
  });

  it('FR-AUTH-001 & FR-AUTH-007: Signup creates user, character, and returns RS256 tokens', async () => {
    const response = await authService.signup({
      email: 'hunter@arise.io',
      password: 'SecurePassword123!',
      difficultyMode: 'casual',
      chronotype: 'early_bird',
    });

    expect(response.user.id).toBeDefined();
    expect(response.user.email).toBe('hunter@arise.io');
    expect(response.character).toBeDefined();
    expect(response.character?.level).toBe(1);
    expect(response.character?.totalXp).toBe(0);
    expect(response.character?.currentMana).toBe(100);
    expect(response.character?.rank).toBe('E');
    expect(response.tokens.accessToken).toBeDefined();
    expect(response.tokens.refreshToken).toBeDefined();

    // Verify RS256 JWT payload contains ONLY userId and tokenVersion (§6.1 / §13.1)
    const payload = jwtTokenService.verifyAccessToken(response.tokens.accessToken);
    expect(payload.userId).toBe(response.user.id);
    expect(payload.tokenVersion).toBe(1);
    expect((payload as unknown as Record<string, unknown>).role).toBeUndefined();
    expect((payload as unknown as Record<string, unknown>).plan).toBeUndefined();
  });

  it('FR-AUTH-002: Login validates credentials via Argon2id', async () => {
    await authService.signup({
      email: 'sung@arise.io',
      password: 'ShadowMonarch99!',
      difficultyMode: 'hardcore',
      chronotype: 'night_owl',
    });

    const loginRes = await authService.login({
      email: 'sung@arise.io',
      password: 'ShadowMonarch99!',
    });

    expect(loginRes.user.email).toBe('sung@arise.io');
    expect(loginRes.tokens.accessToken).toBeDefined();

    // Rejection on bad password
    await expect(
      authService.login({
        email: 'sung@arise.io',
        password: 'WrongPassword!',
      }),
    ).rejects.toThrow();
  });

  it('FR-AUTH-003: Single-use refresh token rotation succeeds', async () => {
    const signupRes = await authService.signup({
      email: 'jinwoo@arise.io',
      password: 'Password123!',
      difficultyMode: 'casual',
      chronotype: 'early_bird',
    });

    const initialRefreshToken = signupRes.tokens.refreshToken;

    // First rotation succeeds
    const rotatedTokens = await authService.refresh({
      refreshToken: initialRefreshToken,
    });

    expect(rotatedTokens.accessToken).toBeDefined();
    expect(rotatedTokens.refreshToken).toBeDefined();
    expect(rotatedTokens.refreshToken).not.toBe(initialRefreshToken);
  });

  /**
   * §19 Acceptance Criterion for FR-AUTH-004 (Hard AC Requirement):
   * Given a refresh token that has already been rotated (used once),
   * When it is submitted again to POST /auth/refresh,
   * Then the request is rejected 401, AND ALL ACTIVE SESSIONS for that user are revoked.
   */
  it('AC-AUTH-004: Refresh token reuse detection triggers 401 and revokes ALL user sessions', async () => {
    // 1. User registers and obtains Token Pair 1
    const signupRes = await authService.signup({
      email: 'victim@arise.io',
      password: 'Password123!',
      difficultyMode: 'casual',
      chronotype: 'early_bird',
    });

    const token1 = signupRes.tokens.refreshToken;

    // 2. Legitimate client rotates Token 1 -> receives Token 2
    const tokenPair2 = await authService.refresh({
      refreshToken: token1,
    });
    const token2 = tokenPair2.refreshToken;
    expect(token2).not.toBe(token1);

    // 3. Attacker (or intercepted client) attempts to reuse the already-rotated Token 1
    await expect(
      authService.refresh({
        refreshToken: token1,
      }),
    ).rejects.toThrow(/Refresh token reuse detected/i);

    // 4. Assert that ALL active sessions for that user were revoked:
    // Even Token 2 (which was previously valid) must now be rejected
    await expect(
      authService.refresh({
        refreshToken: token2,
      }),
    ).rejects.toThrow();
  });

  it('FR-AUTH-009: Account soft delete revokes sessions and prevents login', async () => {
    const signupRes = await authService.signup({
      email: 'delete_me@arise.io',
      password: 'Password123!',
      difficultyMode: 'casual',
      chronotype: 'early_bird',
    });

    await authService.deleteAccount(signupRes.user.id);

    // Login must now be rejected
    await expect(
      authService.login({
        email: 'delete_me@arise.io',
        password: 'Password123!',
      }),
    ).rejects.toThrow();
  });
});
