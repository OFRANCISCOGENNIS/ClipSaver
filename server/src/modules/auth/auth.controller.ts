/**
 * HTTP surface of the auth module.
 *
 * Responsibility: validate bodies with zod, map service results to
 * responses, and expose the OpenAPI contract. Login/refresh are heavily
 * throttled (credential stuffing defense).
 */
import { Body, Controller, Get, HttpCode, Post, Req, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiOkResponse, ApiOperation, ApiTags } from '@nestjs/swagger';
import { Throttle } from '@nestjs/throttler';
import { z } from 'zod';
import { ZodValidationPipe } from '../../common/zod-validation.pipe.js';
import { AuthService, type TokenPair } from './auth.service.js';
import { JwtAuthGuard, type AuthenticatedRequest } from './jwt-auth.guard.js';

const credentialsSchema = z.object({
  email: z.string().email().max(320),
  // NIST-style: length over composition rules.
  password: z.string().min(10).max(128),
});

const refreshSchema = z.object({ refreshToken: z.string().min(32).max(512) });

type Credentials = z.infer<typeof credentialsSchema>;
type RefreshBody = z.infer<typeof refreshSchema>;

@ApiTags('auth')
@Controller('auth')
export class AuthController {
  constructor(private readonly auth: AuthService) {}

  @Post('register')
  @Throttle({ default: { limit: 5, ttl: 60_000 } })
  @ApiOperation({ summary: 'Cria uma conta' })
  register(
    @Body(new ZodValidationPipe(credentialsSchema)) body: Credentials,
  ): Promise<{ id: string; email: string }> {
    return this.auth.register(body.email, body.password);
  }

  @Post('login')
  @HttpCode(200)
  @Throttle({ default: { limit: 5, ttl: 60_000 } })
  @ApiOperation({ summary: 'Autentica e emite JWT (15min) + refresh token' })
  login(@Body(new ZodValidationPipe(credentialsSchema)) body: Credentials): Promise<TokenPair> {
    return this.auth.login(body.email, body.password);
  }

  @Post('refresh')
  @HttpCode(200)
  @Throttle({ default: { limit: 10, ttl: 60_000 } })
  @ApiOperation({ summary: 'Rotaciona o refresh token (reuso revoga a família)' })
  refresh(@Body(new ZodValidationPipe(refreshSchema)) body: RefreshBody): Promise<TokenPair> {
    return this.auth.refresh(body.refreshToken);
  }

  @Post('logout')
  @HttpCode(204)
  @ApiOperation({ summary: 'Revoga a família de tokens da sessão' })
  async logout(@Body(new ZodValidationPipe(refreshSchema)) body: RefreshBody): Promise<void> {
    await this.auth.logout(body.refreshToken);
  }

  @Get('me')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Identidade do usuário autenticado' })
  @ApiOkResponse({ description: 'Claims do token de acesso.' })
  me(@Req() request: AuthenticatedRequest): { id: string; email: string } {
    return { id: request.user.sub, email: request.user.email };
  }
}
