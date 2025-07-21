// src/users/users.service.ts
import { Injectable, NotFoundException, BadRequestException, OnModuleInit } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import { User, UserDocument } from '../schemas/user.schema';
import { Role, RoleDocument, RoleType } from '../schemas/role.schema';
import { FarmerProfile, FarmerProfileDocument } from '../schemas/farmer-profile.schema';
import { SpecialistProfile, SpecialistProfileDocument } from '../schemas/specialist-profile.schema';
import * as bcrypt from 'bcryptjs';

// Define a type for user with populated roles/profiles for consistent return type
type UserWithPopulatedFields = UserDocument & {
  role: { _id: Types.ObjectId; name: RoleType };
  farmerProfile?: { _id: Types.ObjectId; farmName?: string };
  specialistProfile?: { _id: Types.ObjectId; specialization: string; certificationImage: string };
};

@Injectable()
export class UsersService {
  constructor(
    // Inject Mongoose models
    @InjectModel(User.name) private userModel: Model<UserDocument>,
    @InjectModel(Role.name) private roleModel: Model<RoleDocument>,
    @InjectModel(FarmerProfile.name) private farmerProfileModel: Model<FarmerProfileDocument>,
    @InjectModel(SpecialistProfile.name) private specialistProfileModel: Model<SpecialistProfileDocument>,
  ) { }

  async onModuleInit() {
    // --- Mongoose Role Seeding (Replaces PrismaService seeding) ---
    console.log('Ensuring roles exist in MongoDB...');
    try {
      await this.roleModel.findOneAndUpdate(
        { name: RoleType.FARMER },
        { $setOnInsert: { name: RoleType.FARMER } },
        { upsert: true, new: true, setDefaultsOnInsert: true }
      );
      await this.roleModel.findOneAndUpdate(
        { name: RoleType.SPECIALIST },
        { $setOnInsert: { name: RoleType.SPECIALIST } },
        { upsert: true, new: true, setDefaultsOnInsert: true }
      );
      console.log('Roles ensured successfully in MongoDB.');
    } catch (error) {
      console.error('Error during automatic role seeding for MongoDB:', error);
    }
    // --- End Mongoose Role Seeding ---
  }

  private async hashPassword(password: string): Promise<string> {
    const saltRounds = 10;
    return bcrypt.hash(password, saltRounds);
  }

  async findOneByUsername(username: string): Promise<UserWithPopulatedFields | undefined> {
    const user = await this.userModel.findOne({ username })
      .populate('role')
      .populate('farmerProfile')
      .populate('specialistProfile')
      .lean<UserWithPopulatedFields>() // Use .lean() and cast here
      .exec();

    // Explicitly return undefined if user is null
    return user || undefined; // If user is null, it will be undefined in TS
  }

  async create(userData: Record<string, any>): Promise<UserWithPopulatedFields> {
    const {
      username,
      password,
      fullName,
      phoneNumber,
      roleName,
      profilePictureUrl,
      farmName,
      farmLocation,
      specialization,
      certificationImage
    } = userData;

    if (typeof fullName !== 'string' || fullName.trim() === '') {
      throw new BadRequestException('Full name is required and cannot be empty.');
    }

    if (typeof phoneNumber !== 'string' || phoneNumber.trim() === '') {
      throw new BadRequestException('Phone number is required and cannot be empty.');
    }

    if (typeof password !== 'string' || password.trim() === '') {
      throw new BadRequestException('Password is required and cannot be empty.');
    }

    const existingUserByUsername = await this.userModel.findOne({ username }).exec();
    if (existingUserByUsername) {
      throw new BadRequestException('Username already exists.');
    }

    const existingUserByPhoneNumber = await this.userModel.findOne({ phoneNumber }).exec();
    if (existingUserByPhoneNumber) {
      throw new BadRequestException('Phone number already in use.');
    }

    const validRoleTypes = Object.values(RoleType);
    if (!validRoleTypes.includes(roleName)) {
      throw new NotFoundException(`Role '${roleName}' not found. Please provide a valid role type (e.g., ${validRoleTypes.join(', ')}).`);
    }

    const role = await this.roleModel.findOne({ name: roleName }).exec();

    if (!role) {
      throw new NotFoundException(`Role '${roleName}' not found in the database. Please ensure it is seeded.`);
    }

    const hashedPassword = await this.hashPassword(password);

    // Initialize variables to null/undefined to resolve TS2454
    let createdUser: UserDocument | null = null;
    let createdFarmerProfile: FarmerProfileDocument | null = null;
    let createdSpecialistProfile: SpecialistProfileDocument | null = null;

    try {
      createdUser = await this.userModel.create({
        username,
        password: hashedPassword,
        fullName,
        phoneNumber,
        profilePictureUrl: profilePictureUrl || null,
        role: role._id, // Link to Role using its ObjectId
      });

      if (role.name === RoleType.FARMER) {
        if (typeof farmName !== 'string' || farmName.trim() === '') {
          throw new BadRequestException('Farm name is required for FARMER role.');
        }
        if (typeof farmLocation !== 'string' || farmLocation.trim() === '') {
          throw new BadRequestException('Farm location is required for FARMER role.');
        }
        createdFarmerProfile = await this.farmerProfileModel.create({
          farmName: farmName,
          farmLocation: farmLocation,
          userId: createdUser._id, // Link to User using its ObjectId
        });
        // Update the User document to link to the new FarmerProfile
        await this.userModel.findByIdAndUpdate(createdUser._id, { farmerProfile: createdFarmerProfile._id }).exec();

      } else if (role.name === RoleType.SPECIALIST) {
        if (typeof specialization !== 'string' || specialization.trim() === '') {
          throw new BadRequestException('Specialization is required for SPECIALIST role.');
        }
        if (typeof certificationImage !== 'string' || certificationImage.trim() === '') {
          throw new BadRequestException('Certification image is required for SPECIALIST role.');
        }
        createdSpecialistProfile = await this.specialistProfileModel.create({
          specialization: specialization,
          certificationImage: certificationImage,
          userId: createdUser._id, // Link to User using its ObjectId
        });
        // Update the User document to link to the new SpecialistProfile
        await this.userModel.findByIdAndUpdate(createdUser._id, { specialistProfile: createdSpecialistProfile._id }).exec();
      }

      // Fetch the final user with populated relations and convert to plain object
      const finalUser = await this.userModel.findById(createdUser._id)
        .populate('role')
        .populate('farmerProfile')
        .populate('specialistProfile')
        .lean<UserWithPopulatedFields>() // Use .lean() here
        .exec();

      // finalUser will be null if not found, but we just created it so it should exist
      return finalUser!; // Use non-null assertion as it's guaranteed to exist here

    } catch (error: any) {
      // Handle unique constraint errors (e.g., username, phoneNumber, userId in profiles)
      // MongoDB duplicate key error code is 11000
      if (error.code === 11000) {
        if (error.message.includes('username_1') || error.message.includes('username')) {
          throw new BadRequestException('Username already exists.');
        }
        if (error.message.includes('phoneNumber_1') || error.message.includes('phoneNumber')) {
          throw new BadRequestException('Phone number already in use.');
        }
        if (error.message.includes('userId_1') && (error.message.includes('specialistprofiles') || error.message.includes('farmerprofiles'))) {
          throw new BadRequestException('A profile for this user already exists.');
        }
      }

      // Clean up partially created records on error
      if (createdUser && createdUser._id) { // Check _id exists before deleting
        await this.userModel.findByIdAndDelete(createdUser._id).exec();
      }
      if (createdFarmerProfile && createdFarmerProfile._id) {
        await this.farmerProfileModel.findByIdAndDelete(createdFarmerProfile._id).exec();
      }
      if (createdSpecialistProfile && createdSpecialistProfile._id) {
        await this.specialistProfileModel.findByIdAndDelete(createdSpecialistProfile._id).exec();
      }

      throw error;
    }
  }

  async updateSpecialistLocation(
    userId: string,
    locationData: {
      locationType: string;
      locationCoordinates: number[];
      locationUpdatedAt: string;
      district: string;
    }) {
    // Convert locationUpdatedAt string to Date object before saving
    const updatedAt = new Date(locationData.locationUpdatedAt);
    return this.specialistProfileModel.updateOne(
      { userId: userId }, // match by userId in SpecialistProfile collection
      {
        $set: {
          locationType: locationData.locationType,
          locationCoordinates: locationData.locationCoordinates,
          locationUpdatedAt: updatedAt,
          district: locationData.district,
        },
      },
      { upsert: true } // create document if not exists
    );
  }

  async UserfindById(specialistId: string) {

    const user = await this.userModel.findById(specialistId).lean();
    if (!user) {
      throw new NotFoundException(`User with id not found`);
    }

    return { user };
  }
}
