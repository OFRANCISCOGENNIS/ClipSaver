/**
 * Idempotent analysis cache port (section 4.3: same URL within 24h
 * returns the cached verdict).
 *
 * Responsibility: define the cache contract and provide the in-memory
 * implementation used by tests and Redis-less local development. The
 * Redis implementation lives in `redis-analysis-cache.ts`.
 */
import type { AnalysisResponse } from './analysis.service.js';

/** Cache port keyed by URL hash. */
export interface AnalysisCache {
  get(key: string): Promise<AnalysisResponse | null>;
  set(key: string, value: AnalysisResponse, ttlSeconds: number): Promise<void>;
}

/** Nest injection token for the cache. */
export const ANALYSIS_CACHE = Symbol('ANALYSIS_CACHE');

/** Process-local cache with TTL; suitable for tests and dev only. */
export class InMemoryAnalysisCache implements AnalysisCache {
  private readonly entries = new Map<string, { value: AnalysisResponse; expiresAt: number }>();

  constructor(private readonly now: () => number = Date.now) {}

  async get(key: string): Promise<AnalysisResponse | null> {
    const entry = this.entries.get(key);
    if (!entry) return null;
    if (entry.expiresAt <= this.now()) {
      this.entries.delete(key);
      return null;
    }
    return entry.value;
  }

  async set(key: string, value: AnalysisResponse, ttlSeconds: number): Promise<void> {
    this.entries.set(key, { value, expiresAt: this.now() + ttlSeconds * 1000 });
  }
}
