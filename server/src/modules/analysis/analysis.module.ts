/**
 * Analysis module wiring.
 *
 * Responsibility: bind the ports to their implementations according to
 * the environment — Redis-backed cache/queue when REDIS_URL is set,
 * in-memory otherwise (tests and local dev). The service and controller
 * never know which flavor they got.
 */
import { Module } from '@nestjs/common';
import { Redis } from 'ioredis';
import { ENV, type Env } from '../../config/env.js';
import { EligibilityModule } from '../eligibility/eligibility.module.js';
import { ANALYSIS_CACHE, InMemoryAnalysisCache } from './analysis-cache.js';
import { ANALYSIS_EXECUTOR, InlineAnalysisExecutor } from './analysis-executor.js';
import { AnalysisController } from './analysis.controller.js';
import { ANALYSIS_CACHE_TTL, AnalysisService } from './analysis.service.js';
import { BullMqAnalysisExecutor } from './bullmq-analysis-executor.js';
import { HttpMetadataProbe } from './http-metadata-probe.js';
import { METADATA_PROBE } from './metadata-probe.js';
import { RedisAnalysisCache } from './redis-analysis-cache.js';

/** Shared Redis connection token (also used by future modules). */
export const REDIS = Symbol('REDIS');

@Module({
  imports: [EligibilityModule],
  controllers: [AnalysisController],
  providers: [
    AnalysisService,
    {
      provide: REDIS,
      inject: [ENV],
      useFactory: (env: Env) => (env.REDIS_URL ? new Redis(env.REDIS_URL) : null),
    },
    {
      provide: ANALYSIS_CACHE_TTL,
      inject: [ENV],
      useFactory: (env: Env) => env.ANALYSIS_CACHE_TTL_SECONDS,
    },
    {
      provide: METADATA_PROBE,
      // Node 20+ global fetch; tests override this provider with fakes.
      useValue: new HttpMetadataProbe((url, init) => fetch(url, init)),
    },
    {
      provide: ANALYSIS_CACHE,
      inject: [REDIS],
      useFactory: (redis: Redis | null) =>
        redis ? new RedisAnalysisCache(redis) : new InMemoryAnalysisCache(),
    },
    {
      provide: ANALYSIS_EXECUTOR,
      inject: [REDIS, AnalysisService],
      useFactory: (redis: Redis | null, service: AnalysisService) =>
        redis ? new BullMqAnalysisExecutor(redis, service) : new InlineAnalysisExecutor(service),
    },
  ],
  // REDIS is exported so the readiness probe checks the same connection
  // the queue uses, instead of opening a second one that can be healthy
  // while the real pool is not.
  exports: [AnalysisService, REDIS],
})
export class AnalysisModule {}
