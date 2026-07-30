/**
 * Authorization by ownership (section 2.1, criterion 3).
 *
 * Responsibility: authorize downloads of content the authenticated user
 * owns on the origin platform, proven via OAuth identity — never via
 * scraped sessions or borrowed cookies.
 */

import type { PlatformAdapter } from '../platform-adapter.js';
import type { AnalysisContext, EligibilityResult } from '../types.js';

/** Grants `user_owned` when OAuth identity matches the content owner. */
export class UserOwnedAdapter implements PlatformAdapter {
  readonly id = 'user_owned_oauth';
  readonly legalBasis =
    'O titular do conteúdo tem o direito de obter cópia do próprio material; ' +
    'a titularidade é verificada por OAuth na plataforma de origem.';
  readonly officialEndpoint =
    'OAuth 2.0 da plataforma de origem + endpoint autenticado de mídia do próprio usuário';

  evaluate(context: AnalysisContext): EligibilityResult | null {
    const { ownership, platform } = context;
    if (!ownership?.authenticatedUserId || !ownership.contentOwnerId) return null;
    if (ownership.authenticatedUserId !== ownership.contentOwnerId) return null;
    const formats = platform?.formats ?? context.directFileFormats ?? [];
    if (formats.length === 0) return null; // nothing real to offer
    return {
      eligible: true,
      source: 'user_owned',
      reason: 'Você é o dono deste conteúdo na plataforma de origem (verificado via OAuth).',
      availableFormats: formats,
      restrictions: [],
    };
  }
}
