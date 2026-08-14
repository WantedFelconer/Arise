import { Controller, Get } from '@nestjs/common';
import { Public } from './core/decorators/public.decorator';

@Controller('health')
export class HealthController {
  @Public()
  @Get()
  getHealth() {
    return {
      status: 'ok',
      timestamp: new Date().toISOString(),
    };
  }
}
