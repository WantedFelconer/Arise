import { CallHandler, ExecutionContext, Injectable, NestInterceptor } from '@nestjs/common';
import { Observable } from 'rxjs';
import { tap } from 'rxjs/operators';
import { appLogger } from '../logger/winston.logger';

@Injectable()
export class LoggingInterceptor implements NestInterceptor {
  intercept(context: ExecutionContext, next: CallHandler): Observable<unknown> {
    const req = context.switchToHttp().getRequest();
    const { method, url, ip } = req;
    const requestId = req.id || req.headers['x-request-id'] || 'no-id';
    const userId = req.auth?.userId || 'anonymous';
    const start = Date.now();

    return next.handle().pipe(
      tap({
        next: () => {
          const res = context.switchToHttp().getResponse();
          const duration = Date.now() - start;
          appLogger.log(`${method} ${url} ${res.statusCode} +${duration}ms`, {
            requestId,
            userId,
            method,
            url,
            statusCode: res.statusCode,
            durationMs: duration,
            ip,
          });
        },
        error: (err: unknown) => {
          const duration = Date.now() - start;
          const errObj = err as Record<string, unknown>;
          const status = (errObj?.status as number) || (errObj?.statusCode as number) || 500;
          appLogger.error(
            `${method} ${url} ${status} +${duration}ms - ${(errObj?.message as string) || 'Error'}`,
            undefined,
            {
              requestId,
              userId,
              method,
              url,
              statusCode: status,
              durationMs: duration,
              ip,
            },
          );
        },
      }),
    );
  }
}
