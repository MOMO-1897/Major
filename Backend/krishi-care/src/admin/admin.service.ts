import { Injectable, Logger } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import * as bcrypt from 'bcrypt';

// Import the schemas and interfaces from the correct paths
import { User, UserDocument } from '../schemas/user.schema';
import { Role, RoleDocument } from '../schemas/role.schema';
import { FarmerProfile, FarmerProfileDocument } from '../schemas/farmer-profile.schema';
import { SpecialistProfile, SpecialistProfileDocument } from '../schemas/specialist-profile.schema';
import { Report, ReportDocument } from '../schemas/report.schema';

@Injectable()
export class AdminService {
  // Use a logger for better console output management
  private readonly logger = new Logger(AdminService.name);

  constructor(
    @InjectModel(User.name) private readonly userModel: Model<UserDocument>,
    @InjectModel(Role.name) private readonly roleModel: Model<RoleDocument>,
    @InjectModel(FarmerProfile.name) private readonly farmerProfileModel: Model<FarmerProfileDocument>,
    @InjectModel(SpecialistProfile.name) private readonly specialistProfileModel: Model<SpecialistProfileDocument>,
    @InjectModel(Report.name) private readonly reportModel: Model<ReportDocument>,
  ) {}

  /**
   * Validates a user's login credentials and checks if they have the 'ADMIN' role.
   * @param username The username of the user.
   * @param password The password provided by the user.
   * @returns A promise that resolves to the User document if login is successful and the user is an admin, otherwise null.
   */
  async validateAdminLogin(username: string, password: string): Promise<User | null> {
    const user = await this.userModel.findOne({ username }).populate('role').exec();

    if (!user) {
      return null;
    }

    const isPasswordCorrect = await bcrypt.compare(password, user.password);

    if (!isPasswordCorrect) {
      return null;
    }

    const userRole = (user.role as unknown as RoleDocument)?.name;

    if (userRole !== 'ADMIN') {
      return null;
    }

    return user;
  }

  /**
   * Finds and returns all users from the database.
   * @returns A promise that resolves to an array of User documents.
   */
  async findAllUsers(): Promise<User[]> {
    return this.userModel.find().populate('role').exec();
  }

  /**
   * Finds a single user by their ID.
   * @param id The ID of the user to find.
   * @returns A promise that resolves to a single User document or null if not found.
   */
  async findUserById(id: string): Promise<User | null> {
    return this.userModel.findById(id).populate('role').exec();
  }

  /**
   * Creates a new user in the database.
   * @param userData The data for the new user.
   * @returns A promise that resolves to the newly created User document.
   */
  async createUser(userData: any): Promise<User> {
    return this.userModel.create(userData);
  }

  /**
   * Deletes a user from the database by their ID.
   * @param id The ID of the user to delete.
   * @returns A promise that resolves to the deleted User document or null if not found.
   */
  async deleteUser(id: string): Promise<User | null> {
    return this.userModel.findByIdAndDelete(id).exec();
  }

  /**
   * Finds and returns all farmer profiles, populating the associated user data.
   * @returns A promise that resolves to an array of FarmerProfile documents.
   */
  async findAllFarmers(): Promise<FarmerProfile[]> {
    return this.farmerProfileModel.find().populate('userId').exec();
  }

  /**
   * Finds and returns all specialist profiles, populating the associated user data.
   * @returns A promise that resolves to an array of SpecialistProfile documents.
   */
  async findAllSpecialists(): Promise<SpecialistProfile[]> {
    return this.specialistProfileModel.find().populate('userId').exec();
  }

  /**
   * Finds and returns all specialist profiles that are NOT yet verified.
   * This replaces the old logic that used a 'status' field.
   * @returns A promise that resolves to an array of SpecialistProfile documents.
   */
  async findPendingSpecialists(): Promise<SpecialistProfile[]> {
    // FIX: Changed from { status: 'Pending' } to { isVerified: false }
    return this.specialistProfileModel.find({ isVerified: false }).populate('userId').exec();
  }

  /**
   * Verifies a specialist by their ID, setting their isVerified field to true.
   * @param id The ID of the specialist profile to verify.
   * @returns A promise that resolves to the updated SpecialistProfile document or null if not found.
   */
  async verifySpecialist(id: string): Promise<SpecialistProfile | null> {
    this.logger.log(`Attempting to verify specialist with ID: ${id}`);
    try {
      const specialist = await this.specialistProfileModel.findByIdAndUpdate(
        id,
        { $set: { isVerified: true } },
        { new: true } // Return the updated document
      ).exec();

      if (specialist) {
        this.logger.log(`Successfully verified specialist: ${id}`);
      } else {
        this.logger.warn(`Could not find specialist with ID: ${id}`);
      }

      return specialist;
    } catch (error) {
      this.logger.error(`Error verifying specialist ${id}:`, error.stack);
      return null;
    }
  }
  
  /**
   * Deletes a report from the database.
   * @param reportId The ID of the report to delete.
   * @returns A promise that resolves to the deleted Report document or null if not found.
   */
  async deleteReport(reportId: string): Promise<Report | null> {
      try {
          // Check if the ID is a valid ObjectId
          if (!Types.ObjectId.isValid(reportId)) {
              this.logger.error(`Invalid ObjectId format for reportId: ${reportId}`);
              return null;
          }
          this.logger.log(`Attempting to delete report with ID: ${reportId}`);
          const deletedReport = await this.reportModel.findByIdAndDelete(reportId).exec();
          
          if (deletedReport) {
              this.logger.log(`Successfully deleted report: ${reportId}`);
          } else {
              this.logger.warn(`Could not find report with ID: ${reportId}`);
          }
          
          return deletedReport;
      } catch (error) {
          this.logger.error(`Error deleting report ${reportId}:`, error.stack);
          return null;
      }
  }

  /**
   * Logs all specialist data to the console for inspection.
   * You can call this method from a controller or test function to see the output.
   */
  async logAllSpecialists(): Promise<void> {
    this.logger.log('Fetching and logging all specialist data...');
    try {
      const specialists = await this.findAllSpecialists();
      // Console.log the data so you can inspect it in your terminal
      this.logger.debug('Specialist Data:', specialists);
      this.logger.log(`Successfully fetched ${specialists.length} specialist(s).`);
    } catch (error) {
      this.logger.error('Error fetching specialist data:', error);
    }
  }

  /**
   * Fetches all the data required for the admin dashboard from the database.
   * @returns An object containing counts and recent reports.
   */
  async getDashboardData() {
    const totalFarmers = await this.farmerProfileModel.countDocuments().exec();
    const totalSpecialists = await this.specialistProfileModel.countDocuments().exec();
    // FIX: Changed from { status: 'Pending' } to { isVerified: false }
    const pendingSpecialists = await this.specialistProfileModel.countDocuments({ isVerified: false }).exec();

    const recentReports = await this.reportModel.find()
      .populate('userId', 'fullName profilePictureUrl')
      .sort({ createdAt: -1 })
      .limit(5)
      .exec();

    const reportsWithBadges = recentReports.map(report => {
      const farmer = report.userId as unknown as UserDocument;
      return {
        _id: report._id, // Add the report ID for deletion
        farmerName: farmer?.fullName || 'N/A',
        farmerPhoto: farmer?.profilePictureUrl || 'https://placehold.co/40x40/E5E7EB/1F2937?text=U',
        title: report.reportTitle,
        category: report.category,
        description: report.description,
        imageLink: report.imageUrl,
        categoryBadge: this.getCategoryBadgeColor(report.category),
      };
    });

    return {
      counts: {
        farmers: totalFarmers,
        specialists: totalSpecialists,
        pending: pendingSpecialists,
      },
      reports: reportsWithBadges,
    };
  }

  /**
   * Helper function to retrieve a role's ID from the database by name.
   * It returns the ID as a string, or null if the role is not found.
   */
  private async getRoleId(roleName: string): Promise<string | null> {
    const role = await this.roleModel.findOne({ name: roleName }).exec();
    if (role && role._id) {
      return role._id.toString();
    }
    return null;
  }

  /**
   * Helper function to map report categories to Bootstrap badge classes.
   */
  private getCategoryBadgeColor(category: string): string {
    switch (category.toLowerCase()) {
      case 'crop':
        return 'bg-danger';
      case 'soil':
        return 'bg-primary';
      case 'pest':
        return 'bg-warning';
      case 'disease':
        return 'bg-success';
      default:
        return 'bg-secondary';
    }
  }
}
