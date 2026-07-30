/// Process-backed [MediaConverter] for desktop and mobile targets that
/// can spawn an FFmpeg binary.
///
/// Responsibility: run FFmpeg out of process — section 11 requires the UI
/// never to block — and translate its `-progress` stream into the 0..1
/// fraction the queue expects.
///
/// A separate process, not an isolate: FFmpeg is native code, and killing
/// a process is the only reliable way to abort a transcode mid-frame.
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../application/ffmpeg_command_builder.dart';
import '../domain/media_converter.dart';

/// Starts a process; injectable so tests never spawn a real binary.
typedef ProcessStarter = Future<Process> Function(
  String executable,
  List<String> arguments,
);

/// Runs conversions through an FFmpeg executable.
final class ProcessMediaConverter implements MediaConverter {
  /// Creates the converter.
  ///
  /// [executable] defaults to whatever `ffmpeg` resolves to on PATH;
  /// release builds pass the bundled binary's absolute path.
  ProcessMediaConverter({
    this.executable = 'ffmpeg',
    ProcessStarter? startProcess,
  }) : _startProcess = startProcess ?? Process.start;

  /// Path to the FFmpeg binary.
  final String executable;

  final ProcessStarter _startProcess;
  final Map<String, Process> _running = {};
  final Set<String> _canceled = {};

  @override
  Future<ConversionResult> run({
    required String jobId,
    required List<String> arguments,
    required Duration? sourceDuration,
    required void Function(double progress) onProgress,
  }) async {
    _canceled.remove(jobId);

    final Process process;
    try {
      process = await _startProcess(executable, arguments);
    } on Object {
      return const ConversionResult(
        ConversionOutcome.failure,
        errorMessage: 'Não foi possível iniciar o conversor de mídia.',
      );
    }
    _running[jobId] = process;

    // A cancel that arrived while the process was starting must still take
    // effect — otherwise the job runs to completion after being canceled.
    if (_canceled.contains(jobId)) process.kill();

    // FFmpeg's last stderr lines are what actually explain a failure;
    // keeping a bounded tail avoids holding a whole log in memory.
    final errorTail = <String>[];
    final stderrDone = process.stderr
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen((line) {
      if (line.trim().isEmpty) return;
      errorTail.add(line);
      if (errorTail.length > 10) errorTail.removeAt(0);
    }).asFuture<void>();

    final stdoutDone = process.stdout
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen((line) {
      if (sourceDuration == null) return;
      final progress = parseFfmpegProgress(line, sourceDuration);
      if (progress != null) onProgress(progress);
    }).asFuture<void>();

    final exitCode = await process.exitCode;
    await Future.wait([stdoutDone, stderrDone]);
    _running.remove(jobId);

    if (_canceled.remove(jobId)) {
      return const ConversionResult(ConversionOutcome.canceled);
    }
    if (exitCode == 0) {
      return const ConversionResult(ConversionOutcome.success);
    }
    return ConversionResult(
      ConversionOutcome.failure,
      errorMessage: _describeFailure(errorTail),
    );
  }

  @override
  void cancel(String jobId) {
    _canceled.add(jobId);
    _running[jobId]?.kill();
  }

  /// Turns FFmpeg's stderr tail into something a user can act on.
  String _describeFailure(List<String> errorTail) {
    final joined = errorTail.join(' ').toLowerCase();
    if (joined.contains('no such file') ||
        joined.contains('no such file or directory')) {
      return 'O arquivo de origem não foi encontrado.';
    }
    if (joined.contains('permission denied')) {
      return 'Sem permissão para gravar o arquivo convertido.';
    }
    if (joined.contains('unknown encoder') ||
        joined.contains('encoder not found')) {
      return 'Este formato não é suportado pela instalação do FFmpeg.';
    }
    if (joined.contains('no space left')) {
      return 'Espaço insuficiente para gravar o arquivo convertido.';
    }
    if (joined.contains('invalid data') ||
        joined.contains('moov atom not found')) {
      return 'O arquivo de origem parece estar corrompido.';
    }
    // Nothing recognized: show FFmpeg's own last words rather than a
    // generic message that helps nobody.
    return errorTail.isEmpty
        ? 'A conversão falhou. Tente novamente.'
        : 'A conversão falhou: ${errorTail.last}';
  }
}
