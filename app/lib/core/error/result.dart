/// Functional result type used across all layers instead of thrown exceptions.
///
/// Responsibility: make every fallible operation's outcome explicit in its
/// signature (`Result<T>`), so unhandled errors are a compile-time smell,
/// not a runtime surprise.
library;

import 'failures.dart';

/// Either a successful value ([Ok]) or a typed [Failure] ([Err]).
sealed class Result<T> {
  const Result();

  /// Wraps a successful value.
  const factory Result.ok(T value) = Ok<T>;

  /// Wraps a failure.
  const factory Result.err(Failure failure) = Err<T>;

  /// Whether this result is a success.
  bool get isOk => this is Ok<T>;

  /// Whether this result is a failure.
  bool get isErr => this is Err<T>;

  /// Returns the value or `null` — convenient in tests and guards.
  T? get valueOrNull =>
      switch (this) { Ok(:final value) => value, Err() => null };

  /// Returns the failure or `null`.
  Failure? get failureOrNull =>
      switch (this) { Ok() => null, Err(:final failure) => failure };

  /// Exhaustive fold: both branches must be handled.
  R fold<R>(R Function(T value) onOk, R Function(Failure failure) onErr) =>
      switch (this) {
        Ok(:final value) => onOk(value),
        Err(:final failure) => onErr(failure),
      };

  /// Transforms the success value, propagating failures untouched.
  Result<R> map<R>(R Function(T value) transform) => switch (this) {
        Ok(:final value) => Result.ok(transform(value)),
        Err(:final failure) => Result.err(failure),
      };

  /// Monadic bind: chains another fallible operation.
  Result<R> flatMap<R>(Result<R> Function(T value) transform) => switch (this) {
        Ok(:final value) => transform(value),
        Err(:final failure) => Result.err(failure),
      };
}

/// Successful branch of [Result].
final class Ok<T> extends Result<T> {
  /// Wraps the successful [value].
  const Ok(this.value);

  /// The successful value.
  final T value;

  @override
  bool operator ==(Object other) => other is Ok<T> && other.value == value;

  @override
  int get hashCode => Object.hash('Ok', value);

  @override
  String toString() => 'Ok($value)';
}

/// Failure branch of [Result].
final class Err<T> extends Result<T> {
  /// Wraps the [failure].
  const Err(this.failure);

  /// The typed failure describing what went wrong.
  final Failure failure;

  @override
  bool operator ==(Object other) => other is Err<T> && other.failure == failure;

  @override
  int get hashCode => Object.hash('Err', failure);

  @override
  String toString() => 'Err($failure)';
}
