import 'reflect-metadata';
import { NestFactory } from '@nestjs/core';
import { ConfigService } from '@nestjs/config';
import helmet from 'helmet';
import { AppModule } from './app.module';
import { GlobalExceptionFilter } from './core/filters/global-exception.filter';
import { ZodValidationPipe } from './core/pipes/zod-validation.pipe';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  const configService = app.get(ConfigService);

  // Security headers via Helmet
  app.use(helmet());

  // CORS configuration
  const corsOrigin =
    configService.get<string>('CORS_ORIGIN') || 'http://localhost:8443,http://localhost:3000';
  const origins = corsOrigin.split(',').map((origin) => origin.trim());
  app.enableCors({
    origin: origins,
    credentials: true,
  });

  // Global routing prefix (/api/v1 per SRS §9)
  app.setGlobalPrefix('api/v1', {
    exclude: ['health'],
  });

  // Global filters and pipes
  app.useGlobalFilters(new GlobalExceptionFilter());
  app.useGlobalPipes(new ZodValidationPipe());

  const port = configService.get<number>('PORT') || 3000;
  await app.listen(port);
  console.log(`[ARISE Server] NestJS application running on http://localhost:${port}`);
}

bootstrap();
