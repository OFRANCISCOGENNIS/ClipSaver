import 'package:test/test.dart';
import 'package:vidora/core/error/failures.dart';
import 'package:vidora/core/error/result.dart';

void main() {
  const failure = NetworkFailure('sem conexão');

  group('Result', () {
    test('ok exposes value and flags', () {
      const result = Result.ok(42);
      expect(result.isOk, isTrue);
      expect(result.isErr, isFalse);
      expect(result.valueOrNull, 42);
      expect(result.failureOrNull, isNull);
    });

    test('err exposes failure and flags', () {
      const result = Result<int>.err(failure);
      expect(result.isErr, isTrue);
      expect(result.valueOrNull, isNull);
      expect(result.failureOrNull, failure);
    });

    test('fold is exhaustive over both branches', () {
      expect(const Result.ok(2).fold((v) => v * 10, (_) => -1), 20);
      expect(const Result<int>.err(failure).fold((v) => v, (f) => -1), -1);
    });

    test('map transforms success and propagates failure', () {
      expect(const Result.ok(2).map((v) => v + 1), const Result.ok(3));
      expect(
        const Result<int>.err(failure).map((v) => v + 1),
        const Result<int>.err(failure),
      );
    });

    test('flatMap chains fallible operations', () {
      Result<int> half(int v) => v.isEven
          ? Result.ok(v ~/ 2)
          : const Result.err(ValidationFailure('ímpar'));
      expect(const Result.ok(4).flatMap(half), const Result.ok(2));
      expect(const Result.ok(3).flatMap(half).isErr, isTrue);
      expect(
        const Result<int>.err(failure).flatMap(half),
        const Result<int>.err(failure),
      );
    });

    test('equality holds for equal values and failures', () {
      expect(const Result.ok(1), const Result.ok(1));
      expect(
        const Result<int>.err(NetworkFailure('sem conexão')),
        const Result<int>.err(failure),
      );
    });
  });

  group('Failure equality', () {
    test('same type and message are equal', () {
      expect(const ValidationFailure('x'), const ValidationFailure('x'));
    });

    test('different types with same message differ', () {
      expect(
        const ValidationFailure('x'),
        isNot(equals(const NetworkFailure('x'))),
      );
    });

    test('ServerFailure compares status code', () {
      expect(
        const ServerFailure('x', statusCode: 500),
        isNot(equals(const ServerFailure('x', statusCode: 503))),
      );
    });
  });
}
