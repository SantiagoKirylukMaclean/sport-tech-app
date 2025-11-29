// lib/domain/profiles/entities/user_profile.dart

import 'package:equatable/equatable.dart';
import 'package:sport_tech_app/core/constants/app_constants.dart';

/// Represents a user profile in the domain
/// Maps to the public.profiles table in Supabase
class UserProfile extends Equatable {
  final String userId; // FK to auth.users.id
  final UserRole role;
  final String displayName;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserProfile({
    required this.userId,
    required this.role,
    required this.displayName,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Check if this profile has admin privileges
  bool get isAdmin => role.isAdmin;

  /// Check if this profile is a super admin
  bool get isSuperAdmin => role.isSuperAdmin;

  /// Check if this profile can manage teams
  bool get canManageTeams => role.canManageTeams;

  @override
  List<Object?> get props => [userId, role, displayName, createdAt, updatedAt];

  @override
  String toString() =>
      'UserProfile(userId: $userId, role: ${role.value}, displayName: $displayName)';
}
