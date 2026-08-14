import { Controller, Get, Inject } from '@nestjs/common';
import { CurrentUser } from '../../../core/decorators/current-user.decorator';
import { AdminService } from '../service/admin.service';

@Controller('admin')
export class AdminController {
  constructor(@Inject(AdminService) private readonly adminService: AdminService) {}

  @Get('config')
  getBalancingConfig() {
    const data = this.adminService.getBalancingConfig();
    return { data };
  }

  @Get('feature-flags')
  getFeatureFlags(@CurrentUser('userId') userId: string) {
    const data = this.adminService.getFeatureFlags(userId);
    return { data };
  }
}
