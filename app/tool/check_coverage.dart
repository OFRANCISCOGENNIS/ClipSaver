/// Coverage gate (section 4.4: ≥95% no domínio/aplicação, ≥80% no total).
///
/// Responsibility: turn `coverage/lcov.info` into a pass/fail decision per
/// layer, because a single global number hides the case this project cares
/// about most — a well-tested UI floating an untested state machine.
///
/// Usage: `dart run tool/check_coverage.dart [caminho/para/lcov.info]`
library;

import 'dart:convert';
import 'dart:io';

/// Minimum line coverage for the layers that hold the rules.
const double kCriticalThreshold = 95.0;

/// Minimum line coverage for the package as a whole.
const double kOverallThreshold = 80.0;

/// Files excluded from every number.
///
/// Generated code is not authored, so measuring it says nothing about the
/// tests; including `database.g.dart` alone would swing the total by tens
/// of points in whichever direction the generator happened to emit.
bool isGenerated(String path) =>
    path.endsWith('.g.dart') ||
    path.endsWith('.freezed.dart') ||
    path.startsWith('lib/l10n/generated/');

/// The layers section 4.4 holds to the higher bar.
bool isCritical(String path) =>
    path.contains('/domain/') || path.contains('/application/');

/// Line counts for one file or bucket.
class Counts {
  /// Lines instrumented.
  int found = 0;

  /// Lines executed at least once.
  int hit = 0;

  /// Percentage covered; an empty bucket counts as fully covered, since
  /// there is nothing in it that could be untested.
  double get percent => found == 0 ? 100 : hit * 100 / found;
}

/// One record parsed out of the lcov file.
typedef FileCoverage = ({String path, int found, int hit});

/// Parses lcov [content] into per-file records, skipping generated code.
List<FileCoverage> parseLcov(String content) {
  final records = <FileCoverage>[];
  String? path;
  var found = 0;
  var hit = 0;

  for (final line in const LineSplitter().convert(content)) {
    if (line.startsWith('SF:')) {
      path = line.substring(3).trim();
      found = 0;
      hit = 0;
    } else if (line.startsWith('LF:')) {
      found = int.parse(line.substring(3).trim());
    } else if (line.startsWith('LH:')) {
      hit = int.parse(line.substring(3).trim());
    } else if (line.trim() == 'end_of_record' && path != null) {
      if (!isGenerated(path)) {
        records.add((path: path, found: found, hit: hit));
      }
      path = null;
    }
  }
  return records;
}

void main(List<String> args) {
  final file = File(args.isEmpty ? 'coverage/lcov.info' : args.first);
  if (!file.existsSync()) {
    stderr.writeln(
      'Arquivo de cobertura não encontrado: ${file.path}\n'
      'Rode `flutter test --coverage` antes.',
    );
    exit(2);
  }

  final records = parseLcov(file.readAsStringSync());
  if (records.isEmpty) {
    // An empty report passing every gate is the worst possible outcome:
    // it reads as "100% covered" when nothing ran at all.
    stderr.writeln('Relatório de cobertura vazio — nenhum arquivo medido.');
    exit(2);
  }

  final critical = Counts();
  final overall = Counts();
  for (final record in records) {
    overall
      ..found += record.found
      ..hit += record.hit;
    if (isCritical(record.path)) {
      critical
        ..found += record.found
        ..hit += record.hit;
    }
  }

  String row(String label, Counts counts, double threshold) =>
      '${label.padRight(24)} '
      '${counts.percent.toStringAsFixed(2).padLeft(6)}%  '
      '(${counts.hit}/${counts.found})  '
      'mínimo ${threshold.toStringAsFixed(0)}%';

  stdout
    ..writeln('Cobertura por camada (${records.length} arquivos medidos)')
    ..writeln(row('domínio + aplicação', critical, kCriticalThreshold))
    ..writeln(row('total', overall, kOverallThreshold));

  final failures = <String>[
    if (critical.percent < kCriticalThreshold)
      'domínio/aplicação em ${critical.percent.toStringAsFixed(2)}% '
          '(mínimo ${kCriticalThreshold.toStringAsFixed(0)}%)',
    if (overall.percent < kOverallThreshold)
      'total em ${overall.percent.toStringAsFixed(2)}% '
          '(mínimo ${kOverallThreshold.toStringAsFixed(0)}%)',
  ];

  if (failures.isEmpty) {
    stdout.writeln('\nGates de cobertura aprovados.');
    return;
  }

  // Naming the biggest gaps turns a red build into a work list instead of
  // a number to argue with.
  final worst = records.where((r) => r.found > r.hit).toList()
    ..sort((a, b) => (b.found - b.hit).compareTo(a.found - a.hit));

  stdout.writeln('\nMaiores lacunas:');
  for (final record in worst.take(10)) {
    final percent = (record.hit * 100 / record.found).toStringAsFixed(1);
    stdout.writeln(
      '  ${(record.found - record.hit).toString().padLeft(5)} linhas '
      'sem cobertura  ($percent%)  ${record.path}',
    );
  }

  stderr.writeln('\nGate de cobertura reprovado: ${failures.join('; ')}.');
  exit(1);
}
