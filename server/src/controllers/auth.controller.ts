import { Envelope } from '../api/envelope.ts';
import { AuthService } from '../modules/auth/auth.service.ts';

export class AuthController {
  /**
   * POST /api/v1/auth/signup
   */
  public static async signup(req: any, res: any) {
    try {
      const { email, password, difficultyMode } = req.body || {};
      if (!email || !password) {
        return res.status(400).json(Envelope.error('Email and password are required'));
      }

      const mockUserId = `user_${Math.random().toString(36).substring(2, 9)}`;
      const tokens = AuthService.generateTokens(mockUserId, email, difficultyMode || 'casual');

      return res.status(201).json(
        Envelope.success({
          userId: mockUserId,
          email,
          difficultyMode: difficultyMode || 'casual',
          ...tokens,
        })
      );
    } catch (err: any) {
      return res.status(500).json(Envelope.error(err.message || 'Signup failed'));
    }
  }

  /**
   * POST /api/v1/auth/login
   */
  public static async login(req: any, res: any) {
    try {
      const { email, password } = req.body || {};
      if (!email || !password) {
        return res.status(400).json(Envelope.error('Email and password are required'));
      }

      const mockUserId = `user_${Math.random().toString(36).substring(2, 9)}`;
      const tokens = AuthService.generateTokens(mockUserId, email, 'casual');

      return res.status(200).json(
        Envelope.success({
          userId: mockUserId,
          email,
          ...tokens,
        })
      );
    } catch (err: any) {
      return res.status(500).json(Envelope.error(err.message || 'Login failed'));
    }
  }

  /**
   * POST /api/v1/auth/refresh
   */
  public static async refresh(req: any, res: any) {
    try {
      const { refreshToken } = req.body || {};
      if (!refreshToken) {
        return res.status(400).json(Envelope.error('Refresh token is required'));
      }

      const tokens = AuthService.generateTokens('user_refreshed', 'user@arise.app', 'casual');
      return res.status(200).json(Envelope.success(tokens));
    } catch (err: any) {
      return res.status(401).json(Envelope.error('Invalid refresh token'));
    }
  }
}
