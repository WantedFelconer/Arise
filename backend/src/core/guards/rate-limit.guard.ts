import {
  CanActivate,
  ExecutionContext,
  Injectable,
  HttpException,
  HttpStatus,
  SetMetadata,
  Inject,
  Optional,
} from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { ConfigService } from '@nestjs/config';

export const RATE_LIMIT_KEY = 'rate_limit_options';
export interface RateLimitOptions {
  limit: number;
  ttlSeconds: number;
}

export const RateLimit = (limit: number, ttlSeconds: number) =>
  SetMetadata(RATE_LIMIT_KEY, { limit, ttlSeconds });

@Injectable()
export class RateLimitGuard implements CanActivate {
  private static inMemoryStore = new Map<string, { count: number; expiresAt: number }>();
  private reflectorInstance: Reflector;
  private configServiceInstance?: ConfigService;

  constructor(
    @Optional() @Inject(Reflector) reflector?: Reflector,
    @Optional() @Inject(ConfigService) configService?: ConfigService,
  ) {
    this.reflectorInstance = reflector || new Reflector();
    this.configServiceInstance = configService;
  }

  canActivate(context: ExecutionContext): boolean {
    const customOptions = this.reflectorInstance.getAllAndOverride<RateLimitOptions>(
      RATE_LIMIT_KEY,
      [context.getHandler(), context.getClass()],
    );

    const defaultLimit = this.configServiceInstance?.get<number>('RATE_LIMIT_LIMIT') || 10;
    const defaultTtl = this.configServiceInstance?.get<number>('RATE_LIMIT_TTL') || 900; // 15 mins

    const limit = customOptions?.limit ?? defaultLimit;
    const ttlSeconds = customOptions?.ttlSeconds ?? defaultTtl;

    const request = context.switchToHttp().getRequest();
    const forwarded = request.headers['x-forwarded-for'];
    const ip =
      (Array.isArray(forwarded) ? forwarded[0] : forwarded) ||
      request.ip ||
      request.socket?.remoteAddress ||
      'unknown-ip';
    const email = request.body?.email ? `:${request.body.email}` : '';
    const routeKey = `${request.method}:${request.path}:${ip}${email}`;

    const now = Date.now();
    const record = RateLimitGuard.inMemoryStore.get(routeKey);

    if (!record || record.expiresAt < now) {
      RateLimitGuard.inMemoryStore.set(routeKey, {
        count: 1,
        expiresAt: now + ttlSeconds * 1000,
      });
      return true;
    }

    if (record.count >= limit) {
      throw new HttpException(
        {
          error: {
            code: 'TOO_MANY_REQUESTS',
            message: 'Too many requests. Please try again later.',
          },
        },
        HttpStatus.TOO_MANY_REQUESTS,
      );
    }

    record.count += 1;
    return true;
  }
}
