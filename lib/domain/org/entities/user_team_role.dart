// lib/domain/org/entities/user_team_role.dart

import 'package:equatable/equatable.dart';
import 'package:sport_tech_app/core/constants/app_constants.dart';

/// Represents a user's role assignment to a team
/// Maps to the public.user_team_roles table in Supabase
class UserTeamRole extends Equatable {
  final String id;
  final String userId;
  final String teamId;
  final TeamRole role;
  final DateTime createdAt;

  const UserTeamRole({
    required this.id,
    required this.userId,
    required this.teamId,
    required this.role,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, userId, teamId, role, createdAt];

  @override
  String toString() =>
      'UserTeamRole(userId: $userId, teamId: $teamId, role: ${role.value})';

  /// Create a copy with updated fields
  UserTeamRole copyWith({
    String? id,
    String? userId,
    String? teamId,
    TeamRole? role,
    DateTime? createdAt,
  }) {
    return UserTeamRole(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      teamId: teamId ?? this.teamId,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Team-specific roles (coach or admin within a team context)
enum TeamRole {
  coach('coach'),
  admin('admin');

  final String value;
  const TeamRole(this.value);

  static TeamRole fromString(String value) {
    return TeamRole.values.firstWhere(
      (role) => role.value == value,
      orElse: () => TeamRole.coach,
    );
  }
}
