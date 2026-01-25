import 'package:sport_tech_app/core/utils/result.dart';
import 'package:sport_tech_app/domain/stats/entities/basketball_match_stat.dart';

abstract class BasketballStatsRepository {
  /// Get stats by match ID
  Future<Result<List<BasketballMatchStat>>> getStatsByMatch(String matchId);

  /// Get stats by player in a match
  Future<Result<List<BasketballMatchStat>>> getStatsByPlayer(
      String matchId, String playerId);

  /// Add a new statistic event
  Future<Result<BasketballMatchStat>> addStat(BasketballMatchStat stat);

  /// Delete a statistic event
  Future<Result<void>> deleteStat(String id);
}
