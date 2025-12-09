// lib/domain/org/repositories/teams_repository.dart

import 'package:sport_tech_app/core/utils/result.dart';
import 'package:sport_tech_app/domain/org/entities/team.dart';

/// Repository interface for teams operations
/// This is the contract that infrastructure layer must implement
abstract class TeamsRepository {
  /// Get all teams
  /// Returns list of [Team] on success, [Failure] on error
  Future<Result<List<Team>>> getAllTeams();

  /// Get teams by club
  /// Returns list of [Team] on success, [Failure] on error
  Future<Result<List<Team>>> getTeamsByClub(String clubId);

  /// Get teams for a specific user (based on user_team_roles)
  /// Returns list of [Team] on success, [Failure] on error
  Future<Result<List<Team>>> getTeamsByUser(String userId);

  /// Get a team by ID
  /// Returns [Team] on success, [Failure] on error
  Future<Result<Team>> getTeamById(String id);

  /// Create a new team
  /// Returns created [Team] on success, [Failure] on error
  Future<Result<Team>> createTeam({
    required String clubId,
    required String name,
    String? standingsUrl,
    String? resultsUrl,
    String? calendarUrl,
  });

  /// Update an existing team
  /// Returns updated [Team] on success, [Failure] on error
  Future<Result<Team>> updateTeam({
    required String id,
    required String name,
    String? standingsUrl,
    String? resultsUrl,
    String? calendarUrl,
  });

  /// Delete a team
  /// Returns void on success, [Failure] on error
  Future<Result<void>> deleteTeam(String id);
}
