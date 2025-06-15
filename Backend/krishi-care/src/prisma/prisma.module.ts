// src/prisma/prisma.module.ts
import { Module, Global } from '@nestjs/common';
import { PrismaService } from './prisma.service';

@Global() // Make PrismaService available globally without re-importing in every module
@Module({
  providers: [PrismaService],
  exports: [PrismaService], // Export PrismaService so other modules can use it
})
export class PrismaModule {}