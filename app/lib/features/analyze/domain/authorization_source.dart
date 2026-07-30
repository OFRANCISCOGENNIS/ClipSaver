/// The four authorization sources of section 2.1, plus `none`.
///
/// Responsibility: give every eligibility decision an explicit, auditable
/// legal basis. The badge text for each source lives in the l10n layer
/// (`AuthorizationSourceL10n`), never here — the domain has no language.
library;

/// Legal basis that authorizes (or refuses) a download.
enum AuthorizationSource {
  /// Platform exposes an official, documented download endpoint.
  officialApi('official_api'),

  /// Content carries an open license (CC/public domain) in its metadata.
  openLicense('open_license'),

  /// The authenticated user owns the content on the origin platform.
  userOwned('user_owned'),

  /// URL points directly to a publicly served media file.
  directFile('direct_file'),

  /// No authorization basis found — download must be refused.
  none('none');

  const AuthorizationSource(this.wireValue);

  /// Value used in the backend contract (section 2.2).
  final String wireValue;

  /// Parses a backend wire value, failing closed to [none].
  static AuthorizationSource fromWire(String value) => values.firstWhere(
        (s) => s.wireValue == value,
        orElse: () => AuthorizationSource.none,
      );
}
