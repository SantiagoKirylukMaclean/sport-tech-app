// lib/domain/auth/repositories/auth_repository.dart

import 'package:sport_tech_app/core/utils/result.dart';
import 'package:sport_tech_app/domain/auth/entities/auth_user.dart';

/// Repository interface for authentication operations
/// This is the contract that infrastructure layer must implement
abstract class AuthRepository {
  /// Sign in with email and password
  /// Returns [AuthUser] on success, [Failure] on error
  Future<Result<AuthUser>> signIn({
    required String email,
    required String password,
  });

  /// Sign out the current user
  /// Returns void on success, [Failure] on error
  Future<Result<void>> signOut();

  /// Get the currently authenticated user
  /// Returns [AuthUser] if signed in, null if not signed in
  Future<Result<AuthUser?>> getCurrentUser();

  /// Listen to auth state changes
  /// Returns a stream of [AuthUser?] (null when signed out)
  Stream<AuthUser?> authStateChanges();

  /// Sign up a new user with email and password
  /// Returns [AuthUser] on success, [Failure] on error
  Future<Result<AuthUser>> signUp({
    required String email,
    required String password,
  });

  /// Reset password for the given email
  /// Returns void on success, [Failure] on error
  Future<Result<void>> resetPassword({
    required String email,
  });
}
