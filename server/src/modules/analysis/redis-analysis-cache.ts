/**
 * Redis-backed analysis cache (section 4.3) for production/staging.
 *
 * Responsibility: store analysis verdicts under a hashed key with TTL.
 * Keys are `analysis:<sha256(url)>` — the raw URL never reaches Redis,
 * keeping cache keys aligned with the log-hygiene rule (section 13).
 */
import type { Redis } from 'ioredis';
import type { AnalysisCache } from './analysis-cache.js';
import type { AnalysisResponse } from './analysis.service.js';

export class RedisAnalysisCache implements AnalysisCache {
  constructor(private readonly redis: Redis) {}

  async get(key: string): Promise<AnalysisResponse | null> {
    const raw = await this.redis.get(`analysis:${key}`);
    if (!raw) return null;
    try {
      return JSON.parse(raw) as AnalysisResponse;
    } catch {
      // Corrupted entry: treat as miss; it will be overwritten.
      return null;
    }
  }

  async set(key: string, value: AnalysisResponse, ttlSeconds: number): Promise<void> {
    await this.redis.set(`analysis:${key}`, JSON.stringify(value), 'EX', ttlSeconds);
  }
}
