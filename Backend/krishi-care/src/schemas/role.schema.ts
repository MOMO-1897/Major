import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document } from 'mongoose';

export type RoleDocument = Role & Document;

export enum RoleType {
  FARMER = 'FARMER',
  SPECIALIST = 'SPECIALIST',
  ADMIN = 'ADMIN', // Add the ADMIN role here
}

@Schema({ timestamps: true })
export class Role {
  @Prop({ type: String, enum: RoleType, required: true, unique: true })
  name: RoleType;
}

export const RoleSchema = SchemaFactory.createForClass(Role);
