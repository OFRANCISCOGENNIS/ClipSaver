/// The four authorization sources of section 2.1, plus `none`.
///
/// Responsibility: give every eligibility decision an explicit, auditable
/// legal basis. UI badges (section 2.3) derive directly from this enum.
library;

/// Legal basis that authorizes (or refuses) a download.
enum AuthorizationSource {
  /// Platform exposes an official, documented download endpoint.
  officialApi('official_api', 'Download oficial'),

  /// Content carries an open license (CC/public domain) in its metadata.
  openLicense('open_license', 'Licença aberta'),

  /// The authenticated user owns the content on the origin platform.
  userOwned('user_owned', 'Seu conteúdo'),

  /// URL points directly to a publicly served media file.
  directFile('direct_file', 'Arquivo direto'),

  /// No authorization basis found — download must be refused.
  none('none', 'Não autorizado');

  const AuthorizationSource(this.wireValue, this.badgeLabel);

  /// Value used in the backend contract (section 2.2).
  final String wireValue;

  /// Text of the authorization badge shown on result cards.
  final String badgeLabel;

  /// Parses a backend wire value, failing closed to [none].
  static AuthorizationSource fromWire(String value) => values.firstWhere(
        (s) => s.wireValue == value,
        orElse: () => AuthorizationSource.none,
      );
}
