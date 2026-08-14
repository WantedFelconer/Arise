import { Request, Response, NextFunction } from 'express';
import { ReminderService } from '../service/reminders.service';

export class ReminderController {
  constructor(private readonly service: ReminderService) {}

  getById = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const data = await this.service.getById(req.params.id || '');
      res.json({ data });
    } catch (err) {
      next(err);
    }
  };
}
