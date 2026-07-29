/**
 * E2E tests of the probe endpoints: full Nest app, real HTTP, with the
 * indicator list overridden so a failing dependency can be simulated
 * without one being installed.
 */
import { Test } from '@nestjs/testing';
import type { INestApplication } from '@nestjs/common';
import request from 'supertest';
import { afterEach, describe, expect, it } from 'vitest';
import { AppModule } from '../../src/app.module.js';
import {
  HEALTH_INDICATORS,
  type HealthIndicator,
} from '../../src/modules/health/health-indicator.js';

/** Builds an app whose readiness sees exactly [indicators]. */
async function bootstrap(indicators: HealthIndicator[]): Promise<INestApplication> {
  const moduleRef = await Test.createTestingModule({ imports: [AppModule] })
    .overrideProvider(HEALTH_INDICATORS)
    .useValue(indicators)
    .compile();
  const app = moduleRef.createNestApplication();
  await app.init();
  return app;
}

describe('health probes (e2e)', () => {
  let app: INestApplication | undefined;

  afterEach(async () => {
    await app?.close();
    app = undefined;
  });

  it('GET /health/live returns 200 even when a dependency is down', async () => {
    app = await bootstrap([
      { name: 'redis', check: () => Promise.reject(new Error('fora do ar')) },
    ]);

    const response = await request(app.getHttpServer()).get('/health/live');

    expect(response.status).toBe(200);
    expect(response.body.status).toBe('ok');
  });

  it('GET /health/ready returns 200 when every dependency answers', async () => {
    app = await bootstrap([{ name: 'redis', check: () => Promise.resolve() }]);

    const response = await request(app.getHttpServer()).get('/health/ready');

    expect(response.status).toBe(200);
    expect(response.body).toMatchObject({
      status: 'ok',
      checks: [{ name: 'redis', healthy: true }],
    });
  });

  it('GET /health/ready returns 503 when a dependency is down', async () => {
    app = await bootstrap([
      { name: 'database', check: () => Promise.reject(new Error('conexão recusada')) },
    ]);

    const response = await request(app.getHttpServer()).get('/health/ready');

    // 503 is what removes the pod from the Service endpoints; a 500 would
    // be read as an application bug and trigger a restart instead.
    expect(response.status).toBe(503);
    expect(response.body.status).toBe('degraded');
    expect(response.body.checks[0]).toMatchObject({
      name: 'database',
      healthy: false,
      error: 'conexão recusada',
    });
  });

  it('probes are exempt from rate limiting', async () => {
    app = await bootstrap([]);
    const server = app.getHttpServer();

    // The default throttle is 30 requests per window; a probe every second
    // would trip it and take the whole deployment down.
    for (let i = 0; i < 40; i += 1) {
      // eslint-disable-next-line no-await-in-loop -- sequential on purpose:
      // the throttler counts requests, and parallel ones race the counter.
      const response = await request(server).get('/health/live');
      expect(response.status).toBe(200);
    }
  });
});
