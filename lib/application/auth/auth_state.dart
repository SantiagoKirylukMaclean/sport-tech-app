// lib/application/auth/auth_state.dart

import 'package:equatable/equatable.dart';
import 'package:sport_tech_app/domain/auth/entities/auth_user.dart';
import 'package:sport_tech_app/domain/profiles/entities/user_profile.dart';

/// Represents the authentication state of the application
sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial state or when checking authentication
class AuthStateInitial extends AuthState {
  const AuthStateInitial();
}

/// Loading state during authentication operations
class AuthStateLoading extends AuthState {
  const AuthStateLoading();
}

/// User is not authenticated
class AuthStateUnauthenticated extends AuthState {
  const AuthStateUnauthenticated();
}

/// User is authenticated with both auth user and profile loaded
class AuthStateAuthenticated extends AuthState {
  final AuthUser user;
  final UserProfile profile;

  const AuthStateAuthenticated({
    required this.user,
    required this.profile,
  });

  @override
  List<Object?> get props => [user, profile];
}

/// Error state during authentication
class AuthStateError extends AuthState {
  final String message;

  const AuthStateError(this.message);

  @override
  List<Object?> get props => [message];
}
