import 'package:flutter_test/flutter_test.dart';
import 'package:vidora/features/converter/application/ffmpeg_command_builder.dart';
import 'package:vidora/features/converter/domain/conversion_job.dart';
import 'package:vidora/features/converter/domain/conversion_request.dart';

void main() {
  List<String> build(ConversionRequest request) => FfmpegCommandBuilder.build(
        sourcePath: '/library/aula.mkv',
        outputPath: '/library/aula.mp4',
        request: request,
      );

  /// Value that follows [flag] in the argument list.
  String? valueOf(List<String> args, String flag) {
    final index = args.indexOf(flag);
    return index == -1 || index + 1 >= args.length ? null : args[index + 1];
  }

  group('common arguments', () {
    test('always overwrites, silences the banner and reports progress', () {
      final args = build(const ConversionRequest(target: ConversionTarget.mp4));
      expect(args, contains('-y'));
      expect(args, contains('-hide_banner'));
      expect(valueOf(args, '-progress'), 'pipe:1');
      expect(args, contains('-nostats'));
    });

    test('input comes before the output path', () {
      final args = build(const ConversionRequest(target: ConversionTarget.mp4));
      expect(valueOf(args, '-i'), '/library/aula.mkv');
      expect(args.last, '/library/aula.mp4');
    });
  });

  group('video conversion', () {
    test('applies the requested codec and CRF', () {
      final args = build(
        const ConversionRequest(
          target: ConversionTarget.mp4,
          videoCodec: VideoCodec.h265,
          crf: 28,
        ),
      );
      expect(valueOf(args, '-c:v'), 'libx265');
      expect(valueOf(args, '-crf'), '28');
    });

    test('scales keeping the aspect ratio with an even width', () {
      final args = build(
        const ConversionRequest(target: ConversionTarget.mp4, heightPx: 720),
      );
      // -2 rounds the width to an even number, which H.264 requires.
      expect(valueOf(args, '-vf'), 'scale=-2:720');
    });

    test('picks a sensible default codec per container', () {
      expect(
        valueOf(build(const ConversionRequest(target: ConversionTarget.webm)),
            '-c:v'),
        'libvpx-vp9',
      );
      expect(
        valueOf(build(const ConversionRequest(target: ConversionTarget.mp4)),
            '-c:v'),
        'libx264',
      );
      // Matroska is a container swap; re-encoding would be pure waste.
      expect(
        valueOf(build(const ConversionRequest(target: ConversionTarget.mkv)),
            '-c:v'),
        'copy',
      );
    });

    test('does not pass encoder settings when copying the stream', () {
      final args = build(
        const ConversionRequest(
          target: ConversionTarget.mkv,
          videoCodec: VideoCodec.copy,
          crf: 20,
          heightPx: 480,
        ),
      );
      expect(args, isNot(contains('-crf')));
      expect(args, isNot(contains('-vf')));
    });
  });

  group('audio extraction', () {
    test('drops the video stream and preserves metadata', () {
      final args = build(const ConversionRequest(target: ConversionTarget.mp3));
      expect(args, contains('-vn'));
      expect(valueOf(args, '-map_metadata'), '0');
      expect(args, isNot(contains('-c:v')));
    });

    test('maps each audio container to its codec', () {
      final expected = {
        ConversionTarget.mp3: 'libmp3lame',
        ConversionTarget.aac: 'aac',
        ConversionTarget.wav: 'pcm_s16le',
        ConversionTarget.flac: 'flac',
        ConversionTarget.ogg: 'libvorbis',
        ConversionTarget.opus: 'libopus',
      };
      for (final entry in expected.entries) {
        final args = build(ConversionRequest(target: entry.key));
        expect(valueOf(args, '-c:a'), entry.value, reason: entry.key.name);
      }
    });

    test('applies bitrate, sample rate and channels', () {
      final args = build(
        const ConversionRequest(
          target: ConversionTarget.mp3,
          audioBitrateKbps: 128,
          sampleRateHz: 44100,
          channels: 1,
        ),
      );
      expect(valueOf(args, '-b:a'), '128k');
      expect(valueOf(args, '-ar'), '44100');
      expect(valueOf(args, '-ac'), '1');
    });

    test('never passes a bitrate to a lossless codec', () {
      // FFmpeg errors out on -b:a with FLAC/PCM, so it must be omitted.
      for (final target in [ConversionTarget.flac, ConversionTarget.wav]) {
        final args = build(
          ConversionRequest(target: target, audioBitrateKbps: 320),
        );
        expect(args, isNot(contains('-b:a')), reason: target.name);
      }
    });
  });

  group('trimming', () {
    final trim = TrimRange(
      start: const Duration(minutes: 1, seconds: 30),
      end: const Duration(minutes: 2, seconds: 45, milliseconds: 500),
    );

    test('seeks before the input for a fast keyframe seek', () {
      final args = build(
        ConversionRequest(target: ConversionTarget.mp4, trim: trim),
      );
      expect(args.indexOf('-ss'), lessThan(args.indexOf('-i')));
      expect(valueOf(args, '-ss'), '00:01:30.000');
      expect(valueOf(args, '-t'), '00:01:15.500');
    });

    test('a pure trim copies the streams instead of re-encoding', () {
      final args = build(
        ConversionRequest(target: ConversionTarget.mp4, trim: trim),
      );
      expect(valueOf(args, '-c'), 'copy');
      expect(args, isNot(contains('-c:v')));
      expect(args, isNot(contains('-c:a')));
    });

    test('a trim combined with re-encoding does not copy', () {
      final args = build(
        ConversionRequest(
          target: ConversionTarget.mp4,
          trim: trim,
          crf: 20,
        ),
      );
      expect(valueOf(args, '-c'), isNot('copy'));
      expect(valueOf(args, '-crf'), '20');
    });

    test('formats timestamps as HH:MM:SS.mmm across hours', () {
      final args = build(
        ConversionRequest(
          target: ConversionTarget.mp4,
          trim: TrimRange(
            start: const Duration(hours: 2, minutes: 3, seconds: 4),
            end: const Duration(hours: 2, minutes: 3, seconds: 5),
          ),
        ),
      );
      expect(valueOf(args, '-ss'), '02:03:04.000');
    });
  });

  group('presets (section 11)', () {
    test('maximum compatibility is H.264 + AAC in MP4', () {
      final request = ConversionPreset.maxCompatibility.toRequest();
      expect(request.target, ConversionTarget.mp4);
      final args = build(request);
      expect(valueOf(args, '-c:v'), 'libx264');
      expect(valueOf(args, '-c:a'), 'aac');
    });

    test('smallest size uses H.265 with a higher CRF', () {
      final request = ConversionPreset.smallestSize.toRequest();
      expect(valueOf(build(request), '-c:v'), 'libx265');
      expect(request.crf,
          greaterThan(ConversionPreset.maxCompatibility.toRequest().crf!));
    });

    test('podcast audio is MP3 at 128 kbps', () {
      final request = ConversionPreset.podcastAudio.toRequest();
      expect(request.target, ConversionTarget.mp3);
      expect(valueOf(build(request), '-b:a'), '128k');
    });

    test('lossless is FLAC with no bitrate', () {
      final request = ConversionPreset.lossless.toRequest();
      expect(request.target, ConversionTarget.flac);
      expect(build(request), isNot(contains('-b:a')));
    });

    test('each preset maps to its own distinct target', () {
      // Guards against unqualified enum patterns, which would silently
      // make every preset resolve to the first branch.
      final targets =
          ConversionPreset.values.map((p) => p.toRequest().target).toList();
      expect(targets, [
        ConversionTarget.mp4,
        ConversionTarget.mp4,
        ConversionTarget.mp3,
        ConversionTarget.flac,
      ]);
      expect(
        ConversionPreset.maxCompatibility.toRequest().videoCodec,
        isNot(ConversionPreset.smallestSize.toRequest().videoCodec),
      );
    });
  });

  group('request validation', () {
    test('rejects out-of-range CRF and bitrate', () {
      expect(
        () => ConversionRequest(target: ConversionTarget.mp4, crf: 99),
        throwsA(isA<AssertionError>()),
      );
      expect(
        () => ConversionRequest(
          target: ConversionTarget.mp3,
          audioBitrateKbps: 5000,
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('rejects a trim that ends before it starts', () {
      expect(
        () => TrimRange(
          start: const Duration(minutes: 2),
          end: const Duration(minutes: 1),
        ),
        throwsArgumentError,
      );
    });
  });

  group('parseFfmpegProgress', () {
    const total = Duration(seconds: 100);

    test('reads out_time_us as a fraction of the source duration', () {
      expect(parseFfmpegProgress('out_time_us=50000000', total), 0.5);
    });

    test('reads out_time_ms too', () {
      expect(parseFfmpegProgress('out_time_ms=25000', total), 0.25);
    });

    test('ignores unrelated progress keys', () {
      expect(parseFfmpegProgress('frame=120', total), isNull);
      expect(parseFfmpegProgress('speed=1.5x', total), isNull);
    });

    test('clamps overshoot and rejects negatives', () {
      expect(parseFfmpegProgress('out_time_us=999000000', total), 1.0);
      expect(parseFfmpegProgress('out_time_us=-1', total), isNull);
    });

    test('returns null when the source duration is unknown', () {
      expect(parseFfmpegProgress('out_time_us=1000', Duration.zero), isNull);
    });
  });
}
