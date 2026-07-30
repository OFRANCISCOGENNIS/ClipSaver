/**
 * Authorization for direct file links (section 2.1, criterion 4).
 *
 * Responsibility: authorize URLs that point straight at a publicly
 * served media file — no session, no paywall, no DRM in the way. The
 * engine has already refused all of those barriers before adapters run,
 * so this adapter only has to recognize "this URL *is* the file".
 */

import type { PlatformAdapter } from '../platform-adapter.js';
import type { AnalysisContext, EligibilityResult, MediaFormat } from '../types.js';

const VIDEO_EXTENSIONS = new Set(['mp4', 'webm', 'mkv', 'mov', 'm4v']);
const AUDIO_EXTENSIONS = new Set(['mp3', 'aac', 'wav', 'flac', 'ogg', 'opus', 'm4a']);

const MEDIA_CONTENT_TYPES = /^(video|audio)\//;

/** Grants `direct_file` for plain public media file URLs. */
export class DirectFileAdapter implements PlatformAdapter {
  readonly id = 'direct_file';
  readonly legalBasis =
    'Arquivo de mídia servido publicamente por link direto, sem burla de ' +
    'autenticação, paywall ou DRM (barreiras são recusadas antes deste adaptador).';
  readonly officialEndpoint = 'GET direto na própria URL (HTTP Range quando suportado)';

  evaluate(context: AnalysisContext): EligibilityResult | null {
    const kind = this.mediaKind(context);
    if (!kind) return null;
    const formats: MediaFormat[] =
      context.directFileFormats && context.directFileFormats.length > 0
        ? context.directFileFormats
        : [this.fallbackFormat(context, kind)];
    return {
      eligible: true,
      source: 'direct_file',
      reason: 'A URL aponta diretamente para um arquivo de mídia servido publicamente.',
      availableFormats: formats,
      restrictions: [],
    };
  }

  /** Detects media by Content-Type first, then by path extension. */
  private mediaKind(context: AnalysisContext): 'video' | 'audio' | null {
    const contentType = context.contentType?.toLowerCase() ?? '';
    if (MEDIA_CONTENT_TYPES.test(contentType)) {
      return contentType.startsWith('video/') ? 'video' : 'audio';
    }
    const path = context.url.pathname.toLowerCase();
    const extension = path.includes('.') ? path.split('.').pop()! : '';
    if (VIDEO_EXTENSIONS.has(extension)) return 'video';
    if (AUDIO_EXTENSIONS.has(extension)) return 'audio';
    return null;
  }

  /** Minimal honest format when the origin reports nothing richer. */
  private fallbackFormat(context: AnalysisContext, kind: 'video' | 'audio'): MediaFormat {
    const path = context.url.pathname.toLowerCase();
    const fromPath = path.includes('.') ? path.split('.').pop()! : '';
    const fromType = context.contentType?.split('/')[1]?.split(';')[0] ?? '';
    return {
      id: 'direct',
      kind,
      container: fromPath || fromType || 'bin',
    };
  }
}
