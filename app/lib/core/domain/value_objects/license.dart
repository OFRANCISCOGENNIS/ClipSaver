/// Value object for content licenses detected by the Eligibility Engine.
///
/// Responsibility: map raw license identifiers (SPDX-ish strings from
/// oEmbed/schema.org metadata) to the badge and restrictions the UI shows
/// (sections 2.1 criterion 2 and 2.3).
library;

/// A recognized content license with its UI badge and obligations.
final class License {
  const License._(
    this.spdxId,
    this.displayName,
    this.restrictions, {
    required this.allowsDownload,
  });

  /// SPDX-style identifier, e.g. "CC-BY-4.0", "CC0-1.0", "PDM".
  final String spdxId;

  /// Short badge text, e.g. "Licença CC-BY".
  final String displayName;

  /// User-facing obligations, e.g. ["atribuição obrigatória"].
  final List<String> restrictions;

  /// Whether this license authorizes redistribution/download at all.
  final bool allowsDownload;

  /// Public Domain Mark: no restrictions.
  static const publicDomain = License._(
    'PDM',
    'Domínio público',
    [],
    allowsDownload: true,
  );

  /// CC0: rights waived, no restrictions.
  static const cc0 = License._(
    'CC0-1.0',
    'Licença CC0',
    [],
    allowsDownload: true,
  );

  /// CC-BY: reuse allowed with attribution.
  static const ccBy = License._(
    'CC-BY-4.0',
    'Licença CC-BY',
    ['atribuição obrigatória'],
    allowsDownload: true,
  );

  /// CC-BY-SA: attribution + share-alike.
  static const ccBySa = License._(
    'CC-BY-SA-4.0',
    'Licença CC-BY-SA',
    ['atribuição obrigatória', 'compartilhamento pela mesma licença'],
    allowsDownload: true,
  );

  /// CC-BY-NC: attribution + non-commercial use only.
  static const ccByNc = License._(
    'CC-BY-NC-4.0',
    'Licença CC-BY-NC',
    ['atribuição obrigatória', 'uso não comercial'],
    allowsDownload: true,
  );

  /// CC-BY-ND: attribution + no derivative works.
  static const ccByNd = License._(
    'CC-BY-ND-4.0',
    'Licença CC-BY-ND',
    ['atribuição obrigatória', 'sem obras derivadas'],
    allowsDownload: true,
  );

  /// "All rights reserved" or any unrecognized declaration: download is
  /// only possible via another authorization source (official API,
  /// user-owned content), never via this license.
  static const allRightsReserved = License._(
    'proprietary',
    'Todos os direitos reservados',
    [],
    allowsDownload: false,
  );

  static const _known = [
    publicDomain,
    cc0,
    ccBy,
    ccBySa,
    ccByNc,
    ccByNd,
  ];

  /// Resolves a raw metadata string to a known license.
  /// Unknown strings resolve to [allRightsReserved]: fail closed.
  static License fromMetadata(String? raw) {
    if (raw == null) return allRightsReserved;
    final normalized = raw.trim().toUpperCase();
    for (final license in _known) {
      if (normalized.startsWith(license.spdxId.toUpperCase())) return license;
    }
    // Creative Commons URLs (creativecommons.org/licenses/by/4.0/…).
    final ccUrl =
        RegExp(r'creativecommons\.org/(licenses/([a-z-]+)|publicdomain)')
            .firstMatch(raw.trim().toLowerCase());
    if (ccUrl != null) {
      if (ccUrl.group(1)!.startsWith('publicdomain')) return cc0;
      return switch (ccUrl.group(2)) {
        'by' => ccBy,
        'by-sa' => ccBySa,
        'by-nc' => ccByNc,
        'by-nd' => ccByNd,
        _ => allRightsReserved, // by-nc-nd etc.: unmapped → fail closed
      };
    }
    return allRightsReserved;
  }

  @override
  bool operator ==(Object other) => other is License && other.spdxId == spdxId;

  @override
  int get hashCode => spdxId.hashCode;

  @override
  String toString() => 'License($spdxId)';
}
