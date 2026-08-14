import {
  Controller,
  Get,
  Post,
  Param,
  Body,
  UsePipes,
  Inject,
  Headers,
  Optional,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import { GateService } from '../service/gate.service';
import { IdempotencyService } from '../../../core/idempotency/idempotency.service';
import { CurrentUser } from '../../../core/decorators/current-user.decorator';
import { ZodValidationPipe } from '../../../core/pipes/zod-validation.pipe';
import {
  startGateSessionSchema,
  collapseGateSessionSchema,
  StartGateSessionInput,
  CollapseGateSessionInput,
} from '../validation/gate.schema';

@Controller('gates')
export class GateController {
  constructor(
    @Inject(GateService) private gateService: GateService,
    @Optional() @Inject(IdempotencyService) private idempotencyService?: IdempotencyService,
  ) {}

  @Get('stats')
  async getStats(@CurrentUser('userId') userId: string) {
    const data = await this.gateService.getStats(userId);
    return { data };
  }

  @Post('sessions')
  @UsePipes(new ZodValidationPipe(startGateSessionSchema))
  async start(
    @CurrentUser('userId') userId: string,
    @Body() body: StartGateSessionInput,
    @Headers('idempotency-key') idempotencyKey?: string,
  ) {
    if (idempotencyKey && this.idempotencyService) {
      const result = await this.idempotencyService.executeIdempotent(
        userId,
        idempotencyKey,
        'START_GATE_SESSION',
        async () => {
          const data = await this.gateService.startSession(userId, body);
          return { status: 201, body: data };
        },
      );
      return { data: result.body };
    }

    const data = await this.gateService.startSession(userId, body);
    return { data };
  }

  @Get('sessions/:id')
  async getSession(@CurrentUser('userId') userId: string, @Param('id') id: string) {
    const data = await this.gateService.getSession(userId, id);
    return { data };
  }

  @Post('sessions/:id/pause')
  @HttpCode(HttpStatus.OK)
  async pauseSession(
    @CurrentUser('userId') userId: string,
    @Param('id') id: string,
    @Headers('x-difficulty-mode') difficultyMode?: string,
  ) {
    const mode = difficultyMode || 'casual';
    const data = await this.gateService.pauseSession(userId, id, mode);
    return { data };
  }

  @Post('sessions/:id/resume')
  @HttpCode(HttpStatus.OK)
  async resumeSession(@CurrentUser('userId') userId: string, @Param('id') id: string) {
    const data = await this.gateService.resumeSession(userId, id);
    return { data };
  }

  @Post('sessions/:id/complete')
  @HttpCode(HttpStatus.OK)
  async completeSession(
    @CurrentUser('userId') userId: string,
    @Param('id') id: string,
    @Headers('idempotency-key') idempotencyKey?: string,
  ) {
    if (idempotencyKey && this.idempotencyService) {
      const result = await this.idempotencyService.executeIdempotent(
        userId,
        idempotencyKey,
        'COMPLETE_GATE_SESSION',
        async () => {
          const data = await this.gateService.completeSession(userId, id);
          return { status: 200, body: data };
        },
      );
      return { data: result.body };
    }

    const data = await this.gateService.completeSession(userId, id);
    return { data };
  }

  @Post(':id/complete')
  @HttpCode(HttpStatus.OK)
  async completeDirect(
    @CurrentUser('userId') userId: string,
    @Param('id') id: string,
    @Headers('idempotency-key') idempotencyKey?: string,
  ) {
    return this.completeSession(userId, id, idempotencyKey);
  }

  @Post('sessions/:id/collapse')
  @HttpCode(HttpStatus.OK)
  @UsePipes(new ZodValidationPipe(collapseGateSessionSchema))
  async collapseSession(
    @CurrentUser('userId') userId: string,
    @Param('id') id: string,
    @Body() body: CollapseGateSessionInput,
    @Headers('x-difficulty-mode') difficultyMode?: string,
    @Headers('idempotency-key') idempotencyKey?: string,
  ) {
    const mode = difficultyMode || 'casual';
    if (idempotencyKey && this.idempotencyService) {
      const result = await this.idempotencyService.executeIdempotent(
        userId,
        idempotencyKey,
        'COLLAPSE_GATE_SESSION',
        async () => {
          const data = await this.gateService.collapseSession(userId, id, mode, body);
          return { status: 200, body: data };
        },
      );
      return { data: result.body };
    }

    const data = await this.gateService.collapseSession(userId, id, mode, body);
    return { data };
  }

  @Post(':id/collapse')
  @HttpCode(HttpStatus.OK)
  @UsePipes(new ZodValidationPipe(collapseGateSessionSchema))
  async collapseDirect(
    @CurrentUser('userId') userId: string,
    @Param('id') id: string,
    @Body() body: CollapseGateSessionInput,
    @Headers('x-difficulty-mode') difficultyMode?: string,
    @Headers('idempotency-key') idempotencyKey?: string,
  ) {
    return this.collapseSession(userId, id, body, difficultyMode, idempotencyKey);
  }
}
