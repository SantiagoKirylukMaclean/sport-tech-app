// lib/domain/auth/entities/auth_user.dart

import 'package:equatable/equatable.dart';

/// Represents an authenticated user in the domain
/// This is a minimal representation focusing only on authentication
class AuthUser extends Equatable {
  final String id;
  final String email;
  final DateTime? emailConfirmedAt;

  const AuthUser({
    required this.id,
    required this.email,
    this.emailConfirmedAt,
  });

  /// Check if the user's email is confirmed
  bool get isEmailConfirmed => emailConfirmedAt != null;

  @override
  List<Object?> get props => [id, email, emailConfirmedAt];

  @override
  String toString() => 'AuthUser(id: $id, email: $email)';
}
