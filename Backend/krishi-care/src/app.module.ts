// src/app.module.ts
import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
// Removed: import { AppService } from './app.service'; // Delete this line
import { UsersModule } from './users/users.module';
import { PrismaModule } from './prisma/prisma.module';
import { FilesModule } from './files/files.module';

@Module({
  imports: [
    PrismaModule,
    UsersModule,
    FilesModule,
  ],
  controllers: [AppController],
  providers: [], // Removed AppService from here
})
export class AppModule {}