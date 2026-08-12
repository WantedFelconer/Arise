import crypto from 'crypto';

export function securityHeadersMiddleware(req: any, res: any, next: () => void) {
  const correlationId = req.headers?.['x-correlation-id'] || crypto.randomUUID();
  req.correlationId = correlationId;

  if (res && res.setHeader) {
    res.setHeader('X-Correlation-ID', correlationId);
    res.setHeader('X-Content-Type-Options', 'nosniff');
    res.setHeader('X-Frame-Options', 'DENY');
    res.setHeader('X-XSS-Protection', '1; mode=block');
    res.setHeader('Strict-Transport-Security', 'max-age=31536000; includeSubDomains');
  }

  if (next) next();
}
