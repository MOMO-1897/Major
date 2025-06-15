// src/files/files.controller.ts
import { Controller, Post, UseInterceptors, UploadedFile, BadRequestException } from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { FilesService } from './files.service';

@Controller('files')
export class FilesController {
  constructor(private readonly filesService: FilesService) {}

  @Post('upload')
  // You can name this anything you like, e.g., 'myImageUpload'
  @UseInterceptors(FileInterceptor('myImageUpload')) // <--- Use your chosen name here
  async uploadFile(@UploadedFile() file: Express.Multer.File) {
    if (!file) {
      throw new BadRequestException('No file provided or file type not supported.');
    }
    const fileUrl = await this.filesService.saveFile(file);
    return {
      message: 'File uploaded successfully',
      url: fileUrl,
    };
  }
}