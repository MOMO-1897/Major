// src/app.controller.ts
import { Controller, Get } from '@nestjs/common';

@Controller("users") // This controller handles requests to the /users path
export class AppController { // You might want to rename this to UsersController for clarity
  
  @Get() // This method handles GET requests to /users
  getUsers(): string { // Changed return type to string, or you can use `any` or an interface
    console.log("user access");
    return "User access granted!"; // Add a return statement here
  }
}