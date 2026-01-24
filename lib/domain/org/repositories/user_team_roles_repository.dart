// lib/domain/org/repositories/user_team_roles_repository.dart

import 'package:sport_tech_app/core/utils/result.dart';
import 'package:sport_tech_app/domain/org/entities/user_team_role.dart';

/// Repository interface for user team roles operations
/// This is the contract that infrastructure layer must implement
abstract class UserTeamRolesRepository {
  /// Get roles by user
  /// Returns list of [UserTeamRole] on success, [Failure] on error
  Future<Result<List<UserTeamRole>>> getRolesByUser(String userId);

  /// Get roles by team
  /// Returns list of [UserTeamRole] on success, [Failure] on error
  Future<Result<List<UserTeamRole>>> getRolesByTeam(String teamId);

  /// Assign a role to a user for a team
  /// Returns created [UserTeamRole] on success, [Failure] on error
  Future<Result<UserTeamRole>> assignRole({
    required String userId,
    required String teamId,
    required TeamRole role,
  });

  /// Remove a role assignment
  /// Returns void on success, [Failure] on error
  Future<Result<void>> removeRole({
    required String userId,
    required String teamId,
    required TeamRole role,
  });
}
