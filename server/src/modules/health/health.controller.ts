/**
 * Probe endpoints consumed by Kubernetes and by the deploy smoke test.
 *
 * Responsibility: translate the aggregate health into a status code. The
 * routes are exempt from rate limiting — throttling a probe would make
 * the orchestrator evict healthy pods under load, which is exactly when
 * evicting them is worst.
 */
import { Controller, Get, HttpCode, Res } from '@nestjs/common';
import { SkipThrottle } from '@nestjs/throttler';
import { ApiOperation, ApiResponse, ApiTags } from '@nestjs/swagger';
import type { Response } from 'express';
import {
  HealthService,
  type LivenessReport,
  type ReadinessReport,
} from './health.service.js';

@ApiTags('health')
@SkipThrottle()
@Controller('health')
export class HealthController {
  constructor(private readonly health: HealthService) {}

  @Get('live')
  @HttpCode(200)
  @ApiOperation({ summary: 'Liveness: o processo está de pé (não checa dependências)' })
  @ApiResponse({ status: 200, description: 'Processo vivo.' })
  live(): LivenessReport {
    return this.health.live();
  }

  @Get('ready')
  @ApiOperation({ summary: 'Readiness: dependências alcançáveis' })
  @ApiResponse({ status: 200, description: 'Pronto para receber tráfego.' })
  @ApiResponse({ status: 503, description: 'Alguma dependência está fora.' })
  async ready(@Res({ passthrough: true }) response: Response): Promise<ReadinessReport> {
    const report = await this.health.ready();
    // 503 (not 500): "not ready yet", which is what makes kubelet pull the
    // pod out of the Service endpoints instead of restarting it.
    response.status(report.status === 'ok' ? 200 : 503);
    return report;
  }
}
