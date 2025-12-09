// lib/infrastructure/auth/supabase_auth_repository.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sport_tech_app/core/error/failures.dart';
import 'package:sport_tech_app/core/utils/result.dart';
import 'package:sport_tech_app/domain/auth/entities/auth_user.dart' as domain;
import 'package:sport_tech_app/domain/auth/repositories/auth_repository.dart';
import 'package:sport_tech_app/infrastructure/auth/mappers/auth_user_mapper.dart';

/// Supabase implementation of [AuthRepository]
class SupabaseAuthRepository implements AuthRepository {
  final SupabaseClient _client;

  SupabaseAuthRepository(this._client);

  @override
  Future<Result<domain.AuthUser>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );

      if (response.user == null) {
        return const Failed(
          AuthFailure('Sign in failed: No user returned'),
        );
      }

      return Success(AuthUserMapper.fromSupabase(response.user!));
    } on AuthException catch (e) {
      return Failed(AuthFailure(e.message, code: e.statusCode));
    } catch (e) {
      return Failed(AuthFailure('Unexpected error during sign in: $e'));
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      await _client.auth.signOut();
      return const Success(null);
    } on AuthException catch (e) {
      return Failed(AuthFailure(e.message, code: e.statusCode));
    } catch (e) {
      return Failed(AuthFailure('Unexpected error during sign out: $e'));
    }
  }

  @override
  Future<Result<domain.AuthUser?>> getCurrentUser() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        return const Success(null);
      }
      return Success(AuthUserMapper.fromSupabase(user));
    } catch (e) {
      return Failed(AuthFailure('Error getting current user: $e'));
    }
  }

  @override
  Stream<domain.AuthUser?> authStateChanges() {
    return _client.auth.onAuthStateChange.map((state) {
      final user = state.session?.user;
      return user != null ? AuthUserMapper.fromSupabase(user) : null;
    });
  }

  @override
  Future<Result<domain.AuthUser>> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email.trim(),
        password: password,
      );

      if (response.user == null) {
        return const Failed(
          AuthFailure('Sign up failed: No user returned'),
        );
      }

      return Success(AuthUserMapper.fromSupabase(response.user!));
    } on AuthException catch (e) {
      return Failed(AuthFailure(e.message, code: e.statusCode));
    } catch (e) {
      return Failed(AuthFailure('Unexpected error during sign up: $e'));
    }
  }

  @override
  Future<Result<void>> resetPassword({required String email}) async {
    try {
      await _client.auth.resetPasswordForEmail(email.trim());
      return const Success(null);
    } on AuthException catch (e) {
      return Failed(AuthFailure(e.message, code: e.statusCode));
    } catch (e) {
      return Failed(AuthFailure('Unexpected error during password reset: $e'));
    }
  }

  @override
  Future<Result<void>> updatePassword({required String newPassword}) async {
    try {
      await _client.auth.updateUser(
        UserAttributes(password: newPassword),
      );
      return const Success(null);
    } on AuthException catch (e) {
      return Failed(AuthFailure(e.message, code: e.statusCode));
    } catch (e) {
      return Failed(AuthFailure('Unexpected error updating password: $e'));
    }
  }
}
