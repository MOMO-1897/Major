import { Module } from '@nestjs/common';
import { FilesService } from './files.service';
import { FilesController } from './files.controller';

@Module({
  providers: [FilesService],
  controllers: [FilesController],
  exports: [FilesService], // Export if other modules might need FilesService
})
export class FilesModule {}