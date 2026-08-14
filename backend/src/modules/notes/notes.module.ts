import { Module } from '@nestjs/common';
import { NoteController } from './controller/note.controller';
import { NoteService } from './service/note.service';
import { NoteRepository } from './repository/note.repository';

@Module({
  controllers: [NoteController],
  providers: [NoteService, NoteRepository],
  exports: [NoteService, NoteRepository],
})
export class NotesModule {}
