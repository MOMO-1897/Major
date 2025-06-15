// src/app.controller.ts
import { Controller, Get } from '@nestjs/common';

@Controller("users")
export class AppController {
  @Get()
  getUsers(): string {
    console.log("User access attempted on root path /users");
    return "User access granted from main controller!";
  }
}