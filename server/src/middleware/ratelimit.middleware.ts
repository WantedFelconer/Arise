export class RateLimiter {
  private requests: Map<string, number[]> = new Map();

  /**
   * Simple sliding window rate limiter.
   * @param limit Maximum requests per window
   * @param windowMs Window duration in milliseconds
   */
  public limit(key: string, limit = 100, windowMs = 60000): { allowed: boolean; remaining: number } {
    const now = Date.now();
    const timestamps = this.requests.get(key) || [];

    // Filter timestamps within window
    const validTimestamps = timestamps.filter((t) => t > now - windowMs);

    if (validTimestamps.length >= limit) {
      return { allowed: false, remaining: 0 };
    }

    validTimestamps.push(now);
    this.requests.set(key, validTimestamps);

    return {
      allowed: true,
      remaining: limit - validTimestamps.length,
    };
  }
}

export const globalRateLimiter = new RateLimiter();

export function rateLimitMiddleware(limit = 100, windowMs = 60000) {
  return (req: any, res: any, next: () => void) => {
    const clientIp = req.headers?.['x-forwarded-for'] || req.socket?.remoteAddress || '127.0.0.1';
    const result = globalRateLimiter.limit(String(clientIp), limit, windowMs);

    if (res && res.setHeader) {
      res.setHeader('X-RateLimit-Limit', limit);
      res.setHeader('X-RateLimit-Remaining', result.remaining);
    }

    if (!result.allowed) {
      if (res && res.status) {
        return res.status(429).json({ error: 'Too many requests. Rate limit exceeded.' });
      }
      throw new Error('429: Rate limit exceeded');
    }

    if (next) next();
  };
}
