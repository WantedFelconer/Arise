import { createParamDecorator, ExecutionContext } from '@nestjs/common';

export interface AuthContext {
  userId: string;
  tokenVersion?: number;
}

export const CurrentUser = createParamDecorator(
  (data: keyof AuthContext | undefined, ctx: ExecutionContext) => {
    const request = ctx.switchToHttp().getRequest();
    const auth: AuthContext = request.auth || request.user;
    if (!auth) return null;
    return data ? auth[data] : auth;
  },
);
