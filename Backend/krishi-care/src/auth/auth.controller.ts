// src/auth/auth.controller.ts
import { Controller, Request, Post, UseGuards, Body, HttpStatus, HttpCode } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { AuthService } from './auth.service';

@Controller('auth')
export class AuthController {
  constructor(private authService: AuthService) {}

  @HttpCode(HttpStatus.OK)
  @UseGuards(AuthGuard('local'))
  @Post('login')
  async login(@Request() req) {
    // The AuthGuard('local') already validates the username and password from req.body
    // and attaches the validated user (without password) to req.user.
    return this.authService.login(req.user);
  }
}