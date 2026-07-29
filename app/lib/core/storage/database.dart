/// Local database (drift/SQLite) — section 5: "reativo, tipado,
/// migrations versionadas".
///
/// Responsibility: define the relational schema for downloads, library
/// and analysis history. Repositories in each feature's infrastructure
/// layer map these rows to domain entities; domain types never leak into
/// the schema and vice versa.
library;

import 'package:drift/drift.dart';

import 'search_index.dart';

part 'database.g.dart';

/// Download queue persistence (feature `downloads`).
class DownloadTaskRows extends Table {
  /// Task id (uuid).
  TextColumn get id => text()();

  /// Analyzed media item this task materializes.
  TextColumn get mediaItemId => text()();

  /// Denormalized title for queue rendering.
  TextColumn get title => text()();

  /// Chosen rendition, flattened.
  TextColumn get formatId => text()();

  /// 'video' | 'audio'.
  TextColumn get formatKind => text()();

  /// Container without dot (mp4, mp3…).
  TextColumn get formatContainer => text()();

  /// Codec, when known.
  TextColumn get formatCodec => text().nullable()();

  /// Vertical resolution for video renditions.
  IntColumn get formatHeight => integer().nullable()();

  /// Average bitrate, when known.
  IntColumn get formatBitrateKbps => integer().nullable()();

  /// Resolved source URL, so a queued download resumes after a restart.
  TextColumn get sourceUrl => text()();

  /// Final destination path.
  TextColumn get destinationPath => text()();

  /// DownloadState name (queued, downloading…).
  TextColumn get state => text()();

  /// Bytes received so far.
  IntColumn get bytesDownloaded => integer().withDefault(const Constant(0))();

  /// Content-Length when known.
  IntColumn get totalBytes => integer().nullable()();

  /// 'sha256' | 'md5', when the origin published a checksum.
  TextColumn get checksumAlgorithm => text().nullable()();

  /// Lowercase hex digest, when published.
  TextColumn get checksumHex => text().nullable()();

  /// Queue priority; lower runs first.
  IntColumn get priority => integer().withDefault(const Constant(0))();

  /// Retries consumed.
  IntColumn get retryCount => integer().withDefault(const Constant(0))();

  /// User-facing failure reason while state == failed.
  TextColumn get failureReason => text().nullable()();

  /// Enqueue timestamp.
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Library persistence (feature `library`).
class LibraryEntryRows extends Table {
  /// Entry id (uuid).
  TextColumn get id => text()();

  /// Display title.
  TextColumn get title => text()();

  /// Absolute file path.
  TextColumn get filePath => text()();

  /// 'video' | 'audio'.
  TextColumn get kind => text()();

  /// File size in bytes.
  IntColumn get sizeBytes => integer()();

  /// Media duration in milliseconds, when known.
  IntColumn get durationMs => integer().nullable()();

  /// Author/channel from the origin metadata. Searchable (section 10).
  TextColumn get author => text().nullable()();

  /// Origin platform slug for the badge.
  TextColumn get platform => text().nullable()();

  /// License SPDX id for the badge; null for owned/official content.
  TextColumn get licenseSpdxId => text().nullable()();

  /// Favorite flag.
  BoolColumn get favorite => boolean().withDefault(const Constant(false))();

  /// JSON array of user tags.
  TextColumn get tagsJson => text().withDefault(const Constant('[]'))();

  /// LibraryFileStatus name (available, missing, trashed).
  TextColumn get status => text()();

  /// Download completion timestamp.
  DateTimeColumn get downloadedAt => dateTime()();

  /// Trash entry timestamp; set iff status == trashed.
  DateTimeColumn get trashedAt => dateTime().nullable()();

  /// Last playback; null means never played (section 15).
  DateTimeColumn get lastPlayedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Analysis history (feature `analyze`, section 9: histórico separado).
class AnalysisHistoryRows extends Table {
  /// Analysis id (sha256 of the URL, mirrors the backend).
  TextColumn get id => text()();

  /// Analyzed URL.
  TextColumn get url => text()();

  /// Title from origin metadata, or the URL as fallback.
  TextColumn get title => text()();

  /// Author, when reported.
  TextColumn get author => text().nullable()();

  /// Thumbnail URL, when reported.
  TextColumn get thumbnailUrl => text().nullable()();

  /// Verdict flag.
  BoolColumn get eligible => boolean()();

  /// AuthorizationSource wire value.
  TextColumn get source => text()();

  /// License SPDX id, when open-licensed.
  TextColumn get licenseSpdxId => text().nullable()();

  /// User-facing reason of the verdict.
  TextColumn get reason => text()();

  /// JSON array of restriction strings.
  TextColumn get restrictionsJson => text().withDefault(const Constant('[]'))();

  /// JSON array of MediaFormat wire objects.
  TextColumn get formatsJson => text().withDefault(const Constant('[]'))();

  /// When this analysis ran (latest wins for the same id).
  DateTimeColumn get analyzedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Key-value store for user preferences (section 16).
///
/// One row holding the whole settings JSON, rather than a column per
/// preference: settings change shape often, and a schema migration for
/// every new toggle would be pure friction.
class PreferenceRows extends Table {
  /// Preference key.
  TextColumn get key => text()();

  /// JSON-encoded value.
  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}

/// The app database. Schema changes bump [schemaVersion] and add a
/// migration step — never edit an existing step.
@DriftDatabase(
  tables: [
    DownloadTaskRows,
    LibraryEntryRows,
    AnalysisHistoryRows,
    PreferenceRows,
  ],
)
class AppDatabase extends _$AppDatabase {
  /// Opens the database on [executor] (NativeDatabase file/memory).
  AppDatabase(super.executor);

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await customStatement(kSearchTableDdl);
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            // v2 adds the searchable author column and the FTS5 index.
            await m.addColumn(libraryEntryRows, libraryEntryRows.author);
            await customStatement(kSearchTableDdl);
          }
          if (from < 4) {
            // v4 adds the preferences store.
            await m.createTable(preferenceRows);
          }
          if (from < 3) {
            // v3 tracks playback so the storage report can spot items
            // that were downloaded and never opened.
            await m.addColumn(
              libraryEntryRows,
              libraryEntryRows.lastPlayedAt,
            );
          }
        },
        beforeOpen: (details) async {
          // Foreign keys are off by default in SQLite and must be enabled
          // per connection, not once per database.
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );
}
