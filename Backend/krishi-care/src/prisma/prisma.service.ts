// src/prisma/prisma.service.ts
import { Injectable, OnModuleInit, OnModuleDestroy } from '@nestjs/common';
import { PrismaClient } from '@prisma/client';

@Injectable()
export class PrismaService extends PrismaClient implements OnModuleInit, OnModuleDestroy {
  async onModuleInit() {
    // Connect to the database when the module initializes
    await this.$connect();
    console.log("database connected")
  }

  async onModuleDestroy() {
    // Disconnect from the database when the module is destroyed
    await this.$disconnect();
  }

  // The 'enableShutdownHooks' method and the '$on("beforeExit")' listener
  // have been removed because they are no longer supported or needed in this form.
  // NestJS's OnModuleDestroy handles graceful disconnection during shutdown.
}