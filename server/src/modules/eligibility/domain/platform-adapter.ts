/**
 * Platform adapter contract and registry (section 2.2).
 *
 * Responsibility: every way Vidora talks to an origin platform is one
 * adapter, and every adapter must document its legal basis, the official
 * endpoint it uses and the platform's ToS. The registry evaluates
 * adapters in a fixed priority order and the first authorization wins;
 * if none authorizes, the engine fails closed.
 */

import type { AnalysisContext, EligibilityResult } from './types.js';

/**
 * One authorization strategy for one platform (or class of platforms).
 *
 * Invariant: an adapter either returns a *fully eligible* result or
 * `null` ("not my case"). Adapters never return ineligible results —
 * refusal, with its educational message, is the engine's job, so refusal
 * text stays consistent across platforms.
 */
export interface PlatformAdapter {
  /** Stable slug, e.g. "user_owned_oauth", "podcast_rss". */
  readonly id: string;
  /** Human summary of why this access path is lawful (audit trail). */
  readonly legalBasis: string;
  /** Official API/endpoint documentation backing [legalBasis]. */
  readonly officialEndpoint: string;
  /** Link to the origin platform's Terms of Service, when applicable. */
  readonly tosUrl?: string;
  /**
   * Returns an eligible verdict when this adapter authorizes the
   * download, or `null` when it does not apply to [context].
   */
  evaluate(context: AnalysisContext): EligibilityResult | null;
}

/** Ordered adapter collection; order expresses authorization priority. */
export class PlatformAdapterRegistry {
  private readonly adapters: PlatformAdapter[] = [];

  /** Registers [adapter] at the end of the priority list. */
  register(adapter: PlatformAdapter): void {
    if (this.adapters.some((a) => a.id === adapter.id)) {
      throw new Error(`adapter '${adapter.id}' is already registered`);
    }
    this.adapters.push(adapter);
  }

  /** Adapters in evaluation order. */
  list(): readonly PlatformAdapter[] {
    return this.adapters;
  }

  /** First eligible verdict, or `null` when no adapter authorizes. */
  evaluate(context: AnalysisContext): EligibilityResult | null {
    for (const adapter of this.adapters) {
      const verdict = adapter.evaluate(context);
      if (verdict) return verdict;
    }
    return null;
  }
}
