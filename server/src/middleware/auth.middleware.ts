import { AuthService } from '../modules/auth/auth.service.ts';
import type { TokenPayload } from '../modules/auth/auth.service.ts';

export interface AuthenticatedRequest {
  headers: Record<string, string | string[] | undefined>;
  user?: TokenPayload;
}

export function authMiddleware(req: AuthenticatedRequest, res: any, next: () => void) {
  const authHeader = req.headers['authorization'] || req.headers['Authorization'];
  const token = typeof authHeader === 'string' && authHeader.startsWith('Bearer ')
    ? authHeader.substring(7)
    : null;

  if (!token) {
    if (res && res.status) {
      return res.status(401).json({ error: 'Authentication required. Bearer token missing.' });
    }
    throw new Error('401: Authentication required');
  }

  try {
    const payload = AuthService.verifyAccessToken(token);
    req.user = payload;
    if (next) next();
  } catch (err: any) {
    if (res && res.status) {
      return res.status(401).json({ error: err.message || 'Invalid or expired token.' });
    }
    throw new Error(`401: ${err.message}`);
  }
}
