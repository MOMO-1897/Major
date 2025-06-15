// src/files/files.service.ts
import { Injectable, BadRequestException } from '@nestjs/common';
import { existsSync, mkdirSync, writeFileSync } from 'fs';
import { join, extname } from 'path'; // Import extname
import { v4 as uuidv4 } from 'uuid';

@Injectable()
export class FilesService {
  private readonly uploadPath = join(__dirname, '..', '..', 'uploads'); // Path to the 'uploads' folder

  constructor() {
    if (!existsSync(this.uploadPath)) {
      mkdirSync(this.uploadPath, { recursive: true });
    }
  }

  async saveFile(file: Express.Multer.File): Promise<string> {
    if (!file || !file.buffer) { // Check for buffer as well, since we're using memory storage in controller
      throw new BadRequestException('No file buffer provided for saving.');
    }

    const fileExtension = extname(file.originalname); // Use extname for robustness
    const uniqueFilename = `${uuidv4()}${fileExtension}`;
    const filePath = join(this.uploadPath, uniqueFilename);

    try {
      writeFileSync(filePath, file.buffer);
      return `/uploads/${uniqueFilename}`; // Return the public URL path
    } catch (error) {
      console.error('Error saving file:', error);
      throw new BadRequestException('Could not save file.');
    }
  }
}