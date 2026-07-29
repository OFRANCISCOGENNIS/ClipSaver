/// Equality, hashing and construction invariants of the domain values.
///
/// These look mechanical, and they are the ones that break quietly. Every
/// entity here is identified by `id`, so a broken `==`/`hashCode` pair
/// does not throw — it makes a `Set` accept the same download twice, a
/// `Map` lose a library entry, and a list diff rebuild the whole queue.
/// The constructor guards are the other half: they are the only thing
/// stopping an empty path or a backwards date range from reaching disk.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:vidora/core/domain/value_objects/checksum.dart';
import 'package:vidora/core/domain/value_objects/file_size.dart';
import 'package:vidora/core/domain/value_objects/license.dart';
import 'package:vidora/core/domain/value_objects/media_format.dart';
import 'package:vidora/core/domain/value_objects/media_url.dart';
import 'package:vidora/features/converter/domain/conversion_job.dart';
import 'package:vidora/features/converter/domain/conversion_request.dart';
import 'package:vidora/features/downloads/domain/download_task.dart';
import 'package:vidora/features/intelligence/domain/series_detector.dart';
import 'package:vidora/features/library/domain/library_entry.dart';
import 'package:vidora/features/library/domain/library_repository.dart';
import 'package:vidora/features/search/domain/search_query.dart';

import '../support/analyze_fakes.dart';
import '../support/download_fakes.dart';

/// Builds a conversion job with the fields the tests do not care about
/// already filled in.
ConversionJob jobFixture({String id = 'j1'}) => ConversionJob(
      id: id,
      libraryEntryId: 'e1',
      sourcePath: '/library/a.mp4',
      request: const ConversionRequest(target: ConversionTarget.mp3),
    );

/// Builds a library entry, varying only what a test asserts on.
LibraryEntry entryFixture({String id = 'e1', String title = 'Aula'}) =>
    LibraryEntry(
      id: id,
      title: title,
      filePath: '/library/$id.mp4',
      kind: MediaKind.video,
      size: FileSize.ofBytes(1024),
      downloadedAt: DateTime.utc(2026, 7, 1),
    );

void main() {
  group('identity is by id, not by contents', () {
    test('DownloadTask', () {
      final one = taskFixture(destination: '/downloads/a.mp4');
      final same = taskFixture(destination: '/downloads/b.mp4');
      final other = taskFixture(id: 't2');

      // Same id, different destination: still the same task. A queue that
      // disagreed would show one transfer as two rows.
      expect(one, same);
      expect(one.hashCode, same.hashCode);
      expect(one, isNot(other));
      expect({one, same, other}, hasLength(2));
      expect(one.toString(), contains('t1'));
    });

    test('ConversionJob', () {
      expect(jobFixture(), jobFixture());
      expect(jobFixture().hashCode, jobFixture().hashCode);
      expect(jobFixture(), isNot(jobFixture(id: 'j2')));
      expect(jobFixture().toString(), contains('mp3'));
    });

    test('LibraryEntry', () {
      final renamed = entryFixture(title: 'Aula renomeada');
      expect(entryFixture(), renamed);
      expect(entryFixture().hashCode, renamed.hashCode);
      expect(entryFixture(), isNot(entryFixture(id: 'e2')));
      expect(entryFixture().toString(), contains('available'));
    });

    test('MediaItem', () {
      expect(mediaItemFixture(), mediaItemFixture(title: 'outro título'));
      expect(
        mediaItemFixture().hashCode,
        mediaItemFixture(title: 'outro título').hashCode,
      );
      expect(mediaItemFixture(), isNot(mediaItemFixture(id: 'm2')));
      expect(mediaItemFixture().toString(), contains('eligible=true'));
    });

    test('MediaFormat', () {
      const one = MediaFormat(id: 'v720', kind: MediaKind.video, container: 'mp4');
      const same =
          MediaFormat(id: 'v720', kind: MediaKind.audio, container: 'mp3');
      expect(one.hashCode, same.hashCode);
      expect(one.toString(), contains('v720'));
    });

    test('License', () {
      expect(License.ccBy.hashCode, License.ccBy.hashCode);
      expect(License.ccBy.hashCode, isNot(License.cc0.hashCode));
      expect(License.ccBy.toString(), 'License(CC-BY-4.0)');
    });
  });

  group('value equality is by contents', () {
    test('Checksum', () {
      final digest = 'a' * 64;
      final one =
          Checksum.create(ChecksumAlgorithm.sha256, digest).valueOrNull!;
      final same = Checksum.create(
        ChecksumAlgorithm.sha256,
        digest.toUpperCase(),
      ).valueOrNull!;
      final other =
          Checksum.create(ChecksumAlgorithm.sha256, 'b' * 64).valueOrNull!;

      expect(one, same);
      expect(one.hashCode, same.hashCode);
      expect(one, isNot(other));
      expect(one.toString(), contains('sha256'));
    });

    test('DateRange', () {
      final one = DateRange(
        from: DateTime.utc(2026, 1, 1),
        to: DateTime.utc(2026, 2, 1),
      );
      final same = DateRange(
        from: DateTime.utc(2026, 1, 1),
        to: DateTime.utc(2026, 2, 1),
      );
      final other = DateRange(
        from: DateTime.utc(2026, 1, 1),
        to: DateTime.utc(2026, 3, 1),
      );

      expect(one, same);
      expect(one.hashCode, same.hashCode);
      expect(one, isNot(other));
    });

    test('LibraryCounts', () {
      const one =
          LibraryCounts(videos: 3, audios: 2, favorites: 1, trashed: 0);
      const same =
          LibraryCounts(videos: 3, audios: 2, favorites: 1, trashed: 0);
      const other =
          LibraryCounts(videos: 3, audios: 2, favorites: 1, trashed: 4);

      expect(one, same);
      expect(one.hashCode, same.hashCode);
      expect(one, isNot(other));
      expect(one.toString(), contains('videos: 3'));
    });

    test('SeriesMarker', () {
      const one = SeriesMarker(seriesName: 'Curso', season: 1, episode: 2);
      const same = SeriesMarker(seriesName: 'Curso', season: 1, episode: 2);
      const other = SeriesMarker(seriesName: 'Curso', season: 2, episode: 2);

      expect(one, same);
      expect(one.hashCode, same.hashCode);
      expect(one, isNot(other));
      expect(one.toString(), contains('Curso'));
    });

    test('SearchQuery hashes filters, and set order does not matter', () {
      SearchQuery build(Set<String> tags) => SearchQuery(
            text: 'aula',
            kind: MediaKind.video,
            platform: 'exemplo',
            durationBucket: DurationBucket.medium,
            dateRange: DateRange(
              from: DateTime.utc(2026),
              to: DateTime.utc(2026, 2),
            ),
            minSize: FileSize.ofBytes(1),
            maxSize: FileSize.ofBytes(2),
            containers: const {'mp4', 'mkv'},
            tags: tags,
          );

      // The chips render in whatever order the user tapped them; two
      // queries differing only in that order are the same query.
      expect(build({'a', 'b'}), build({'b', 'a'}));
      expect(build({'a', 'b'}).hashCode, build({'b', 'a'}).hashCode);
      expect(build({'a', 'b'}), isNot(build({'a'})));
    });
  });

  group('constructors refuse impossible values', () {
    test('DownloadTask rejects empty identifiers and out-of-range retries', () {
      DownloadTask build({
        String mediaItemId = 'm1',
        String destinationPath = '/downloads/a.mp4',
        String sourceUrl = 'https://files.example.com/a.mp4',
        int retryCount = 0,
      }) =>
          DownloadTask(
            id: 't1',
            mediaItemId: mediaItemId,
            title: 'Arquivo',
            format: const MediaFormat(
              id: 'v720',
              kind: MediaKind.video,
              container: 'mp4',
            ),
            sourceUrl: sourceUrl,
            destinationPath: destinationPath,
            createdAt: DateTime.utc(2026, 7, 1),
            retryCount: retryCount,
          );

      expect(() => build(mediaItemId: '  '), throwsArgumentError);
      expect(() => build(destinationPath: ''), throwsArgumentError);
      expect(() => build(sourceUrl: ''), throwsArgumentError);
      expect(() => build(retryCount: -1), throwsArgumentError);
      expect(
        () => build(retryCount: DownloadTask.maxRetries + 1),
        throwsArgumentError,
      );
      expect(build(retryCount: DownloadTask.maxRetries), isNotNull);
    });

    test('ConversionJob rejects empty identifiers', () {
      ConversionJob build({
        String libraryEntryId = 'e1',
        String sourcePath = '/library/a.mp4',
      }) =>
          ConversionJob(
            id: 'j1',
            libraryEntryId: libraryEntryId,
            sourcePath: sourcePath,
            request: const ConversionRequest(target: ConversionTarget.mp3),
          );

      expect(() => build(libraryEntryId: ''), throwsArgumentError);
      expect(() => build(sourcePath: '   '), throwsArgumentError);
    });

    test('LibraryEntry rejects an empty file path', () {
      expect(
        () => LibraryEntry(
          id: 'e1',
          title: 'Aula',
          filePath: '  ',
          kind: MediaKind.video,
          size: FileSize.ofBytes(1),
          downloadedAt: DateTime.utc(2026),
        ),
        throwsArgumentError,
      );
    });

    test('DateRange rejects a backwards interval', () {
      expect(
        () => DateRange(
          from: DateTime.utc(2026, 3, 1),
          to: DateTime.utc(2026, 1, 1),
        ),
        throwsArgumentError,
      );
      // Equal bounds are a single-day range, not an error.
      expect(
        DateRange(from: DateTime.utc(2026), to: DateTime.utc(2026)),
        isNotNull,
      );
    });
  });

  group('quality labels fall back in order', () {
    test('height, then bitrate, then container', () {
      const withHeight =
          MediaFormat(id: 'a', kind: MediaKind.video, container: 'mp4', height: 720);
      const withBitrate = MediaFormat(
        id: 'b',
        kind: MediaKind.audio,
        container: 'mp3',
        bitrateKbps: 128,
      );
      const bare = MediaFormat(id: 'c', kind: MediaKind.audio, container: 'flac');

      expect(withHeight.qualityLabel, '720p');
      expect(withBitrate.qualityLabel, '128 kbps');
      // Lossless audio has neither height nor a meaningful bitrate, so the
      // container is the only honest thing left to show.
      expect(bare.qualityLabel, 'FLAC');
    });
  });

  group('License.fromMetadata maps every Creative Commons URL', () {
    test('by-nc and by-nd resolve to their licenses', () {
      expect(
        License.fromMetadata('https://creativecommons.org/licenses/by-nc/4.0/'),
        License.ccByNc,
      );
      expect(
        License.fromMetadata('https://creativecommons.org/licenses/by-nd/4.0/'),
        License.ccByNd,
      );
    });

    test('an unmapped combination fails closed', () {
      // by-nc-nd is a real license this app does not model; guessing would
      // authorize a download on a license nobody checked.
      expect(
        License.fromMetadata(
          'https://creativecommons.org/licenses/by-nc-nd/4.0/',
        ),
        License.allRightsReserved,
      );
    });
  });

  group('MediaUrl', () {
    test('equal values hash equally', () {
      final one = MediaUrl.create('https://Example.com/a').valueOrNull!;
      final same = MediaUrl.create('https://example.com/a').valueOrNull!;
      expect(one, same);
      expect(one.hashCode, same.hashCode);
    });
  });
}
