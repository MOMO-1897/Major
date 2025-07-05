// src/reports/reports.controller.ts
import {
  Controller,
  Post,
  Get,
  Put,
  Delete,
  Body,
  Param,
  UseInterceptors,
  UploadedFile,
  BadRequestException,
  HttpStatus,
  HttpCode,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { ReportsService } from './reports.service';
import { FilesService } from '../files/files.service'; // For Multer storage/filter
import { ReportDocument } from '../schemas/report.schema';

@Controller('reports')
export class ReportsController {
  constructor(
    private readonly reportsService: ReportsService,
    private readonly filesService: FilesService, // Inject FilesService to access multerStorage and imageFileFilter
  ) {}

  /**
   * POST /reports
   * Creates a new report with an image upload.
   */
  @Post()
  @UseInterceptors(
    FileInterceptor('image', { // 'image' is the field name for the file in the multipart request
      storage: FilesService.prototype.multerStorage,
      fileFilter: FilesService.imageFileFilter,
      limits: { fileSize: 10 * 1024 * 1024 }, // 10 MB limit
    }),
  )
  @HttpCode(HttpStatus.CREATED)
  async createReport(
    @Body() reportData: {
      reportTitle: string;
      category: string;
      description: string;
      soilData: string; // Expect it as a string from form-data
      userId: string;
    },
    @UploadedFile() image: Express.Multer.File,
  ): Promise<ReportDocument> {
    if (!image) {
      throw new BadRequestException('Report image file is required.');
    }

    // --- FIX: Convert soilData string to boolean ---
    let parsedSoilData: boolean;
    if (reportData.soilData === 'true') {
      parsedSoilData = true;
    } else if (reportData.soilData === 'false') {
      parsedSoilData = false;
    } else {
      throw new BadRequestException('soilData must be "true" or "false" (as strings).');
    }
    // --- End FIX ---

    // Pass the parsed boolean to the service
    return this.reportsService.createReport(
      { ...reportData, soilData: parsedSoilData }, // Override soilData with boolean
      image
    );
  }

  /**
   * GET /reports
   * Retrieves all reports.
   */
  @Get()
  async findAllReports(): Promise<ReportDocument[]> {
    return this.reportsService.findAllReports();
  }

  /**
   * GET /reports/:id
   * Retrieves a single report by ID.
   */
  @Get(':id')
  async findReportById(@Param('id') id: string): Promise<ReportDocument> {
    return this.reportsService.findReportById(id);
  }

  /**
   * PUT /reports/:id
   * Updates an existing report, optionally with a new image.
   */
  @Put(':id')
  @UseInterceptors(
    FileInterceptor('image', { // 'image' is the field name for the file in the multipart request
      storage: FilesService.prototype.multerStorage,
      fileFilter: FilesService.imageFileFilter,
      limits: { fileSize: 10 * 1024 * 1024 }, // 10 MB limit
    }),
  )
  async updateReport(
    @Param('id') id: string,
    @Body() updateData: Partial<{
      reportTitle: string;
      category: string;
      description: string;
      soilData: string; // Expect it as a string from form-data for update
      isResolved: boolean;
    }>,
    @UploadedFile() image?: Express.Multer.File, // Image is optional for update
  ): Promise<ReportDocument> {
    // --- FIX: Convert soilData string to boolean if provided in updateData ---
    const updatedBody: Partial<any> = { ...updateData }; // Create a mutable copy
    if (updatedBody.soilData !== undefined) {
      if (updatedBody.soilData === 'true') {
        updatedBody.soilData = true;
      } else if (updatedBody.soilData === 'false') {
        updatedBody.soilData = false;
      } else {
        throw new BadRequestException('soilData must be "true" or "false" (as strings) for update.');
      }
    }
    // --- End FIX ---

    return this.reportsService.updateReport(id, updatedBody, image);
  }

  /**
   * DELETE /reports/:id
   * Deletes a report by ID.
   */
  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT) // 204 No Content for successful deletion
  async deleteReport(@Param('id') id: string): Promise<void> {
    await this.reportsService.deleteReport(id);
  }
}