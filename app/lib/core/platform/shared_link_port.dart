/// Incoming shared-link port.
///
/// Responsibility: the contract for "another app handed us a link". The
/// Android manifest has declared an `ACTION_SEND` filter since phase 6 and
/// the router has accepted `?url=` just as long — but nothing ever read
/// the incoming intent, so a shared link opened the app and was dropped on
/// the floor. This is the missing wire, behind an interface so the routing
/// side is testable without an Android device.
///
/// Nothing here decides whether a link may be downloaded. A shared link is
/// attacker-controlled input like any other: it lands on Analyze and goes
/// through the same server-side eligibility check as a pasted one. There
/// is no shortcut, because a shortcut here would be a compliance hole
/// dressed as a convenience.
library;

/// Delivers links shared from other apps.
abstract interface class SharedLinkPort {
  /// The link that launched the app, if it was launched by a share.
  ///
  /// Null when the app was opened normally. Reading it is not idempotent
  /// by contract — an implementation may consume the intent — so callers
  /// read it once at startup.
  Future<String?> initialLink();

  /// Links shared while the app is already running (Android delivers these
  /// as `onNewIntent` to a live activity, without a cold start).
  Stream<String> links();
}

/// Adapter for platforms with no share mechanism (desktop, web).
final class NoopSharedLinkPort implements SharedLinkPort {
  /// Creates the no-op.
  const NoopSharedLinkPort();

  @override
  Future<String?> initialLink() async => null;

  @override
  Stream<String> links() => const Stream<String>.empty();
}

/// Extracts the first plausible http(s) URL from shared text.
///
/// Share sheets rarely hand over a bare URL: apps append titles, hashtags
/// and "shared via" footers, and some put the URL last. Taking the whole
/// blob as a URL would make every real share fail validation before the
/// eligibility check even ran.
///
/// Deliberately permissive about *finding* and strict about nothing else:
/// whatever comes out still has to survive `MediaUrl` validation and the
/// server's verdict. This function's only job is to not throw away a
/// perfectly good link because it arrived with company.
String? extractSharedUrl(String? text) {
  if (text == null) return null;
  final match = RegExp(r'https?://[^\s<>"]+').firstMatch(text);
  if (match == null) return null;
  // Trailing punctuation is almost always sentence punctuation, not part
  // of the URL: "veja https://exemplo.org/aula." is one link and one dot.
  return match.group(0)!.replaceFirst(RegExp(r'[.,;:!?)\]]+$'), '');
}
