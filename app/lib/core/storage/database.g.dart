// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $DownloadTaskRowsTable extends DownloadTaskRows
    with TableInfo<$DownloadTaskRowsTable, DownloadTaskRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DownloadTaskRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _mediaItemIdMeta =
      const VerificationMeta('mediaItemId');
  @override
  late final GeneratedColumn<String> mediaItemId = GeneratedColumn<String>(
      'media_item_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _formatIdMeta =
      const VerificationMeta('formatId');
  @override
  late final GeneratedColumn<String> formatId = GeneratedColumn<String>(
      'format_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _formatKindMeta =
      const VerificationMeta('formatKind');
  @override
  late final GeneratedColumn<String> formatKind = GeneratedColumn<String>(
      'format_kind', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _formatContainerMeta =
      const VerificationMeta('formatContainer');
  @override
  late final GeneratedColumn<String> formatContainer = GeneratedColumn<String>(
      'format_container', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _formatCodecMeta =
      const VerificationMeta('formatCodec');
  @override
  late final GeneratedColumn<String> formatCodec = GeneratedColumn<String>(
      'format_codec', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _formatHeightMeta =
      const VerificationMeta('formatHeight');
  @override
  late final GeneratedColumn<int> formatHeight = GeneratedColumn<int>(
      'format_height', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _formatBitrateKbpsMeta =
      const VerificationMeta('formatBitrateKbps');
  @override
  late final GeneratedColumn<int> formatBitrateKbps = GeneratedColumn<int>(
      'format_bitrate_kbps', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _destinationPathMeta =
      const VerificationMeta('destinationPath');
  @override
  late final GeneratedColumn<String> destinationPath = GeneratedColumn<String>(
      'destination_path', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
      'state', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _bytesDownloadedMeta =
      const VerificationMeta('bytesDownloaded');
  @override
  late final GeneratedColumn<int> bytesDownloaded = GeneratedColumn<int>(
      'bytes_downloaded', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _totalBytesMeta =
      const VerificationMeta('totalBytes');
  @override
  late final GeneratedColumn<int> totalBytes = GeneratedColumn<int>(
      'total_bytes', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _checksumAlgorithmMeta =
      const VerificationMeta('checksumAlgorithm');
  @override
  late final GeneratedColumn<String> checksumAlgorithm =
      GeneratedColumn<String>('checksum_algorithm', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _checksumHexMeta =
      const VerificationMeta('checksumHex');
  @override
  late final GeneratedColumn<String> checksumHex = GeneratedColumn<String>(
      'checksum_hex', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _priorityMeta =
      const VerificationMeta('priority');
  @override
  late final GeneratedColumn<int> priority = GeneratedColumn<int>(
      'priority', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _retryCountMeta =
      const VerificationMeta('retryCount');
  @override
  late final GeneratedColumn<int> retryCount = GeneratedColumn<int>(
      'retry_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _failureReasonMeta =
      const VerificationMeta('failureReason');
  @override
  late final GeneratedColumn<String> failureReason = GeneratedColumn<String>(
      'failure_reason', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        mediaItemId,
        title,
        formatId,
        formatKind,
        formatContainer,
        formatCodec,
        formatHeight,
        formatBitrateKbps,
        destinationPath,
        state,
        bytesDownloaded,
        totalBytes,
        checksumAlgorithm,
        checksumHex,
        priority,
        retryCount,
        failureReason,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'download_task_rows';
  @override
  VerificationContext validateIntegrity(Insertable<DownloadTaskRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('media_item_id')) {
      context.handle(
          _mediaItemIdMeta,
          mediaItemId.isAcceptableOrUnknown(
              data['media_item_id']!, _mediaItemIdMeta));
    } else if (isInserting) {
      context.missing(_mediaItemIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('format_id')) {
      context.handle(_formatIdMeta,
          formatId.isAcceptableOrUnknown(data['format_id']!, _formatIdMeta));
    } else if (isInserting) {
      context.missing(_formatIdMeta);
    }
    if (data.containsKey('format_kind')) {
      context.handle(
          _formatKindMeta,
          formatKind.isAcceptableOrUnknown(
              data['format_kind']!, _formatKindMeta));
    } else if (isInserting) {
      context.missing(_formatKindMeta);
    }
    if (data.containsKey('format_container')) {
      context.handle(
          _formatContainerMeta,
          formatContainer.isAcceptableOrUnknown(
              data['format_container']!, _formatContainerMeta));
    } else if (isInserting) {
      context.missing(_formatContainerMeta);
    }
    if (data.containsKey('format_codec')) {
      context.handle(
          _formatCodecMeta,
          formatCodec.isAcceptableOrUnknown(
              data['format_codec']!, _formatCodecMeta));
    }
    if (data.containsKey('format_height')) {
      context.handle(
          _formatHeightMeta,
          formatHeight.isAcceptableOrUnknown(
              data['format_height']!, _formatHeightMeta));
    }
    if (data.containsKey('format_bitrate_kbps')) {
      context.handle(
          _formatBitrateKbpsMeta,
          formatBitrateKbps.isAcceptableOrUnknown(
              data['format_bitrate_kbps']!, _formatBitrateKbpsMeta));
    }
    if (data.containsKey('destination_path')) {
      context.handle(
          _destinationPathMeta,
          destinationPath.isAcceptableOrUnknown(
              data['destination_path']!, _destinationPathMeta));
    } else if (isInserting) {
      context.missing(_destinationPathMeta);
    }
    if (data.containsKey('state')) {
      context.handle(
          _stateMeta, state.isAcceptableOrUnknown(data['state']!, _stateMeta));
    } else if (isInserting) {
      context.missing(_stateMeta);
    }
    if (data.containsKey('bytes_downloaded')) {
      context.handle(
          _bytesDownloadedMeta,
          bytesDownloaded.isAcceptableOrUnknown(
              data['bytes_downloaded']!, _bytesDownloadedMeta));
    }
    if (data.containsKey('total_bytes')) {
      context.handle(
          _totalBytesMeta,
          totalBytes.isAcceptableOrUnknown(
              data['total_bytes']!, _totalBytesMeta));
    }
    if (data.containsKey('checksum_algorithm')) {
      context.handle(
          _checksumAlgorithmMeta,
          checksumAlgorithm.isAcceptableOrUnknown(
              data['checksum_algorithm']!, _checksumAlgorithmMeta));
    }
    if (data.containsKey('checksum_hex')) {
      context.handle(
          _checksumHexMeta,
          checksumHex.isAcceptableOrUnknown(
              data['checksum_hex']!, _checksumHexMeta));
    }
    if (data.containsKey('priority')) {
      context.handle(_priorityMeta,
          priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta));
    }
    if (data.containsKey('retry_count')) {
      context.handle(
          _retryCountMeta,
          retryCount.isAcceptableOrUnknown(
              data['retry_count']!, _retryCountMeta));
    }
    if (data.containsKey('failure_reason')) {
      context.handle(
          _failureReasonMeta,
          failureReason.isAcceptableOrUnknown(
              data['failure_reason']!, _failureReasonMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DownloadTaskRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DownloadTaskRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      mediaItemId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}media_item_id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      formatId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}format_id'])!,
      formatKind: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}format_kind'])!,
      formatContainer: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}format_container'])!,
      formatCodec: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}format_codec']),
      formatHeight: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}format_height']),
      formatBitrateKbps: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}format_bitrate_kbps']),
      destinationPath: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}destination_path'])!,
      state: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}state'])!,
      bytesDownloaded: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}bytes_downloaded'])!,
      totalBytes: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}total_bytes']),
      checksumAlgorithm: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}checksum_algorithm']),
      checksumHex: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}checksum_hex']),
      priority: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}priority'])!,
      retryCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}retry_count'])!,
      failureReason: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}failure_reason']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $DownloadTaskRowsTable createAlias(String alias) {
    return $DownloadTaskRowsTable(attachedDatabase, alias);
  }
}

class DownloadTaskRow extends DataClass implements Insertable<DownloadTaskRow> {
  /// Task id (uuid).
  final String id;

  /// Analyzed media item this task materializes.
  final String mediaItemId;

  /// Denormalized title for queue rendering.
  final String title;

  /// Chosen rendition, flattened.
  final String formatId;

  /// 'video' | 'audio'.
  final String formatKind;

  /// Container without dot (mp4, mp3…).
  final String formatContainer;

  /// Codec, when known.
  final String? formatCodec;

  /// Vertical resolution for video renditions.
  final int? formatHeight;

  /// Average bitrate, when known.
  final int? formatBitrateKbps;

  /// Final destination path.
  final String destinationPath;

  /// DownloadState name (queued, downloading…).
  final String state;

  /// Bytes received so far.
  final int bytesDownloaded;

  /// Content-Length when known.
  final int? totalBytes;

  /// 'sha256' | 'md5', when the origin published a checksum.
  final String? checksumAlgorithm;

  /// Lowercase hex digest, when published.
  final String? checksumHex;

  /// Queue priority; lower runs first.
  final int priority;

  /// Retries consumed.
  final int retryCount;

  /// User-facing failure reason while state == failed.
  final String? failureReason;

  /// Enqueue timestamp.
  final DateTime createdAt;
  const DownloadTaskRow(
      {required this.id,
      required this.mediaItemId,
      required this.title,
      required this.formatId,
      required this.formatKind,
      required this.formatContainer,
      this.formatCodec,
      this.formatHeight,
      this.formatBitrateKbps,
      required this.destinationPath,
      required this.state,
      required this.bytesDownloaded,
      this.totalBytes,
      this.checksumAlgorithm,
      this.checksumHex,
      required this.priority,
      required this.retryCount,
      this.failureReason,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['media_item_id'] = Variable<String>(mediaItemId);
    map['title'] = Variable<String>(title);
    map['format_id'] = Variable<String>(formatId);
    map['format_kind'] = Variable<String>(formatKind);
    map['format_container'] = Variable<String>(formatContainer);
    if (!nullToAbsent || formatCodec != null) {
      map['format_codec'] = Variable<String>(formatCodec);
    }
    if (!nullToAbsent || formatHeight != null) {
      map['format_height'] = Variable<int>(formatHeight);
    }
    if (!nullToAbsent || formatBitrateKbps != null) {
      map['format_bitrate_kbps'] = Variable<int>(formatBitrateKbps);
    }
    map['destination_path'] = Variable<String>(destinationPath);
    map['state'] = Variable<String>(state);
    map['bytes_downloaded'] = Variable<int>(bytesDownloaded);
    if (!nullToAbsent || totalBytes != null) {
      map['total_bytes'] = Variable<int>(totalBytes);
    }
    if (!nullToAbsent || checksumAlgorithm != null) {
      map['checksum_algorithm'] = Variable<String>(checksumAlgorithm);
    }
    if (!nullToAbsent || checksumHex != null) {
      map['checksum_hex'] = Variable<String>(checksumHex);
    }
    map['priority'] = Variable<int>(priority);
    map['retry_count'] = Variable<int>(retryCount);
    if (!nullToAbsent || failureReason != null) {
      map['failure_reason'] = Variable<String>(failureReason);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  DownloadTaskRowsCompanion toCompanion(bool nullToAbsent) {
    return DownloadTaskRowsCompanion(
      id: Value(id),
      mediaItemId: Value(mediaItemId),
      title: Value(title),
      formatId: Value(formatId),
      formatKind: Value(formatKind),
      formatContainer: Value(formatContainer),
      formatCodec: formatCodec == null && nullToAbsent
          ? const Value.absent()
          : Value(formatCodec),
      formatHeight: formatHeight == null && nullToAbsent
          ? const Value.absent()
          : Value(formatHeight),
      formatBitrateKbps: formatBitrateKbps == null && nullToAbsent
          ? const Value.absent()
          : Value(formatBitrateKbps),
      destinationPath: Value(destinationPath),
      state: Value(state),
      bytesDownloaded: Value(bytesDownloaded),
      totalBytes: totalBytes == null && nullToAbsent
          ? const Value.absent()
          : Value(totalBytes),
      checksumAlgorithm: checksumAlgorithm == null && nullToAbsent
          ? const Value.absent()
          : Value(checksumAlgorithm),
      checksumHex: checksumHex == null && nullToAbsent
          ? const Value.absent()
          : Value(checksumHex),
      priority: Value(priority),
      retryCount: Value(retryCount),
      failureReason: failureReason == null && nullToAbsent
          ? const Value.absent()
          : Value(failureReason),
      createdAt: Value(createdAt),
    );
  }

  factory DownloadTaskRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DownloadTaskRow(
      id: serializer.fromJson<String>(json['id']),
      mediaItemId: serializer.fromJson<String>(json['mediaItemId']),
      title: serializer.fromJson<String>(json['title']),
      formatId: serializer.fromJson<String>(json['formatId']),
      formatKind: serializer.fromJson<String>(json['formatKind']),
      formatContainer: serializer.fromJson<String>(json['formatContainer']),
      formatCodec: serializer.fromJson<String?>(json['formatCodec']),
      formatHeight: serializer.fromJson<int?>(json['formatHeight']),
      formatBitrateKbps: serializer.fromJson<int?>(json['formatBitrateKbps']),
      destinationPath: serializer.fromJson<String>(json['destinationPath']),
      state: serializer.fromJson<String>(json['state']),
      bytesDownloaded: serializer.fromJson<int>(json['bytesDownloaded']),
      totalBytes: serializer.fromJson<int?>(json['totalBytes']),
      checksumAlgorithm:
          serializer.fromJson<String?>(json['checksumAlgorithm']),
      checksumHex: serializer.fromJson<String?>(json['checksumHex']),
      priority: serializer.fromJson<int>(json['priority']),
      retryCount: serializer.fromJson<int>(json['retryCount']),
      failureReason: serializer.fromJson<String?>(json['failureReason']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'mediaItemId': serializer.toJson<String>(mediaItemId),
      'title': serializer.toJson<String>(title),
      'formatId': serializer.toJson<String>(formatId),
      'formatKind': serializer.toJson<String>(formatKind),
      'formatContainer': serializer.toJson<String>(formatContainer),
      'formatCodec': serializer.toJson<String?>(formatCodec),
      'formatHeight': serializer.toJson<int?>(formatHeight),
      'formatBitrateKbps': serializer.toJson<int?>(formatBitrateKbps),
      'destinationPath': serializer.toJson<String>(destinationPath),
      'state': serializer.toJson<String>(state),
      'bytesDownloaded': serializer.toJson<int>(bytesDownloaded),
      'totalBytes': serializer.toJson<int?>(totalBytes),
      'checksumAlgorithm': serializer.toJson<String?>(checksumAlgorithm),
      'checksumHex': serializer.toJson<String?>(checksumHex),
      'priority': serializer.toJson<int>(priority),
      'retryCount': serializer.toJson<int>(retryCount),
      'failureReason': serializer.toJson<String?>(failureReason),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  DownloadTaskRow copyWith(
          {String? id,
          String? mediaItemId,
          String? title,
          String? formatId,
          String? formatKind,
          String? formatContainer,
          Value<String?> formatCodec = const Value.absent(),
          Value<int?> formatHeight = const Value.absent(),
          Value<int?> formatBitrateKbps = const Value.absent(),
          String? destinationPath,
          String? state,
          int? bytesDownloaded,
          Value<int?> totalBytes = const Value.absent(),
          Value<String?> checksumAlgorithm = const Value.absent(),
          Value<String?> checksumHex = const Value.absent(),
          int? priority,
          int? retryCount,
          Value<String?> failureReason = const Value.absent(),
          DateTime? createdAt}) =>
      DownloadTaskRow(
        id: id ?? this.id,
        mediaItemId: mediaItemId ?? this.mediaItemId,
        title: title ?? this.title,
        formatId: formatId ?? this.formatId,
        formatKind: formatKind ?? this.formatKind,
        formatContainer: formatContainer ?? this.formatContainer,
        formatCodec: formatCodec.present ? formatCodec.value : this.formatCodec,
        formatHeight:
            formatHeight.present ? formatHeight.value : this.formatHeight,
        formatBitrateKbps: formatBitrateKbps.present
            ? formatBitrateKbps.value
            : this.formatBitrateKbps,
        destinationPath: destinationPath ?? this.destinationPath,
        state: state ?? this.state,
        bytesDownloaded: bytesDownloaded ?? this.bytesDownloaded,
        totalBytes: totalBytes.present ? totalBytes.value : this.totalBytes,
        checksumAlgorithm: checksumAlgorithm.present
            ? checksumAlgorithm.value
            : this.checksumAlgorithm,
        checksumHex: checksumHex.present ? checksumHex.value : this.checksumHex,
        priority: priority ?? this.priority,
        retryCount: retryCount ?? this.retryCount,
        failureReason:
            failureReason.present ? failureReason.value : this.failureReason,
        createdAt: createdAt ?? this.createdAt,
      );
  DownloadTaskRow copyWithCompanion(DownloadTaskRowsCompanion data) {
    return DownloadTaskRow(
      id: data.id.present ? data.id.value : this.id,
      mediaItemId:
          data.mediaItemId.present ? data.mediaItemId.value : this.mediaItemId,
      title: data.title.present ? data.title.value : this.title,
      formatId: data.formatId.present ? data.formatId.value : this.formatId,
      formatKind:
          data.formatKind.present ? data.formatKind.value : this.formatKind,
      formatContainer: data.formatContainer.present
          ? data.formatContainer.value
          : this.formatContainer,
      formatCodec:
          data.formatCodec.present ? data.formatCodec.value : this.formatCodec,
      formatHeight: data.formatHeight.present
          ? data.formatHeight.value
          : this.formatHeight,
      formatBitrateKbps: data.formatBitrateKbps.present
          ? data.formatBitrateKbps.value
          : this.formatBitrateKbps,
      destinationPath: data.destinationPath.present
          ? data.destinationPath.value
          : this.destinationPath,
      state: data.state.present ? data.state.value : this.state,
      bytesDownloaded: data.bytesDownloaded.present
          ? data.bytesDownloaded.value
          : this.bytesDownloaded,
      totalBytes:
          data.totalBytes.present ? data.totalBytes.value : this.totalBytes,
      checksumAlgorithm: data.checksumAlgorithm.present
          ? data.checksumAlgorithm.value
          : this.checksumAlgorithm,
      checksumHex:
          data.checksumHex.present ? data.checksumHex.value : this.checksumHex,
      priority: data.priority.present ? data.priority.value : this.priority,
      retryCount:
          data.retryCount.present ? data.retryCount.value : this.retryCount,
      failureReason: data.failureReason.present
          ? data.failureReason.value
          : this.failureReason,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DownloadTaskRow(')
          ..write('id: $id, ')
          ..write('mediaItemId: $mediaItemId, ')
          ..write('title: $title, ')
          ..write('formatId: $formatId, ')
          ..write('formatKind: $formatKind, ')
          ..write('formatContainer: $formatContainer, ')
          ..write('formatCodec: $formatCodec, ')
          ..write('formatHeight: $formatHeight, ')
          ..write('formatBitrateKbps: $formatBitrateKbps, ')
          ..write('destinationPath: $destinationPath, ')
          ..write('state: $state, ')
          ..write('bytesDownloaded: $bytesDownloaded, ')
          ..write('totalBytes: $totalBytes, ')
          ..write('checksumAlgorithm: $checksumAlgorithm, ')
          ..write('checksumHex: $checksumHex, ')
          ..write('priority: $priority, ')
          ..write('retryCount: $retryCount, ')
          ..write('failureReason: $failureReason, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      mediaItemId,
      title,
      formatId,
      formatKind,
      formatContainer,
      formatCodec,
      formatHeight,
      formatBitrateKbps,
      destinationPath,
      state,
      bytesDownloaded,
      totalBytes,
      checksumAlgorithm,
      checksumHex,
      priority,
      retryCount,
      failureReason,
      createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DownloadTaskRow &&
          other.id == this.id &&
          other.mediaItemId == this.mediaItemId &&
          other.title == this.title &&
          other.formatId == this.formatId &&
          other.formatKind == this.formatKind &&
          other.formatContainer == this.formatContainer &&
          other.formatCodec == this.formatCodec &&
          other.formatHeight == this.formatHeight &&
          other.formatBitrateKbps == this.formatBitrateKbps &&
          other.destinationPath == this.destinationPath &&
          other.state == this.state &&
          other.bytesDownloaded == this.bytesDownloaded &&
          other.totalBytes == this.totalBytes &&
          other.checksumAlgorithm == this.checksumAlgorithm &&
          other.checksumHex == this.checksumHex &&
          other.priority == this.priority &&
          other.retryCount == this.retryCount &&
          other.failureReason == this.failureReason &&
          other.createdAt == this.createdAt);
}

class DownloadTaskRowsCompanion extends UpdateCompanion<DownloadTaskRow> {
  final Value<String> id;
  final Value<String> mediaItemId;
  final Value<String> title;
  final Value<String> formatId;
  final Value<String> formatKind;
  final Value<String> formatContainer;
  final Value<String?> formatCodec;
  final Value<int?> formatHeight;
  final Value<int?> formatBitrateKbps;
  final Value<String> destinationPath;
  final Value<String> state;
  final Value<int> bytesDownloaded;
  final Value<int?> totalBytes;
  final Value<String?> checksumAlgorithm;
  final Value<String?> checksumHex;
  final Value<int> priority;
  final Value<int> retryCount;
  final Value<String?> failureReason;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const DownloadTaskRowsCompanion({
    this.id = const Value.absent(),
    this.mediaItemId = const Value.absent(),
    this.title = const Value.absent(),
    this.formatId = const Value.absent(),
    this.formatKind = const Value.absent(),
    this.formatContainer = const Value.absent(),
    this.formatCodec = const Value.absent(),
    this.formatHeight = const Value.absent(),
    this.formatBitrateKbps = const Value.absent(),
    this.destinationPath = const Value.absent(),
    this.state = const Value.absent(),
    this.bytesDownloaded = const Value.absent(),
    this.totalBytes = const Value.absent(),
    this.checksumAlgorithm = const Value.absent(),
    this.checksumHex = const Value.absent(),
    this.priority = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.failureReason = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DownloadTaskRowsCompanion.insert({
    required String id,
    required String mediaItemId,
    required String title,
    required String formatId,
    required String formatKind,
    required String formatContainer,
    this.formatCodec = const Value.absent(),
    this.formatHeight = const Value.absent(),
    this.formatBitrateKbps = const Value.absent(),
    required String destinationPath,
    required String state,
    this.bytesDownloaded = const Value.absent(),
    this.totalBytes = const Value.absent(),
    this.checksumAlgorithm = const Value.absent(),
    this.checksumHex = const Value.absent(),
    this.priority = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.failureReason = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        mediaItemId = Value(mediaItemId),
        title = Value(title),
        formatId = Value(formatId),
        formatKind = Value(formatKind),
        formatContainer = Value(formatContainer),
        destinationPath = Value(destinationPath),
        state = Value(state),
        createdAt = Value(createdAt);
  static Insertable<DownloadTaskRow> custom({
    Expression<String>? id,
    Expression<String>? mediaItemId,
    Expression<String>? title,
    Expression<String>? formatId,
    Expression<String>? formatKind,
    Expression<String>? formatContainer,
    Expression<String>? formatCodec,
    Expression<int>? formatHeight,
    Expression<int>? formatBitrateKbps,
    Expression<String>? destinationPath,
    Expression<String>? state,
    Expression<int>? bytesDownloaded,
    Expression<int>? totalBytes,
    Expression<String>? checksumAlgorithm,
    Expression<String>? checksumHex,
    Expression<int>? priority,
    Expression<int>? retryCount,
    Expression<String>? failureReason,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (mediaItemId != null) 'media_item_id': mediaItemId,
      if (title != null) 'title': title,
      if (formatId != null) 'format_id': formatId,
      if (formatKind != null) 'format_kind': formatKind,
      if (formatContainer != null) 'format_container': formatContainer,
      if (formatCodec != null) 'format_codec': formatCodec,
      if (formatHeight != null) 'format_height': formatHeight,
      if (formatBitrateKbps != null) 'format_bitrate_kbps': formatBitrateKbps,
      if (destinationPath != null) 'destination_path': destinationPath,
      if (state != null) 'state': state,
      if (bytesDownloaded != null) 'bytes_downloaded': bytesDownloaded,
      if (totalBytes != null) 'total_bytes': totalBytes,
      if (checksumAlgorithm != null) 'checksum_algorithm': checksumAlgorithm,
      if (checksumHex != null) 'checksum_hex': checksumHex,
      if (priority != null) 'priority': priority,
      if (retryCount != null) 'retry_count': retryCount,
      if (failureReason != null) 'failure_reason': failureReason,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DownloadTaskRowsCompanion copyWith(
      {Value<String>? id,
      Value<String>? mediaItemId,
      Value<String>? title,
      Value<String>? formatId,
      Value<String>? formatKind,
      Value<String>? formatContainer,
      Value<String?>? formatCodec,
      Value<int?>? formatHeight,
      Value<int?>? formatBitrateKbps,
      Value<String>? destinationPath,
      Value<String>? state,
      Value<int>? bytesDownloaded,
      Value<int?>? totalBytes,
      Value<String?>? checksumAlgorithm,
      Value<String?>? checksumHex,
      Value<int>? priority,
      Value<int>? retryCount,
      Value<String?>? failureReason,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return DownloadTaskRowsCompanion(
      id: id ?? this.id,
      mediaItemId: mediaItemId ?? this.mediaItemId,
      title: title ?? this.title,
      formatId: formatId ?? this.formatId,
      formatKind: formatKind ?? this.formatKind,
      formatContainer: formatContainer ?? this.formatContainer,
      formatCodec: formatCodec ?? this.formatCodec,
      formatHeight: formatHeight ?? this.formatHeight,
      formatBitrateKbps: formatBitrateKbps ?? this.formatBitrateKbps,
      destinationPath: destinationPath ?? this.destinationPath,
      state: state ?? this.state,
      bytesDownloaded: bytesDownloaded ?? this.bytesDownloaded,
      totalBytes: totalBytes ?? this.totalBytes,
      checksumAlgorithm: checksumAlgorithm ?? this.checksumAlgorithm,
      checksumHex: checksumHex ?? this.checksumHex,
      priority: priority ?? this.priority,
      retryCount: retryCount ?? this.retryCount,
      failureReason: failureReason ?? this.failureReason,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (mediaItemId.present) {
      map['media_item_id'] = Variable<String>(mediaItemId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (formatId.present) {
      map['format_id'] = Variable<String>(formatId.value);
    }
    if (formatKind.present) {
      map['format_kind'] = Variable<String>(formatKind.value);
    }
    if (formatContainer.present) {
      map['format_container'] = Variable<String>(formatContainer.value);
    }
    if (formatCodec.present) {
      map['format_codec'] = Variable<String>(formatCodec.value);
    }
    if (formatHeight.present) {
      map['format_height'] = Variable<int>(formatHeight.value);
    }
    if (formatBitrateKbps.present) {
      map['format_bitrate_kbps'] = Variable<int>(formatBitrateKbps.value);
    }
    if (destinationPath.present) {
      map['destination_path'] = Variable<String>(destinationPath.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (bytesDownloaded.present) {
      map['bytes_downloaded'] = Variable<int>(bytesDownloaded.value);
    }
    if (totalBytes.present) {
      map['total_bytes'] = Variable<int>(totalBytes.value);
    }
    if (checksumAlgorithm.present) {
      map['checksum_algorithm'] = Variable<String>(checksumAlgorithm.value);
    }
    if (checksumHex.present) {
      map['checksum_hex'] = Variable<String>(checksumHex.value);
    }
    if (priority.present) {
      map['priority'] = Variable<int>(priority.value);
    }
    if (retryCount.present) {
      map['retry_count'] = Variable<int>(retryCount.value);
    }
    if (failureReason.present) {
      map['failure_reason'] = Variable<String>(failureReason.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DownloadTaskRowsCompanion(')
          ..write('id: $id, ')
          ..write('mediaItemId: $mediaItemId, ')
          ..write('title: $title, ')
          ..write('formatId: $formatId, ')
          ..write('formatKind: $formatKind, ')
          ..write('formatContainer: $formatContainer, ')
          ..write('formatCodec: $formatCodec, ')
          ..write('formatHeight: $formatHeight, ')
          ..write('formatBitrateKbps: $formatBitrateKbps, ')
          ..write('destinationPath: $destinationPath, ')
          ..write('state: $state, ')
          ..write('bytesDownloaded: $bytesDownloaded, ')
          ..write('totalBytes: $totalBytes, ')
          ..write('checksumAlgorithm: $checksumAlgorithm, ')
          ..write('checksumHex: $checksumHex, ')
          ..write('priority: $priority, ')
          ..write('retryCount: $retryCount, ')
          ..write('failureReason: $failureReason, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LibraryEntryRowsTable extends LibraryEntryRows
    with TableInfo<$LibraryEntryRowsTable, LibraryEntryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LibraryEntryRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _filePathMeta =
      const VerificationMeta('filePath');
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
      'file_path', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
      'kind', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sizeBytesMeta =
      const VerificationMeta('sizeBytes');
  @override
  late final GeneratedColumn<int> sizeBytes = GeneratedColumn<int>(
      'size_bytes', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _durationMsMeta =
      const VerificationMeta('durationMs');
  @override
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
      'duration_ms', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _platformMeta =
      const VerificationMeta('platform');
  @override
  late final GeneratedColumn<String> platform = GeneratedColumn<String>(
      'platform', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _licenseSpdxIdMeta =
      const VerificationMeta('licenseSpdxId');
  @override
  late final GeneratedColumn<String> licenseSpdxId = GeneratedColumn<String>(
      'license_spdx_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _favoriteMeta =
      const VerificationMeta('favorite');
  @override
  late final GeneratedColumn<bool> favorite = GeneratedColumn<bool>(
      'favorite', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("favorite" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _tagsJsonMeta =
      const VerificationMeta('tagsJson');
  @override
  late final GeneratedColumn<String> tagsJson = GeneratedColumn<String>(
      'tags_json', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('[]'));
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _downloadedAtMeta =
      const VerificationMeta('downloadedAt');
  @override
  late final GeneratedColumn<DateTime> downloadedAt = GeneratedColumn<DateTime>(
      'downloaded_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _trashedAtMeta =
      const VerificationMeta('trashedAt');
  @override
  late final GeneratedColumn<DateTime> trashedAt = GeneratedColumn<DateTime>(
      'trashed_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        title,
        filePath,
        kind,
        sizeBytes,
        durationMs,
        platform,
        licenseSpdxId,
        favorite,
        tagsJson,
        status,
        downloadedAt,
        trashedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'library_entry_rows';
  @override
  VerificationContext validateIntegrity(Insertable<LibraryEntryRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('file_path')) {
      context.handle(_filePathMeta,
          filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta));
    } else if (isInserting) {
      context.missing(_filePathMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
          _kindMeta, kind.isAcceptableOrUnknown(data['kind']!, _kindMeta));
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('size_bytes')) {
      context.handle(_sizeBytesMeta,
          sizeBytes.isAcceptableOrUnknown(data['size_bytes']!, _sizeBytesMeta));
    } else if (isInserting) {
      context.missing(_sizeBytesMeta);
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
          _durationMsMeta,
          durationMs.isAcceptableOrUnknown(
              data['duration_ms']!, _durationMsMeta));
    }
    if (data.containsKey('platform')) {
      context.handle(_platformMeta,
          platform.isAcceptableOrUnknown(data['platform']!, _platformMeta));
    }
    if (data.containsKey('license_spdx_id')) {
      context.handle(
          _licenseSpdxIdMeta,
          licenseSpdxId.isAcceptableOrUnknown(
              data['license_spdx_id']!, _licenseSpdxIdMeta));
    }
    if (data.containsKey('favorite')) {
      context.handle(_favoriteMeta,
          favorite.isAcceptableOrUnknown(data['favorite']!, _favoriteMeta));
    }
    if (data.containsKey('tags_json')) {
      context.handle(_tagsJsonMeta,
          tagsJson.isAcceptableOrUnknown(data['tags_json']!, _tagsJsonMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('downloaded_at')) {
      context.handle(
          _downloadedAtMeta,
          downloadedAt.isAcceptableOrUnknown(
              data['downloaded_at']!, _downloadedAtMeta));
    } else if (isInserting) {
      context.missing(_downloadedAtMeta);
    }
    if (data.containsKey('trashed_at')) {
      context.handle(_trashedAtMeta,
          trashedAt.isAcceptableOrUnknown(data['trashed_at']!, _trashedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LibraryEntryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LibraryEntryRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      filePath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}file_path'])!,
      kind: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}kind'])!,
      sizeBytes: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}size_bytes'])!,
      durationMs: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}duration_ms']),
      platform: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}platform']),
      licenseSpdxId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}license_spdx_id']),
      favorite: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}favorite'])!,
      tagsJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tags_json'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      downloadedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}downloaded_at'])!,
      trashedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}trashed_at']),
    );
  }

  @override
  $LibraryEntryRowsTable createAlias(String alias) {
    return $LibraryEntryRowsTable(attachedDatabase, alias);
  }
}

class LibraryEntryRow extends DataClass implements Insertable<LibraryEntryRow> {
  /// Entry id (uuid).
  final String id;

  /// Display title.
  final String title;

  /// Absolute file path.
  final String filePath;

  /// 'video' | 'audio'.
  final String kind;

  /// File size in bytes.
  final int sizeBytes;

  /// Media duration in milliseconds, when known.
  final int? durationMs;

  /// Origin platform slug for the badge.
  final String? platform;

  /// License SPDX id for the badge; null for owned/official content.
  final String? licenseSpdxId;

  /// Favorite flag.
  final bool favorite;

  /// JSON array of user tags.
  final String tagsJson;

  /// LibraryFileStatus name (available, missing, trashed).
  final String status;

  /// Download completion timestamp.
  final DateTime downloadedAt;

  /// Trash entry timestamp; set iff status == trashed.
  final DateTime? trashedAt;
  const LibraryEntryRow(
      {required this.id,
      required this.title,
      required this.filePath,
      required this.kind,
      required this.sizeBytes,
      this.durationMs,
      this.platform,
      this.licenseSpdxId,
      required this.favorite,
      required this.tagsJson,
      required this.status,
      required this.downloadedAt,
      this.trashedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['file_path'] = Variable<String>(filePath);
    map['kind'] = Variable<String>(kind);
    map['size_bytes'] = Variable<int>(sizeBytes);
    if (!nullToAbsent || durationMs != null) {
      map['duration_ms'] = Variable<int>(durationMs);
    }
    if (!nullToAbsent || platform != null) {
      map['platform'] = Variable<String>(platform);
    }
    if (!nullToAbsent || licenseSpdxId != null) {
      map['license_spdx_id'] = Variable<String>(licenseSpdxId);
    }
    map['favorite'] = Variable<bool>(favorite);
    map['tags_json'] = Variable<String>(tagsJson);
    map['status'] = Variable<String>(status);
    map['downloaded_at'] = Variable<DateTime>(downloadedAt);
    if (!nullToAbsent || trashedAt != null) {
      map['trashed_at'] = Variable<DateTime>(trashedAt);
    }
    return map;
  }

  LibraryEntryRowsCompanion toCompanion(bool nullToAbsent) {
    return LibraryEntryRowsCompanion(
      id: Value(id),
      title: Value(title),
      filePath: Value(filePath),
      kind: Value(kind),
      sizeBytes: Value(sizeBytes),
      durationMs: durationMs == null && nullToAbsent
          ? const Value.absent()
          : Value(durationMs),
      platform: platform == null && nullToAbsent
          ? const Value.absent()
          : Value(platform),
      licenseSpdxId: licenseSpdxId == null && nullToAbsent
          ? const Value.absent()
          : Value(licenseSpdxId),
      favorite: Value(favorite),
      tagsJson: Value(tagsJson),
      status: Value(status),
      downloadedAt: Value(downloadedAt),
      trashedAt: trashedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(trashedAt),
    );
  }

  factory LibraryEntryRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LibraryEntryRow(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      filePath: serializer.fromJson<String>(json['filePath']),
      kind: serializer.fromJson<String>(json['kind']),
      sizeBytes: serializer.fromJson<int>(json['sizeBytes']),
      durationMs: serializer.fromJson<int?>(json['durationMs']),
      platform: serializer.fromJson<String?>(json['platform']),
      licenseSpdxId: serializer.fromJson<String?>(json['licenseSpdxId']),
      favorite: serializer.fromJson<bool>(json['favorite']),
      tagsJson: serializer.fromJson<String>(json['tagsJson']),
      status: serializer.fromJson<String>(json['status']),
      downloadedAt: serializer.fromJson<DateTime>(json['downloadedAt']),
      trashedAt: serializer.fromJson<DateTime?>(json['trashedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'filePath': serializer.toJson<String>(filePath),
      'kind': serializer.toJson<String>(kind),
      'sizeBytes': serializer.toJson<int>(sizeBytes),
      'durationMs': serializer.toJson<int?>(durationMs),
      'platform': serializer.toJson<String?>(platform),
      'licenseSpdxId': serializer.toJson<String?>(licenseSpdxId),
      'favorite': serializer.toJson<bool>(favorite),
      'tagsJson': serializer.toJson<String>(tagsJson),
      'status': serializer.toJson<String>(status),
      'downloadedAt': serializer.toJson<DateTime>(downloadedAt),
      'trashedAt': serializer.toJson<DateTime?>(trashedAt),
    };
  }

  LibraryEntryRow copyWith(
          {String? id,
          String? title,
          String? filePath,
          String? kind,
          int? sizeBytes,
          Value<int?> durationMs = const Value.absent(),
          Value<String?> platform = const Value.absent(),
          Value<String?> licenseSpdxId = const Value.absent(),
          bool? favorite,
          String? tagsJson,
          String? status,
          DateTime? downloadedAt,
          Value<DateTime?> trashedAt = const Value.absent()}) =>
      LibraryEntryRow(
        id: id ?? this.id,
        title: title ?? this.title,
        filePath: filePath ?? this.filePath,
        kind: kind ?? this.kind,
        sizeBytes: sizeBytes ?? this.sizeBytes,
        durationMs: durationMs.present ? durationMs.value : this.durationMs,
        platform: platform.present ? platform.value : this.platform,
        licenseSpdxId:
            licenseSpdxId.present ? licenseSpdxId.value : this.licenseSpdxId,
        favorite: favorite ?? this.favorite,
        tagsJson: tagsJson ?? this.tagsJson,
        status: status ?? this.status,
        downloadedAt: downloadedAt ?? this.downloadedAt,
        trashedAt: trashedAt.present ? trashedAt.value : this.trashedAt,
      );
  LibraryEntryRow copyWithCompanion(LibraryEntryRowsCompanion data) {
    return LibraryEntryRow(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
      kind: data.kind.present ? data.kind.value : this.kind,
      sizeBytes: data.sizeBytes.present ? data.sizeBytes.value : this.sizeBytes,
      durationMs:
          data.durationMs.present ? data.durationMs.value : this.durationMs,
      platform: data.platform.present ? data.platform.value : this.platform,
      licenseSpdxId: data.licenseSpdxId.present
          ? data.licenseSpdxId.value
          : this.licenseSpdxId,
      favorite: data.favorite.present ? data.favorite.value : this.favorite,
      tagsJson: data.tagsJson.present ? data.tagsJson.value : this.tagsJson,
      status: data.status.present ? data.status.value : this.status,
      downloadedAt: data.downloadedAt.present
          ? data.downloadedAt.value
          : this.downloadedAt,
      trashedAt: data.trashedAt.present ? data.trashedAt.value : this.trashedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LibraryEntryRow(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('filePath: $filePath, ')
          ..write('kind: $kind, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('durationMs: $durationMs, ')
          ..write('platform: $platform, ')
          ..write('licenseSpdxId: $licenseSpdxId, ')
          ..write('favorite: $favorite, ')
          ..write('tagsJson: $tagsJson, ')
          ..write('status: $status, ')
          ..write('downloadedAt: $downloadedAt, ')
          ..write('trashedAt: $trashedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      title,
      filePath,
      kind,
      sizeBytes,
      durationMs,
      platform,
      licenseSpdxId,
      favorite,
      tagsJson,
      status,
      downloadedAt,
      trashedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LibraryEntryRow &&
          other.id == this.id &&
          other.title == this.title &&
          other.filePath == this.filePath &&
          other.kind == this.kind &&
          other.sizeBytes == this.sizeBytes &&
          other.durationMs == this.durationMs &&
          other.platform == this.platform &&
          other.licenseSpdxId == this.licenseSpdxId &&
          other.favorite == this.favorite &&
          other.tagsJson == this.tagsJson &&
          other.status == this.status &&
          other.downloadedAt == this.downloadedAt &&
          other.trashedAt == this.trashedAt);
}

class LibraryEntryRowsCompanion extends UpdateCompanion<LibraryEntryRow> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> filePath;
  final Value<String> kind;
  final Value<int> sizeBytes;
  final Value<int?> durationMs;
  final Value<String?> platform;
  final Value<String?> licenseSpdxId;
  final Value<bool> favorite;
  final Value<String> tagsJson;
  final Value<String> status;
  final Value<DateTime> downloadedAt;
  final Value<DateTime?> trashedAt;
  final Value<int> rowid;
  const LibraryEntryRowsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.filePath = const Value.absent(),
    this.kind = const Value.absent(),
    this.sizeBytes = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.platform = const Value.absent(),
    this.licenseSpdxId = const Value.absent(),
    this.favorite = const Value.absent(),
    this.tagsJson = const Value.absent(),
    this.status = const Value.absent(),
    this.downloadedAt = const Value.absent(),
    this.trashedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LibraryEntryRowsCompanion.insert({
    required String id,
    required String title,
    required String filePath,
    required String kind,
    required int sizeBytes,
    this.durationMs = const Value.absent(),
    this.platform = const Value.absent(),
    this.licenseSpdxId = const Value.absent(),
    this.favorite = const Value.absent(),
    this.tagsJson = const Value.absent(),
    required String status,
    required DateTime downloadedAt,
    this.trashedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        title = Value(title),
        filePath = Value(filePath),
        kind = Value(kind),
        sizeBytes = Value(sizeBytes),
        status = Value(status),
        downloadedAt = Value(downloadedAt);
  static Insertable<LibraryEntryRow> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? filePath,
    Expression<String>? kind,
    Expression<int>? sizeBytes,
    Expression<int>? durationMs,
    Expression<String>? platform,
    Expression<String>? licenseSpdxId,
    Expression<bool>? favorite,
    Expression<String>? tagsJson,
    Expression<String>? status,
    Expression<DateTime>? downloadedAt,
    Expression<DateTime>? trashedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (filePath != null) 'file_path': filePath,
      if (kind != null) 'kind': kind,
      if (sizeBytes != null) 'size_bytes': sizeBytes,
      if (durationMs != null) 'duration_ms': durationMs,
      if (platform != null) 'platform': platform,
      if (licenseSpdxId != null) 'license_spdx_id': licenseSpdxId,
      if (favorite != null) 'favorite': favorite,
      if (tagsJson != null) 'tags_json': tagsJson,
      if (status != null) 'status': status,
      if (downloadedAt != null) 'downloaded_at': downloadedAt,
      if (trashedAt != null) 'trashed_at': trashedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LibraryEntryRowsCompanion copyWith(
      {Value<String>? id,
      Value<String>? title,
      Value<String>? filePath,
      Value<String>? kind,
      Value<int>? sizeBytes,
      Value<int?>? durationMs,
      Value<String?>? platform,
      Value<String?>? licenseSpdxId,
      Value<bool>? favorite,
      Value<String>? tagsJson,
      Value<String>? status,
      Value<DateTime>? downloadedAt,
      Value<DateTime?>? trashedAt,
      Value<int>? rowid}) {
    return LibraryEntryRowsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      filePath: filePath ?? this.filePath,
      kind: kind ?? this.kind,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      durationMs: durationMs ?? this.durationMs,
      platform: platform ?? this.platform,
      licenseSpdxId: licenseSpdxId ?? this.licenseSpdxId,
      favorite: favorite ?? this.favorite,
      tagsJson: tagsJson ?? this.tagsJson,
      status: status ?? this.status,
      downloadedAt: downloadedAt ?? this.downloadedAt,
      trashedAt: trashedAt ?? this.trashedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (sizeBytes.present) {
      map['size_bytes'] = Variable<int>(sizeBytes.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (platform.present) {
      map['platform'] = Variable<String>(platform.value);
    }
    if (licenseSpdxId.present) {
      map['license_spdx_id'] = Variable<String>(licenseSpdxId.value);
    }
    if (favorite.present) {
      map['favorite'] = Variable<bool>(favorite.value);
    }
    if (tagsJson.present) {
      map['tags_json'] = Variable<String>(tagsJson.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (downloadedAt.present) {
      map['downloaded_at'] = Variable<DateTime>(downloadedAt.value);
    }
    if (trashedAt.present) {
      map['trashed_at'] = Variable<DateTime>(trashedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LibraryEntryRowsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('filePath: $filePath, ')
          ..write('kind: $kind, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('durationMs: $durationMs, ')
          ..write('platform: $platform, ')
          ..write('licenseSpdxId: $licenseSpdxId, ')
          ..write('favorite: $favorite, ')
          ..write('tagsJson: $tagsJson, ')
          ..write('status: $status, ')
          ..write('downloadedAt: $downloadedAt, ')
          ..write('trashedAt: $trashedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AnalysisHistoryRowsTable extends AnalysisHistoryRows
    with TableInfo<$AnalysisHistoryRowsTable, AnalysisHistoryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AnalysisHistoryRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
      'url', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _authorMeta = const VerificationMeta('author');
  @override
  late final GeneratedColumn<String> author = GeneratedColumn<String>(
      'author', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _thumbnailUrlMeta =
      const VerificationMeta('thumbnailUrl');
  @override
  late final GeneratedColumn<String> thumbnailUrl = GeneratedColumn<String>(
      'thumbnail_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _eligibleMeta =
      const VerificationMeta('eligible');
  @override
  late final GeneratedColumn<bool> eligible = GeneratedColumn<bool>(
      'eligible', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("eligible" IN (0, 1))'));
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
      'source', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _licenseSpdxIdMeta =
      const VerificationMeta('licenseSpdxId');
  @override
  late final GeneratedColumn<String> licenseSpdxId = GeneratedColumn<String>(
      'license_spdx_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
      'reason', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _restrictionsJsonMeta =
      const VerificationMeta('restrictionsJson');
  @override
  late final GeneratedColumn<String> restrictionsJson = GeneratedColumn<String>(
      'restrictions_json', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('[]'));
  static const VerificationMeta _formatsJsonMeta =
      const VerificationMeta('formatsJson');
  @override
  late final GeneratedColumn<String> formatsJson = GeneratedColumn<String>(
      'formats_json', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('[]'));
  static const VerificationMeta _analyzedAtMeta =
      const VerificationMeta('analyzedAt');
  @override
  late final GeneratedColumn<DateTime> analyzedAt = GeneratedColumn<DateTime>(
      'analyzed_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        url,
        title,
        author,
        thumbnailUrl,
        eligible,
        source,
        licenseSpdxId,
        reason,
        restrictionsJson,
        formatsJson,
        analyzedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'analysis_history_rows';
  @override
  VerificationContext validateIntegrity(Insertable<AnalysisHistoryRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('url')) {
      context.handle(
          _urlMeta, url.isAcceptableOrUnknown(data['url']!, _urlMeta));
    } else if (isInserting) {
      context.missing(_urlMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('author')) {
      context.handle(_authorMeta,
          author.isAcceptableOrUnknown(data['author']!, _authorMeta));
    }
    if (data.containsKey('thumbnail_url')) {
      context.handle(
          _thumbnailUrlMeta,
          thumbnailUrl.isAcceptableOrUnknown(
              data['thumbnail_url']!, _thumbnailUrlMeta));
    }
    if (data.containsKey('eligible')) {
      context.handle(_eligibleMeta,
          eligible.isAcceptableOrUnknown(data['eligible']!, _eligibleMeta));
    } else if (isInserting) {
      context.missing(_eligibleMeta);
    }
    if (data.containsKey('source')) {
      context.handle(_sourceMeta,
          source.isAcceptableOrUnknown(data['source']!, _sourceMeta));
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('license_spdx_id')) {
      context.handle(
          _licenseSpdxIdMeta,
          licenseSpdxId.isAcceptableOrUnknown(
              data['license_spdx_id']!, _licenseSpdxIdMeta));
    }
    if (data.containsKey('reason')) {
      context.handle(_reasonMeta,
          reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta));
    } else if (isInserting) {
      context.missing(_reasonMeta);
    }
    if (data.containsKey('restrictions_json')) {
      context.handle(
          _restrictionsJsonMeta,
          restrictionsJson.isAcceptableOrUnknown(
              data['restrictions_json']!, _restrictionsJsonMeta));
    }
    if (data.containsKey('formats_json')) {
      context.handle(
          _formatsJsonMeta,
          formatsJson.isAcceptableOrUnknown(
              data['formats_json']!, _formatsJsonMeta));
    }
    if (data.containsKey('analyzed_at')) {
      context.handle(
          _analyzedAtMeta,
          analyzedAt.isAcceptableOrUnknown(
              data['analyzed_at']!, _analyzedAtMeta));
    } else if (isInserting) {
      context.missing(_analyzedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AnalysisHistoryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AnalysisHistoryRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      url: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}url'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      author: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}author']),
      thumbnailUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}thumbnail_url']),
      eligible: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}eligible'])!,
      source: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source'])!,
      licenseSpdxId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}license_spdx_id']),
      reason: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}reason'])!,
      restrictionsJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}restrictions_json'])!,
      formatsJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}formats_json'])!,
      analyzedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}analyzed_at'])!,
    );
  }

  @override
  $AnalysisHistoryRowsTable createAlias(String alias) {
    return $AnalysisHistoryRowsTable(attachedDatabase, alias);
  }
}

class AnalysisHistoryRow extends DataClass
    implements Insertable<AnalysisHistoryRow> {
  /// Analysis id (sha256 of the URL, mirrors the backend).
  final String id;

  /// Analyzed URL.
  final String url;

  /// Title from origin metadata, or the URL as fallback.
  final String title;

  /// Author, when reported.
  final String? author;

  /// Thumbnail URL, when reported.
  final String? thumbnailUrl;

  /// Verdict flag.
  final bool eligible;

  /// AuthorizationSource wire value.
  final String source;

  /// License SPDX id, when open-licensed.
  final String? licenseSpdxId;

  /// User-facing reason of the verdict.
  final String reason;

  /// JSON array of restriction strings.
  final String restrictionsJson;

  /// JSON array of MediaFormat wire objects.
  final String formatsJson;

  /// When this analysis ran (latest wins for the same id).
  final DateTime analyzedAt;
  const AnalysisHistoryRow(
      {required this.id,
      required this.url,
      required this.title,
      this.author,
      this.thumbnailUrl,
      required this.eligible,
      required this.source,
      this.licenseSpdxId,
      required this.reason,
      required this.restrictionsJson,
      required this.formatsJson,
      required this.analyzedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['url'] = Variable<String>(url);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || author != null) {
      map['author'] = Variable<String>(author);
    }
    if (!nullToAbsent || thumbnailUrl != null) {
      map['thumbnail_url'] = Variable<String>(thumbnailUrl);
    }
    map['eligible'] = Variable<bool>(eligible);
    map['source'] = Variable<String>(source);
    if (!nullToAbsent || licenseSpdxId != null) {
      map['license_spdx_id'] = Variable<String>(licenseSpdxId);
    }
    map['reason'] = Variable<String>(reason);
    map['restrictions_json'] = Variable<String>(restrictionsJson);
    map['formats_json'] = Variable<String>(formatsJson);
    map['analyzed_at'] = Variable<DateTime>(analyzedAt);
    return map;
  }

  AnalysisHistoryRowsCompanion toCompanion(bool nullToAbsent) {
    return AnalysisHistoryRowsCompanion(
      id: Value(id),
      url: Value(url),
      title: Value(title),
      author:
          author == null && nullToAbsent ? const Value.absent() : Value(author),
      thumbnailUrl: thumbnailUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(thumbnailUrl),
      eligible: Value(eligible),
      source: Value(source),
      licenseSpdxId: licenseSpdxId == null && nullToAbsent
          ? const Value.absent()
          : Value(licenseSpdxId),
      reason: Value(reason),
      restrictionsJson: Value(restrictionsJson),
      formatsJson: Value(formatsJson),
      analyzedAt: Value(analyzedAt),
    );
  }

  factory AnalysisHistoryRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AnalysisHistoryRow(
      id: serializer.fromJson<String>(json['id']),
      url: serializer.fromJson<String>(json['url']),
      title: serializer.fromJson<String>(json['title']),
      author: serializer.fromJson<String?>(json['author']),
      thumbnailUrl: serializer.fromJson<String?>(json['thumbnailUrl']),
      eligible: serializer.fromJson<bool>(json['eligible']),
      source: serializer.fromJson<String>(json['source']),
      licenseSpdxId: serializer.fromJson<String?>(json['licenseSpdxId']),
      reason: serializer.fromJson<String>(json['reason']),
      restrictionsJson: serializer.fromJson<String>(json['restrictionsJson']),
      formatsJson: serializer.fromJson<String>(json['formatsJson']),
      analyzedAt: serializer.fromJson<DateTime>(json['analyzedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'url': serializer.toJson<String>(url),
      'title': serializer.toJson<String>(title),
      'author': serializer.toJson<String?>(author),
      'thumbnailUrl': serializer.toJson<String?>(thumbnailUrl),
      'eligible': serializer.toJson<bool>(eligible),
      'source': serializer.toJson<String>(source),
      'licenseSpdxId': serializer.toJson<String?>(licenseSpdxId),
      'reason': serializer.toJson<String>(reason),
      'restrictionsJson': serializer.toJson<String>(restrictionsJson),
      'formatsJson': serializer.toJson<String>(formatsJson),
      'analyzedAt': serializer.toJson<DateTime>(analyzedAt),
    };
  }

  AnalysisHistoryRow copyWith(
          {String? id,
          String? url,
          String? title,
          Value<String?> author = const Value.absent(),
          Value<String?> thumbnailUrl = const Value.absent(),
          bool? eligible,
          String? source,
          Value<String?> licenseSpdxId = const Value.absent(),
          String? reason,
          String? restrictionsJson,
          String? formatsJson,
          DateTime? analyzedAt}) =>
      AnalysisHistoryRow(
        id: id ?? this.id,
        url: url ?? this.url,
        title: title ?? this.title,
        author: author.present ? author.value : this.author,
        thumbnailUrl:
            thumbnailUrl.present ? thumbnailUrl.value : this.thumbnailUrl,
        eligible: eligible ?? this.eligible,
        source: source ?? this.source,
        licenseSpdxId:
            licenseSpdxId.present ? licenseSpdxId.value : this.licenseSpdxId,
        reason: reason ?? this.reason,
        restrictionsJson: restrictionsJson ?? this.restrictionsJson,
        formatsJson: formatsJson ?? this.formatsJson,
        analyzedAt: analyzedAt ?? this.analyzedAt,
      );
  AnalysisHistoryRow copyWithCompanion(AnalysisHistoryRowsCompanion data) {
    return AnalysisHistoryRow(
      id: data.id.present ? data.id.value : this.id,
      url: data.url.present ? data.url.value : this.url,
      title: data.title.present ? data.title.value : this.title,
      author: data.author.present ? data.author.value : this.author,
      thumbnailUrl: data.thumbnailUrl.present
          ? data.thumbnailUrl.value
          : this.thumbnailUrl,
      eligible: data.eligible.present ? data.eligible.value : this.eligible,
      source: data.source.present ? data.source.value : this.source,
      licenseSpdxId: data.licenseSpdxId.present
          ? data.licenseSpdxId.value
          : this.licenseSpdxId,
      reason: data.reason.present ? data.reason.value : this.reason,
      restrictionsJson: data.restrictionsJson.present
          ? data.restrictionsJson.value
          : this.restrictionsJson,
      formatsJson:
          data.formatsJson.present ? data.formatsJson.value : this.formatsJson,
      analyzedAt:
          data.analyzedAt.present ? data.analyzedAt.value : this.analyzedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AnalysisHistoryRow(')
          ..write('id: $id, ')
          ..write('url: $url, ')
          ..write('title: $title, ')
          ..write('author: $author, ')
          ..write('thumbnailUrl: $thumbnailUrl, ')
          ..write('eligible: $eligible, ')
          ..write('source: $source, ')
          ..write('licenseSpdxId: $licenseSpdxId, ')
          ..write('reason: $reason, ')
          ..write('restrictionsJson: $restrictionsJson, ')
          ..write('formatsJson: $formatsJson, ')
          ..write('analyzedAt: $analyzedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      url,
      title,
      author,
      thumbnailUrl,
      eligible,
      source,
      licenseSpdxId,
      reason,
      restrictionsJson,
      formatsJson,
      analyzedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AnalysisHistoryRow &&
          other.id == this.id &&
          other.url == this.url &&
          other.title == this.title &&
          other.author == this.author &&
          other.thumbnailUrl == this.thumbnailUrl &&
          other.eligible == this.eligible &&
          other.source == this.source &&
          other.licenseSpdxId == this.licenseSpdxId &&
          other.reason == this.reason &&
          other.restrictionsJson == this.restrictionsJson &&
          other.formatsJson == this.formatsJson &&
          other.analyzedAt == this.analyzedAt);
}

class AnalysisHistoryRowsCompanion extends UpdateCompanion<AnalysisHistoryRow> {
  final Value<String> id;
  final Value<String> url;
  final Value<String> title;
  final Value<String?> author;
  final Value<String?> thumbnailUrl;
  final Value<bool> eligible;
  final Value<String> source;
  final Value<String?> licenseSpdxId;
  final Value<String> reason;
  final Value<String> restrictionsJson;
  final Value<String> formatsJson;
  final Value<DateTime> analyzedAt;
  final Value<int> rowid;
  const AnalysisHistoryRowsCompanion({
    this.id = const Value.absent(),
    this.url = const Value.absent(),
    this.title = const Value.absent(),
    this.author = const Value.absent(),
    this.thumbnailUrl = const Value.absent(),
    this.eligible = const Value.absent(),
    this.source = const Value.absent(),
    this.licenseSpdxId = const Value.absent(),
    this.reason = const Value.absent(),
    this.restrictionsJson = const Value.absent(),
    this.formatsJson = const Value.absent(),
    this.analyzedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AnalysisHistoryRowsCompanion.insert({
    required String id,
    required String url,
    required String title,
    this.author = const Value.absent(),
    this.thumbnailUrl = const Value.absent(),
    required bool eligible,
    required String source,
    this.licenseSpdxId = const Value.absent(),
    required String reason,
    this.restrictionsJson = const Value.absent(),
    this.formatsJson = const Value.absent(),
    required DateTime analyzedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        url = Value(url),
        title = Value(title),
        eligible = Value(eligible),
        source = Value(source),
        reason = Value(reason),
        analyzedAt = Value(analyzedAt);
  static Insertable<AnalysisHistoryRow> custom({
    Expression<String>? id,
    Expression<String>? url,
    Expression<String>? title,
    Expression<String>? author,
    Expression<String>? thumbnailUrl,
    Expression<bool>? eligible,
    Expression<String>? source,
    Expression<String>? licenseSpdxId,
    Expression<String>? reason,
    Expression<String>? restrictionsJson,
    Expression<String>? formatsJson,
    Expression<DateTime>? analyzedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (url != null) 'url': url,
      if (title != null) 'title': title,
      if (author != null) 'author': author,
      if (thumbnailUrl != null) 'thumbnail_url': thumbnailUrl,
      if (eligible != null) 'eligible': eligible,
      if (source != null) 'source': source,
      if (licenseSpdxId != null) 'license_spdx_id': licenseSpdxId,
      if (reason != null) 'reason': reason,
      if (restrictionsJson != null) 'restrictions_json': restrictionsJson,
      if (formatsJson != null) 'formats_json': formatsJson,
      if (analyzedAt != null) 'analyzed_at': analyzedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AnalysisHistoryRowsCompanion copyWith(
      {Value<String>? id,
      Value<String>? url,
      Value<String>? title,
      Value<String?>? author,
      Value<String?>? thumbnailUrl,
      Value<bool>? eligible,
      Value<String>? source,
      Value<String?>? licenseSpdxId,
      Value<String>? reason,
      Value<String>? restrictionsJson,
      Value<String>? formatsJson,
      Value<DateTime>? analyzedAt,
      Value<int>? rowid}) {
    return AnalysisHistoryRowsCompanion(
      id: id ?? this.id,
      url: url ?? this.url,
      title: title ?? this.title,
      author: author ?? this.author,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      eligible: eligible ?? this.eligible,
      source: source ?? this.source,
      licenseSpdxId: licenseSpdxId ?? this.licenseSpdxId,
      reason: reason ?? this.reason,
      restrictionsJson: restrictionsJson ?? this.restrictionsJson,
      formatsJson: formatsJson ?? this.formatsJson,
      analyzedAt: analyzedAt ?? this.analyzedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (author.present) {
      map['author'] = Variable<String>(author.value);
    }
    if (thumbnailUrl.present) {
      map['thumbnail_url'] = Variable<String>(thumbnailUrl.value);
    }
    if (eligible.present) {
      map['eligible'] = Variable<bool>(eligible.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (licenseSpdxId.present) {
      map['license_spdx_id'] = Variable<String>(licenseSpdxId.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (restrictionsJson.present) {
      map['restrictions_json'] = Variable<String>(restrictionsJson.value);
    }
    if (formatsJson.present) {
      map['formats_json'] = Variable<String>(formatsJson.value);
    }
    if (analyzedAt.present) {
      map['analyzed_at'] = Variable<DateTime>(analyzedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AnalysisHistoryRowsCompanion(')
          ..write('id: $id, ')
          ..write('url: $url, ')
          ..write('title: $title, ')
          ..write('author: $author, ')
          ..write('thumbnailUrl: $thumbnailUrl, ')
          ..write('eligible: $eligible, ')
          ..write('source: $source, ')
          ..write('licenseSpdxId: $licenseSpdxId, ')
          ..write('reason: $reason, ')
          ..write('restrictionsJson: $restrictionsJson, ')
          ..write('formatsJson: $formatsJson, ')
          ..write('analyzedAt: $analyzedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $DownloadTaskRowsTable downloadTaskRows =
      $DownloadTaskRowsTable(this);
  late final $LibraryEntryRowsTable libraryEntryRows =
      $LibraryEntryRowsTable(this);
  late final $AnalysisHistoryRowsTable analysisHistoryRows =
      $AnalysisHistoryRowsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [downloadTaskRows, libraryEntryRows, analysisHistoryRows];
  @override
  DriftDatabaseOptions get options =>
      const DriftDatabaseOptions(storeDateTimeAsText: true);
}

typedef $$DownloadTaskRowsTableCreateCompanionBuilder
    = DownloadTaskRowsCompanion Function({
  required String id,
  required String mediaItemId,
  required String title,
  required String formatId,
  required String formatKind,
  required String formatContainer,
  Value<String?> formatCodec,
  Value<int?> formatHeight,
  Value<int?> formatBitrateKbps,
  required String destinationPath,
  required String state,
  Value<int> bytesDownloaded,
  Value<int?> totalBytes,
  Value<String?> checksumAlgorithm,
  Value<String?> checksumHex,
  Value<int> priority,
  Value<int> retryCount,
  Value<String?> failureReason,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$DownloadTaskRowsTableUpdateCompanionBuilder
    = DownloadTaskRowsCompanion Function({
  Value<String> id,
  Value<String> mediaItemId,
  Value<String> title,
  Value<String> formatId,
  Value<String> formatKind,
  Value<String> formatContainer,
  Value<String?> formatCodec,
  Value<int?> formatHeight,
  Value<int?> formatBitrateKbps,
  Value<String> destinationPath,
  Value<String> state,
  Value<int> bytesDownloaded,
  Value<int?> totalBytes,
  Value<String?> checksumAlgorithm,
  Value<String?> checksumHex,
  Value<int> priority,
  Value<int> retryCount,
  Value<String?> failureReason,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$DownloadTaskRowsTableFilterComposer
    extends Composer<_$AppDatabase, $DownloadTaskRowsTable> {
  $$DownloadTaskRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get mediaItemId => $composableBuilder(
      column: $table.mediaItemId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get formatId => $composableBuilder(
      column: $table.formatId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get formatKind => $composableBuilder(
      column: $table.formatKind, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get formatContainer => $composableBuilder(
      column: $table.formatContainer,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get formatCodec => $composableBuilder(
      column: $table.formatCodec, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get formatHeight => $composableBuilder(
      column: $table.formatHeight, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get formatBitrateKbps => $composableBuilder(
      column: $table.formatBitrateKbps,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get destinationPath => $composableBuilder(
      column: $table.destinationPath,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get state => $composableBuilder(
      column: $table.state, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get bytesDownloaded => $composableBuilder(
      column: $table.bytesDownloaded,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get totalBytes => $composableBuilder(
      column: $table.totalBytes, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get checksumAlgorithm => $composableBuilder(
      column: $table.checksumAlgorithm,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get checksumHex => $composableBuilder(
      column: $table.checksumHex, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get priority => $composableBuilder(
      column: $table.priority, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get failureReason => $composableBuilder(
      column: $table.failureReason, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$DownloadTaskRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $DownloadTaskRowsTable> {
  $$DownloadTaskRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get mediaItemId => $composableBuilder(
      column: $table.mediaItemId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get formatId => $composableBuilder(
      column: $table.formatId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get formatKind => $composableBuilder(
      column: $table.formatKind, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get formatContainer => $composableBuilder(
      column: $table.formatContainer,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get formatCodec => $composableBuilder(
      column: $table.formatCodec, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get formatHeight => $composableBuilder(
      column: $table.formatHeight,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get formatBitrateKbps => $composableBuilder(
      column: $table.formatBitrateKbps,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get destinationPath => $composableBuilder(
      column: $table.destinationPath,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get state => $composableBuilder(
      column: $table.state, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get bytesDownloaded => $composableBuilder(
      column: $table.bytesDownloaded,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get totalBytes => $composableBuilder(
      column: $table.totalBytes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get checksumAlgorithm => $composableBuilder(
      column: $table.checksumAlgorithm,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get checksumHex => $composableBuilder(
      column: $table.checksumHex, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get priority => $composableBuilder(
      column: $table.priority, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get failureReason => $composableBuilder(
      column: $table.failureReason,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$DownloadTaskRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DownloadTaskRowsTable> {
  $$DownloadTaskRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get mediaItemId => $composableBuilder(
      column: $table.mediaItemId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get formatId =>
      $composableBuilder(column: $table.formatId, builder: (column) => column);

  GeneratedColumn<String> get formatKind => $composableBuilder(
      column: $table.formatKind, builder: (column) => column);

  GeneratedColumn<String> get formatContainer => $composableBuilder(
      column: $table.formatContainer, builder: (column) => column);

  GeneratedColumn<String> get formatCodec => $composableBuilder(
      column: $table.formatCodec, builder: (column) => column);

  GeneratedColumn<int> get formatHeight => $composableBuilder(
      column: $table.formatHeight, builder: (column) => column);

  GeneratedColumn<int> get formatBitrateKbps => $composableBuilder(
      column: $table.formatBitrateKbps, builder: (column) => column);

  GeneratedColumn<String> get destinationPath => $composableBuilder(
      column: $table.destinationPath, builder: (column) => column);

  GeneratedColumn<String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<int> get bytesDownloaded => $composableBuilder(
      column: $table.bytesDownloaded, builder: (column) => column);

  GeneratedColumn<int> get totalBytes => $composableBuilder(
      column: $table.totalBytes, builder: (column) => column);

  GeneratedColumn<String> get checksumAlgorithm => $composableBuilder(
      column: $table.checksumAlgorithm, builder: (column) => column);

  GeneratedColumn<String> get checksumHex => $composableBuilder(
      column: $table.checksumHex, builder: (column) => column);

  GeneratedColumn<int> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => column);

  GeneratedColumn<String> get failureReason => $composableBuilder(
      column: $table.failureReason, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$DownloadTaskRowsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DownloadTaskRowsTable,
    DownloadTaskRow,
    $$DownloadTaskRowsTableFilterComposer,
    $$DownloadTaskRowsTableOrderingComposer,
    $$DownloadTaskRowsTableAnnotationComposer,
    $$DownloadTaskRowsTableCreateCompanionBuilder,
    $$DownloadTaskRowsTableUpdateCompanionBuilder,
    (
      DownloadTaskRow,
      BaseReferences<_$AppDatabase, $DownloadTaskRowsTable, DownloadTaskRow>
    ),
    DownloadTaskRow,
    PrefetchHooks Function()> {
  $$DownloadTaskRowsTableTableManager(
      _$AppDatabase db, $DownloadTaskRowsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DownloadTaskRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DownloadTaskRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DownloadTaskRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> mediaItemId = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> formatId = const Value.absent(),
            Value<String> formatKind = const Value.absent(),
            Value<String> formatContainer = const Value.absent(),
            Value<String?> formatCodec = const Value.absent(),
            Value<int?> formatHeight = const Value.absent(),
            Value<int?> formatBitrateKbps = const Value.absent(),
            Value<String> destinationPath = const Value.absent(),
            Value<String> state = const Value.absent(),
            Value<int> bytesDownloaded = const Value.absent(),
            Value<int?> totalBytes = const Value.absent(),
            Value<String?> checksumAlgorithm = const Value.absent(),
            Value<String?> checksumHex = const Value.absent(),
            Value<int> priority = const Value.absent(),
            Value<int> retryCount = const Value.absent(),
            Value<String?> failureReason = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DownloadTaskRowsCompanion(
            id: id,
            mediaItemId: mediaItemId,
            title: title,
            formatId: formatId,
            formatKind: formatKind,
            formatContainer: formatContainer,
            formatCodec: formatCodec,
            formatHeight: formatHeight,
            formatBitrateKbps: formatBitrateKbps,
            destinationPath: destinationPath,
            state: state,
            bytesDownloaded: bytesDownloaded,
            totalBytes: totalBytes,
            checksumAlgorithm: checksumAlgorithm,
            checksumHex: checksumHex,
            priority: priority,
            retryCount: retryCount,
            failureReason: failureReason,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String mediaItemId,
            required String title,
            required String formatId,
            required String formatKind,
            required String formatContainer,
            Value<String?> formatCodec = const Value.absent(),
            Value<int?> formatHeight = const Value.absent(),
            Value<int?> formatBitrateKbps = const Value.absent(),
            required String destinationPath,
            required String state,
            Value<int> bytesDownloaded = const Value.absent(),
            Value<int?> totalBytes = const Value.absent(),
            Value<String?> checksumAlgorithm = const Value.absent(),
            Value<String?> checksumHex = const Value.absent(),
            Value<int> priority = const Value.absent(),
            Value<int> retryCount = const Value.absent(),
            Value<String?> failureReason = const Value.absent(),
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              DownloadTaskRowsCompanion.insert(
            id: id,
            mediaItemId: mediaItemId,
            title: title,
            formatId: formatId,
            formatKind: formatKind,
            formatContainer: formatContainer,
            formatCodec: formatCodec,
            formatHeight: formatHeight,
            formatBitrateKbps: formatBitrateKbps,
            destinationPath: destinationPath,
            state: state,
            bytesDownloaded: bytesDownloaded,
            totalBytes: totalBytes,
            checksumAlgorithm: checksumAlgorithm,
            checksumHex: checksumHex,
            priority: priority,
            retryCount: retryCount,
            failureReason: failureReason,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$DownloadTaskRowsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DownloadTaskRowsTable,
    DownloadTaskRow,
    $$DownloadTaskRowsTableFilterComposer,
    $$DownloadTaskRowsTableOrderingComposer,
    $$DownloadTaskRowsTableAnnotationComposer,
    $$DownloadTaskRowsTableCreateCompanionBuilder,
    $$DownloadTaskRowsTableUpdateCompanionBuilder,
    (
      DownloadTaskRow,
      BaseReferences<_$AppDatabase, $DownloadTaskRowsTable, DownloadTaskRow>
    ),
    DownloadTaskRow,
    PrefetchHooks Function()>;
typedef $$LibraryEntryRowsTableCreateCompanionBuilder
    = LibraryEntryRowsCompanion Function({
  required String id,
  required String title,
  required String filePath,
  required String kind,
  required int sizeBytes,
  Value<int?> durationMs,
  Value<String?> platform,
  Value<String?> licenseSpdxId,
  Value<bool> favorite,
  Value<String> tagsJson,
  required String status,
  required DateTime downloadedAt,
  Value<DateTime?> trashedAt,
  Value<int> rowid,
});
typedef $$LibraryEntryRowsTableUpdateCompanionBuilder
    = LibraryEntryRowsCompanion Function({
  Value<String> id,
  Value<String> title,
  Value<String> filePath,
  Value<String> kind,
  Value<int> sizeBytes,
  Value<int?> durationMs,
  Value<String?> platform,
  Value<String?> licenseSpdxId,
  Value<bool> favorite,
  Value<String> tagsJson,
  Value<String> status,
  Value<DateTime> downloadedAt,
  Value<DateTime?> trashedAt,
  Value<int> rowid,
});

class $$LibraryEntryRowsTableFilterComposer
    extends Composer<_$AppDatabase, $LibraryEntryRowsTable> {
  $$LibraryEntryRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get filePath => $composableBuilder(
      column: $table.filePath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get kind => $composableBuilder(
      column: $table.kind, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sizeBytes => $composableBuilder(
      column: $table.sizeBytes, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get durationMs => $composableBuilder(
      column: $table.durationMs, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get platform => $composableBuilder(
      column: $table.platform, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get licenseSpdxId => $composableBuilder(
      column: $table.licenseSpdxId, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get favorite => $composableBuilder(
      column: $table.favorite, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tagsJson => $composableBuilder(
      column: $table.tagsJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get downloadedAt => $composableBuilder(
      column: $table.downloadedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get trashedAt => $composableBuilder(
      column: $table.trashedAt, builder: (column) => ColumnFilters(column));
}

class $$LibraryEntryRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $LibraryEntryRowsTable> {
  $$LibraryEntryRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get filePath => $composableBuilder(
      column: $table.filePath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get kind => $composableBuilder(
      column: $table.kind, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sizeBytes => $composableBuilder(
      column: $table.sizeBytes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get durationMs => $composableBuilder(
      column: $table.durationMs, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get platform => $composableBuilder(
      column: $table.platform, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get licenseSpdxId => $composableBuilder(
      column: $table.licenseSpdxId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get favorite => $composableBuilder(
      column: $table.favorite, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tagsJson => $composableBuilder(
      column: $table.tagsJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get downloadedAt => $composableBuilder(
      column: $table.downloadedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get trashedAt => $composableBuilder(
      column: $table.trashedAt, builder: (column) => ColumnOrderings(column));
}

class $$LibraryEntryRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LibraryEntryRowsTable> {
  $$LibraryEntryRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get filePath =>
      $composableBuilder(column: $table.filePath, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<int> get sizeBytes =>
      $composableBuilder(column: $table.sizeBytes, builder: (column) => column);

  GeneratedColumn<int> get durationMs => $composableBuilder(
      column: $table.durationMs, builder: (column) => column);

  GeneratedColumn<String> get platform =>
      $composableBuilder(column: $table.platform, builder: (column) => column);

  GeneratedColumn<String> get licenseSpdxId => $composableBuilder(
      column: $table.licenseSpdxId, builder: (column) => column);

  GeneratedColumn<bool> get favorite =>
      $composableBuilder(column: $table.favorite, builder: (column) => column);

  GeneratedColumn<String> get tagsJson =>
      $composableBuilder(column: $table.tagsJson, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get downloadedAt => $composableBuilder(
      column: $table.downloadedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get trashedAt =>
      $composableBuilder(column: $table.trashedAt, builder: (column) => column);
}

class $$LibraryEntryRowsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LibraryEntryRowsTable,
    LibraryEntryRow,
    $$LibraryEntryRowsTableFilterComposer,
    $$LibraryEntryRowsTableOrderingComposer,
    $$LibraryEntryRowsTableAnnotationComposer,
    $$LibraryEntryRowsTableCreateCompanionBuilder,
    $$LibraryEntryRowsTableUpdateCompanionBuilder,
    (
      LibraryEntryRow,
      BaseReferences<_$AppDatabase, $LibraryEntryRowsTable, LibraryEntryRow>
    ),
    LibraryEntryRow,
    PrefetchHooks Function()> {
  $$LibraryEntryRowsTableTableManager(
      _$AppDatabase db, $LibraryEntryRowsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LibraryEntryRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LibraryEntryRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LibraryEntryRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> filePath = const Value.absent(),
            Value<String> kind = const Value.absent(),
            Value<int> sizeBytes = const Value.absent(),
            Value<int?> durationMs = const Value.absent(),
            Value<String?> platform = const Value.absent(),
            Value<String?> licenseSpdxId = const Value.absent(),
            Value<bool> favorite = const Value.absent(),
            Value<String> tagsJson = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<DateTime> downloadedAt = const Value.absent(),
            Value<DateTime?> trashedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LibraryEntryRowsCompanion(
            id: id,
            title: title,
            filePath: filePath,
            kind: kind,
            sizeBytes: sizeBytes,
            durationMs: durationMs,
            platform: platform,
            licenseSpdxId: licenseSpdxId,
            favorite: favorite,
            tagsJson: tagsJson,
            status: status,
            downloadedAt: downloadedAt,
            trashedAt: trashedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String title,
            required String filePath,
            required String kind,
            required int sizeBytes,
            Value<int?> durationMs = const Value.absent(),
            Value<String?> platform = const Value.absent(),
            Value<String?> licenseSpdxId = const Value.absent(),
            Value<bool> favorite = const Value.absent(),
            Value<String> tagsJson = const Value.absent(),
            required String status,
            required DateTime downloadedAt,
            Value<DateTime?> trashedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LibraryEntryRowsCompanion.insert(
            id: id,
            title: title,
            filePath: filePath,
            kind: kind,
            sizeBytes: sizeBytes,
            durationMs: durationMs,
            platform: platform,
            licenseSpdxId: licenseSpdxId,
            favorite: favorite,
            tagsJson: tagsJson,
            status: status,
            downloadedAt: downloadedAt,
            trashedAt: trashedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LibraryEntryRowsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $LibraryEntryRowsTable,
    LibraryEntryRow,
    $$LibraryEntryRowsTableFilterComposer,
    $$LibraryEntryRowsTableOrderingComposer,
    $$LibraryEntryRowsTableAnnotationComposer,
    $$LibraryEntryRowsTableCreateCompanionBuilder,
    $$LibraryEntryRowsTableUpdateCompanionBuilder,
    (
      LibraryEntryRow,
      BaseReferences<_$AppDatabase, $LibraryEntryRowsTable, LibraryEntryRow>
    ),
    LibraryEntryRow,
    PrefetchHooks Function()>;
typedef $$AnalysisHistoryRowsTableCreateCompanionBuilder
    = AnalysisHistoryRowsCompanion Function({
  required String id,
  required String url,
  required String title,
  Value<String?> author,
  Value<String?> thumbnailUrl,
  required bool eligible,
  required String source,
  Value<String?> licenseSpdxId,
  required String reason,
  Value<String> restrictionsJson,
  Value<String> formatsJson,
  required DateTime analyzedAt,
  Value<int> rowid,
});
typedef $$AnalysisHistoryRowsTableUpdateCompanionBuilder
    = AnalysisHistoryRowsCompanion Function({
  Value<String> id,
  Value<String> url,
  Value<String> title,
  Value<String?> author,
  Value<String?> thumbnailUrl,
  Value<bool> eligible,
  Value<String> source,
  Value<String?> licenseSpdxId,
  Value<String> reason,
  Value<String> restrictionsJson,
  Value<String> formatsJson,
  Value<DateTime> analyzedAt,
  Value<int> rowid,
});

class $$AnalysisHistoryRowsTableFilterComposer
    extends Composer<_$AppDatabase, $AnalysisHistoryRowsTable> {
  $$AnalysisHistoryRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get url => $composableBuilder(
      column: $table.url, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get author => $composableBuilder(
      column: $table.author, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get thumbnailUrl => $composableBuilder(
      column: $table.thumbnailUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get eligible => $composableBuilder(
      column: $table.eligible, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get licenseSpdxId => $composableBuilder(
      column: $table.licenseSpdxId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get reason => $composableBuilder(
      column: $table.reason, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get restrictionsJson => $composableBuilder(
      column: $table.restrictionsJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get formatsJson => $composableBuilder(
      column: $table.formatsJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get analyzedAt => $composableBuilder(
      column: $table.analyzedAt, builder: (column) => ColumnFilters(column));
}

class $$AnalysisHistoryRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $AnalysisHistoryRowsTable> {
  $$AnalysisHistoryRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get url => $composableBuilder(
      column: $table.url, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get author => $composableBuilder(
      column: $table.author, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get thumbnailUrl => $composableBuilder(
      column: $table.thumbnailUrl,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get eligible => $composableBuilder(
      column: $table.eligible, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get licenseSpdxId => $composableBuilder(
      column: $table.licenseSpdxId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get reason => $composableBuilder(
      column: $table.reason, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get restrictionsJson => $composableBuilder(
      column: $table.restrictionsJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get formatsJson => $composableBuilder(
      column: $table.formatsJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get analyzedAt => $composableBuilder(
      column: $table.analyzedAt, builder: (column) => ColumnOrderings(column));
}

class $$AnalysisHistoryRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AnalysisHistoryRowsTable> {
  $$AnalysisHistoryRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get author =>
      $composableBuilder(column: $table.author, builder: (column) => column);

  GeneratedColumn<String> get thumbnailUrl => $composableBuilder(
      column: $table.thumbnailUrl, builder: (column) => column);

  GeneratedColumn<bool> get eligible =>
      $composableBuilder(column: $table.eligible, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get licenseSpdxId => $composableBuilder(
      column: $table.licenseSpdxId, builder: (column) => column);

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<String> get restrictionsJson => $composableBuilder(
      column: $table.restrictionsJson, builder: (column) => column);

  GeneratedColumn<String> get formatsJson => $composableBuilder(
      column: $table.formatsJson, builder: (column) => column);

  GeneratedColumn<DateTime> get analyzedAt => $composableBuilder(
      column: $table.analyzedAt, builder: (column) => column);
}

class $$AnalysisHistoryRowsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AnalysisHistoryRowsTable,
    AnalysisHistoryRow,
    $$AnalysisHistoryRowsTableFilterComposer,
    $$AnalysisHistoryRowsTableOrderingComposer,
    $$AnalysisHistoryRowsTableAnnotationComposer,
    $$AnalysisHistoryRowsTableCreateCompanionBuilder,
    $$AnalysisHistoryRowsTableUpdateCompanionBuilder,
    (
      AnalysisHistoryRow,
      BaseReferences<_$AppDatabase, $AnalysisHistoryRowsTable,
          AnalysisHistoryRow>
    ),
    AnalysisHistoryRow,
    PrefetchHooks Function()> {
  $$AnalysisHistoryRowsTableTableManager(
      _$AppDatabase db, $AnalysisHistoryRowsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AnalysisHistoryRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AnalysisHistoryRowsTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AnalysisHistoryRowsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> url = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String?> author = const Value.absent(),
            Value<String?> thumbnailUrl = const Value.absent(),
            Value<bool> eligible = const Value.absent(),
            Value<String> source = const Value.absent(),
            Value<String?> licenseSpdxId = const Value.absent(),
            Value<String> reason = const Value.absent(),
            Value<String> restrictionsJson = const Value.absent(),
            Value<String> formatsJson = const Value.absent(),
            Value<DateTime> analyzedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AnalysisHistoryRowsCompanion(
            id: id,
            url: url,
            title: title,
            author: author,
            thumbnailUrl: thumbnailUrl,
            eligible: eligible,
            source: source,
            licenseSpdxId: licenseSpdxId,
            reason: reason,
            restrictionsJson: restrictionsJson,
            formatsJson: formatsJson,
            analyzedAt: analyzedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String url,
            required String title,
            Value<String?> author = const Value.absent(),
            Value<String?> thumbnailUrl = const Value.absent(),
            required bool eligible,
            required String source,
            Value<String?> licenseSpdxId = const Value.absent(),
            required String reason,
            Value<String> restrictionsJson = const Value.absent(),
            Value<String> formatsJson = const Value.absent(),
            required DateTime analyzedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              AnalysisHistoryRowsCompanion.insert(
            id: id,
            url: url,
            title: title,
            author: author,
            thumbnailUrl: thumbnailUrl,
            eligible: eligible,
            source: source,
            licenseSpdxId: licenseSpdxId,
            reason: reason,
            restrictionsJson: restrictionsJson,
            formatsJson: formatsJson,
            analyzedAt: analyzedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AnalysisHistoryRowsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AnalysisHistoryRowsTable,
    AnalysisHistoryRow,
    $$AnalysisHistoryRowsTableFilterComposer,
    $$AnalysisHistoryRowsTableOrderingComposer,
    $$AnalysisHistoryRowsTableAnnotationComposer,
    $$AnalysisHistoryRowsTableCreateCompanionBuilder,
    $$AnalysisHistoryRowsTableUpdateCompanionBuilder,
    (
      AnalysisHistoryRow,
      BaseReferences<_$AppDatabase, $AnalysisHistoryRowsTable,
          AnalysisHistoryRow>
    ),
    AnalysisHistoryRow,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$DownloadTaskRowsTableTableManager get downloadTaskRows =>
      $$DownloadTaskRowsTableTableManager(_db, _db.downloadTaskRows);
  $$LibraryEntryRowsTableTableManager get libraryEntryRows =>
      $$LibraryEntryRowsTableTableManager(_db, _db.libraryEntryRows);
  $$AnalysisHistoryRowsTableTableManager get analysisHistoryRows =>
      $$AnalysisHistoryRowsTableTableManager(_db, _db.analysisHistoryRows);
}
