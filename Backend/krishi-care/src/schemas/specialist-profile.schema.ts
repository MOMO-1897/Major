// src/schemas/specialist-profile.schema.ts
import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export type SpecialistProfileDocument = SpecialistProfile & Document;

@Schema({ timestamps: true })
export class SpecialistProfile {
  @Prop({ required: true })
  specialization: string;

  @Prop({ required: true })
  certificationImage: string; // URL for certification image

  // One-to-one relationship with User:
  // This field links back to the User document.
  @Prop({ type: Types.ObjectId, ref: 'User', unique: true, required: true })
  userId: Types.ObjectId; // Required to link to a User
}

export const SpecialistProfileSchema = SchemaFactory.createForClass(SpecialistProfile);