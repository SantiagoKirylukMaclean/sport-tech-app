// lib/infrastructure/org/mappers/user_team_role_mapper.dart

import 'package:sport_tech_app/domain/org/entities/user_team_role.dart';

/// Mapper for converting between Supabase JSON and UserTeamRole entity
class UserTeamRoleMapper {
  /// Convert from Supabase JSON to UserTeamRole entity
  static UserTeamRole fromJson(Map<String, dynamic> json) {
    return UserTeamRole(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      teamId: json['team_id'] as String,
      role: TeamRole.fromString(json['role'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Convert from UserTeamRole entity to Supabase JSON
  static Map<String, dynamic> toJson(UserTeamRole userTeamRole) {
    return {
      'id': userTeamRole.id,
      'user_id': userTeamRole.userId,
      'team_id': userTeamRole.teamId,
      'role': userTeamRole.role.value,
      'created_at': userTeamRole.createdAt.toIso8601String(),
    };
  }
}
