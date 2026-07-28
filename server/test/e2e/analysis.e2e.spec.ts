/**
 * E2E tests of the analysis endpoint: full Nest app, HTTP in/out, with a
 * deterministic probe (no real network) and in-memory cache.
 */
import { Test } from '@nestjs/testing';
import type { INestApplication } from '@nestjs/common';
import request from 'supertest';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { AppModule } from '../../src/app.module.js';
import { METADATA_PROBE, type MetadataProbe, type ProbeResult } from '../../src/modules/analysis/metadata-probe.js';

/** Probe fake keyed by hostname; counts calls to prove cache idempotency. */
class FakeProbe implements MetadataProbe {
  calls = 0;
  private readonly byHost = new Map<string, ProbeResult>();

  set(host: string, result: ProbeResult): void {
    this.byHost.set(host, result);
  }

  async probe(url: URL): Promise<ProbeResult> {
    this.calls += 1;
    const result = this.byHost.get(url.hostname);
    if (!result) throw new Error(`unexpected probe for ${url.hostname}`);
    return result;
  }
}

describe('POST /analysis (e2e)', () => {
  let app: INestApplication;
  const probe = new FakeProbe();

  beforeAll(async () => {
    probe.set('files.example.com', {
      contentType: 'video/mp4',
      paywalled: false,
      requiresAuthentication: false,
      drmDetected: false,
    });
    probe.set('cc.example.com', {
      contentType: 'text/html; charset=utf-8',
      title: 'Aula aberta',
      licenseMetadata: 'https://creativecommons.org/licenses/by/4.0/',
      paywalled: false,
      requiresAuthentication: false,
      drmDetected: false,
      directFileFormats: [{ id: 'v720', kind: 'video', container: 'mp4', height: 720 }],
    });
    probe.set('drm.example.com', {
      contentType: 'text/html',
      paywalled: false,
      requiresAuthentication: false,
      drmDetected: true,
    });

    const moduleRef = await Test.createTestingModule({ imports: [AppModule] })
      .overrideProvider(METADATA_PROBE)
      .useValue(probe)
      .compile();
    app = moduleRef.createNestApplication();
    await app.init();
  });

  afterAll(async () => {
    await app.close();
  });

  it('approves a direct media file', async () => {
    const response = await request(app.getHttpServer())
      .post('/analysis')
      .send({ url: 'https://files.example.com/talk.mp4' })
      .expect(200);
    expect(response.body.eligibility.eligible).toBe(true);
    expect(response.body.eligibility.source).toBe('direct_file');
    expect(response.body.cached).toBe(false);
  });

  it('approves CC-BY pages and carries title + restrictions', async () => {
    const response = await request(app.getHttpServer())
      .post('/analysis')
      .send({ url: 'https://cc.example.com/aula' })
      .expect(200);
    expect(response.body.title).toBe('Aula aberta');
    expect(response.body.eligibility.license).toBe('CC-BY-4.0');
    expect(response.body.eligibility.restrictions).toContain('atribuição obrigatória');
  });

  it('refuses DRM pages with an educational reason', async () => {
    const response = await request(app.getHttpServer())
      .post('/analysis')
      .send({ url: 'https://drm.example.com/filme' })
      .expect(200);
    expect(response.body.eligibility.eligible).toBe(false);
    expect(response.body.eligibility.reason).toContain('DRM');
  });

  it('serves repeat analyses from the idempotent cache (probe called once)', async () => {
    const before = probe.calls;
    const first = await request(app.getHttpServer())
      .post('/analysis')
      .send({ url: 'https://files.example.com/cache-me.mp4' })
      .expect(200);
    const second = await request(app.getHttpServer())
      .post('/analysis')
      .send({ url: 'https://files.example.com/cache-me.mp4' })
      .expect(200);
    expect(first.body.cached).toBe(false);
    expect(second.body.cached).toBe(true);
    expect(second.body.eligibility).toEqual(first.body.eligibility);
    expect(probe.calls - before).toBe(1);
  });

  it('refuses SSRF targets without probing', async () => {
    const before = probe.calls;
    const response = await request(app.getHttpServer())
      .post('/analysis')
      .send({ url: 'http://169.254.169.254/latest/meta-data' })
      .expect(200);
    expect(response.body.eligibility.eligible).toBe(false);
    expect(probe.calls).toBe(before);
  });

  it('rejects invalid bodies with field-level errors', async () => {
    const response = await request(app.getHttpServer())
      .post('/analysis')
      .send({ link: 'https://x.example' })
      .expect(400);
    expect(response.body.errors?.[0]?.path).toBe('url');
  });
});
