import { Request, Response, NextFunction } from 'express';
import { NoteService } from '../service/notes.service';

export class NoteController {
  constructor(private readonly service: NoteService) {}

  getById = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const data = await this.service.getById(req.params.id || '');
      res.json({ data });
    } catch (err) {
      next(err);
    }
  };
}
