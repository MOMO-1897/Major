// src/main.ts
import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { ValidationPipe } from '@nestjs/common';
import { NestExpressApplication } from '@nestjs/platform-express'; // Import this
import { join } from 'path'; // Import join from 'path'

async function bootstrap() {
  const app = await NestFactory.create<NestExpressApplication>(AppModule); // Specify NestExpressApplication
  app.enableCors(); // If you have a frontend on a different origin
  app.useGlobalPipes(new ValidationPipe({ whitelist: true, transform: true })); // Keep your global pipes

  // Configure serving static files (uploaded images)
  // 'uploads' will be the directory where images are saved
  // You can access them via http://localhost:3000/uploads/your-image.jpg
  app.useStaticAssets(join(__dirname, '..', 'uploads'), {
    prefix: '/uploads/', // The URL prefix to access static files
  });

  await app.listen(3000);
  console.log(`Application is running on: ${await app.getUrl()}`);
}
bootstrap();