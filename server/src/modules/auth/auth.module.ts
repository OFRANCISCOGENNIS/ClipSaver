/**
 * Auth module wiring. Phase 2 binds the in-memory repositories by
 * default; the Prisma implementations are swapped in via the DATABASE_URL
 * environment (see prisma-repositories.ts) once migrations run.
 */
import { Module } from '@nestjs/common';
import { JwtModule } from '@nestjs/jwt';
import { ENV, type Env } from '../../config/env.js';
import { AuthController } from './auth.controller.js';
import { AuthService } from './auth.service.js';
import {
  InMemoryRefreshTokensRepository,
  InMemoryUsersRepository,
} from './in-memory-repositories.js';
import { JwtAuthGuard } from './jwt-auth.guard.js';
import { REFRESH_TOKENS_REPOSITORY, USERS_REPOSITORY } from './ports.js';
import { PrismaRefreshTokensRepository, PrismaUsersRepository, createPrismaClient } from './prisma-repositories.js';

@Module({
  imports: [JwtModule.register({})],
  controllers: [AuthController],
  providers: [
    AuthService,
    JwtAuthGuard,
    {
      provide: USERS_REPOSITORY,
      inject: [ENV],
      useFactory: async (env: Env) =>
        env.DATABASE_URL
          ? new PrismaUsersRepository(await createPrismaClient(env.DATABASE_URL))
          : new InMemoryUsersRepository(),
    },
    {
      provide: REFRESH_TOKENS_REPOSITORY,
      inject: [ENV],
      useFactory: async (env: Env) =>
        env.DATABASE_URL
          ? new PrismaRefreshTokensRepository(await createPrismaClient(env.DATABASE_URL))
          : new InMemoryRefreshTokensRepository(),
    },
  ],
  exports: [AuthService, JwtAuthGuard],
})
export class AuthModule {}
