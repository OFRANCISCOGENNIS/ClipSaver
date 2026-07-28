/// Typed failures shared by every layer of the app.
///
/// Responsibility: describe *what* went wrong in domain vocabulary so the
/// presentation layer can map each case to a specific, actionable message
/// (section 7.2 requires per-type error messages, never a generic one).
library;

/// Base class for every recoverable error the domain can express.
///
/// Failures are values, not exceptions: they travel inside [Result] so the
/// type system forces callers to handle them.
sealed class Failure {
  const Failure(this.message);

  /// Human-readable, user-safe description (no stack traces, no PII).
  final String message;

  @override
  String toString() => '$runtimeType($message)';

  @override
  bool operator ==(Object other) =>
      other.runtimeType == runtimeType && (other as Failure).message == message;

  @override
  int get hashCode => Object.hash(runtimeType, message);
}

/// Input did not satisfy a domain invariant (e.g. malformed URL).
final class ValidationFailure extends Failure {
  /// Creates a validation failure with a user-facing [message].
  const ValidationFailure(super.message);
}

/// The device has no route to the backend or the origin server.
final class NetworkFailure extends Failure {
  /// Creates a network failure with a user-facing [message].
  const NetworkFailure(super.message);
}

/// The backend answered, but with an error status.
final class ServerFailure extends Failure {
  /// Creates a server failure, optionally carrying the HTTP [statusCode].
  const ServerFailure(super.message, {this.statusCode});

  /// HTTP status code returned by the backend, when known.
  final int? statusCode;

  @override
  bool operator ==(Object other) =>
      super == other && (other as ServerFailure).statusCode == statusCode;

  @override
  int get hashCode => Object.hash(super.hashCode, statusCode);
}

/// The URL was analyzed and is not eligible for download (section 2).
/// Carries the educational reason shown to the user.
final class IneligibleContentFailure extends Failure {
  /// Creates an ineligibility failure with the educational [message].
  const IneligibleContentFailure(super.message, {this.legitimatePath});

  /// Optional legitimate alternative to suggest, e.g.
  /// "Você pode salvá-lo na sua conta da plataforma de origem.".
  final String? legitimatePath;

  @override
  bool operator ==(Object other) =>
      super == other &&
      (other as IneligibleContentFailure).legitimatePath == legitimatePath;

  @override
  int get hashCode => Object.hash(super.hashCode, legitimatePath);
}

/// Local persistence (SQLite/filesystem) error.
final class StorageFailure extends Failure {
  /// Creates a storage failure with a user-facing [message].
  const StorageFailure(super.message);
}

/// A state-machine transition that the domain forbids
/// (e.g. resuming a completed download).
final class InvalidTransitionFailure extends Failure {
  /// Creates an invalid-transition failure describing the refused move.
  const InvalidTransitionFailure(super.message);
}

/// Downloaded bytes failed the integrity check (section 8.3).
final class IntegrityFailure extends Failure {
  /// Creates an integrity failure describing the failed verification.
  const IntegrityFailure(super.message);
}
