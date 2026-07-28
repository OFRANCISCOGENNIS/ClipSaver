import 'package:test/test.dart';
import 'package:vidora/core/domain/value_objects/media_url.dart';
import 'package:vidora/core/error/failures.dart';

void main() {
  group('MediaUrl.create', () {
    test('accepts a plain https URL and normalizes the host', () {
      final result = MediaUrl.create('https://Example.COM/video.mp4');
      expect(result.isOk, isTrue);
      expect(result.valueOrNull!.host, 'example.com');
      expect(result.valueOrNull!.pathExtension, 'mp4');
    });

    test('accepts http URLs', () {
      expect(MediaUrl.create('http://example.org/ep.mp3').isOk, isTrue);
    });

    test('trims surrounding whitespace', () {
      final result = MediaUrl.create('  https://example.com/a.mp4  ');
      expect(result.isOk, isTrue);
    });

    test('rejects empty input with a user-facing message', () {
      final result = MediaUrl.create('   ');
      expect(result.failureOrNull, isA<ValidationFailure>());
    });

    test('rejects non-URL text', () {
      expect(MediaUrl.create('not a url').isErr, isTrue);
    });

    test('rejects unsupported schemes', () {
      expect(MediaUrl.create('ftp://example.com/a.mp4').isErr, isTrue);
      expect(MediaUrl.create('file:///etc/passwd').isErr, isTrue);
      expect(MediaUrl.create('javascript:alert(1)').isErr, isTrue);
    });

    test('rejects embedded credentials', () {
      expect(
        MediaUrl.create('https://user:pass@example.com/a.mp4').isErr,
        isTrue,
      );
    });

    test('rejects localhost and .local hosts', () {
      expect(MediaUrl.create('http://localhost/a.mp4').isErr, isTrue);
      expect(MediaUrl.create('http://foo.localhost/a.mp4').isErr, isTrue);
      expect(MediaUrl.create('http://nas.local/a.mp4').isErr, isTrue);
    });

    test('rejects private, loopback, link-local and CGNAT IPv4 ranges', () {
      for (final host in [
        '10.0.0.5',
        '127.0.0.1',
        '169.254.169.254', // cloud metadata endpoint
        '172.16.0.1',
        '172.31.255.255',
        '192.168.1.10',
        '100.64.0.1',
        '0.0.0.0',
      ]) {
        expect(
          MediaUrl.create('http://$host/a.mp4').isErr,
          isTrue,
          reason: '$host must be rejected',
        );
      }
    });

    test('accepts public IPv4 addresses', () {
      expect(MediaUrl.create('http://203.0.113.7/a.mp4').isOk, isTrue);
      expect(MediaUrl.create('http://172.32.0.1/a.mp4').isOk, isTrue);
    });

    test('rejects IPv6 loopback and unique-local literals', () {
      expect(MediaUrl.create('http://[::1]/a.mp4').isErr, isTrue);
      expect(MediaUrl.create('http://[fd00::1]/a.mp4').isErr, isTrue);
      expect(MediaUrl.create('http://[fe80::1]/a.mp4').isErr, isTrue);
    });

    test('pathExtension is empty when the path has no extension', () {
      final result = MediaUrl.create('https://example.com/watch');
      expect(result.valueOrNull!.pathExtension, isEmpty);
    });

    test('equality is by normalized value', () {
      final a = MediaUrl.create('https://example.com/a.mp4').valueOrNull;
      final b = MediaUrl.create('https://EXAMPLE.com/a.mp4').valueOrNull;
      expect(a, equals(b));
    });
  });
}
