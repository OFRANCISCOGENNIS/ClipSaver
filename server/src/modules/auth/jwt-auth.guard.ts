/**
 * Bearer-token guard for authenticated routes.
 *
 * Responsibility: extract and verify the access JWT, attaching its claims
 * to the request as `request.user`. Routes without the guard stay public.
 */
import {
  CanActivate,
  Injectable,
  UnauthorizedException,
  type ExecutionContext,
} from '@nestjs/common';
import type { Request } from 'express';
import { AuthService, type AccessClaims } from './auth.service.js';

/** Request augmented by the guard. */
export interface AuthenticatedRequest extends Request {
  user: AccessClaims;
}

@Injectable()
export class JwtAuthGuard implements CanActivate {
  constructor(private readonly auth: AuthService) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const request = context.switchToHttp().getRequest<AuthenticatedRequest>();
    const header = request.headers.authorization ?? '';
    const [scheme, token] = header.split(' ');
    if (scheme !== 'Bearer' || !token) {
      throw new UnauthorizedException('Autenticação necessária.');
    }
    request.user = await this.auth.verifyAccessToken(token);
    return true;
  }
}
