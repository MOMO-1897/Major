// src/app.module.ts
import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { PrismaService } from './prisma/prisma.service'; // Import your PrismaService

@Module({
  imports: [
    // Your feature modules would go here, e.g., UsersModule
  ],
  controllers: [AppController],
  providers: [
    PrismaService, // Make PrismaService available throughout your application
  ],
})
export class AppModule {}