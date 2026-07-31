/// Routes an incoming shared link to the Analyze screen.
///
/// Kept out of `main.dart` so it can be tested without a real app: the
/// interesting behaviour is the URL that comes out the other side, and
/// asserting on a location string beats booting a widget tree.
library;

import 'router.dart';

/// The location a shared [url] should open.
///
/// Percent-encoded, always. A YouTube-style link carries `?v=…&t=…`, and
/// pasting that raw into a query string would make `&t=` a second
/// parameter of *our* route instead of part of the shared URL — the app
/// would then analyze a truncated link and blame the user for it.
String analyzeLocationFor(String url) =>
    '${Routes.analyze}?$kSharedUrlParam=${Uri.encodeComponent(url)}';
