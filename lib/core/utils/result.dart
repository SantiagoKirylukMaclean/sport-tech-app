// lib/core/utils/result.dart

import 'package:sport_tech_app/core/error/failures.dart';

/// A Result type that represents either a success or a failure
sealed class Result<T> {
  const Result();

  /// Execute a function based on whether this is a success or failure
  R when<R>({
    required R Function(T data) success,
    required R Function(Failure failure) failure,
  }) {
    return switch (this) {
      Success(data: final data) => success(data),
      Failed(failure: final error) => failure(error),
    };
  }

  /// Maps the success value to a new value
  Result<R> map<R>(R Function(T) mapper) {
    return when(
      success: (data) => Success(mapper(data)),
      failure: (error) => Failed(error),
    );
  }

  /// Returns true if this is a success
  bool get isSuccess => this is Success<T>;

  /// Returns true if this is a failure
  bool get isFailure => this is Failed<T>;

  /// Gets the data if success, otherwise returns null
  T? get dataOrNull => when(
        success: (data) => data,
        failure: (_) => null,
      );

  /// Gets the failure if failed, otherwise returns null
  Failure? get failureOrNull => when(
        success: (_) => null,
        failure: (error) => error,
      );
}

/// Represents a successful result
final class Success<T> extends Result<T> {
  final T data;

  const Success(this.data);
}

/// Represents a failed result
final class Failed<T> extends Result<T> {
  final Failure failure;

  const Failed(this.failure);
}
