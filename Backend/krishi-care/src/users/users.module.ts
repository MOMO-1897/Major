// src/users/users.module.ts
import { Module } from '@nestjs/common';
import { UsersService } from './users.service';
import { UsersController } from './users.controller';
import { PrismaModule } from '../prisma/prisma.module'; // Corrected import path
import { FilesModule } from '../files/files.module';   // Corrected import path

@Module({
  imports: [PrismaModule, FilesModule], // Import necessary modules
  controllers: [UsersController],
  providers: [UsersService],
  exports: [UsersService],
})
export class UsersModule {}