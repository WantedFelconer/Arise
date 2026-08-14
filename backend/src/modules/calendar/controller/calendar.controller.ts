import { Request, Response, NextFunction } from 'express';
import { CalendarService } from '../service/calendar.service';

export class CalendarController {
  constructor(private readonly service: CalendarService) {}

  getById = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const data = await this.service.getById(req.params.id || '');
      res.json({ data });
    } catch (err) {
      next(err);
    }
  };
}
