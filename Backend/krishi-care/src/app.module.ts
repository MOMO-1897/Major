// src/app.module.ts
import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { UsersModule } from './users/users.module';
import { PrismaModule } from './prisma/prisma.module';
import { FilesModule } from './files/files.module';
import { AuthModule } from './auth/auth.module';

@Module({
  imports: [
    PrismaModule,
    UsersModule,
    FilesModule,
    AuthModule, // Add AuthModule here
  ],
  controllers: [AppController],
  providers: [],
})
export class AppModule {}