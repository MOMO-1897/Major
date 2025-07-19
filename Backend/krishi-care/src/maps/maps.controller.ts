import { Controller, Get, Request, Param, NotFoundException, UseGuards, BadRequestException } from '@nestjs/common';
import { MapsService } from './maps.service';
import { Types } from 'mongoose';
import { AuthGuard } from '@nestjs/passport';

@Controller('specialists')
export class MapsController {
  constructor(private readonly mapsService: MapsService) { }

  @UseGuards(AuthGuard('jwt'))
  @Get('nearby')
  async getSpecialistNearby(@Request() req) {
    const userId = req.user.userId;

    if (!Types.ObjectId.isValid(userId)) {
      throw new BadRequestException('Invalid user ID in token');
    }

    const { specialists, district, } = await this.mapsService.getSpecialistNearby(userId);

    return { specialists, district, };
  }
}

