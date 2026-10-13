import { Injectable, OnModuleInit, OnModuleDestroy } from '@nestjs/common';
import { PrismaClient } from '@prisma/client';

@Injectable()
export class PrismaService extends PrismaClient implements OnModuleInit, OnModuleDestroy {
  public isConnected = false;

  async onModuleInit() {
    // Only connect if not in disconnected test environments
    if (process.env.DATABASE_URL && process.env.NODE_ENV !== 'test') {
      try {
        await this.$connect();
        this.isConnected = true;
      } catch {
        this.isConnected = false;
        console.warn('[PrismaService] Database connection deferred/failed in current environment. In-memory storage active.');
      }
    }
  }

  async onModuleDestroy() {
    await this.$disconnect();
    this.isConnected = false;
  }
}
