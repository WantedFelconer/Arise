import {
  CanActivate,
  ExecutionContext,
  Injectable,
  UnauthorizedException,
  Inject,
  Optional,
} from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { IS_PUBLIC_KEY } from '../decorators/public.decorator';
import { JwtTokenService } from '../auth/jwt-token.service';

@Injectable()
export class JwtAuthGuard implements CanActivate {
  private reflectorInstance: Reflector;
  private tokenServiceInstance: JwtTokenService;

  constructor(
    @Optional() @Inject(Reflector) reflector?: Reflector,
    @Optional() @Inject(JwtTokenService) jwtTokenService?: JwtTokenService,
  ) {
    this.reflectorInstance = reflector || new Reflector();
    this.tokenServiceInstance = jwtTokenService || new JwtTokenService();
  }

  canActivate(context: ExecutionContext): boolean {
    const isPublic = this.reflectorInstance.getAllAndOverride<boolean>(IS_PUBLIC_KEY, [
      context.getHandler(),
      context.getClass(),
    ]);

    if (isPublic) {
      return true;
    }

    const request = context.switchToHttp().getRequest();
    const authHeader = request.headers['authorization'];

    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      throw new UnauthorizedException({
        code: 'UNAUTHORIZED',
        message: 'Missing or invalid Authorization header',
      });
    }

    const token = authHeader.split(' ')[1];

    try {
      const payload = this.tokenServiceInstance.verifyAccessToken(token);
      request.auth = {
        userId: payload.userId,
        tokenVersion: payload.tokenVersion,
      };
      return true;
    } catch {
      throw new UnauthorizedException({
        code: 'UNAUTHORIZED',
        message: 'Invalid or expired access token',
      });
    }
  }
}
