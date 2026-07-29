/**
 * Root module: validated env, global rate limiting and the feature
 * modules (eligibility, analysis, auth, health).
 */
import { Module } from '@nestjs/common';
import { APP_GUARD } from '@nestjs/core';
import { ThrottlerGuard, ThrottlerModule } from '@nestjs/throttler';
import { ENV, type Env } from './config/env.js';
import { EnvModule } from './config/env.module.js';
import { AnalysisModule } from './modules/analysis/analysis.module.js';
import { AuthModule } from './modules/auth/auth.module.js';
import { EligibilityModule } from './modules/eligibility/eligibility.module.js';
import { HealthModule } from './modules/health/health.module.js';

@Module({
  imports: [
    EnvModule,
    ThrottlerModule.forRootAsync({
      imports: [EnvModule],
      inject: [ENV],
      useFactory: (env: Env) => ({
        throttlers: [{ ttl: env.THROTTLE_TTL_SECONDS * 1000, limit: env.THROTTLE_LIMIT }],
      }),
    }),
    EligibilityModule,
    AnalysisModule,
    AuthModule,
    HealthModule,
  ],
  providers: [{ provide: APP_GUARD, useClass: ThrottlerGuard }],
})
export class AppModule {}
