import { Injectable, OnModuleInit, OnModuleDestroy } from '@nestjs/common';
import { PrismaClient } from '@prisma/client';

@Injectable()
export class PrismaService extends PrismaClient implements OnModuleInit, OnModuleDestroy {
  async onModuleInit() {
    // Only connect if not in disconnected test environments
    if (process.env.DATABASE_URL && process.env.NODE_ENV !== 'test') {
      try {
        await this.$connect();
      } catch {
        console.warn('[PrismaService] Database connection deferred/failed in current environment.');
      }
    }
  }

  async onModuleDestroy() {
    await this.$disconnect();
  }
}
