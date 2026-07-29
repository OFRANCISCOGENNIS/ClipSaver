/**
 * Health module wiring.
 *
 * Responsibility: register one indicator per dependency the deployment
 * actually has. An environment without REDIS_URL or DATABASE_URL runs on
 * the in-memory ports, so it has nothing external to check — readiness
 * with an empty indicator list is legitimately `ok`, not a blind pass.
 */
import { Module } from '@nestjs/common';
import type { Redis } from 'ioredis';
import { ENV, type Env } from '../../config/env.js';
import { createPrismaClient } from '../auth/prisma-repositories.js';
import { AnalysisModule, REDIS } from '../analysis/analysis.module.js';
import {
  HEALTH_INDICATORS,
  type HealthIndicator,
  PrismaIndicator,
  RedisIndicator,
} from './health-indicator.js';
import { HealthController } from './health.controller.js';
import {
  DEFAULT_CHECK_TIMEOUT_MS,
  HEALTH_CHECK_TIMEOUT_MS,
  HealthService,
} from './health.service.js';

@Module({
  imports: [AnalysisModule],
  controllers: [HealthController],
  providers: [
    HealthService,
    { provide: HEALTH_CHECK_TIMEOUT_MS, useValue: DEFAULT_CHECK_TIMEOUT_MS },
    {
      provide: HEALTH_INDICATORS,
      inject: [ENV, REDIS],
      useFactory: async (env: Env, redis: Redis | null): Promise<HealthIndicator[]> => {
        const indicators: HealthIndicator[] = [];
        // Reuses the connection the analysis queue already owns: a probe
        // on its own socket would report healthy while the pool the app
        // actually uses is exhausted.
        if (redis) indicators.push(new RedisIndicator(redis));
        if (env.DATABASE_URL) {
          indicators.push(new PrismaIndicator(await createPrismaClient(env.DATABASE_URL)));
        }
        return indicators;
      },
    },
  ],
})
export class HealthModule {}
