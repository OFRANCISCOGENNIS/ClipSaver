/**
 * Metadata probe port (section 4.3, módulo `analysis`).
 *
 * Responsibility: define what the analysis pipeline needs to learn about a
 * URL — content type, license declarations, access barriers, DRM hints —
 * independent of how it is fetched. The HTTP implementation lives in
 * `http-metadata-probe.ts`; tests inject deterministic fakes.
 */
import type { AnalysisContext, MediaFormat } from '../eligibility/domain/types.js';
import type { PlatformFacts } from './platform/archive-org.probe.js';

/** Raw facts a probe gathered about one URL. */
export interface ProbeResult {
  /** Content-Type of the resource, when the origin reports one. */
  contentType?: string;
  /** Display title extracted from metadata, when available. */
  title?: string;
  /** Author/channel name, when available. */
  author?: string;
  /** Thumbnail URL from og:image / oEmbed, when available. */
  thumbnailUrl?: string;
  /** Raw license declaration (schema.org / rel=license / og fields). */
  licenseMetadata?: string;
  /** True when metadata declares the content is NOT freely accessible. */
  paywalled: boolean;
  /** True when the origin demanded authentication (401/403 or login wall). */
  requiresAuthentication: boolean;
  /** True when DRM markers were detected (manifest/page hints). */
  drmDetected: boolean;
  /** Renditions when the URL is itself a media file. */
  directFileFormats?: MediaFormat[];
  /**
   * Facts contributed by a platform-specific probe that recognized the
   * URL. Only a probe that consulted the platform's official API may set
   * this: `officialDownloadEnabled` is what authorizes the download, so
   * inferring it from the URL alone would turn a guess into permission.
   */
  platform?: PlatformFacts;
}

/** Port implemented by HTTP/platform-specific probes. */
export interface MetadataProbe {
  /** Gathers facts about [url]. Must never follow to private networks. */
  probe(url: URL): Promise<ProbeResult>;
}

/** Nest injection token for the probe. */
export const METADATA_PROBE = Symbol('METADATA_PROBE');

/** Builds the eligibility context from a probe result. */
export function toAnalysisContext(url: URL, probe: ProbeResult): AnalysisContext {
  const context: AnalysisContext = {
    url,
    drm: { detected: probe.drmDetected },
    accessControl: {
      paywalled: probe.paywalled,
      requiresAuthentication: probe.requiresAuthentication,
    },
  };
  if (probe.contentType !== undefined) context.contentType = probe.contentType;
  if (probe.licenseMetadata !== undefined) context.licenseMetadata = probe.licenseMetadata;
  if (probe.directFileFormats !== undefined) context.directFileFormats = probe.directFileFormats;
  if (probe.platform !== undefined) context.platform = probe.platform;
  return context;
}
