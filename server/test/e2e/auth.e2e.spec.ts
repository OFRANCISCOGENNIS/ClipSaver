/**
 * E2E tests of the auth lifecycle: register → login → protected route →
 * refresh rotation → reuse detection (family revocation) → logout.
 */
import { Test } from '@nestjs/testing';
import type { INestApplication } from '@nestjs/common';
import request from 'supertest';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { AppModule } from '../../src/app.module.js';

const credentials = { email: 'ana@example.com', password: 'correta-e-longa-123' };

describe('auth lifecycle (e2e)', () => {
  let app: INestApplication;

  beforeAll(async () => {
    const moduleRef = await Test.createTestingModule({ imports: [AppModule] }).compile();
    app = moduleRef.createNestApplication();
    await app.init();
  });

  afterAll(async () => {
    await app.close();
  });

  it('registers, refuses duplicates and weak passwords', async () => {
    const created = await request(app.getHttpServer())
      .post('/auth/register')
      .send(credentials)
      .expect(201);
    expect(created.body.email).toBe(credentials.email);
    expect(created.body.passwordHash).toBeUndefined();

    await request(app.getHttpServer()).post('/auth/register').send(credentials).expect(409);
    await request(app.getHttpServer())
      .post('/auth/register')
      .send({ email: 'x@example.com', password: 'curta' })
      .expect(400);
  });

  it('logs in with valid credentials only', async () => {
    await request(app.getHttpServer())
      .post('/auth/login')
      .send({ ...credentials, password: 'senha-errada-123' })
      .expect(401);

    const login = await request(app.getHttpServer())
      .post('/auth/login')
      .send(credentials)
      .expect(200);
    expect(login.body.accessToken).toBeTruthy();
    expect(login.body.refreshToken).toBeTruthy();
    expect(login.body.expiresIn).toBe(15 * 60);
  });

  it('guards protected routes and accepts valid bearer tokens', async () => {
    await request(app.getHttpServer()).get('/auth/me').expect(401);
    await request(app.getHttpServer())
      .get('/auth/me')
      .set('Authorization', 'Bearer invalido')
      .expect(401);

    const login = await request(app.getHttpServer())
      .post('/auth/login')
      .send(credentials)
      .expect(200);
    const me = await request(app.getHttpServer())
      .get('/auth/me')
      .set('Authorization', `Bearer ${login.body.accessToken}`)
      .expect(200);
    expect(me.body.email).toBe(credentials.email);
  });

  it('rotates refresh tokens and revokes the family on reuse', async () => {
    const login = await request(app.getHttpServer())
      .post('/auth/login')
      .send(credentials)
      .expect(200);
    const firstRefresh = login.body.refreshToken as string;

    const rotated = await request(app.getHttpServer())
      .post('/auth/refresh')
      .send({ refreshToken: firstRefresh })
      .expect(200);
    const secondRefresh = rotated.body.refreshToken as string;
    expect(secondRefresh).not.toBe(firstRefresh);

    // Reusing the rotated-away token is treated as theft…
    await request(app.getHttpServer())
      .post('/auth/refresh')
      .send({ refreshToken: firstRefresh })
      .expect(401);
    // …and takes the whole family down, including the newest token.
    await request(app.getHttpServer())
      .post('/auth/refresh')
      .send({ refreshToken: secondRefresh })
      .expect(401);
  });

  it('logout revokes the family idempotently', async () => {
    const login = await request(app.getHttpServer())
      .post('/auth/login')
      .send(credentials)
      .expect(200);
    const token = login.body.refreshToken as string;

    await request(app.getHttpServer()).post('/auth/logout').send({ refreshToken: token }).expect(204);
    await request(app.getHttpServer()).post('/auth/refresh').send({ refreshToken: token }).expect(401);
    // Second logout with the same token: still 204, nothing to revoke.
    await request(app.getHttpServer()).post('/auth/logout').send({ refreshToken: token }).expect(204);
  });
});
