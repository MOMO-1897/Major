// src/auth/auth.service.ts
import { Injectable } from '@nestjs/common';
import { UsersService } from '../users/users.service';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcryptjs';
import { User, RoleType, Prisma } from '@prisma/client';

type UserWithRoleAndProfiles = Prisma.UserGetPayload<{
  include: {
    role: true;
    farmerProfile: true;
    specialistProfile: true;
  };
}>;

@Injectable()
export class AuthService {
  constructor(
    private usersService: UsersService,
    private jwtService: JwtService,
  ) {}

  async validateUser(username: string, pass: string): Promise<UserWithRoleAndProfiles | null> {
    const user = await this.usersService.findOneByUsername(username);
    if (user && await bcrypt.compare(pass, user.password)) {
      const { password, ...result } = user;
      return result as UserWithRoleAndProfiles;
    }
    return null;
  }

  async login(user: UserWithRoleAndProfiles) {
    // --- MODIFIED PAYLOAD HERE ---
    const payload = {
      username: user.username,
      sub: user.id,
      role: user.role.name,
      fullName: user.fullName, // <--- ADDED THIS LINE
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
        id: user.id,
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