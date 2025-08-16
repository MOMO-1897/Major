// src/app.module.ts
import { Module, OnModuleInit } from '@nestjs/common';
import { AppController } from './app.controller';
import { UsersModule } from './users/users.module';
import { FilesModule } from './files/files.module';
import { AuthModule } from './auth/auth.module';
import { ReportsModule } from './reports/reports.module';
import { MongooseModule, InjectModel } from '@nestjs/mongoose';
import { ServeStaticModule } from '@nestjs/serve-static';
import { join } from 'path';
import * as mongoose from 'mongoose';
import { Role, RoleDocument, RoleSchema, RoleType } from './schemas/role.schema';
import { SpecialistProfile, SpecialistProfileDocument, SpecialistProfileSchema } from './schemas/specialist-profile.schema';
import { Model } from 'mongoose';
import { ConfigModule } from '@nestjs/config';
import { MapsModule } from './maps/maps.module';
import { AdminModule } from './admin/admin.module';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
    }),

    // --- Mongoose Database Connection ---
    MongooseModule.forRoot('mongodb://127.0.0.1:27017/krishicare_db'),

    // Register schemas here so they can be injected and used in AppModule's onModuleInit
    MongooseModule.forFeature([
      { name: Role.name, schema: RoleSchema },
      { name: SpecialistProfile.name, schema: SpecialistProfileSchema }, // Inject the SpecialistProfile schema
    ]),

    // Mongoose connection event listeners for logging
    (() => {
      const connection = mongoose.connection;
      connection.on('connected', () => console.log('[MongoDB] Connected to database!'));
      connection.on('error', (err) => console.error('[MongoDB] Connection error:', err));
      connection.on('disconnected', () => console.log('[MongoDB] Disconnected from database.'));
      return { module: MongooseModule };
    })(),

    // Core application modules
    UsersModule,
    FilesModule,
    AuthModule,
    ReportsModule,
    AdminModule,
    MapsModule,
    // Serve static files (e.g., uploaded profile pictures, certification images)
    ServeStaticModule.forRoot({
      rootPath: join(process.cwd(), 'uploads'),
      serveRoot: '/uploads',
    }),
  ],
  controllers: [AppController],
  providers: [],
})
export class AppModule implements OnModuleInit {
  constructor(
    @InjectModel(Role.name) private roleModel: Model<RoleDocument>,
    // Inject the Mongoose SpecialistProfile Model
    @InjectModel(SpecialistProfile.name) private specialistProfileModel: Model<SpecialistProfileDocument>,
  ) { }

  async onModuleInit() {
    console.log('[AppModule] Ensuring roles and specialist profiles are up-to-date...');
    try {
      // --- Roles Seeding Logic (Existing) ---
      const existingRoles = await this.roleModel.find({ name: { $in: [RoleType.FARMER, RoleType.SPECIALIST] } }).exec();
      const existingRoleNames = new Set(existingRoles.map(role => role.name));

      const rolesToInsert: { name: RoleType }[] = [];
      if (!existingRoleNames.has(RoleType.FARMER)) {
        rolesToInsert.push({ name: RoleType.FARMER });
      }
      if (!existingRoleNames.has(RoleType.SPECIALIST)) {
        rolesToInsert.push({ name: RoleType.SPECIALIST });
      }

      if (rolesToInsert.length > 0) {
        await this.roleModel.insertMany(rolesToInsert, { ordered: false });
        console.log(`[AppModule] Inserted new roles: ${rolesToInsert.map((r: { name: RoleType }) => r.name).join(', ')}`);
      } else {
        console.log('[AppModule] All required roles already exist.');
      }
      
      // --- Specialist Profile Migration Logic (New) ---
      // This will add the 'isVerified: false' field to all existing documents
      // that do not have this field. It's a safe and repeatable operation.
      const updateResult = await this.specialistProfileModel.updateMany(
        { isVerified: { $exists: false } }, // Find documents where the 'isVerified' field does not exist
        { $set: { isVerified: false } }     // Set the field to false
      );
      console.log(`[AppModule] Specialist profiles migration complete. Updated ${updateResult.modifiedCount} old documents.`);

      console.log('[AppModule] Database integrity check completed successfully.');

    } catch (error) {
      console.error('[AppModule] Error during database initialization or migration:', error);
      if (error.code === 11000) {
        console.warn('[AppModule] Encountered a duplicate key error, this is usually harmless during seeding.');
      } else {
        throw error;
      }
    }
  }
}
