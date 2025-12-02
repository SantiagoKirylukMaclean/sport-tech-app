// lib/domain/matches/repositories/match_goals_repository.dart

import 'package:sport_tech_app/core/utils/result.dart';
import 'package:sport_tech_app/domain/matches/entities/match_goal.dart';

/// Repository interface for match goals operations
abstract class MatchGoalsRepository {
  /// Get all goals for a match
  /// Returns list of [MatchGoal] on success, [Failure] on error
  Future<Result<List<MatchGoal>>> getGoalsByMatch(String matchId);

  /// Get goals for a specific quarter in a match
  /// Returns list of [MatchGoal] on success, [Failure] on error
  Future<Result<List<MatchGoal>>> getGoalsByMatchAndQuarter({
    required String matchId,
    required int quarter,
  });

  /// Create a new goal
  /// Returns created [MatchGoal] on success, [Failure] on error
  Future<Result<MatchGoal>> createGoal({
    required String matchId,
    required int quarter,
    required String scorerId,
    String? assisterId,
  });

  /// Update an existing goal
  /// Returns updated [MatchGoal] on success, [Failure] on error
  Future<Result<MatchGoal>> updateGoal({
    required String id,
    String? scorerId,
    String? assisterId,
  });

  /// Delete a goal
  /// Returns void on success, [Failure] on error
  Future<Result<void>> deleteGoal(String id);
}
