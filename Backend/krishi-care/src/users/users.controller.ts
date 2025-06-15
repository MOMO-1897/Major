// src/users/users.controller.ts
import {
  Controller,
  Post,
  Body,
  HttpStatus,
  HttpCode,
  UseInterceptors,
  UploadedFiles,
  BadRequestException,
} from '@nestjs/common';
import { FilesService } from '../files/files.service'; // Corrected import path
import { UsersService } from './users.service';
import { FileFieldsInterceptor } from '@nestjs/platform-express';
import { MulterOptions } from '@nestjs/platform-express/multer/interfaces/multer-options.interface';


// Define Multer options for the interceptor.
const multerOptions: MulterOptions = {
  storage: undefined, // Use memory storage so we get a buffer
  limits: {
    fileSize: 5 * 1024 * 1024, // 5 MB file size limit
  },
  fileFilter: (req, file, cb) => {
    if (!file.originalname.match(/\.(jpg|jpeg|png|gif)$/i)) {
      return cb(new BadRequestException('Only image files (jpg, jpeg, png, gif) are allowed!'), false);
    }
    cb(null, true);
  },
};

@Controller('users')
export class UsersController {
  constructor(
    private readonly usersService: UsersService,
    private readonly filesService: FilesService,
  ) {}

  @Post()
  @HttpCode(HttpStatus.CREATED)
  @UseInterceptors(
    FileFieldsInterceptor(
      [
        { name: 'profilePicture', maxCount: 1 },
        { name: 'certificationImage', maxCount: 1 },
      ],
      multerOptions,
    ),
  )
  async create(
    @Body() userData: Record<string, any>,
    @UploadedFiles()
    files: {
      profilePicture?: Express.Multer.File[];
      certificationImage?: Express.Multer.File[];
    },
  ) {
    const profilePictureFile = files.profilePicture ? files.profilePicture[0] : null;
    const certificationImageFile = files.certificationImage ? files.certificationImage[0] : null;

    let profilePictureUrl: string | null = null;
    let certificationImageUrl: string | null = null;

    if (profilePictureFile) {
      profilePictureUrl = await this.filesService.saveFile(profilePictureFile);
    }

    if (certificationImageFile) {
      certificationImageUrl = await this.filesService.saveFile(certificationImageFile);
    }

    return this.usersService.create({
      ...userData,
      profilePictureUrl: profilePictureUrl,
      certificationImage: certificationImageUrl,
    });
  }
}