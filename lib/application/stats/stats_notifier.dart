import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport_tech_app/application/stats/stats_state.dart';
import 'package:sport_tech_app/domain/stats/entities/player_statistics.dart';
import 'package:sport_tech_app/domain/stats/entities/scorer_stats.dart';
import 'package:sport_tech_app/domain/stats/entities/match_summary.dart';
import 'package:sport_tech_app/domain/stats/entities/quarter_performance.dart';
import 'package:sport_tech_app/domain/stats/entities/player_quarter_stats.dart';
import 'package:sport_tech_app/domain/stats/repositories/stats_repository.dart';

class StatsNotifier extends StateNotifier<StatsState> {
  final StatsRepository _repository;

  StatsNotifier(this._repository) : super(const StatsState());

  /// Load all statistics for a team
  Future<void> loadTeamStats(String teamId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Load all stats in parallel
      final results = await Future.wait<dynamic>([
        _repository.getTeamPlayerStatistics(teamId),
        _repository.getScorersRanking(teamId),
        _repository.getAssistersRanking(teamId),
        _repository.getMatchesSummary(teamId),
        _repository.getQuarterPerformance(teamId),
        _repository.getTeamTrainingAttendance(teamId),
        _repository.getPlayerQuarterStats(teamId),
      ]);

      state = state.copyWith(
        playerStatistics: results[0] as List<PlayerStatistics>,
        scorers: results[1] as List<ScorerStats>,
        assisters: results[2] as List<ScorerStats>,
        matches: results[3] as List<MatchSummary>,
        quarters: results[4] as List<QuarterPerformance>,
        teamTrainingAttendance: results[5] as double,
        playerQuarterStats: results[6] as List<PlayerQuarterStats>,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Refresh all statistics
  Future<void> refresh(String teamId) async {
    await loadTeamStats(teamId);
  }
}
