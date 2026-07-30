/**
 * Environment configuration, validated with zod (section 4.3 of the spec:
 * "validação de env com zod").
 *
 * Responsibility: fail fast at boot on invalid configuration and expose a
 * single typed object — no `process.env` access anywhere else.
 */
import { z } from 'zod';

const envSchema = z.object({
  NODE_ENV: z.enum(['development', 'test', 'production']).default('development'),
  PORT: z.coerce.number().int().min(1).max(65535).default(3000),
  /**
   * Secret for signing access tokens. In production this must come from a
   * secret manager; the schema refuses short/default values there.
   */
  JWT_SECRET: z.string().min(16).default('dev-only-secret-change-me'),
  /** Access-token lifetime (section 13: short-lived, 15 minutes). */
  JWT_ACCESS_TTL_SECONDS: z.coerce.number().int().positive().default(15 * 60),
  /** Refresh-token lifetime. */
  REFRESH_TTL_SECONDS: z.coerce.number().int().positive().default(30 * 24 * 3600),
  /** Redis connection; absent means in-memory ports (tests/local dev). */
  REDIS_URL: z.string().url().optional(),
  /** Postgres connection for Prisma. */
  DATABASE_URL: z.string().optional(),
  /** Idempotent analysis cache TTL (section 4.3: 24h, configurable). */
  ANALYSIS_CACHE_TTL_SECONDS: z.coerce.number().int().positive().default(24 * 3600),
  /** Rate limiting window and cap (per IP). */
  THROTTLE_TTL_SECONDS: z.coerce.number().int().positive().default(60),
  THROTTLE_LIMIT: z.coerce.number().int().positive().default(30),
  /**
   * Billing (section 14). Each store's verifier only registers when its
   * credential is present; a provider left unset is refused fail-closed.
   */
  STRIPE_SECRET_KEY: z.string().min(8).optional(),
  GOOGLE_PLAY_PACKAGE: z.string().min(3).optional(),
  GOOGLE_PLAY_ACCESS_TOKEN: z.string().min(8).optional(),
  APPLE_API_TOKEN: z.string().min(8).optional(),
});

/** Parsed, validated environment. */
export type Env = z.infer<typeof envSchema>;

/** Parses [source] (defaults to process.env), throwing on invalid config. */
export function loadEnv(source: NodeJS.ProcessEnv = process.env): Env {
  const parsed = envSchema.safeParse(source);
  if (!parsed.success) {
    const issues = parsed.error.issues
      .map((i) => `${i.path.join('.')}: ${i.message}`)
      .join('; ');
    throw new Error(`Invalid environment configuration — ${issues}`);
  }
  if (parsed.data.NODE_ENV === 'production' && parsed.data.JWT_SECRET.startsWith('dev-only')) {
    throw new Error('JWT_SECRET must be set explicitly in production');
  }
  return parsed.data;
}

/** Nest injection token for the validated environment. */
export const ENV = Symbol('ENV');
