// src/schemas/report.schema.ts
import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export type ReportDocument = Report & Document;

@Schema({ timestamps: true }) // Mongoose will automatically add createdAt and updatedAt
export class Report {
  _id?: Types.ObjectId; // MongoDB's default primary key

  @Prop({ required: true })
  reportTitle: string;

  @Prop({ required: true })
  category: string; // Consider making this an enum if categories are fixed (e.g., 'Soil', 'Pest', 'Disease')

  @Prop({ required: true })
  description: string;

  @Prop({ required: true })
  imageUrl: string; // URL for the uploaded report image

  @Prop({ default: false }) // Boolean with default value of false
  soilData: boolean; // CHANGED: Now a boolean

  @Prop({ required: true })
  farmLocation: string;

  @Prop({ required: true, enum: ['Pending', 'Scheduled', 'Completed'], default: 'Pending' })
  status: 'Pending' | 'Scheduled' | 'Completed';

  @Prop()
  scheduledAt?: Date;

  @Prop()
  completedAt?: Date;

  @Prop({ default: false })
  specialistVisited: boolean;

  @Prop({ default: '' })
  specialistSummary?: string;

  @Prop({ type: Types.ObjectId, ref: 'User', required: true })
  userId: Types.ObjectId;

  @Prop({ type: Types.ObjectId, ref: 'User' })
  specialistId?: Types.ObjectId;

  @Prop()
  scheduleDate?: string;

  @Prop()
  scheduleTime?: string;

  @Prop()
  fee?: number;

  @Prop({ default: 'Pending' })
  scheduleAccepted: string;
}

export const ReportSchema = SchemaFactory.createForClass(Report);
