import 'package:flutter_test/flutter_test.dart';
import 'package:vidora/core/domain/value_objects/file_size.dart';
import 'package:vidora/core/domain/value_objects/license.dart';
import 'package:vidora/core/domain/value_objects/media_format.dart';
import 'package:vidora/features/library/domain/library_entry.dart';

void main() {
  final downloadedAt = DateTime.utc(2026, 7, 1);

  LibraryEntry entry({
    LibraryFileStatus status = LibraryFileStatus.available,
    DateTime? trashedAt,
  }) =>
      LibraryEntry(
        id: 'l1',
        title: 'Aula de Flutter',
        filePath: '/library/aula.mp4',
        kind: MediaKind.video,
        size: FileSize.ofBytes(1024 * 1024),
        downloadedAt: downloadedAt,
        license: License.ccBy,
        status: status,
        trashedAt: trashedAt,
      );

  group('LibraryEntry trash lifecycle', () {
    test('trashed entries must carry trashedAt — and only they may', () {
      expect(
        () => entry(status: LibraryFileStatus.trashed),
        throwsArgumentError,
      );
      expect(() => entry(trashedAt: downloadedAt), throwsArgumentError);
      expect(
        entry(status: LibraryFileStatus.trashed, trashedAt: downloadedAt)
            .status,
        LibraryFileStatus.trashed,
      );
    });

    test('trash expires after the 7-day retention window', () {
      final trashed = entry(
        status: LibraryFileStatus.trashed,
        trashedAt: DateTime.utc(2026, 7, 10),
      );
      expect(trashed.isTrashExpired(DateTime.utc(2026, 7, 16)), isFalse);
      expect(trashed.isTrashExpired(DateTime.utc(2026, 7, 17)), isTrue);
    });

    test('available entries never report trash expiry', () {
      expect(entry().isTrashExpired(DateTime.utc(2030)), isFalse);
    });

    test('copyWith can restore from trash clearing trashedAt', () {
      final restored = entry(
        status: LibraryFileStatus.trashed,
        trashedAt: downloadedAt,
      ).copyWith(status: LibraryFileStatus.available, clearTrashedAt: true);
      expect(restored.status, LibraryFileStatus.available);
      expect(restored.trashedAt, isNull);
    });
  });

  group('LibraryEntry playability and metadata', () {
    test('only available entries are playable', () {
      expect(entry().isPlayable, isTrue);
      expect(entry(status: LibraryFileStatus.missing).isPlayable, isFalse);
    });

    test('tags list is immutable to callers', () {
      final tagged = entry().copyWith(tags: ['flutter']);
      expect(() => tagged.tags.add('x'), throwsUnsupportedError);
    });

    test('license badge data is carried for the UI', () {
      expect(entry().license, License.ccBy);
    });

    test('constructor rejects blank required fields', () {
      expect(
        () => LibraryEntry(
          id: 'x',
          title: ' ',
          filePath: '/f',
          kind: MediaKind.audio,
          size: FileSize.zero,
          downloadedAt: downloadedAt,
        ),
        throwsArgumentError,
      );
    });
  });
}
