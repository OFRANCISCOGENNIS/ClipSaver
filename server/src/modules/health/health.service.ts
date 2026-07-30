/**
 * Health aggregation.
 *
 * Responsibility: run every readiness indicator under a deadline and
 * combine the results. Two rules drive the design:
 *
 * 1. **Liveness never touches dependencies.** If a Redis outage failed
 *    liveness, Kubernetes would restart every pod at once — turning a
 *    recoverable dependency blip into a full outage. Liveness answers
 *    "is this process still able to serve?", which the reply itself
 *    proves.
 * 2. **Readiness has a deadline shorter than the probe's.** A hung TCP
 *    connect never rejects; without a timeout the probe would be killed
 *    by kubelet with no diagnosis. Timing out ourselves lets the payload
 *    name the dependency that stalled.
 */
import { Inject, Injectable } from '@nestjs/common';
import {
  HEALTH_INDICATORS,
  type HealthIndicator,
  type IndicatorResult,
} from './health-indicator.js';

/** Default per-indicator deadline; below the 3s probe timeout in k8s. */
export const DEFAULT_CHECK_TIMEOUT_MS = 2_000;

/** Nest injection token for the per-check deadline. */
export const HEALTH_CHECK_TIMEOUT_MS = Symbol('HEALTH_CHECK_TIMEOUT_MS');

/** Aggregate readiness payload. */
export interface ReadinessReport {
  /** `ok` only when every indicator is healthy. */
  readonly status: 'ok' | 'degraded';
  /** Per-dependency detail, in registration order. */
  readonly checks: readonly IndicatorResult[];
}

/** Liveness payload. */
export interface LivenessReport {
  readonly status: 'ok';
  /** Whole seconds since the process started, for restart-loop triage. */
  readonly uptimeSeconds: number;
}

@Injectable()
export class HealthService {
  private readonly startedAt = Date.now();

  constructor(
    @Inject(HEALTH_INDICATORS) private readonly indicators: readonly HealthIndicator[],
    @Inject(HEALTH_CHECK_TIMEOUT_MS) private readonly timeoutMs: number,
  ) {}

  /** Liveness: the process is running and the event loop is responsive. */
  live(): LivenessReport {
    return {
      status: 'ok',
      uptimeSeconds: Math.floor((Date.now() - this.startedAt) / 1000),
    };
  }

  /**
   * Readiness: every dependency answered. Indicators run concurrently —
   * serial checks would make the probe's latency the sum of all
   * dependencies, and readiness has to fit inside one probe interval.
   */
  async ready(): Promise<ReadinessReport> {
    const checks = await Promise.all(
      this.indicators.map((indicator) => this.runOne(indicator)),
    );
    return {
      status: checks.every((check) => check.healthy) ? 'ok' : 'degraded',
      checks,
    };
  }

  private async runOne(indicator: HealthIndicator): Promise<IndicatorResult> {
    const started = Date.now();
    let timer: ReturnType<typeof setTimeout> | undefined;
    try {
      await Promise.race([
        indicator.check(),
        new Promise<never>((_resolve, reject) => {
          timer = setTimeout(
            () => reject(new Error(`tempo esgotado após ${this.timeoutMs}ms`)),
            this.timeoutMs,
          );
        }),
      ]);
      return { name: indicator.name, healthy: true, durationMs: Date.now() - started };
    } catch (error) {
      return {
        name: indicator.name,
        healthy: false,
        durationMs: Date.now() - started,
        // Only the message: a driver error can carry the connection URL,
        // and this payload is reachable from outside the cluster.
        error: error instanceof Error ? error.message : String(error),
      };
    } finally {
      // Without this the losing timer keeps the process alive for up to
      // `timeoutMs` after every successful check — enough to make a
      // graceful shutdown look hung.
      if (timer !== undefined) clearTimeout(timer);
    }
  }
}
