// lib/domain/matches/repositories/match_quarter_results_repository.dart

import 'package:sport_tech_app/core/utils/result.dart';
import 'package:sport_tech_app/domain/matches/entities/match_quarter_result.dart';

/// Repository interface for match quarter results operations
abstract class MatchQuarterResultsRepository {
  /// Get all quarter results for a match
  /// Returns list of [MatchQuarterResult] on success, [Failure] on error
  Future<Result<List<MatchQuarterResult>>> getResultsByMatch(String matchId);

  /// Get a specific quarter result
  /// Returns [MatchQuarterResult] on success, [Failure] on error
  Future<Result<MatchQuarterResult?>> getResultByMatchAndQuarter({
    required String matchId,
    required int quarter,
  });

  /// Create or update a quarter result
  /// Returns created/updated [MatchQuarterResult] on success, [Failure] on error
  Future<Result<MatchQuarterResult>> upsertQuarterResult({
    required String matchId,
    required int quarter,
    required int teamGoals,
    required int opponentGoals,
  });

  /// Delete a quarter result
  /// Returns void on success, [Failure] on error
  Future<Result<void>> deleteQuarterResult({
    required String matchId,
    required int quarter,
  });
}
