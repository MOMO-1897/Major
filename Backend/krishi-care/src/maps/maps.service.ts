import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose'
import { User, UserDocument } from '../schemas/user.schema';
import { FarmerProfile, FarmerProfileDocument } from '../schemas/farmer-profile.schema';
import { SpecialistProfile, SpecialistProfileDocument } from '../schemas/specialist-profile.schema';

@Injectable()
export class MapsService {
  constructor(
    @InjectModel(User.name) private userModel: Model<UserDocument>,
    @InjectModel(SpecialistProfile.name) private specialistModel: Model<SpecialistProfileDocument>,
    @InjectModel(FarmerProfile.name) private farmerModel: Model<FarmerProfileDocument>,
  ) { }

  async getSpecialistNearby(userId: string) {
    const user = await this.userModel
      .findById(userId)
      .populate('farmerProfile')
      .lean<User & { farmerProfile: FarmerProfile }>()
      .exec();

    if (!user || !user.farmerProfile) {
      throw new NotFoundException('Farmer profile not found.');
    }

    const district = user.farmerProfile.farmLocation;
    if (!district) {
      throw new NotFoundException('Farmer district is missing');
    }

    const specialists = await this.specialistModel
      .find({ district: { $regex: new RegExp(`^${district}$`, 'i') } })
      .populate({
        path: 'userId',
        select: '-password -refreshToken',
        populate: {
          path: 'specialistProfile',
          select: 'specialization'
        }
      })
      .exec();

    return { specialists, district };
  }

  async getFarmLocationById(userId: string) {
    const farm = await this.farmerModel.findOne({ userId: new Types.ObjectId(userId) }, 'farmName farmLocation').exec();
    if (!farm) {
      throw new NotFoundException(`No farm found for user "${userId}".`);
    }
    return farm;

  }
}
