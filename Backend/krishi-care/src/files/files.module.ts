// src/files/files.module.ts
import { Module } from '@nestjs/common';
import { FilesService } from './files.service';

@Module({
  providers: [FilesService],
  exports: [FilesService], // Export FilesService so it can be used in other modules (e.g., UsersModule)
})
export class FilesModule {}