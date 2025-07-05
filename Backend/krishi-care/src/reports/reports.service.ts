// src/reports/reports.service.ts
import { Injectable, BadRequestException, NotFoundException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import { Report, ReportDocument } from '../schemas/report.schema';
import { FilesService } from '../files/files.service'; // For handling image uploads

@Injectable()
export class ReportsService {
  constructor(
    @InjectModel(Report.name) private reportModel: Model<ReportDocument>,
    private filesService: FilesService, // Inject FilesService
  ) {}

  /**
   * Creates a new report.
   * @param reportData - The data for the new report (title, category, description, soilData, userId).
   * @param imageFile - The image file to upload.
   * @returns The created report document.
   */
  async createReport(
    reportData: {
      reportTitle: string;
      category: string;
      description: string;
      soilData: boolean; // CHANGED: Now boolean
      userId: string; // User ID who created the report
    },
    imageFile: Express.Multer.File,
  ): Promise<ReportDocument> {
    const { reportTitle, category, description, soilData, userId } = reportData;

    // Basic validation
    if (!reportTitle || !category || !description || userId === undefined || userId === null) { // userId check
      throw new BadRequestException('Report title, category, description, and user ID are required.');
    }

    // Validate soilData (must be a boolean)
    if (typeof soilData !== 'boolean') { // CHANGED: Validate as boolean
      throw new BadRequestException('soilData must be a boolean value (true/false).');
    }

    // Handle image upload
    if (!imageFile) {
      throw new BadRequestException('Report image is required.');
    }
    const imageUrl = `/uploads/${imageFile.filename}`; // Get URL from uploaded file

    // Create the report document
    const newReport = await this.reportModel.create({
      reportTitle,
      category,
      description,
      imageUrl,
      soilData, // CHANGED: Assign soilData directly
      isResolved: false, // Default value
      userId: new Types.ObjectId(userId), // Convert string userId to ObjectId
    });

    return newReport;
  }

  /**
   * Finds all reports.
   * @returns An array of report documents.
   */
  async findAllReports(): Promise<ReportDocument[]> {
    return this.reportModel.find().exec();
  }

  /**
   * Finds a single report by its ID.
   * @param id - The ID of the report.
   * @returns The report document.
   */
  async findReportById(id: string): Promise<ReportDocument> {
    if (!Types.ObjectId.isValid(id)) {
      throw new BadRequestException('Invalid Report ID format.');
    }
    const report = await this.reportModel.findById(id).exec();
    if (!report) {
      throw new NotFoundException(`Report with ID "${id}" not found.`);
    }
    return report;
  }

  /**
   * Updates a report.
   * @param id - The ID of the report to update.
   * @param updateData - The data to update.
   * @param imageFile - Optional new image file.
   * @returns The updated report document.
   */
  async updateReport(
    id: string,
    updateData: Partial<{
      reportTitle: string;
      category: string;
      description: string;
      soilData: boolean; // CHANGED: Now boolean
      isResolved: boolean;
    }>,
    imageFile?: Express.Multer.File,
  ): Promise<ReportDocument> {
    if (!Types.ObjectId.isValid(id)) {
      throw new BadRequestException('Invalid Report ID format.');
    }

    const report = await this.reportModel.findById(id).exec();
    if (!report) {
      throw new NotFoundException(`Report with ID "${id}" not found.`);
    }

    // Handle image update if a new file is provided
    if (imageFile) {
      updateData['imageUrl'] = `/uploads/${imageFile.filename}`;
      // You might want to add logic here to delete the old image file from disk
    }

    // Validate soilData if provided in update
    if (updateData.soilData !== undefined) { // Check if it's explicitly provided
      if (typeof updateData.soilData !== 'boolean') {
        throw new BadRequestException('soilData must be a boolean value (true/false) for update.');
      }
    }

    // Update the document
    Object.assign(report, updateData);
    return report.save();
  }

  /**
   * Deletes a report by its ID.
   * @param id - The ID of the report to delete.
   */
  async deleteReport(id: string): Promise<void> {
    if (!Types.ObjectId.isValid(id)) {
      throw new BadRequestException('Invalid Report ID format.');
    }
    const result = await this.reportModel.deleteOne({ _id: id }).exec();
    if (result.deletedCount === 0) {
      throw new NotFoundException(`Report with ID "${id}" not found.`);
    }
    // You might want to add logic here to delete the associated image file from disk
  }
}