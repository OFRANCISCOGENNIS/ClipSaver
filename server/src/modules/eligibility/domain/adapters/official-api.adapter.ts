/**
 * Authorization by official platform API (section 2.1, criterion 1).
 *
 * Responsibility: authorize downloads that the origin platform itself
 * offers through a public, documented endpoint — e.g. a creator-enabled
 * download button or a podcast RSS enclosure. The analysis module sets
 * `platform.officialDownloadEnabled` only after querying that official
 * API; this adapter never infers permission.
 */

import type { PlatformAdapter } from '../platform-adapter.js';
import type { AnalysisContext, EligibilityResult } from '../types.js';

/** Grants `official_api` when the platform's own API offers the file. */
export class OfficialApiAdapter implements PlatformAdapter {
  readonly id = 'official_api';
  readonly legalBasis =
    'A própria plataforma fornece o arquivo por endpoint público e documentado; ' +
    'baixar por esse endpoint é o uso previsto pelo serviço.';
  readonly officialEndpoint =
    'Endpoint de download documentado da plataforma (por adaptador registrado no catálogo)';

  evaluate(context: AnalysisContext): EligibilityResult | null {
    const platform = context.platform;
    if (!platform?.officialDownloadEnabled) return null;
    if (platform.formats.length === 0) return null;
    return {
      eligible: true,
      source: 'official_api',
      reason: 'A plataforma de origem oferece o download oficialmente para este item.',
      availableFormats: platform.formats,
      restrictions: [],
    };
  }
}
