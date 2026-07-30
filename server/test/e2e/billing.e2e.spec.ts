/**
 * E2E tests of the billing endpoints: full Nest app, real HTTP, with the
 * verifier list overridden so no store is contacted.
 */
import { Test } from '@nestjs/testing';
import type { INestApplication } from '@nestjs/common';
import request from 'supertest';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { AppModule } from '../../src/app.module.js';
import {
  RECEIPT_VERIFIERS,
  ReceiptRejectedError,
  type ReceiptVerifier,
} from '../../src/modules/billing/domain/receipt-verifier.js';

/** Verifier that accepts exactly one receipt string. */
const fakeStripe: ReceiptVerifier = {
  provider: 'stripe',
  verify: async (token) => {
    if (token !== 'sub_valido') {
      throw new ReceiptRejectedError('Stripe recusou o recibo.', 'stripe');
    }
    return {
      provider: 'stripe',
      transactionId: 'sub_valido',
      productId: 'price_premium',
      expiresAt: new Date(Date.now() + 86_400_000),
      autoRenewing: true,
    };
  },
};

describe('billing (e2e)', () => {
  let app: INestApplication;
  let bearer: string;

  beforeAll(async () => {
    const moduleRef = await Test.createTestingModule({ imports: [AppModule] })
      .overrideProvider(RECEIPT_VERIFIERS)
      .useValue([fakeStripe])
      .compile();
    app = moduleRef.createNestApplication();
    await app.init();

    const credentials = { email: 'ana@example.com', password: 'correta-e-longa-123' };
    await request(app.getHttpServer()).post('/auth/register').send(credentials);
    const login = await request(app.getHttpServer())
      .post('/auth/login')
      .send(credentials);
    bearer = `Bearer ${login.body.accessToken}`;
  });

  afterAll(async () => {
    await app.close();
  });

  it('requires authentication — an entitlement belongs to an account', async () => {
    const response = await request(app.getHttpServer()).get('/billing/status');
    expect(response.status).toBe(401);
  });

  it('starts free', async () => {
    const response = await request(app.getHttpServer())
      .get('/billing/status')
      .set('Authorization', bearer);
    expect(response.status).toBe(200);
    expect(response.body).toMatchObject({ plan: 'free', inGracePeriod: false });
  });

  it('validates the body shape', async () => {
    const response = await request(app.getHttpServer())
      .post('/billing/redeem')
      .set('Authorization', bearer)
      .send({ provider: 'lojinha', receipt: 'x' });
    expect(response.status).toBe(400);
  });

  it('a store-rejected receipt is 422 and grants nothing', async () => {
    const response = await request(app.getHttpServer())
      .post('/billing/redeem')
      .set('Authorization', bearer)
      .send({ provider: 'stripe', receipt: 'sub_falsificado' });
    expect(response.status).toBe(422);

    const status = await request(app.getHttpServer())
      .get('/billing/status')
      .set('Authorization', bearer);
    expect(status.body.plan).toBe('free');
  });

  it('a verified receipt flips the plan to premium', async () => {
    const redeem = await request(app.getHttpServer())
      .post('/billing/redeem')
      .set('Authorization', bearer)
      .send({ provider: 'stripe', receipt: 'sub_valido' });
    expect(redeem.status).toBe(201);
    expect(redeem.body.plan).toBe('premium');

    const status = await request(app.getHttpServer())
      .get('/billing/status')
      .set('Authorization', bearer);
    expect(status.body.plan).toBe('premium');
    expect(status.body.productId).toBe('price_premium');
  });

  it('an unconfigured provider is refused', async () => {
    const response = await request(app.getHttpServer())
      .post('/billing/redeem')
      .set('Authorization', bearer)
      .send({ provider: 'google', receipt: 'algum-token' });
    expect(response.status).toBe(422);
  });
});
