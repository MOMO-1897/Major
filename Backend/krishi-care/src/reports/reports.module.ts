// src/reports/reports.module.ts
import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { ReportsService } from './reports.service';
import { ReportsController } from './reports.controller';
import { Report, ReportSchema } from '../schemas/report.schema'; // Import the new Report schema
import { FilesModule } from '../files/files.module'; // Needed for file uploads

@Module({
  imports: [
    // Register the Report schema with MongooseModule for this module
    MongooseModule.forFeature([{ name: Report.name, schema: ReportSchema }]),
    FilesModule, // Import FilesModule to use FilesService for uploads
  ],
  providers: [ReportsService],
  controllers: [ReportsController],
  exports: [ReportsService], // Export if other modules need to interact with ReportsService
})
export class ReportsModule {}
