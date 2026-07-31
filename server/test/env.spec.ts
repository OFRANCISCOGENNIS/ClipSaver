import { describe, expect, it } from 'vitest';
import { loadEnv } from '../src/config/env.js';

describe('loadEnv', () => {
  it('applies documented defaults', () => {
    const env = loadEnv({} as NodeJS.ProcessEnv);
    expect(env.PORT).toBe(3000);
    expect(env.JWT_ACCESS_TTL_SECONDS).toBe(15 * 60);
    expect(env.ANALYSIS_CACHE_TTL_SECONDS).toBe(24 * 3600);
    expect(env.REDIS_URL).toBeUndefined();
  });

  it('coerces numeric strings', () => {
    const env = loadEnv({ PORT: '8080', THROTTLE_LIMIT: '5' } as NodeJS.ProcessEnv);
    expect(env.PORT).toBe(8080);
    expect(env.THROTTLE_LIMIT).toBe(5);
  });

  it('rejects invalid values with a readable message', () => {
    expect(() => loadEnv({ PORT: 'abc' } as NodeJS.ProcessEnv)).toThrow(/PORT/);
    expect(() => loadEnv({ REDIS_URL: 'not-a-url' } as NodeJS.ProcessEnv)).toThrow(/REDIS_URL/);
  });

  it('refuses the dev JWT secret in production', () => {
    expect(() =>
      loadEnv({ NODE_ENV: 'production', CORS_ORIGINS: 'https://app.example.test' } as NodeJS.ProcessEnv),
    ).toThrow(/JWT_SECRET/);
    const env = loadEnv({
      NODE_ENV: 'production',
      JWT_SECRET: 'a-real-secret-with-length',
      CORS_ORIGINS: 'https://app.example.test',
    } as NodeJS.ProcessEnv);
    expect(env.NODE_ENV).toBe('production');
  });

  it('requires explicit browser origins in production', () => {
    expect(() =>
      loadEnv({
        NODE_ENV: 'production',
        JWT_SECRET: 'a-real-secret-with-length',
      } as NodeJS.ProcessEnv),
    ).toThrow(/CORS_ORIGINS/);
  });
});
