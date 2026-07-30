/**
 * Open-license detector (section 2.1, criterion 2).
 *
 * Responsibility: normalize raw license declarations found in metadata
 * (SPDX ids, Creative Commons URLs) into a known license with its
 * user-facing restrictions. Anything unrecognized fails closed to
 * "all rights reserved" — the golden rule is that compliance wins.
 */

/** A recognized license and the obligations it imposes on the user. */
export interface DetectedLicense {
  /** SPDX-style identifier, e.g. "CC-BY-4.0". */
  spdxId: string;
  /** Badge text for the UI, e.g. "Licença CC-BY". */
  displayName: string;
  /** User-facing obligations, e.g. ["atribuição obrigatória"]. */
  restrictions: string[];
  /** Whether the license authorizes redistribution/download at all. */
  allowsDownload: boolean;
}

const ATTRIBUTION = 'atribuição obrigatória';

const KNOWN: DetectedLicense[] = [
  { spdxId: 'PDM', displayName: 'Domínio público', restrictions: [], allowsDownload: true },
  { spdxId: 'CC0-1.0', displayName: 'Licença CC0', restrictions: [], allowsDownload: true },
  {
    spdxId: 'CC-BY-4.0',
    displayName: 'Licença CC-BY',
    restrictions: [ATTRIBUTION],
    allowsDownload: true,
  },
  {
    spdxId: 'CC-BY-SA-4.0',
    displayName: 'Licença CC-BY-SA',
    restrictions: [ATTRIBUTION, 'compartilhamento pela mesma licença'],
    allowsDownload: true,
  },
  {
    spdxId: 'CC-BY-NC-4.0',
    displayName: 'Licença CC-BY-NC',
    restrictions: [ATTRIBUTION, 'uso não comercial'],
    allowsDownload: true,
  },
  {
    spdxId: 'CC-BY-ND-4.0',
    displayName: 'Licença CC-BY-ND',
    restrictions: [ATTRIBUTION, 'sem obras derivadas'],
    allowsDownload: true,
  },
];

/** Fallback for null/unknown declarations: never downloadable by license. */
export const ALL_RIGHTS_RESERVED: DetectedLicense = {
  spdxId: 'proprietary',
  displayName: 'Todos os direitos reservados',
  restrictions: [],
  allowsDownload: false,
};

const CC_URL_MAP: Record<string, string> = {
  by: 'CC-BY-4.0',
  'by-sa': 'CC-BY-SA-4.0',
  'by-nc': 'CC-BY-NC-4.0',
  'by-nd': 'CC-BY-ND-4.0',
};

/** Resolves a raw metadata string to a known license, failing closed. */
export function detectLicense(raw: string | undefined | null): DetectedLicense {
  if (!raw) return ALL_RIGHTS_RESERVED;
  const normalized = raw.trim().toUpperCase();
  for (const license of KNOWN) {
    if (normalized.startsWith(license.spdxId.toUpperCase())) return license;
  }
  // Creative Commons deed URLs, e.g. creativecommons.org/licenses/by/4.0/.
  const ccUrl = raw
    .trim()
    .toLowerCase()
    .match(/creativecommons\.org\/(licenses\/([a-z-]+)|publicdomain)/);
  if (ccUrl) {
    if (ccUrl[1]!.startsWith('publicdomain')) {
      return KNOWN.find((l) => l.spdxId === 'CC0-1.0')!;
    }
    const spdxId = CC_URL_MAP[ccUrl[2]!];
    if (spdxId) return KNOWN.find((l) => l.spdxId === spdxId)!;
  }
  return ALL_RIGHTS_RESERVED;
}
