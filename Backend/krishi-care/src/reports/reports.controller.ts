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
  Request,
  UnauthorizedException,
  Patch,
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
  ) { }

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
    @Request() req,
    @Body() reportData: {
      reportTitle: string;
      category: string;
      description: string;
      soilData: string;
      farmLocation: string;
    },
    @UploadedFile() image: Express.Multer.File,
  ): Promise<ReportDocument> {
    if (!image) {
      throw new BadRequestException('Report image file is required.');
    }

    const userId = req.headers['user-id'];
    console.log(userId);
    if (!userId) {
      throw new UnauthorizedException('User ID not found in request.');
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
      { ...reportData, soilData: parsedSoilData, userId }, // Override soilData with boolean
      image
    );
  }

  /**
   * GET /reports
   * Retrieves all reports.
   */
  @Get()
  async findAllReports(@Request() req): Promise<ReportDocument[]> {
    const userId = req.headers['user-id'];
    console.log(userId);

    return this.reportsService.findAllReports(userId);
  }


  @Get('specialists')
  async findAllReportsForSpecialist(): Promise<ReportDocument[]> {
    return this.reportsService.findAllReportsSpecialist();
  }

  @Get('location')
  async findReportsByLocation(@Request() req): Promise<ReportDocument[]> {
    const location = req.headers['location'];
    console.log(location);

    return this.reportsService.findLocalReports(location);
  }

  @Get('schedule')
  async findReportsBySchedule(@Request() req): Promise<ReportDocument[]> {
    const id = req.headers['specialist-id'];
    console.log(id);

    return this.reportsService.findAllScheduledReports(id);
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

  @Patch()
  async updateReport(
    @Request() req,
    @Body() updateData: Partial<{
      specialistId: string;
      status: string;
      specialistSummary: string;
    }>,
  ): Promise<ReportDocument> {

    const reportId = req.headers['report-id'];

    if (!reportId) {
      throw BadRequestException
    }

    return this.reportsService.updateReport(reportId, updateData);
  }

  @Patch('visit')
  async updateReportVisit(
    @Request() req,
    @Body() updateData: Partial<{
      scheduleDate: string;
      scheduleTime: string;
      fee: string;
    }>,
  ): Promise<ReportDocument> {

    const reportId = req.headers['report-id'];

    if (!reportId) {
      throw BadRequestException
    }

    return this.reportsService.updateReportAfterVisit(reportId, updateData);
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
