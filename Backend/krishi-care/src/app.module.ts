// src/app.module.ts
import { Module, OnModuleInit } from '@nestjs/common';
import { AppController } from './app.controller';
import { UsersModule } from './users/users.module';
import { FilesModule } from './files/files.module';
import { AuthModule } from './auth/auth.module';
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
      // Upsert (update or insert) the FARMER role
      // $setOnInsert ensures these fields are only set if a new document is inserted
      // We no longer manually set createdAt/updatedAt here, Mongoose handles them due to { timestamps: true } in schema
      await this.roleModel.findOneAndUpdate(
        { name: RoleType.FARMER }, // Query to find if FARMER role exists
        { $setOnInsert: { name: RoleType.FARMER } }, // Fields to set if inserting new document
        { upsert: true, new: true, setDefaultsOnInsert: true } // upsert creates if not found; new returns modified document; setDefaultsOnInsert applies schema defaults
      );

      // Upsert (update or insert) the SPECIALIST role
      await this.roleModel.findOneAndUpdate(
        { name: RoleType.SPECIALIST }, // Query to find if SPECIALIST role exists
        { $setOnInsert: { name: RoleType.SPECIALIST } }, // Fields to set if inserting new document
        { upsert: true, new: true, setDefaultsOnInsert: true }
      );
      console.log('[AppModule] Roles ensured successfully in MongoDB.');
    } catch (error) {
      // Log any errors during the role seeding process
      console.error('[AppModule] Error during automatic role seeding for MongoDB:', error);
      // Depending on your production needs, you might re-throw or handle this error more gracefully
    }
  }
}
