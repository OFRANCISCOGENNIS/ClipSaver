import 'package:test/test.dart';
import 'package:vidora/core/domain/value_objects/checksum.dart';

void main() {
  // SHA-256 of the empty string — a well-known constant.
  const emptySha256 =
      'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855';

  group('Checksum.create', () {
    test('accepts a valid sha256 digest, normalizing case and whitespace', () {
      const result = ChecksumAlgorithm.sha256;
      final checksum =
          Checksum.create(result, ' ${emptySha256.toUpperCase()} ');
      expect(checksum.isOk, isTrue);
      expect(checksum.valueOrNull!.hexDigest, emptySha256);
    });

    test('accepts a valid md5 digest', () {
      expect(
        Checksum.create(
          ChecksumAlgorithm.md5,
          'd41d8cd98f00b204e9800998ecf8427e',
        ).isOk,
        isTrue,
      );
    });

    test('rejects wrong length', () {
      expect(Checksum.create(ChecksumAlgorithm.sha256, 'abc').isErr, isTrue);
      expect(Checksum.create(ChecksumAlgorithm.md5, emptySha256).isErr, isTrue);
    });

    test('rejects non-hex characters', () {
      final digest = 'g${emptySha256.substring(1)}';
      expect(Checksum.create(ChecksumAlgorithm.sha256, digest).isErr, isTrue);
    });
  });

  group('Checksum.matches', () {
    test('equal digests match regardless of input case', () {
      final a =
          Checksum.create(ChecksumAlgorithm.sha256, emptySha256).valueOrNull!;
      final b = Checksum.create(
        ChecksumAlgorithm.sha256,
        emptySha256.toUpperCase(),
      ).valueOrNull!;
      expect(a.matches(b), isTrue);
    });

    test('different digests do not match', () {
      final a =
          Checksum.create(ChecksumAlgorithm.sha256, emptySha256).valueOrNull!;
      final b = Checksum.create(
        ChecksumAlgorithm.sha256,
        '${emptySha256.substring(0, 63)}0',
      ).valueOrNull!;
      expect(a.matches(b), isFalse);
    });

    test('different algorithms never match', () {
      final sha =
          Checksum.create(ChecksumAlgorithm.sha256, emptySha256).valueOrNull!;
      final md5 = Checksum.create(
        ChecksumAlgorithm.md5,
        'd41d8cd98f00b204e9800998ecf8427e',
      ).valueOrNull!;
      expect(sha.matches(md5), isFalse);
    });
  });
}
