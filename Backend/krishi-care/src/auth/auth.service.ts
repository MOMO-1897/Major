// src/auth/auth.service.ts
import { Injectable } from '@nestjs/common';
import { UsersService } from '../users/users.service';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcryptjs';
import { RoleType } from '../schemas/role.schema';
import { UserDocument } from '../schemas/user.schema';
import { Types } from 'mongoose';

type UserWithPopulatedFields = UserDocument & {
  role: { _id: Types.ObjectId; name: RoleType };
  farmerProfile?: { _id: Types.ObjectId; farmName?: string };
  specialistProfile?: { _id: Types.ObjectId; specialization: string; certificationImage: string };
};

@Injectable()
export class AuthService {
  constructor(
    private usersService: UsersService,
    private jwtService: JwtService,
  ) { }

  async validateUser(username: string, pass: string): Promise<UserWithPopulatedFields | null> {
    const user = await this.usersService.findOneByUsername(username);
    if (user && await bcrypt.compare(pass, user.password)) {
      const userPlainObject = user; // user from findOneByUsername is already a plain object due to .lean()
      const { password, ...result } = userPlainObject;
      return result as UserWithPopulatedFields;
    }
    return null;
  }

  async login(user: UserWithPopulatedFields) {
    const payload = {
      username: user.username,
      // Add non-null assertion (!) here
      sub: user._id!.toHexString(), // MongoDB _id is ObjectId, convert to string for JWT
      role: user.role.name,
      fullName: user.fullName,
    };
    const accessToken = this.jwtService.sign(payload);

    let profileSpecificData: Record<string, any> = {};

    if (user.role.name === RoleType.FARMER && user.farmerProfile) {
      profileSpecificData.farmName = user.farmerProfile.farmName;
    } else if (user.role.name === RoleType.SPECIALIST && user.specialistProfile) {
      profileSpecificData.specialization = user.specialistProfile.specialization;
      profileSpecificData.certificationImage = user.specialistProfile.certificationImage;
    }

    return {
      access_token: accessToken,
      user: {
        // Add non-null assertion (!) here
        id: user._id!.toHexString(), // Convert MongoDB ObjectId to string for frontend
        username: user.username,
        fullName: user.fullName,
        phoneNumber: user.phoneNumber,
        role: user.role.name,
        profilePictureUrl: user.profilePictureUrl,
        ...profileSpecificData,
      },
    };
  }
}
