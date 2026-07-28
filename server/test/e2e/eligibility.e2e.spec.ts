/**
 * E2E test of the compliance catalogue endpoint.
 */
import { Test } from '@nestjs/testing';
import type { INestApplication } from '@nestjs/common';
import request from 'supertest';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { AppModule } from '../../src/app.module.js';

describe('GET /eligibility/adapters (e2e)', () => {
  let app: INestApplication;

  beforeAll(async () => {
    const moduleRef = await Test.createTestingModule({ imports: [AppModule] }).compile();
    app = moduleRef.createNestApplication();
    await app.init();
  });

  afterAll(async () => {
    await app.close();
  });

  it('publishes every adapter with its documented legal basis', async () => {
    const response = await request(app.getHttpServer()).get('/eligibility/adapters').expect(200);
    const ids = (response.body as Array<{ id: string }>).map((entry) => entry.id);
    expect(ids).toEqual(['user_owned_oauth', 'official_api', 'open_license', 'direct_file']);
    for (const entry of response.body as Array<{ legalBasis: string; officialEndpoint: string }>) {
      expect(entry.legalBasis.length).toBeGreaterThan(20);
      expect(entry.officialEndpoint.length).toBeGreaterThan(10);
    }
  });
});
