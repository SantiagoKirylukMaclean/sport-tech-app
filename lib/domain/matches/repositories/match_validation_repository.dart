// lib/domain/matches/repositories/match_validation_repository.dart

import 'package:sport_tech_app/core/utils/result.dart';

/// Data class for validation results
class PlayerMinimumPeriodsViolation {
  final String playerId;
  final String playerName;
  final int periodsPlayed;

  const PlayerMinimumPeriodsViolation({
    required this.playerId,
    required this.playerName,
    required this.periodsPlayed,
  });
}

/// Repository interface for match validation operations
abstract class MatchValidationRepository {
  /// Validate that all called-up players have played minimum required periods (2)
  /// Returns list of players who don't meet the minimum requirement
  /// Empty list means all players meet the requirement
  Future<Result<List<PlayerMinimumPeriodsViolation>>>
      validateMinimumPeriods(String matchId);
}
