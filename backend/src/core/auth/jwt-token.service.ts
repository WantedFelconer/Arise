import crypto from 'crypto';
import jwt, { SignOptions } from 'jsonwebtoken';
import { Injectable, Optional } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';

export interface JwtPayload {
  userId: string;
  tokenVersion?: number;
  iat?: number;
  exp?: number;
}

@Injectable()
export class JwtTokenService {
  private privateKey: string;
  private publicKey: string;
  private accessExpiration: string;

  constructor(@Optional() private configService?: ConfigService) {
    const envPrivKey = this.configService?.get<string>('JWT_PRIVATE_KEY');
    const envPubKey = this.configService?.get<string>('JWT_PUBLIC_KEY');

    if (envPrivKey && envPubKey) {
      this.privateKey = envPrivKey.replace(/\\n/g, '\n');
      this.publicKey = envPubKey.replace(/\\n/g, '\n');
    } else {
      // Auto-generate 2048-bit RSA keypair for dev/test
      const { privateKey, publicKey } = crypto.generateKeyPairSync('rsa', {
        modulusLength: 2048,
        publicKeyEncoding: { type: 'spki', format: 'pem' },
        privateKeyEncoding: { type: 'pkcs8', format: 'pem' },
      });
      this.privateKey = privateKey;
      this.publicKey = publicKey;
    }

    this.accessExpiration = this.configService?.get<string>('JWT_ACCESS_EXPIRATION') || '15m';
  }

  generateAccessToken(userId: string, tokenVersion = 1): string {
    // Payload contains ONLY userId and tokenVersion per §6.1 / §13.1 (FR-AUTH-003)
    const payload: JwtPayload = { userId, tokenVersion };
    const signOptions: SignOptions = {
      algorithm: 'RS256',
      expiresIn: this.accessExpiration as SignOptions['expiresIn'],
    };
    return jwt.sign(payload, this.privateKey, signOptions);
  }

  generateRefreshToken(): string {
    return crypto.randomBytes(40).toString('hex');
  }

  hashRefreshToken(token: string): string {
    return crypto.createHash('sha256').update(token).digest('hex');
  }

  verifyAccessToken(token: string): JwtPayload {
    return jwt.verify(token, this.publicKey, { algorithms: ['RS256'] }) as JwtPayload;
  }
}
