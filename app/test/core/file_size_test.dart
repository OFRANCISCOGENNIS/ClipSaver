import 'package:flutter_test/flutter_test.dart';
import 'package:vidora/core/domain/value_objects/file_size.dart';

void main() {
  group('FileSize', () {
    test('rejects negative byte counts', () {
      expect(() => FileSize.ofBytes(-1), throwsArgumentError);
    });

    test('formats adaptively across magnitudes', () {
      expect(FileSize.ofBytes(0).formatted, '0 B');
      expect(FileSize.ofBytes(512).formatted, '512 B');
      expect(FileSize.ofBytes(2048).formatted, '2.0 KB');
      expect(FileSize.ofBytes(5 * 1024 * 1024).formatted, '5.0 MB');
      expect(FileSize.ofBytes(3 * 1024 * 1024 * 1024).formatted, '3.00 GB');
    });

    test('addition sums byte counts', () {
      expect(
        FileSize.ofBytes(100) + FileSize.ofBytes(50),
        FileSize.ofBytes(150),
      );
    });

    test('fractionOf computes progress and clamps', () {
      expect(FileSize.ofBytes(50).fractionOf(FileSize.ofBytes(200)), 0.25);
      expect(FileSize.ofBytes(300).fractionOf(FileSize.ofBytes(200)), 1.0);
    });

    test('fractionOf a zero total is 0 (indeterminate progress)', () {
      expect(FileSize.ofBytes(50).fractionOf(FileSize.zero), 0);
    });

    test('compares by byte count', () {
      expect(FileSize.ofBytes(1).compareTo(FileSize.ofBytes(2)), lessThan(0));
      expect(FileSize.ofBytes(2), FileSize.ofBytes(2));
    });
  });
}
