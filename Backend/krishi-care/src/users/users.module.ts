// src/users/users.module.ts
import { Module } from '@nestjs/common';
import { UsersService } from './users.service';
import { UsersController } from './users.controller';
// import { PrismaModule } from '../prisma/prisma.module'; // REMOVED
import { FilesModule } from '../files/files.module';
import { MongooseModule } from '@nestjs/mongoose'; // ADDED
import { User, UserSchema } from '../schemas/user.schema'; // ADDED
import { Role, RoleSchema } from '../schemas/role.schema'; // ADDED
import { FarmerProfile, FarmerProfileSchema } from '../schemas/farmer-profile.schema'; // ADDED
import { SpecialistProfile, SpecialistProfileSchema } from '../schemas/specialist-profile.schema'; // ADDED

@Module({
  imports: [
    // PrismaModule, // REMOVED
    FilesModule,
    // --- Register Mongoose Schemas for this module ---
    MongooseModule.forFeature([
      { name: User.name, schema: UserSchema },
      { name: Role.name, schema: RoleSchema }, // Role model might be used by UsersService
      { name: FarmerProfile.name, schema: FarmerProfileSchema },
      { name: SpecialistProfile.name, schema: SpecialistProfileSchema },
    ]),
    // ------------------------------------------------
  ],
  providers: [UsersService],
  controllers: [UsersController],
  exports: [UsersService], // Export UsersService so AuthModule can use it
})
export class UsersModule {}