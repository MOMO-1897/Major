// src/main.ts
import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { ValidationPipe } from '@nestjs/common';
import * as express from 'express';
import { join } from 'path';
import { NestExpressApplication } from '@nestjs/platform-express';
import * as session from 'express-session'; // Import the session package

async function bootstrap() {
  const app = await NestFactory.create<NestExpressApplication>(AppModule);

  // --- Session Middleware Configuration ---
  // This is the new part. It initializes the session object for every request.
  // The AdminController's @Session() decorator will now work correctly.
  app.use(
    session({
      secret: 'key', // IMPORTANT: Replace with a unique, secure string.
      resave: false,
      saveUninitialized: false,
      cookie: {
        maxAge: 3600000, // 1 hour (in milliseconds)
        // Set other cookie options as needed, e.g., 'secure: true' in production
      },
    }),
  );

  // This is the crucial part for reading form data from the login page.
  app.use(express.urlencoded({ extended: true }));

  // It's also good practice to include JSON body parsing for other API endpoints.
  app.use(express.json());

  app.useGlobalPipes(new ValidationPipe({
    transform: true,
    whitelist: true,
    forbidNonWhitelisted: true,
  }));

  // Set the base directory for EJS template files.
  app.setBaseViewsDir(join(__dirname, '..', 'src', 'admin', 'views'));
  app.setViewEngine('ejs');

  // Serve static files for the admin dashboard (e.g., CSS, JS, images)
  app.useStaticAssets(join(__dirname, '..', 'src', 'admin', 'public'), {
    prefix: '/admin',
  });

  // Serve static files from the 'uploads' directory (your existing code)
  app.use('/uploads', express.static(join(__dirname, '..', 'uploads')));

  await app.listen(3000, '0.0.0.0');
  console.log(`Application is running on: ${await app.getUrl()}`);
}
bootstrap();
