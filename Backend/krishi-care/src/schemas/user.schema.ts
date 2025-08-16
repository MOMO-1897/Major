// src/schemas/user.schema.ts
import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose'; // Import Types for ObjectId reference

export type UserDocument = User & Document;

@Schema({ timestamps: true })
export class User {
  // Mongoose automatically creates an _id field (ObjectId) for each document
  // We don't need to explicitly define 'id' here for MongoDB's default behavior,
  // but if you have a specific 'id' property in your DTOs, you might map it.
  // For now, NestJS/Mongoose handles mapping _id to 'id' in many contexts.
  _id?: Types.ObjectId; // Explicitly type _id for better intellisense and direct access

  @Prop({ required: true, unique: true })
  username: string;

  @Prop({ required: true })
  password: string; // Hashed password

  @Prop()
  profilePictureUrl?: string; // Optional URL

  @Prop({ required: true })
  fullName: string;

  @Prop({ required: true, unique: true })
  phoneNumber: string;

  @Prop({ type: Types.ObjectId, ref: 'Role', required: true })
  role: Types.ObjectId;

  @Prop({ type: Types.ObjectId, ref: 'SpecialistProfile', unique: true, sparse: true })
  specialistProfile?: Types.ObjectId;

  @Prop({ type: Types.ObjectId, ref: 'FarmerProfile', unique: true, sparse: true })
  farmerProfile?: Types.ObjectId;

  @Prop({ default: false })
  isPremium: boolean;

}

export const UserSchema = SchemaFactory.createForClass(User);
