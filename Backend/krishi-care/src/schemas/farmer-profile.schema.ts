// src/schemas/farmer-profile.schema.ts
import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export type FarmerProfileDocument = FarmerProfile & Document;

@Schema({ timestamps: true })
export class FarmerProfile {
  @Prop()
  farmName?: string; // Optional: Farm name

  // One-to-one relationship with User:
  // This field links back to the User document.
  @Prop({ type: Types.ObjectId, ref: 'User', unique: true, required: true })
  userId: Types.ObjectId; // Required to link to a User

  @Prop({ required: true })
  farmLocation: string;
}

export const FarmerProfileSchema = SchemaFactory.createForClass(FarmerProfile);
