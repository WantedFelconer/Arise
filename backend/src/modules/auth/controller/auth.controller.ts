import {
  Controller,
  Post,
  Delete,
  Body,
  UsePipes,
  HttpCode,
  HttpStatus,
  Inject,
} from '@nestjs/common';
import { AuthService } from '../service/auth.service';
import { Public } from '../../../core/decorators/public.decorator';
import { CurrentUser } from '../../../core/decorators/current-user.decorator';
import { ZodValidationPipe } from '../../../core/pipes/zod-validation.pipe';
import {
  signupSchema,
  loginSchema,
  refreshSchema,
  logoutSchema,
  passwordResetRequestSchema,
  passwordResetConfirmSchema,
} from '../validation/auth.schema';
import {
  SignupDto,
  LoginDto,
  RefreshDto,
  LogoutDto,
  PasswordResetRequestDto,
  PasswordResetConfirmDto,
} from '../dto/auth.dto';

@Controller('auth')
export class AuthController {
  constructor(@Inject(AuthService) private authService: AuthService) {}

  @Public()
  @Post('signup')
  @UsePipes(new ZodValidationPipe(signupSchema))
  @HttpCode(HttpStatus.CREATED)
  async signup(@Body() dto: SignupDto) {
    const data = await this.authService.signup(dto);
    return { data };
  }

  @Public()
  @Post('login')
  @UsePipes(new ZodValidationPipe(loginSchema))
  @HttpCode(HttpStatus.OK)
  async login(@Body() dto: LoginDto) {
    const data = await this.authService.login(dto);
    return { data };
  }

  @Public()
  @Post('refresh')
  @UsePipes(new ZodValidationPipe(refreshSchema))
  @HttpCode(HttpStatus.OK)
  async refresh(@Body() dto: RefreshDto) {
    const data = await this.authService.refresh(dto);
    return { data };
  }

  @Post('logout')
  @UsePipes(new ZodValidationPipe(logoutSchema))
  @HttpCode(HttpStatus.OK)
  async logout(@CurrentUser('userId') userId: string, @Body() dto: LogoutDto) {
    return this.authService.logout(userId, dto);
  }

  @Public()
  @Post('password-reset/request')
  @UsePipes(new ZodValidationPipe(passwordResetRequestSchema))
  @HttpCode(HttpStatus.OK)
  async requestPasswordReset(@Body() dto: PasswordResetRequestDto) {
    return this.authService.requestPasswordReset(dto);
  }

  @Public()
  @Post('password-reset/confirm')
  @UsePipes(new ZodValidationPipe(passwordResetConfirmSchema))
  @HttpCode(HttpStatus.OK)
  async confirmPasswordReset(@Body() dto: PasswordResetConfirmDto) {
    return this.authService.confirmPasswordReset(dto);
  }

  @Delete('account')
  @HttpCode(HttpStatus.OK)
  async deleteAccount(@CurrentUser('userId') userId: string) {
    return this.authService.deleteAccount(userId);
  }
}
