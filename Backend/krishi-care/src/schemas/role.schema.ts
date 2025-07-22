// src/schemas/role.schema.ts
import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document } from 'mongoose';

// Define the Role document type
export type RoleDocument = Role & Document;

// Enum for predefined roles (should match your previous RoleType enum)
export enum RoleType {
  FARMER = 'FARMER',
  SPECIALIST = 'SPECIALIST',
  ADMIN = 'ADMIN', // Consider adding if you might have admin users
}

@Schema({ timestamps: true })
export class Role {
  @Prop({ required: true, unique: true, enum: Object.values(RoleType) })
  name: RoleType;

  // Mongoose automatically manages the reverse relationship
  // You don't typically declare the 'users' array here explicitly for Mongoose.
}

export const RoleSchema = SchemaFactory.createForClass(Role);