import { Request, Response, NextFunction } from 'express';
import { NotificationService } from '../service/notifications.service';

export class NotificationController {
  constructor(private readonly service: NotificationService) {}

  getById = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const data = await this.service.getById(req.params.id || '');
      res.json({ data });
    } catch (err) {
      next(err);
    }
  };
}
