import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { MapsService } from './maps.service';
import { MapsController } from './maps.controller';
import { User, UserSchema } from '../schemas/user.schema';
import { FarmerProfile, FarmerProfileSchema } from '../schemas/farmer-profile.schema';
import { SpecialistProfile, SpecialistProfileSchema } from '../schemas/specialist-profile.schema';

@Module({
  imports: [
    MongooseModule.forFeature([
      { name: User.name, schema: UserSchema },
      { name: FarmerProfile.name, schema: FarmerProfileSchema },
      { name: SpecialistProfile.name, schema: SpecialistProfileSchema },
    ]),
  ],
  controllers: [MapsController],
  providers: [MapsService],
})
export class MapsModule { }

