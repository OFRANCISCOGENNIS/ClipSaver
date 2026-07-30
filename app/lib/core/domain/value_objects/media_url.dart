/// Value object for a user-supplied media URL.
///
/// Responsibility: guarantee that any [MediaUrl] instance in the system is a
/// syntactically valid, http(s)-only, non-local URL. Client-side validation
/// (section 7.2 step 1) lives here; the backend re-validates with the full
/// SSRF guard, so this is defense in depth, never the only barrier.
library;

import '../../error/failures.dart';
import '../../error/result.dart';

/// Validated http(s) URL pointing outside local/private networks.
final class MediaUrl {
  const MediaUrl._(this.uri);

  /// The validated URI. Always absolute, always http or https.
  final Uri uri;

  /// Full normalized URL string.
  String get value => uri.toString();

  /// Host without credentials, lowercase.
  String get host => uri.host;

  /// Parses and validates [input]. Returns [ValidationFailure] with an
  /// explanation suitable for inline display under the URL field.
  static Result<MediaUrl> create(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) {
      return const Result.err(ValidationFailure('Informe um link.'));
    }
    final uri = Uri.tryParse(trimmed);
    if (uri == null || !uri.isAbsolute || uri.host.isEmpty) {
      return const Result.err(
        ValidationFailure('Este texto não parece ser um link válido.'),
      );
    }
    if (uri.scheme != 'http' && uri.scheme != 'https') {
      return const Result.err(
        ValidationFailure('Apenas links http(s) são suportados.'),
      );
    }
    if (uri.userInfo.isNotEmpty) {
      // user:pass@host is a classic phishing / SSRF-confusion vector.
      return const Result.err(
        ValidationFailure('Links com credenciais embutidas não são aceitos.'),
      );
    }
    if (_isLocalOrPrivateHost(uri.host)) {
      return const Result.err(
        ValidationFailure('Links para endereços locais não são aceitos.'),
      );
    }
    return Result.ok(MediaUrl._(uri.replace(host: uri.host.toLowerCase())));
  }

  /// The file extension of the URL path, lowercase and without the dot,
  /// or empty when the path has none. Used by the direct-file heuristic.
  String get pathExtension {
    final segments = uri.pathSegments;
    if (segments.isEmpty) return '';
    final last = segments.last;
    final dot = last.lastIndexOf('.');
    if (dot <= 0 || dot == last.length - 1) return '';
    return last.substring(dot + 1).toLowerCase();
  }

  static bool _isLocalOrPrivateHost(String host) {
    final h = host.toLowerCase();
    if (h == 'localhost' || h.endsWith('.localhost') || h.endsWith('.local')) {
      return true;
    }
    // IPv6 loopback / link-local literals arrive bracket-stripped from Uri.
    if (h == '::1' ||
        h.startsWith('fe80:') ||
        h.startsWith('fc') ||
        h.startsWith('fd')) {
      return true;
    }
    final ipv4 =
        RegExp(r'^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})$').firstMatch(h);
    if (ipv4 == null) return false;
    final octets =
        List.generate(4, (i) => int.parse(ipv4.group(i + 1)!), growable: false);
    if (octets.any((o) => o > 255)) return true; // malformed → reject
    final (a, b) = (octets[0], octets[1]);
    return a == 0 || // "this network"
        a == 10 ||
        a == 127 ||
        (a == 100 && b >= 64 && b <= 127) || // CGNAT
        (a == 169 && b == 254) || // link-local & cloud metadata
        (a == 172 && b >= 16 && b <= 31) ||
        (a == 192 && b == 168);
  }

  @override
  bool operator ==(Object other) => other is MediaUrl && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'MediaUrl($value)';
}
