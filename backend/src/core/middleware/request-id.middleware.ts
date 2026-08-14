import { Injectable, NestMiddleware } from '@nestjs/common';
import { Request, Response, NextFunction } from 'express';
import { v4 as uuidv4 } from 'uuid';

export interface RequestWithId extends Request {
  id?: string;
  auth?: {
    userId: string;
    tokenVersion?: number;
  };
}

@Injectable()
export class RequestIdMiddleware implements NestMiddleware {
  use(req: RequestWithId, res: Response, next: NextFunction) {
    const headerReqId = req.headers['x-request-id'];
    const requestId = (typeof headerReqId === 'string' ? headerReqId : null) || uuidv4();
    req.id = requestId;
    res.setHeader('x-request-id', requestId);
    next();
  }
}
