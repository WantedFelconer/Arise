import { Request, Response, NextFunction } from 'express';
import { DungeonService } from '../service/dungeons.service';

export class DungeonController {
  constructor(private readonly service: DungeonService) {}

  getById = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const data = await this.service.getById(req.params.id || '');
      res.json({ data });
    } catch (err) {
      next(err);
    }
  };
}
