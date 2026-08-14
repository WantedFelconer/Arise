import { Request, Response, NextFunction } from 'express';
import { BossService } from '../service/bosses.service';

export class BossController {
  constructor(private readonly service: BossService) {}

  getById = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const data = await this.service.getById(req.params.id || '');
      res.json({ data });
    } catch (err) {
      next(err);
    }
  };
}
