import { Injectable, CanActivate, ExecutionContext } from '@nestjs/common';
import { Request } from 'express';

/**
 * Custom request interface to add the session property.
 * This resolves the TypeScript error 'Property session does not exist'.
 */
interface RequestWithSession extends Request {
  session: any;
}

@Injectable()
export class SessionGuard implements CanActivate {
  canActivate(context: ExecutionContext): boolean {
    const request: RequestWithSession = context.switchToHttp().getRequest();
    // Check if the user is authenticated by looking for a userId in the session
    return !!request.session.userId;
  }
}
