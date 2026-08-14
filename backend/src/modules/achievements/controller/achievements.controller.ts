import { Request, Response, NextFunction } from 'express';
import { AchievementService } from '../service/achievements.service';

export class AchievementController {
  constructor(private readonly service: AchievementService) {}

  getById = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const data = await this.service.getById(req.params.id || '');
      res.json({ data });
    } catch (err) {
      next(err);
    }
  };
}
