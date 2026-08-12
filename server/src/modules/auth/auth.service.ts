import crypto from 'crypto';

export interface TokenPayload {
  userId: string;
  email: string;
  difficultyMode: 'casual' | 'hardcore';
  iat?: number;
  exp?: number;
}

export interface AuthTokens {
  accessToken: string;
  refreshToken: string;
  expiresInSeconds: number;
}

export class AuthService {
  private static JWT_SECRET = process.env.JWT_SECRET || 'arise_super_secret_jwt_key_2026';
  private static ACCESS_TOKEN_EXPIRY = 900; // 15 minutes
  private static REFRESH_TOKEN_EXPIRY = 2592000; // 30 days

  /**
   * Hash password securely using Node crypto SHA-256 with salt.
   */
  public static hashPassword(password: string, salt = 'arise_static_salt'): string {
    return crypto.pbkdf2Sync(password, salt, 10000, 64, 'sha512').toString('hex');
  }

  /**
   * Verify password against stored hash.
   */
  public static verifyPassword(password: string, storedHash: string, salt = 'arise_static_salt'): boolean {
    const hash = this.hashPassword(password, salt);
    return crypto.timingSafeEqual(Buffer.from(hash), Buffer.from(storedHash));
  }

  /**
   * Generate signed JWT access token and refresh token.
   */
  public static generateTokens(userId: string, email: string, difficultyMode: 'casual' | 'hardcore' = 'casual'): AuthTokens {
    const header = Buffer.from(JSON.stringify({ alg: 'HS256', typ: 'JWT' })).toString('base64url');

    const now = Math.floor(Date.now() / 1000);
    const payloadContent: TokenPayload = {
      userId,
      email,
      difficultyMode,
      iat: now,
      exp: now + this.ACCESS_TOKEN_EXPIRY,
    };

    const payload = Buffer.from(JSON.stringify(payloadContent)).toString('base64url');
    const signature = crypto
      .createHmac('sha256', this.JWT_SECRET)
      .update(`${header}.${payload}`)
      .digest('base64url');

    const accessToken = `${header}.${payload}.${signature}`;
    const refreshToken = crypto.randomBytes(32).toString('hex');

    return {
      accessToken,
      refreshToken,
      expiresInSeconds: this.ACCESS_TOKEN_EXPIRY,
    };
  }

  /**
   * Decode and verify a JWT access token.
   */
  public static verifyAccessToken(token: string): TokenPayload {
    const parts = token.split('.');
    if (parts.length !== 3) {
      throw new Error('Invalid token structure');
    }

    const [header, payload, signature] = parts;
    const expectedSignature = crypto
      .createHmac('sha256', this.JWT_SECRET)
      .update(`${header}.${payload}`)
      .digest('base64url');

    if (!crypto.timingSafeEqual(Buffer.from(signature), Buffer.from(expectedSignature))) {
      throw new Error('Invalid token signature');
    }

    const decodedPayload: TokenPayload = JSON.parse(Buffer.from(payload, 'base64url').toString('utf8'));
    const now = Math.floor(Date.now() / 1000);

    if (decodedPayload.exp && decodedPayload.exp < now) {
      throw new Error('Access token expired');
    }

    return decodedPayload;
  }
}
