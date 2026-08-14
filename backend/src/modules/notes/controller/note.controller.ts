import {
  Controller,
  Get,
  Post,
  Patch,
  Delete,
  Body,
  Param,
  Query,
  HttpCode,
  HttpStatus,
  Inject,
} from '@nestjs/common';
import { CurrentUser } from '../../../core/decorators/current-user.decorator';
import { ZodValidationPipe } from '../../../core/pipes/zod-validation.pipe';
import { NoteService } from '../service/note.service';
import {
  createNoteFolderSchema,
  createNoteSchema,
  noteFilterSchema,
  updateNoteSchema,
} from '../validation/note.schema';
import {
  CreateNoteDto,
  CreateNoteFolderDto,
  NoteFilterDto,
  UpdateNoteDto,
} from '../dto/note.dto';

@Controller('notes')
export class NoteController {
  constructor(@Inject(NoteService) private readonly noteService: NoteService) {}

  // Folder endpoints
  @Get('folders')
  async listFolders(@CurrentUser('userId') userId: string) {
    const data = await this.noteService.listFolders(userId);
    return { data };
  }

  @Post('folders')
  async createFolder(
    @CurrentUser('userId') userId: string,
    @Body(new ZodValidationPipe(createNoteFolderSchema)) dto: CreateNoteFolderDto,
  ) {
    const data = await this.noteService.createFolder(userId, dto);
    return { data };
  }

  @Delete('folders/:id')
  @HttpCode(HttpStatus.NO_CONTENT)
  async deleteFolder(
    @CurrentUser('userId') userId: string,
    @Param('id') id: string,
  ) {
    await this.noteService.deleteFolder(userId, id);
  }

  // Note endpoints
  @Get()
  async listNotes(
    @CurrentUser('userId') userId: string,
    @Query(new ZodValidationPipe(noteFilterSchema)) filter: NoteFilterDto,
  ) {
    const data = await this.noteService.listNotes(userId, filter);
    return { data };
  }

  @Post()
  async createNote(
    @CurrentUser('userId') userId: string,
    @Body(new ZodValidationPipe(createNoteSchema)) dto: CreateNoteDto,
  ) {
    const data = await this.noteService.createNote(userId, dto);
    return { data };
  }

  @Get(':id')
  async getNote(
    @CurrentUser('userId') userId: string,
    @Param('id') id: string,
  ) {
    const data = await this.noteService.getNote(userId, id);
    return { data };
  }

  @Patch(':id')
  async updateNote(
    @CurrentUser('userId') userId: string,
    @Param('id') id: string,
    @Body(new ZodValidationPipe(updateNoteSchema)) dto: UpdateNoteDto,
  ) {
    const data = await this.noteService.updateNote(userId, id, dto);
    return { data };
  }

  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  async deleteNote(
    @CurrentUser('userId') userId: string,
    @Param('id') id: string,
  ) {
    await this.noteService.deleteNote(userId, id);
  }
}
