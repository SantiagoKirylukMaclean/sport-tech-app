// lib/domain/matches/repositories/match_substitutions_repository.dart

import 'package:sport_tech_app/core/utils/result.dart';
import 'package:sport_tech_app/domain/matches/entities/match_substitution.dart';

/// Repository interface for match substitutions operations
abstract class MatchSubstitutionsRepository {
  /// Get all substitutions for a match
  /// Returns list of [MatchSubstitution] on success, [Failure] on error
  Future<Result<List<MatchSubstitution>>> getSubstitutionsByMatch(
    String matchId,
  );

  /// Get substitutions for a specific quarter in a match
  /// Returns list of [MatchSubstitution] on success, [Failure] on error
  Future<Result<List<MatchSubstitution>>> getSubstitutionsByMatchAndQuarter({
    required String matchId,
    required int quarter,
  });

  /// Apply a substitution (uses RPC function)
  /// This automatically updates both players' periods to HALF
  /// Returns void on success, [Failure] on error
  Future<Result<void>> applySubstitution({
    required String matchId,
    required int period,
    required String playerOut,
    required String playerIn,
  });

  /// Remove a substitution (uses RPC function)
  /// This restores the previous state
  /// Returns void on success, [Failure] on error
  Future<Result<void>> removeSubstitution({
    required String matchId,
    required int period,
    required String playerOut,
    required String playerIn,
  });
}
