import { Controller, Get } from '@nestjs/common';

@Controller("users")
export class AppController {
  
  @Get()
  getUsers(): void {
    console.log("user access");
    // No return statement - browser gets empty response
  }
}