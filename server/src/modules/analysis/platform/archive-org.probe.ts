/**
 * Internet Archive platform probe.
 *
 * Responsibility: recognize an archive.org item, ask the Archive's own
 * public metadata API what files it holds, and report those as official
 * download formats. The Archive publishes this endpoint precisely so that
 * clients can enumerate and fetch items — downloading through it is the
 * documented, intended use, not a workaround.
 *
 * The parsing is a pure function on purpose. Deciding whether an item is
 * downloadable is the part worth testing exhaustively, and doing that
 * against real HTTP would make the interesting cases (a lending-restricted
 * book, a dark item) impossible to reproduce.
 */

import type { MediaFormat } from '../../eligibility/domain/types.js';

/** Facts a platform probe contributes to the analysis context. */
export interface PlatformFacts {
  id: string;
  officialDownloadEnabled: boolean;
  formats: MediaFormat[];
}

/** Official, public, documented endpoint. No key, no session, no scraping. */
export const ARCHIVE_METADATA_ENDPOINT = 'https://archive.org/metadata';

/** Shape of the slice of `/metadata/<id>` this probe reads. */
export interface ArchiveMetadata {
  is_dark?: boolean;
  metadata?: {
    identifier?: string;
    'access-restricted-item'?: string | boolean;
    collection?: string | string[];
  };
  files?: Array<{
    name?: string;
    format?: string;
    size?: string | number;
    source?: string;
    height?: string | number;
    /** Present on derivative files; the original they came from. */
    original?: string;
  }>;
}

/**
 * Extracts the item identifier from an archive.org URL.
 *
 * Accepts the two public shapes — `/details/<id>` and `/download/<id>/…` —
 * and nothing else. A URL this returns null for is simply not an Archive
 * item, and the generic probe handles it.
 */
export function archiveIdentifierOf(url: URL): string | null {
  if (url.hostname !== 'archive.org' && url.hostname !== 'www.archive.org') {
    return null;
  }
  const match = /^\/(details|download)\/([^/]+)/.exec(url.pathname);
  if (!match) return null;
  const identifier = decodeURIComponent(match[2] ?? '');
  return identifier.length > 0 ? identifier : null;
}

/** Media containers the Archive reports that the app can actually play. */
const CONTAINERS: Record<string, { kind: 'video' | 'audio'; container: string }> = {
  'h.264': { kind: 'video', container: 'mp4' },
  'h.264 ia': { kind: 'video', container: 'mp4' },
  mpeg4: { kind: 'video', container: 'mp4' },
  '512kb mpeg4': { kind: 'video', container: 'mp4' },
  'ogg video': { kind: 'video', container: 'ogv' },
  matroska: { kind: 'video', container: 'mkv' },
  'vbr mp3': { kind: 'audio', container: 'mp3' },
  mp3: { kind: 'audio', container: 'mp3' },
  'ogg vorbis': { kind: 'audio', container: 'ogg' },
  flac: { kind: 'audio', container: 'flac' },
  wave: { kind: 'audio', container: 'wav' },
};

function isRestricted(payload: ArchiveMetadata): boolean {
  if (payload.is_dark === true) return true;
  const flag = payload.metadata?.['access-restricted-item'];
  // The Archive reports this as the string "true" far more often than as a
  // boolean, and a lending-restricted item is exactly the case that must
  // not be authorized — so both spellings count.
  return flag === true || flag === 'true';
}

/**
 * Turns an Archive metadata payload into platform facts.
 *
 * Returns `officialDownloadEnabled: false` — never a throw and never
 * `null` — when the item exists but may not be downloaded, so the engine
 * refuses it with its own educational message instead of this probe
 * inventing one.
 */
export function archiveFactsFrom(
  identifier: string,
  payload: ArchiveMetadata,
): PlatformFacts {
  const facts: PlatformFacts = {
    id: 'archive_org',
    officialDownloadEnabled: false,
    formats: [],
  };
  if (isRestricted(payload)) return facts;

  for (const file of payload.files ?? []) {
    const name = file.name;
    if (!name) continue;
    const spec = CONTAINERS[(file.format ?? '').toLowerCase()];
    if (!spec) continue;

    const format: MediaFormat = {
      id: name,
      kind: spec.kind,
      container: spec.container,
      url: `https://archive.org/download/${encodeURIComponent(identifier)}/${name
        .split('/')
        .map(encodeURIComponent)
        .join('/')}`,
    };
    const height = Number(file.height);
    if (Number.isFinite(height) && height > 0) format.height = height;
    const size = Number(file.size);
    if (Number.isFinite(size) && size > 0) format.estimatedSizeBytes = size;
    facts.formats.push(format);
  }

  facts.officialDownloadEnabled = facts.formats.length > 0;
  return facts;
}
