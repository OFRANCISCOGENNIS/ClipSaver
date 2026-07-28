/**
 * Core contracts of the Eligibility Engine (section 2.2 of the spec).
 *
 * Responsibility: define the wire-stable types shared between the engine,
 * its platform adapters and (from Phase 2 on) the NestJS HTTP layer.
 * These types are framework-agnostic on purpose: the engine must be
 * testable without HTTP, queues or a database.
 */

/** Legal basis that authorizes a download (section 2.1), or `none`. */
export type AuthorizationSource =
  | 'official_api'
  | 'open_license'
  | 'user_owned'
  | 'direct_file'
  | 'none';

/** One real downloadable rendition reported by the origin. */
export interface MediaFormat {
  /** Origin-side identifier used when requesting this exact rendition. */
  id: string;
  kind: 'video' | 'audio';
  /** Container/extension without dot, lowercase: mp4, webm, mp3… */
  container: string;
  codec?: string;
  /** Vertical resolution for video renditions. */
  height?: number;
  bitrateKbps?: number;
  estimatedSizeBytes?: number;
}

/** The engine's verdict — the exact contract from section 2.2. */
export interface EligibilityResult {
  eligible: boolean;
  source: AuthorizationSource;
  /** SPDX-style license id when source is `open_license`, e.g. "CC-BY-4.0". */
  license?: string;
  /** User-readable explanation of the decision (both outcomes). */
  reason: string;
  availableFormats: MediaFormat[];
  /** License obligations, e.g. ["atribuição obrigatória"]. */
  restrictions: string[];
}

/** DRM systems the analysis step can detect. Any of them blocks download. */
export type DrmSystem = 'widevine' | 'fairplay' | 'playready' | 'other';

/**
 * Everything the analysis module (metadata extraction) learned about a URL.
 * The engine only *decides* — it never fetches. That separation keeps the
 * decision logic pure, deterministic and fully unit-testable.
 */
export interface AnalysisContext {
  /** The already-validated target URL. */
  url: URL;
  /** Content-Type from a HEAD request, when available. */
  contentType?: string;
  /** DRM detection result. */
  drm: { detected: boolean; system?: DrmSystem };
  /** Technical/commercial barriers found on the origin. */
  accessControl: {
    /** Content sits behind a payment barrier. */
    paywalled: boolean;
    /** Content requires a third-party login session to access. */
    requiresAuthentication: boolean;
  };
  /**
   * Raw license declaration from oEmbed / schema.org `license` /
   * `rel=license` tags, untouched. The engine normalizes it.
   */
  licenseMetadata?: string;
  /** Present when a registered platform adapter recognized the URL. */
  platform?: {
    /** Platform slug, e.g. "podcast_rss", "archive_org". */
    id: string;
    /**
     * True when the platform's official, documented API exposes a download
     * for this item (e.g. creator enabled the download button).
     */
    officialDownloadEnabled: boolean;
    /** Real renditions the official API offers. */
    formats: MediaFormat[];
  };
  /** OAuth ownership facts, when the requesting user is authenticated. */
  ownership?: {
    /** Vidora user's identity on the origin platform (via OAuth). */
    authenticatedUserId?: string;
    /** Owner of the content on the origin platform. */
    contentOwnerId?: string;
  };
  /** Renditions detectable when the URL is itself a media file. */
  directFileFormats?: MediaFormat[];
}
