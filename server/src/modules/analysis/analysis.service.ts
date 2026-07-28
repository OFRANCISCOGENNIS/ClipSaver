/**
 * Analysis orchestrator (section 4.3, módulo `analysis`).
 *
 * Responsibility: run one URL through the pipeline
 * safety → cache → probe → eligibility → cache-store, returning the
 * response the app renders. Pure orchestration: fetching lives in the
 * probe, deciding lives in the EligibilityService, storage lives in the
 * cache port.
 */
import { createHash } from 'node:crypto';
import { Inject, Injectable } from '@nestjs/common';
import { EligibilityService } from '../eligibility/domain/eligibility.service.js';
import type { EligibilityResult } from '../eligibility/domain/types.js';
import { checkUrlSafety } from '../eligibility/domain/url-safety.js';
import { ANALYSIS_CACHE, type AnalysisCache } from './analysis-cache.js';
import { METADATA_PROBE, toAnalysisContext, type MetadataProbe } from './metadata-probe.js';

/** Wire response for POST /analysis — consumed by the app's DTO layer. */
export interface AnalysisResponse {
  /** Stable id: sha256 of the normalized URL (also the cache key). */
  id: string;
  url: string;
  title?: string;
  author?: string;
  thumbnailUrl?: string;
  eligibility: EligibilityResult;
  /** True when this verdict came from the idempotent cache. */
  cached: boolean;
}

/** TTL configuration injected by the module (from validated env). */
export const ANALYSIS_CACHE_TTL = Symbol('ANALYSIS_CACHE_TTL');

@Injectable()
export class AnalysisService {
  constructor(
    @Inject(METADATA_PROBE) private readonly probe: MetadataProbe,
    @Inject(ANALYSIS_CACHE) private readonly cache: AnalysisCache,
    @Inject(ANALYSIS_CACHE_TTL) private readonly cacheTtlSeconds: number,
    private readonly eligibility: EligibilityService,
  ) {}

  /** Analyzes [rawUrl], serving idempotent hits from cache (24h default). */
  async analyze(rawUrl: string): Promise<AnalysisResponse> {
    const safety = checkUrlSafety(rawUrl);
    const id = sha256(rawUrl.trim());

    // Unsafe URLs are refused without probing and without caching —
    // a verdict that never touched the network need not occupy cache.
    if (!safety.safe) {
      return {
        id,
        url: rawUrl.trim(),
        cached: false,
        eligibility: {
          eligible: false,
          source: 'none',
          reason: 'Este link não pode ser analisado por segurança. Verifique o endereço.',
          availableFormats: [],
          restrictions: [],
        },
      };
    }

    const cachedResponse = await this.cache.get(id);
    if (cachedResponse) {
      return { ...cachedResponse, cached: true };
    }

    const url = new URL(rawUrl.trim());
    const probed = await this.probe.probe(url);
    const verdict = this.eligibility.evaluate(toAnalysisContext(url, probed));

    const response: AnalysisResponse = {
      id,
      url: url.href,
      cached: false,
      eligibility: verdict,
    };
    if (probed.title !== undefined) response.title = probed.title;
    if (probed.author !== undefined) response.author = probed.author;
    if (probed.thumbnailUrl !== undefined) response.thumbnailUrl = probed.thumbnailUrl;

    await this.cache.set(id, response, this.cacheTtlSeconds);
    return response;
  }
}

function sha256(value: string): string {
  return createHash('sha256').update(value).digest('hex');
}
