import { Request, Response, NextFunction } from 'express';
import { GateService } from '../service/gates.service';

export class GateController {
  constructor(private readonly service: GateService) {}

  getById = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const data = await this.service.getById(req.params.id || '');
      res.json({ data });
    } catch (err) {
      next(err);
    }
  };
}
