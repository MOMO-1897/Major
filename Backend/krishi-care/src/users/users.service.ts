// src/users/users.service.ts
import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { User, RoleType } from '@prisma/client';
import * as bcrypt from 'bcrypt';

@Injectable()
export class UsersService {
  constructor(private prisma: PrismaService) {}

  private async hashPassword(password: string): Promise<string> {
    const saltRounds = 10;
    return bcrypt.hash(password, saltRounds);
  }

  async create(userData: Record<string, any>): Promise<User> {
    const { username, password, fullName, phoneNumber, roleName, profilePictureUrl, farmName, specialization, certificationImage } = userData;

    // Validate core user fields
    if (typeof fullName !== 'string' || fullName.trim() === '') {
      throw new BadRequestException('Full name is required and cannot be empty.');
    }

    if (typeof phoneNumber !== 'string' || phoneNumber.trim() === '') {
      throw new BadRequestException('Phone number is required and cannot be empty.');
    }

    if (typeof password !== 'string' || password.trim() === '') {
      throw new BadRequestException('Password is required and cannot be empty.');
    }

    // Existing username and phone number uniqueness checks
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

    // Role existence and validity check
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

    // Hash the password before storing
    const hashedPassword = await this.hashPassword(password);

    // Prepare the include options for Prisma based on the role
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
        // The include here for .create() mostly handles connecting existing relations.
        // For the *newly created* profile, we'll need to re-fetch as seen below.
        // include: includeOptions, // Can be omitted here if we always re-fetch after profile creation
      });

      // Farmer/Specialist profile creation logic (still needed to create the actual profile record)
      if (role.name === RoleType.FARMER) {
        if (farmName !== undefined && farmName !== null) {
          await this.prisma.farmerProfile.create({
            data: {
              farmName: farmName,
              user: { connect: { id: user.id } },
            },
          });
        }
      } else if (role.name === RoleType.SPECIALIST) {
        if (typeof specialization !== 'string' || specialization.trim() === '') {
          throw new BadRequestException('Specialization is required for SPECIALIST role.');
        }

        if (typeof certificationImage !== 'string' || certificationImage.trim() === '') {
          throw new BadRequestException('Certification image URL is required for SPECIALIST role.');
        }

        await this.prisma.specialistProfile.create({
          data: {
            specialization: specialization,
            certificationImage: certificationImage,
            user: { connect: { id: user.id } },
          },
        });
      }

      // Re-fetch the user with the newly created profile data
      // This is crucial because the .create() above won't automatically include the
      // related profile if it was created in a separate step afterwards.
      const finalUser = await this.prisma.user.findUnique({
        where: { id: user.id },
        include: includeOptions,
      });

      // Use the non-null assertion operator (!) because we are certain finalUser will not be null here.
      return finalUser!;

    } catch (error) {
      if (error.code === 'P2002') {
        if (error.meta?.target?.includes('username')) {
            throw new BadRequestException('Username already exists.');
        }
        if (error.meta?.target?.includes('phoneNumber')) {
            throw new BadRequestException('Phone number already in use.');
        }
      }
      throw error;
    }
  }
}