// src/app.module.ts
import { Module, OnModuleInit } from '@nestjs/common';
import { AppController } from './app.controller';
import { UsersModule } from './users/users.module';
import { FilesModule } from './files/files.module';
import { AuthModule } from './auth/auth.module';
import { ReportsModule } from './reports/reports.module'; // Ensure ReportsModule is imported
import { MongooseModule, InjectModel } from '@nestjs/mongoose';
import { ServeStaticModule } from '@nestjs/serve-static';
import { join } from 'path';
import * as mongoose from 'mongoose';
import { Role, RoleDocument, RoleSchema, RoleType } from './schemas/role.schema';
import { Model } from 'mongoose';

@Module({
  imports: [
    // --- Mongoose Database Connection ---
    // Hardcoded connection string for local MongoDB
    // WARNING: Not suitable for production. Use environment variables for secure credentials.
    MongooseModule.forRoot('mongodb://localhost:27017/krishicare_db'),

    // Register Role schema here so it can be injected and used in AppModule's onModuleInit
    MongooseModule.forFeature([
      { name: Role.name, schema: RoleSchema },
    ]),

    // Mongoose connection event listeners for logging
    (() => {
      const connection = mongoose.connection;
      connection.on('connected', () => console.log('[MongoDB] Connected to database!'));
      connection.on('error', (err) => console.error('[MongoDB] Connection error:', err));
      connection.on('disconnected', () => console.log('[MongoDB] Disconnected from database.'));
      return { module: MongooseModule }; // Must return the MongooseModule to be valid in imports
    })(),

    // Core application modules
    UsersModule,
    FilesModule,
    AuthModule,
    ReportsModule, // Ensure ReportsModule is included here

    // Serve static files (e.g., uploaded profile pictures, certification images)
    ServeStaticModule.forRoot({
      rootPath: join(process.cwd(), 'uploads'), // Path to your local 'uploads' directory
      serveRoot: '/uploads', // The URL path prefix where files will be accessible (e.g., http://localhost:3000/uploads/image.jpg)
    }),
  ],
  controllers: [AppController],
  providers: [], // No global providers needed here beyond those exported by imported modules
})
export class AppModule implements OnModuleInit {
  constructor(
    // Inject the Mongoose Role Model to perform seeding operations
    @InjectModel(Role.name) private roleModel: Model<RoleDocument>,
  ) {}

  /**
   * onModuleInit hook is called once all modules have been initialized.
   * This is used to programmatically seed the default roles (FARMER, SPECIALIST)
   * into the MongoDB database on application startup.
   */
  async onModuleInit() {
    console.log('[AppModule] Ensuring roles exist in MongoDB...');
    try {
      // Find existing roles to avoid duplicate inserts
      const existingRoles = await this.roleModel.find({ name: { $in: [RoleType.FARMER, RoleType.SPECIALIST] } }).exec();
      const existingRoleNames = new Set(existingRoles.map(role => role.name));

      // Explicitly type rolesToInsert to avoid 'never[]' inference
      const rolesToInsert: { name: RoleType }[] = []; // FIX: Added explicit type

      // Check if FARMER role is missing and add to array if so
      if (!existingRoleNames.has(RoleType.FARMER)) {
        rolesToInsert.push({ name: RoleType.FARMER });
      }
      // Check if SPECIALIST role is missing and add to array if so
      if (!existingRoleNames.has(RoleType.SPECIALIST)) {
        rolesToInsert.push({ name: RoleType.SPECIALIST });
      }

      // If there are roles to insert, perform the insertion
      if (rolesToInsert.length > 0) {
        await this.roleModel.insertMany(rolesToInsert, { ordered: false }); // ordered: false allows inserting remaining documents even if one fails
        // FIX: Ensure 'r' is typed correctly in map function
        console.log(`[AppModule] Inserted new roles: ${rolesToInsert.map((r: { name: RoleType }) => r.name).join(', ')}`);
      } else {
        console.log('[AppModule] All required roles already exist.');
      }

      console.log('[AppModule] Roles ensured successfully in MongoDB.');
    } catch (error) {
      // Log any errors during the role seeding process
      console.error('[AppModule] Error during automatic role seeding for MongoDB:', error);
      // For unique constraint errors (code 11000), it means another process might have inserted it concurrently.
      // This is usually harmless for seeding.
      if (error.code === 11000) {
        console.warn('[AppModule] Role seeding encountered a duplicate key error, likely due to concurrent insert. This is usually harmless.');
      } else {
        // Re-throw other unexpected errors to ensure they are noticed
        throw error;
      }
    }
  }
}
