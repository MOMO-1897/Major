// src/users/users.service.ts
import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { User, RoleType } from '@prisma/client';
import * as bcrypt from 'bcryptjs';

@Injectable()
export class UsersService {
  constructor(private prisma: PrismaService) {}

  private async hashPassword(password: string): Promise<string> {
    const saltRounds = 10;
    return bcrypt.hash(password, saltRounds);
  }

  async findOneByUsername(username: string): Promise<User | undefined> {
    const user = await this.prisma.user.findUnique({
      where: { username: username },
      include: {
        role: true,
        // --- ADD THESE LINES TO INCLUDE PROFILES ---
        farmerProfile: true,    // Include farmer profile if it exists
        specialistProfile: true, // Include specialist profile if it exists
        // ------------------------------------------
      },
    });
    // Ensure `null` from Prisma is correctly handled as `undefined` for TypeScript type compatibility.
    return user || undefined; // If user is null, return undefined
  }

  async create(userData: Record<string, any>): Promise<User> {
    const {
      username,
      password,
      fullName,
      phoneNumber,
      roleName,
      profilePictureUrl,
      farmName,
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

    const existingUserByUsername = await this.prisma.user.findUnique({
      where: { username },
    });
    if (existingUserByUsername) {
      throw new BadRequestException('Username already exists.');
    }

    const existingUserByPhoneNumber = await this.prisma.user.findUnique({
      where: { phoneNumber },
    });
    if (existingUserByPhoneNumber) {
      throw new BadRequestException('Phone number already in use.');
    }

    const validRoleTypes = Object.values(RoleType);
    if (!validRoleTypes.includes(roleName)) {
      throw new NotFoundException(`Role '${roleName}' not found. Please provide a valid role type (e.g., ${validRoleTypes.join(', ')}).`);
    }

    const role = await this.prisma.role.findUnique({
      where: { name: roleName as RoleType },
    });

    if (!role) {
      throw new NotFoundException(`Role '${roleName}' not found in the database. Please ensure it is seeded.`);
    }

    const hashedPassword = await this.hashPassword(password);

    // This includeOptions block below the try/catch only affects the final `findUnique`
    // after the user and their specific profile are created. It's fine as is.
    let includeOptions: any = { role: true };

    if (role.name === RoleType.FARMER) {
      includeOptions.farmerProfile = true;
    } else if (role.name === RoleType.SPECIALIST) {
      includeOptions.specialistProfile = true;
    }

    try {
      const user = await this.prisma.user.create({
        data: {
          username,
          password: hashedPassword,
          fullName,
          phoneNumber,
          profilePictureUrl: profilePictureUrl || null,
          role: { connect: { id: role.id } },
        },
      });

      if (role.name === RoleType.FARMER) {
        if (typeof farmName !== 'string' || farmName.trim() === '') {
          throw new BadRequestException('Farm name is required for FARMER role.');
        }
        await this.prisma.farmerProfile.create({
          data: {
            farmName: farmName,
            user: { connect: { id: user.id } },
          },
        });
      } else if (role.name === RoleType.SPECIALIST) {
        if (typeof specialization !== 'string' || specialization.trim() === '') {
          throw new BadRequestException('Specialization is required for SPECIALIST role.');
        }
        if (typeof certificationImage !== 'string' || certificationImage.trim() === '') {
          throw new BadRequestException('Certification image is required for SPECIALIST role.');
        }
        await this.prisma.specialistProfile.create({
          data: {
            specialization: specialization,
            certificationImage: certificationImage,
            user: { connect: { id: user.id } },
          },
        });
      }

      const finalUser = await this.prisma.user.findUnique({
        where: { id: user.id },
        include: includeOptions,
      });

      return finalUser!;

    } catch (error: any) { // Use 'any' for error type if not specific
      if (error.code === 'P2002') {
        if (error.meta?.target?.includes('username')) {
            throw new BadRequestException('Username already exists.');
        }
        if (error.meta?.target?.includes('phoneNumber')) {
            throw new BadRequestException('Phone number already in use.');
        }
        if (error.meta?.target?.includes('userId')) {
            throw new BadRequestException('A profile for this user already exists.');
        }
      }
      throw error;
    }
  }
}