// lib/domain/matches/repositories/match_player_periods_repository.dart

import 'package:sport_tech_app/core/utils/result.dart';
import 'package:sport_tech_app/domain/matches/entities/match_player_period.dart';

/// Repository interface for match player periods operations
abstract class MatchPlayerPeriodsRepository {
  /// Get all player periods for a match
  /// Returns list of [MatchPlayerPeriod] on success, [Failure] on error
  Future<Result<List<MatchPlayerPeriod>>> getPeriodsByMatch(String matchId);

  /// Get periods for a specific player in a match
  /// Returns list of [MatchPlayerPeriod] on success, [Failure] on error
  Future<Result<List<MatchPlayerPeriod>>> getPeriodsByMatchAndPlayer({
    required String matchId,
    required String playerId,
  });

  /// Get periods for a specific quarter in a match
  /// Returns list of [MatchPlayerPeriod] on success, [Failure] on error
  Future<Result<List<MatchPlayerPeriod>>> getPeriodsByMatchAndQuarter({
    required String matchId,
    required int quarter,
  });

  /// Set a player's participation for a specific period
  /// Returns created/updated [MatchPlayerPeriod] on success, [Failure] on error
  Future<Result<MatchPlayerPeriod>> setPlayerPeriod({
    required String matchId,
    required String playerId,
    required int period,
    required Fraction fraction,
  });

  /// Remove a player's participation for a specific period
  /// Returns void on success, [Failure] on error
  Future<Result<void>> removePlayerPeriod({
    required String matchId,
    required String playerId,
    required int period,
  });

  /// Remove all periods for a player in a match
  /// Returns void on success, [Failure] on error
  Future<Result<void>> removeAllPlayerPeriods({
    required String matchId,
    required String playerId,
  });
}
