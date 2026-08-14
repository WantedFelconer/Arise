import { LoggerService } from '@nestjs/common';
import winston from 'winston';

const sensitiveKeys = [
  'password',
  'passwordHash',
  'token',
  'refreshToken',
  'authorization',
  'secret',
  'jwt_private_key',
];

function sanitizeObject(obj: unknown): unknown {
  if (obj === null || obj === undefined) return obj;
  if (typeof obj !== 'object') return obj;
  if (Array.isArray(obj)) return obj.map(sanitizeObject);

  const sanitized: Record<string, unknown> = {};
  for (const [key, value] of Object.entries(obj as Record<string, unknown>)) {
    if (sensitiveKeys.some((k) => key.toLowerCase().includes(k.toLowerCase()))) {
      sanitized[key] = '[REDACTED]';
    } else if (typeof value === 'object' && value !== null) {
      sanitized[key] = sanitizeObject(value);
    } else {
      sanitized[key] = value;
    }
  }
  return sanitized;
}

export class AppLogger implements LoggerService {
  private logger: winston.Logger;

  constructor() {
    this.logger = winston.createLogger({
      level: process.env.NODE_ENV === 'production' ? 'info' : 'debug',
      format: winston.format.combine(winston.format.timestamp(), winston.format.json()),
      transports: [
        new winston.transports.Console({
          format: winston.format.combine(
            winston.format.timestamp(),
            process.env.NODE_ENV === 'production'
              ? winston.format.json()
              : winston.format.printf(({ level, message, timestamp, ...meta }) => {
                  const metaStr = Object.keys(meta).length
                    ? ` ${JSON.stringify(sanitizeObject(meta))}`
                    : '';
                  return `[${timestamp}] [${level.toUpperCase()}]: ${message}${metaStr}`;
                }),
          ),
        }),
      ],
    });
  }

  log(message: string, context?: unknown) {
    this.logger.info(message, sanitizeObject(typeof context === 'object' ? context : { context }));
  }

  error(message: string, trace?: string, context?: unknown) {
    this.logger.error(
      message,
      sanitizeObject({
        trace,
        ...(typeof context === 'object' && context !== null ? context : { context }),
      }),
    );
  }

  warn(message: string, context?: unknown) {
    this.logger.warn(message, sanitizeObject(typeof context === 'object' ? context : { context }));
  }

  debug(message: string, context?: unknown) {
    this.logger.debug(message, sanitizeObject(typeof context === 'object' ? context : { context }));
  }

  verbose(message: string, context?: unknown) {
    this.logger.verbose(
      message,
      sanitizeObject(typeof context === 'object' ? context : { context }),
    );
  }
}

export const appLogger = new AppLogger();
