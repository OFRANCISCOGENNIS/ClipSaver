/**
 * HTTP implementation of the metadata probe.
 *
 * Responsibility: gather honest, public facts about a URL using plain
 * HTTP — a HEAD request for the content type plus a bounded HTML read for
 * standard metadata (schema.org `license`/`isAccessibleForFree`,
 * `rel=license`, Open Graph). It detects barriers (401/403, paywall
 * flags, DRM markers) and *reports* them; circumventing them is the one
 * thing this class must never do.
 */
import type { MetadataProbe, ProbeResult } from './metadata-probe.js';
import {
  ARCHIVE_METADATA_ENDPOINT,
  archiveFactsFrom,
  archiveIdentifierOf,
  type ArchiveMetadata,
} from './platform/archive-org.probe.js';

/** Minimal fetch signature so tests can inject a deterministic client. */
export type FetchLike = (
  url: string,
  init: { method: string; redirect: 'follow'; signal: AbortSignal; headers: Record<string, string> },
) => Promise<{
  status: number;
  headers: { get(name: string): string | null };
  text(): Promise<string>;
}>;

const HTML_BYTE_LIMIT = 256 * 1024;
const TIMEOUT_MS = 8_000;

const DRM_MARKERS = ['widevine', 'playready', 'fairplay', 'encrypted-media'];

export class HttpMetadataProbe implements MetadataProbe {
  constructor(private readonly fetchImpl: FetchLike) {}

  async probe(url: URL): Promise<ProbeResult> {
    // A recognized platform is asked first, and its official API is the
    // authority on that item. Falling through to the generic HTML scrape
    // would read the *page* instead of the platform, and a page never
    // says whether a download is permitted.
    const archive = await this.probeArchiveOrg(url);
    if (archive) return archive;

    const head = await this.request('HEAD', url);
    if (head.status === 401 || head.status === 403) {
      return { ...emptyResult(), requiresAuthentication: true };
    }
    if (head.status === 402) {
      return { ...emptyResult(), paywalled: true };
    }
    const contentType = head.headers.get('content-type')?.toLowerCase() ?? '';

    // Media file? Nothing else to parse — report the type and size.
    if (/^(video|audio)\//.test(contentType)) {
      return { ...emptyResult(), contentType };
    }

    // Non-HTML, non-media (zip, pdf…): report the type; eligibility will
    // refuse it downstream because no adapter recognizes it as media.
    if (!contentType.includes('text/html')) {
      return { ...emptyResult(), contentType };
    }

    const page = await this.request('GET', url);
    const html = (await page.text()).slice(0, HTML_BYTE_LIMIT);
    const result: ProbeResult = { ...emptyResult(), contentType };

    const title = firstMatch(html, [
      /<meta[^>]+property=["']og:title["'][^>]+content=["']([^"']+)["']/i,
      /<title[^>]*>([^<]+)<\/title>/i,
    ]);
    if (title) result.title = decodeEntities(title.trim());

    const author = firstMatch(html, [
      /<meta[^>]+name=["']author["'][^>]+content=["']([^"']+)["']/i,
    ]);
    if (author) result.author = decodeEntities(author.trim());

    const thumb = firstMatch(html, [
      /<meta[^>]+property=["']og:image["'][^>]+content=["']([^"']+)["']/i,
    ]);
    if (thumb) result.thumbnailUrl = thumb.trim();

    const license = firstMatch(html, [
      /<link[^>]+rel=["']license["'][^>]+href=["']([^"']+)["']/i,
      /"license"\s*:\s*"([^"]+)"/i,
      /<meta[^>]+name=["']license["'][^>]+content=["']([^"']+)["']/i,
    ]);
    if (license) result.licenseMetadata = license.trim();

    // schema.org's standard paywall flag; absence means public.
    if (/"isAccessibleForFree"\s*:\s*(false|"false")/i.test(html)) {
      result.paywalled = true;
    }

    const lowered = html.toLowerCase();
    result.drmDetected = DRM_MARKERS.some((marker) => lowered.includes(marker));

    return result;
  }

  /**
   * Consults archive.org's public metadata API for a recognized item.
   *
   * Returns `null` when the URL is not an Archive item, so the generic
   * path handles it. A failure to reach the API also returns `null`
   * rather than a refusal: the caller then treats the URL like any other,
   * which fails closed anyway — but it never reports a permission the
   * Archive did not actually grant.
   */
  private async probeArchiveOrg(url: URL): Promise<ProbeResult | null> {
    const identifier = archiveIdentifierOf(url);
    if (identifier === null) return null;

    try {
      const response = await this.request(
        'GET',
        new URL(`${ARCHIVE_METADATA_ENDPOINT}/${encodeURIComponent(identifier)}`),
      );
      if (response.status !== 200) return null;
      const payload = JSON.parse(await response.text()) as ArchiveMetadata;
      const platform = archiveFactsFrom(identifier, payload);
      return { ...emptyResult(), platform };
    } catch {
      return null;
    }
  }

  private async request(method: 'HEAD' | 'GET', url: URL) {
    const controller = new AbortController();
    const timer = setTimeout(() => controller.abort(), TIMEOUT_MS);
    try {
      return await this.fetchImpl(url.href, {
        method,
        redirect: 'follow',
        signal: controller.signal,
        headers: { 'user-agent': 'VidoraBot/1.0 (+compliance: only public metadata)' },
      });
    } finally {
      clearTimeout(timer);
    }
  }
}

function emptyResult(): ProbeResult {
  return { paywalled: false, requiresAuthentication: false, drmDetected: false };
}

function firstMatch(html: string, patterns: RegExp[]): string | undefined {
  for (const pattern of patterns) {
    const match = html.match(pattern);
    if (match?.[1]) return match[1];
  }
  return undefined;
}

/** Decodes the handful of HTML entities that show up in titles. */
function decodeEntities(text: string): string {
  return text
    .replaceAll('&amp;', '&')
    .replaceAll('&lt;', '<')
    .replaceAll('&gt;', '>')
    .replaceAll('&quot;', '"')
    .replaceAll('&#39;', "'");
}
