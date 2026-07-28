/// Value object for byte counts.
///
/// Responsibility: keep all size arithmetic and human formatting in one
/// place, so the UI never re-implements "MB vs GB" logic (section 8.2 asks
/// for adaptive formatting).
library;

/// Immutable byte count with adaptive human formatting.
final class FileSize implements Comparable<FileSize> {
  const FileSize._(this.bytes);

  /// Total size in bytes. Never negative.
  final int bytes;

  /// A size of zero bytes.
  static const FileSize zero = FileSize._(0);

  /// Creates a size from a byte count. Negative input is a programmer error.
  factory FileSize.ofBytes(int bytes) {
    if (bytes < 0) {
      throw ArgumentError.value(bytes, 'bytes', 'must be >= 0');
    }
    return FileSize._(bytes);
  }

  static const int _kib = 1024;

  /// Adaptive human formatting: B, KB, MB or GB with one decimal
  /// (two for GB), matching the download manager display rules.
  String get formatted {
    if (bytes < _kib) return '$bytes B';
    final kb = bytes / _kib;
    if (kb < _kib) return '${kb.toStringAsFixed(1)} KB';
    final mb = kb / _kib;
    if (mb < _kib) return '${mb.toStringAsFixed(1)} MB';
    return '${(mb / _kib).toStringAsFixed(2)} GB';
  }

  /// Sums two sizes.
  FileSize operator +(FileSize other) => FileSize._(bytes + other.bytes);

  /// Fraction of [total] this size represents, clamped to [0, 1].
  /// A zero [total] yields 0 (unknown-length downloads show indeterminate UI).
  double fractionOf(FileSize total) =>
      total.bytes == 0 ? 0 : (bytes / total.bytes).clamp(0.0, 1.0);

  @override
  int compareTo(FileSize other) => bytes.compareTo(other.bytes);

  @override
  bool operator ==(Object other) => other is FileSize && other.bytes == bytes;

  @override
  int get hashCode => bytes.hashCode;

  @override
  String toString() => 'FileSize($formatted)';
}
