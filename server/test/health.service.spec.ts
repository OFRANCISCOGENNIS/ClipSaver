/**
 * Unit tests for health aggregation: the deadline, the failure payload
 * and the rule that liveness must not depend on anything external.
 */
import { describe, expect, it, vi } from 'vitest';
import {
  PrismaIndicator,
  RedisIndicator,
  type HealthIndicator,
} from '../src/modules/health/health-indicator.js';
import { HealthService } from '../src/modules/health/health.service.js';

/** Indicator whose outcome the test controls. */
function indicator(
  name: string,
  behavior: () => Promise<void>,
): HealthIndicator {
  return { name, check: behavior };
}

const ok = (name: string) => indicator(name, () => Promise.resolve());
const failing = (name: string, message: string) =>
  indicator(name, () => Promise.reject(new Error(message)));
const hanging = (name: string) => indicator(name, () => new Promise<void>(() => {}));

describe('HealthService', () => {
  it('reports ok when every indicator answers', async () => {
    const service = new HealthService([ok('redis'), ok('database')], 100);

    const report = await service.ready();

    expect(report.status).toBe('ok');
    expect(report.checks.map((check) => check.name)).toEqual(['redis', 'database']);
    expect(report.checks.every((check) => check.healthy)).toBe(true);
  });

  it('reports degraded and names the failing dependency', async () => {
    const service = new HealthService(
      [ok('redis'), failing('database', 'conexão recusada')],
      100,
    );

    const report = await service.ready();

    expect(report.status).toBe('degraded');
    const database = report.checks.find((check) => check.name === 'database');
    expect(database?.healthy).toBe(false);
    expect(database?.error).toBe('conexão recusada');
    // The healthy one still reports — an operator needs to know which
    // dependency is fine, not just that something broke.
    expect(report.checks.find((check) => check.name === 'redis')?.healthy).toBe(true);
  });

  it('gives up on a hung dependency instead of hanging the probe', async () => {
    const service = new HealthService([hanging('redis')], 20);

    const report = await service.ready();

    expect(report.status).toBe('degraded');
    expect(report.checks[0]?.error).toContain('tempo esgotado');
  });

  it('runs indicators concurrently, not one after another', async () => {
    const slow = (name: string) =>
      indicator(name, () => new Promise<void>((resolve) => setTimeout(resolve, 40)));
    const service = new HealthService([slow('a'), slow('b'), slow('c')], 200);

    const started = Date.now();
    const report = await service.ready();
    const elapsed = Date.now() - started;

    expect(report.status).toBe('ok');
    // Serial execution would take ~120ms; the deadline is per indicator,
    // so a serial implementation would also blow past a tight probe.
    expect(elapsed).toBeLessThan(110);
  });

  it('does not leave the timeout timer pending after a fast check', async () => {
    // A timer left armed keeps the event loop alive; with a long deadline
    // that delays shutdown well past the termination grace period.
    const clear = vi.spyOn(globalThis, 'clearTimeout');
    const service = new HealthService([ok('redis')], 60_000);

    await service.ready();

    expect(clear).toHaveBeenCalled();
    clear.mockRestore();
  });

  it('liveness answers without consulting any indicator', () => {
    let consulted = false;
    const service = new HealthService(
      [
        indicator('redis', () => {
          consulted = true;
          return Promise.reject(new Error('fora do ar'));
        }),
      ],
      100,
    );

    const report = service.live();

    // The whole point: a dependency outage must not restart every pod.
    expect(report.status).toBe('ok');
    expect(consulted).toBe(false);
    expect(report.uptimeSeconds).toBeGreaterThanOrEqual(0);
  });

  it('readiness with no dependencies configured is ok', async () => {
    const service = new HealthService([], 100);

    const report = await service.ready();

    expect(report).toEqual({ status: 'ok', checks: [] });
  });
});

describe('RedisIndicator', () => {
  it('accepts PONG', async () => {
    await expect(
      new RedisIndicator({ ping: () => Promise.resolve('PONG') }).check(),
    ).resolves.toBeUndefined();
  });

  it('rejects anything else — a proxy answering is not Redis', async () => {
    await expect(
      new RedisIndicator({ ping: () => Promise.resolve('OK') }).check(),
    ).rejects.toThrow(/resposta inesperada/);
  });

  it('propagates a connection error', async () => {
    await expect(
      new RedisIndicator({ ping: () => Promise.reject(new Error('ECONNREFUSED')) }).check(),
    ).rejects.toThrow('ECONNREFUSED');
  });
});

describe('PrismaIndicator', () => {
  it('issues a single round-trip query', async () => {
    const queries: string[] = [];
    const indicator = new PrismaIndicator({
      $queryRaw: (strings: TemplateStringsArray) => {
        queries.push(strings.join('?'));
        return Promise.resolve([{ '?column?': 1 }]);
      },
    });

    await indicator.check();

    expect(queries).toEqual(['SELECT 1']);
  });

  it('propagates a database error', async () => {
    const indicator = new PrismaIndicator({
      $queryRaw: () => Promise.reject(new Error('terminating connection')),
    });

    await expect(indicator.check()).rejects.toThrow('terminating connection');
  });
});
