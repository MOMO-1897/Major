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
  ) { }

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
      soilData: boolean;
      farmLocation: string;
      userId: string; // User ID who created the report
    },
    imageFile: Express.Multer.File,
  ): Promise<ReportDocument> {
    const { reportTitle, category, description, soilData, farmLocation, userId } = reportData;

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
      farmLocation,
      status: 'Pending',
      userId: new Types.ObjectId(userId),

    });

    return newReport;
  }

  /**
   * Finds all reports.
   * @returns An array of report documents.
   */
  async findAllReports(userId: string): Promise<ReportDocument[]> {
    const reports = await this.reportModel
      .find({ userId: new Types.ObjectId(userId) })
      .sort({ createdAt: -1 })
      .populate({
        path: 'userId',
        select: '_id fullName profilePictureUrl phoneNumber'
      })
      .populate({
        path: 'specialistId',
        select: '_id fullName profilePictureUrl phoneNumber'
      })
      .exec();

    if (!reports || reports.length === 0) {
      throw new NotFoundException(`No reports found for user "${userId}".`);
    }

    return reports;
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
      specialistId: string;
      status: string;
      specialistSummary: string;
    }>,
  ): Promise<ReportDocument> {
    if (!Types.ObjectId.isValid(id)) {
      throw new BadRequestException('Invalid Report ID format.');
    }

    const report = await this.reportModel.findById(id);
    if (!report) {
      throw new NotFoundException(`Report with ID "${id}" not found.`);
    }

    // Update only allowed fields
    if (updateData.specialistId) {
      report.specialistId = new Types.ObjectId(updateData.specialistId);
    }
    if (updateData.status) {
      report.status = updateData.status as 'Pending' | 'Scheduled' | 'Completed';
    }
    if (updateData.specialistSummary !== undefined) {
      report.specialistSummary = updateData.specialistSummary;
    }

    await report.save();

    // Return the updated document
    return report;
  }

  async updateReportAfterVisit(
    id: string,
    updateData: Partial<{
      scheduleDate: string;
      scheduleTime: string;
      fee: string;
    }>,
  ): Promise<ReportDocument> {
    if (!Types.ObjectId.isValid(id)) {
      throw new BadRequestException('Invalid Report ID format.');
    }

    const report = await this.reportModel.findById(id);
    if (!report) {
      throw new NotFoundException(`Report with ID "${id}" not found.`);
    }

    // Update only allowed fields
    if (updateData.scheduleDate) {
      report.scheduleDate = updateData.scheduleDate;
    }
    if (updateData.scheduleTime) {
      report.scheduleTime = updateData.scheduleTime;
    }
    if (updateData.fee !== undefined) {
      report.fee = Number(updateData.fee);
    }

    await report.save();

    // Return the updated document
    return report;
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

  async findAllReportsSpecialist(): Promise<ReportDocument[]> {
    const reports = await this.reportModel.find({ status: 'Pending' })
      .populate({
        path: 'userId',
        select: '_id fullName profilePictureUrl phoneNumber'
      })
      .sort({ createdAt: -1 })
      .exec();

    if (!reports || reports.length === 0) {
      throw new NotFoundException(`No reports found.`);
    }

    return reports;
  }

  async findLocalReports(location: string): Promise<ReportDocument[]> {
    const reports = await this.reportModel.find({ farmLocation: location, status: 'Pending' })
      .populate({
        path: 'userId',
        select: '_id fullName profilePictureUrl phoneNumber'
      })
      .sort({ createdAt: -1 })
      .exec();

    if (!reports || reports.length === 0) {
      throw new NotFoundException(`No reports found.`);
    }

    return reports;
  }

  async findAllScheduledReports(specialistId: string): Promise<ReportDocument[]> {
    const reports = await this.reportModel.find({
      status: { $in: ['Scheduled', 'Completed'] },
      specialistId: new Types.ObjectId(specialistId),  // filter by specialistId
    })
      .populate({
        path: 'userId',
        select: '_id fullName profilePictureUrl phoneNumber'
      })
      .sort({ createdAt: -1 })
      .exec();

    if (!reports || reports.length === 0) {
      throw new NotFoundException(`No reports found.`);
    }

    return reports;
  }

}
