// lib/domain/matches/repositories/match_call_ups_repository.dart

import 'package:sport_tech_app/core/utils/result.dart';
import 'package:sport_tech_app/domain/matches/entities/match_call_up.dart';

/// Repository interface for match call-ups operations
abstract class MatchCallUpsRepository {
  /// Get all players called up for a match
  /// Returns list of [MatchCallUp] on success, [Failure] on error
  Future<Result<List<MatchCallUp>>> getCallUpsByMatch(String matchId);

  /// Add a player to the match call-up list
  /// Returns created [MatchCallUp] on success, [Failure] on error
  Future<Result<MatchCallUp>> addPlayerToCallUp({
    required String matchId,
    required String playerId,
  });

  /// Remove a player from the match call-up list
  /// Returns void on success, [Failure] on error
  Future<Result<void>> removePlayerFromCallUp({
    required String matchId,
    required String playerId,
  });

  /// Check if a player is called up for a match
  /// Returns true if player is called up, false otherwise
  Future<Result<bool>> isPlayerCalledUp({
    required String matchId,
    required String playerId,
  });
}
