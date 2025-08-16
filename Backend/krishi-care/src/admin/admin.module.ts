import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';

import { AdminController } from './admin.controller';
import { AdminService } from './admin.service';

import { User, UserSchema } from '../schemas/user.schema';
import { Role, RoleSchema } from '../schemas/role.schema';
import { FarmerProfile, FarmerProfileSchema } from '../schemas/farmer-profile.schema';
import { SpecialistProfile, SpecialistProfileSchema } from '../schemas/specialist-profile.schema';
// Import the Report schema
import { Report, ReportSchema } from '../schemas/report.schema';

@Module({
  imports: [
    MongooseModule.forFeature([
      { name: User.name, schema: UserSchema },
      { name: Role.name, schema: RoleSchema },
      { name: FarmerProfile.name, schema: FarmerProfileSchema },
      { name: SpecialistProfile.name, schema: SpecialistProfileSchema },
      // Register the Report schema to make it available for dependency injection
      { name: Report.name, schema: ReportSchema },
    ]),
  ],
  controllers: [AdminController],
  providers: [AdminService],
})
export class AdminModule {}
