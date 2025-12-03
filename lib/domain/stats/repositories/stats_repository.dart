import 'package:sport_tech_app/domain/stats/entities/player_statistics.dart';
import 'package:sport_tech_app/domain/stats/entities/scorer_stats.dart';
import 'package:sport_tech_app/domain/stats/entities/match_summary.dart';
import 'package:sport_tech_app/domain/stats/entities/quarter_performance.dart';

/// Repository for accessing statistical data
abstract class StatsRepository {
  /// Get comprehensive player statistics for a team
  Future<List<PlayerStatistics>> getTeamPlayerStatistics(String teamId);

  /// Get top scorers ranking for a team
  Future<List<ScorerStats>> getScorersRanking(String teamId, {int limit = 10});

  /// Get top assisters ranking for a team
  Future<List<ScorerStats>> getAssistersRanking(String teamId, {int limit = 10});

  /// Get summary of all matches for a team
  Future<List<MatchSummary>> getMatchesSummary(String teamId);

  /// Get quarter performance statistics for a team
  Future<List<QuarterPerformance>> getQuarterPerformance(String teamId);
}
