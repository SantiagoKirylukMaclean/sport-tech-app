import 'package:sport_tech_app/core/utils/result.dart';
import 'package:sport_tech_app/domain/matches/entities/basketball_match_stat.dart';

abstract class BasketballMatchStatsRepository {
  Future<Result<List<BasketballMatchStat>>> getStatsByMatch(String matchId);

  Future<Result<BasketballMatchStat>> createStat({
    required String matchId,
    required String playerId,
    required int quarter,
    required BasketballStatType statType,
  });

  Future<Result<void>> deleteStat(String statId);
}
