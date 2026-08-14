import { Request, Response, NextFunction } from 'express';
import { QuestService } from '../service/quests.service';

export class QuestController {
  constructor(private readonly service: QuestService) {}

  getById = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const data = await this.service.getById(req.params.id || '');
      res.json({ data });
    } catch (err) {
      next(err);
    }
  };
}
