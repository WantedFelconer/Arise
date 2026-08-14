import { MiddlewareConsumer, Module, NestModule } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { APP_FILTER, APP_GUARD, APP_INTERCEPTOR } from '@nestjs/core';
import { HealthController } from './health.controller';
import { PrismaModule } from './db/prisma/prisma.module';
import { JwtAuthModule } from './core/auth/jwt-auth.module';
import { IdempotencyModule } from './core/idempotency/idempotency.module';
import { JwtAuthGuard } from './core/guards/jwt-auth.guard';
import { RateLimitGuard } from './core/guards/rate-limit.guard';
import { LoggingInterceptor } from './core/interceptors/logging.interceptor';
import { GlobalExceptionFilter } from './core/filters/global-exception.filter';
import { RequestIdMiddleware } from './core/middleware/request-id.middleware';
import { validateEnv } from './config/env.validation';
import { AuthModule } from './modules/auth/auth.module';
import { CharacterModule } from './modules/character/character.module';
import { SyncModule } from './modules/sync/sync.module';
import { QuestsModule } from './modules/quests/quests.module';
import { BossesModule } from './modules/bosses/bosses.module';
import { DungeonsModule } from './modules/dungeons/dungeons.module';
import { GatesModule } from './modules/gates/gates.module';
import { AchievementsModule } from './modules/achievements/achievements.module';
import { RewardCascadeModule } from './core/reward-cascade.module';
import { AiModule } from './modules/ai/ai.module';
import { NotificationsModule } from './modules/notifications/notifications.module';
import { StatisticsModule } from './modules/statistics/statistics.module';
import { ScreenTimeModule } from './modules/screen-time/screen-time.module';
import { RemindersModule } from './modules/reminders/reminders.module';
import { NotesModule } from './modules/notes/notes.module';
import { FitnessModule } from './modules/fitness/fitness.module';
import { MusicModule } from './modules/music/music.module';
import { AnalyticsModule } from './modules/analytics/analytics.module';
import { SettingsModule } from './modules/settings/settings.module';
import { AdminModule } from './modules/admin/admin.module';
import { ReminderDispatchJob } from './jobs/reminder-dispatch.job';
import { AccountPurgeJob } from './jobs/account-purge.job';
import { AnalyticsRollupJob } from './jobs/analytics-rollup.job';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      validate: validateEnv,
    }),
    PrismaModule,
    JwtAuthModule,
    IdempotencyModule,
    AuthModule,
    CharacterModule,
    SyncModule,
    QuestsModule,
    BossesModule,
    DungeonsModule,
    GatesModule,
    AchievementsModule,
    RewardCascadeModule,
    AiModule,
    NotificationsModule,
    StatisticsModule,
    ScreenTimeModule,
    RemindersModule,
    NotesModule,
    FitnessModule,
    MusicModule,
    AnalyticsModule,
    SettingsModule,
    AdminModule,
  ],
  controllers: [HealthController],
  providers: [
    ReminderDispatchJob,
    AccountPurgeJob,
    AnalyticsRollupJob,
    {
      provide: APP_FILTER,
      useClass: GlobalExceptionFilter,
    },
    {
      provide: APP_GUARD,
      useClass: JwtAuthGuard,
    },
    {
      provide: APP_GUARD,
      useClass: RateLimitGuard,
    },
    {
      provide: APP_INTERCEPTOR,
      useClass: LoggingInterceptor,
    },
  ],
})
export class AppModule implements NestModule {
  configure(consumer: MiddlewareConsumer) {
    consumer.apply(RequestIdMiddleware).forRoutes('*');
  }
}
