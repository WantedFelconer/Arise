import { Request, Response, NextFunction } from 'express';
import { IntegrationService } from '../service/integrations.service';

export class IntegrationController {
  constructor(private readonly service: IntegrationService) {}

  getById = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const data = await this.service.getById(req.params.id || '');
      res.json({ data });
    } catch (err) {
      next(err);
    }
  };
}
