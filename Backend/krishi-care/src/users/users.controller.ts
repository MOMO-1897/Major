// src/users/users.controller.ts
import { Controller, Post, Body, UseInterceptors, UploadedFiles, BadRequestException, Patch, UseGuards, Request, ForbiddenException, Get, Param } from '@nestjs/common';
import { UsersService } from './users.service';
import { FileFieldsInterceptor } from '@nestjs/platform-express';
import { FilesService } from '../files/files.service';
import { AuthGuard } from '@nestjs/passport';

@Controller('users')
export class UsersController {
  constructor(
    private readonly usersService: UsersService,
    private readonly filesService: FilesService,
  ) { }

  @Post()
  @UseInterceptors(
    FileFieldsInterceptor([
      { name: 'profilePicture', maxCount: 1 }, // Now available for any user type
      { name: 'certificationImage', maxCount: 1 }, // Still specific to specialist
    ], {
      storage: FilesService.prototype.multerStorage,
      fileFilter: FilesService.imageFileFilter,
      limits: { fileSize: 10 * 1024 * 1024 },
    })
  )
  async createUser(
    @Body() userData: Record<string, any>,
    @UploadedFiles() files: { profilePicture?: Express.Multer.File[], certificationImage?: Express.Multer.File[] },
  ) {
    let profilePictureUrl: string | undefined;
    let certificationImageUrl: string | undefined;

    // Check if profilePicture was uploaded
    if (files.profilePicture && files.profilePicture.length > 0) {
      const file = files.profilePicture[0];
      // --- REMOVED THE ROLE-SPECIFIC CHECK HERE ---
      // The profilePictureUrl is a general user field, so any role can upload it.
      profilePictureUrl = `/uploads/${file.filename}`;
    }

    // Check if certificationImage was uploaded (still specific to SPECIALIST)
    if (files.certificationImage && files.certificationImage.length > 0) {
      const file = files.certificationImage[0];
      if (userData.roleName !== 'SPECIALIST') {
        throw new BadRequestException('Certification image upload is only for SPECIALIST role.');
      }
      certificationImageUrl = `/uploads/${file.filename}`;
    }

    // Validate if necessary files were provided for the specified role
    // Certification image is still required for SPECIALIST
    if (userData.roleName === 'SPECIALIST' && !certificationImageUrl) {
      throw new BadRequestException('Certification image is required for SPECIALIST role.');
    }
    // If you also want to *require* a profile picture for Specialists (and Farmers):
    // if ((userData.roleName === 'FARMER' || userData.roleName === 'SPECIALIST') && !profilePictureUrl) {
    //   throw new BadRequestException('Profile picture is required for FARMER and SPECIALIST roles.');
    // }


    const dataToCreate = {
      ...userData,
      profilePictureUrl: profilePictureUrl,
      certificationImage: certificationImageUrl,
    };

    return this.usersService.create(dataToCreate);
  }

  @UseGuards(AuthGuard('jwt'))
  @Patch('location')
  async updateLocation(
    @Request() req,
    @Body() locationData: {
      locationType: string;
      locationCoordinates: number[];
      locationUpdatedAt: string;
      district: string;
    }
  ) {

    const userId = req.user.userId;
    if (req.user.role.toUpperCase() !== 'SPECIALIST') {
      throw new ForbiddenException('Only specialists can update location');
    }

    return this.usersService.updateSpecialistLocation(userId, locationData);
  }

  @Get('image')
  async getUserImage(@Request() req) {
    const id = req.headers['user-id'];
    return this.usersService.getUserImageUrl(id);
  }


  @Get(':id')
  async getUserById(@Param('id') id: string) {
    return this.usersService.UserfindById(id);
  }

  // NEW ENDPOINT: Set User as Premium
  // Removed @UseGuards(AuthGuard('jwt')) to make this endpoint accessible without authentication.
  @Patch(':id/set-premium') // PATCH request to update a specific user's premium status
  async setPremiumStatus(
    @Param('id') id: string, // User ID from the URL parameter
    // @Request() req, // Request object is no longer needed if no authentication is used
  ) {
    // Since authentication is removed, we also remove the authorization check.
    // This endpoint will now allow anyone to set the premium status for any user ID provided in the URL.
    // Use with caution in a production environment.
    // const authenticatedUserId = req.user.userId;
    // if (id !== authenticatedUserId) {
    //   throw new ForbiddenException('You are not authorized to update another user\'s premium status.');
    // }

    // Call the UsersService to update the isPremium status
    return this.usersService.setPremiumStatus(id);
  }
}
