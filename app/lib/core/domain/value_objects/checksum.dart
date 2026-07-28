/// Value object for file integrity checksums (section 8.3).
///
/// Responsibility: normalize and compare checksums safely so integrity
/// verification never fails on case or whitespace differences.
library;

import '../../error/failures.dart';
import '../../error/result.dart';

/// Digest algorithms the verifier understands.
enum ChecksumAlgorithm {
  /// SHA-256 (preferred).
  sha256,

  /// MD5 — accepted only because some origins still publish it.
  md5,
}

/// Validated, normalized digest for integrity verification.
final class Checksum {
  const Checksum._(this.algorithm, this.hexDigest);

  /// Algorithm that produced [hexDigest].
  final ChecksumAlgorithm algorithm;

  /// Lowercase hexadecimal digest.
  final String hexDigest;

  static const _lengths = {
    ChecksumAlgorithm.sha256: 64,
    ChecksumAlgorithm.md5: 32,
  };

  /// Validates digest shape for the given algorithm.
  static Result<Checksum> create(ChecksumAlgorithm algorithm, String digest) {
    final normalized = digest.trim().toLowerCase();
    final expected = _lengths[algorithm]!;
    final isHex = RegExp(r'^[0-9a-f]+$').hasMatch(normalized);
    if (normalized.length != expected || !isHex) {
      return Result.err(
        ValidationFailure(
          'Checksum ${algorithm.name} inválido: esperado $expected dígitos hex.',
        ),
      );
    }
    return Result.ok(Checksum._(algorithm, normalized));
  }

  /// Constant-time comparison to avoid timing side channels when the
  /// digest comes from an untrusted server header.
  bool matches(Checksum other) {
    if (other.algorithm != algorithm ||
        other.hexDigest.length != hexDigest.length) {
      return false;
    }
    var diff = 0;
    for (var i = 0; i < hexDigest.length; i++) {
      diff |= hexDigest.codeUnitAt(i) ^ other.hexDigest.codeUnitAt(i);
    }
    return diff == 0;
  }

  @override
  bool operator ==(Object other) =>
      other is Checksum &&
      other.algorithm == algorithm &&
      other.hexDigest == hexDigest;

  @override
  int get hashCode => Object.hash(algorithm, hexDigest);

  @override
  String toString() => 'Checksum(${algorithm.name}:$hexDigest)';
}
