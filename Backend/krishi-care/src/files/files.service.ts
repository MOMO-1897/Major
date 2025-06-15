// src/files/files.service.ts
import { Injectable, BadRequestException } from '@nestjs/common';
import { diskStorage } from 'multer';
import { existsSync, mkdirSync } from 'fs';
import { join } from 'path';
import { v4 as uuidv4 } from 'uuid';

@Injectable()
export class FilesService {
  // No longer a class property, nor using OnModuleInit for this path
  // private uploadsDir: string;

  constructor() {
    // Calculate the uploads directory synchronously when the service is instantiated
    const initialUploadsDir = join(process.cwd(), 'uploads');
    console.log(`[FilesService Constructor] Ensuring uploads directory exists at: ${initialUploadsDir}`);

    // Ensure the directory exists
    if (!existsSync(initialUploadsDir)) {
      mkdirSync(initialUploadsDir, { recursive: true });
      console.log(`[FilesService Constructor] Created uploads directory: ${initialUploadsDir}`);
    }
  }

  get multerStorage() {
    return diskStorage({
      destination: (req, file, cb) => {
        // Calculate the uploads directory *every time* a file needs to be stored
        // This guarantees the path is always a valid string at the point of use.
        const uploadsDestinationPath = join(process.cwd(), 'uploads');
        console.log('[Multer Destination] Calculated uploadsDestinationPath:', uploadsDestinationPath);
        cb(null, uploadsDestinationPath); // Provide the calculated path to Multer
      },
      filename: (req, file, cb) => {
        console.log('[Multer Filename] Called.');
        console.log('[Multer Filename] Original filename:', file.originalname);
        console.log('[Multer Filename] Mime type:', file.mimetype);

        const parts = file.originalname.split('.');
        console.log('[Multer Filename] Parts after split:', parts);

        const fileExtension = parts.length > 1 ? parts.pop() : '';
        console.log('[Multer Filename] Extracted file extension:', fileExtension);

        const ext = fileExtension ? `.${fileExtension}` : '';
        console.log('[Multer Filename] Constructed extension string:', ext);

        const uniqueFileName = `${uuidv4()}${ext}`;
        console.log('[Multer Filename] Generated unique filename:', uniqueFileName);

        cb(null, uniqueFileName);
      },
    });
  }

  static imageFileFilter(req: any, file: any, callback: any) {
    console.log('[Image File Filter] Called.');
    console.log('[Image File Filter] File Originalname:', file.originalname);
    if (!file.originalname.match(/\.(jpg|jpeg|png|gif)$/i)) {
      console.log('[Image File Filter] File rejected:', file.originalname);
      return callback(new BadRequestException('Only image files are allowed!'), false);
    }
    console.log('[Image File Filter] File accepted:', file.originalname);
    callback(null, true);
  }
}