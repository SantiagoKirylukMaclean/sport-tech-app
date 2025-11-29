// lib/core/error/failures.dart

import 'package:equatable/equatable.dart';

/// Base class for all failures in the application
abstract class Failure extends Equatable {
  final String message;
  final String? code;

  const Failure(this.message, {this.code});

  @override
  List<Object?> get props => [message, code];
}

/// Server-related failures (API, database, etc.)
class ServerFailure extends Failure {
  const ServerFailure(super.message, {super.code});
}

/// Authentication failures
class AuthFailure extends Failure {
  const AuthFailure(super.message, {super.code});
}

/// Network-related failures
class NetworkFailure extends Failure {
  const NetworkFailure(super.message, {super.code});
}

/// Cache-related failures
class CacheFailure extends Failure {
  const CacheFailure(super.message, {super.code});
}

/// Validation failures
class ValidationFailure extends Failure {
  const ValidationFailure(super.message, {super.code});
}

/// Permission/Authorization failures
class PermissionFailure extends Failure {
  const PermissionFailure(super.message, {super.code});
}

/// Not found failures
class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message, {super.code});
}

/// Unknown/Unexpected failures
class UnknownFailure extends Failure {
  const UnknownFailure(super.message, {super.code});
}
