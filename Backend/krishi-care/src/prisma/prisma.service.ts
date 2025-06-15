// src/prisma/prisma.service.ts
import { Injectable, OnModuleInit, OnModuleDestroy } from '@nestjs/common';
import { PrismaClient, RoleType } from '@prisma/client'; // Import RoleType

@Injectable()
export class PrismaService extends PrismaClient implements OnModuleInit, OnModuleDestroy {
  async onModuleInit() {
    await this.$connect();
    console.log('Prisma connected to database.');

    // --- Start Programmatic Seeding (Use with Caution in Production!) ---
    try {
      console.log('Ensuring roles exist...');
      await this.role.upsert({
        where: { name: RoleType.FARMER },
        update: {},
        create: { name: RoleType.FARMER },
      });
      await this.role.upsert({
        where: { name: RoleType.SPECIALIST },
        update: {},
        create: { name: RoleType.SPECIALIST },
      });
      console.log('Roles ensured successfully on startup.');
    } catch (error) {
      console.error('Error during automatic role seeding on startup:', error);
      // Depending on your error handling strategy, you might want to
      // throw the error or gracefully handle it.
    }
    // --- End Programmatic Seeding ---
  }

  async onModuleDestroy() {
    await this.$disconnect();
    console.log('Prisma disconnected from database.');
  }
}