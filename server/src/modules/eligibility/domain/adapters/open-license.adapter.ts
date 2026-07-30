/**
 * Authorization by open license (section 2.1, criterion 2).
 *
 * Responsibility: authorize downloads of content whose metadata declares
 * a license that permits redistribution (Creative Commons, public
 * domain), surfacing the license's obligations as restrictions.
 */

import { detectLicense } from '../license-detector.js';
import type { PlatformAdapter } from '../platform-adapter.js';
import type { AnalysisContext, EligibilityResult } from '../types.js';

/** Grants `open_license` when declared metadata permits the download. */
export class OpenLicenseAdapter implements PlatformAdapter {
  readonly id = 'open_license';
  readonly legalBasis =
    'O titular declarou uma licença aberta (Creative Commons/domínio público) ' +
    'nos metadados do conteúdo (oEmbed, schema.org, rel=license).';
  readonly officialEndpoint =
    'Metadados públicos da página do conteúdo (oEmbed / schema.org)';

  evaluate(context: AnalysisContext): EligibilityResult | null {
    const license = detectLicense(context.licenseMetadata);
    if (!license.allowsDownload) return null;
    const formats = context.platform?.formats ?? context.directFileFormats ?? [];
    if (formats.length === 0) return null;
    return {
      eligible: true,
      source: 'open_license',
      license: license.spdxId,
      reason: `Conteúdo sob ${license.displayName} — o download é permitido pela licença.`,
      availableFormats: formats,
      restrictions: license.restrictions,
    };
  }
}
