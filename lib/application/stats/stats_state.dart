import 'package:equatable/equatable.dart';
import 'package:sport_tech_app/domain/stats/entities/player_statistics.dart';
import 'package:sport_tech_app/domain/stats/entities/scorer_stats.dart';
import 'package:sport_tech_app/domain/stats/entities/match_summary.dart';
import 'package:sport_tech_app/domain/stats/entities/quarter_performance.dart';

/// State for statistics data
class StatsState extends Equatable {
  final List<PlayerStatistics> playerStatistics;
  final List<ScorerStats> scorers;
  final List<ScorerStats> assisters;
  final List<MatchSummary> matches;
  final List<QuarterPerformance> quarters;
  final bool isLoading;
  final String? error;

  const StatsState({
    this.playerStatistics = const [],
    this.scorers = const [],
    this.assisters = const [],
    this.matches = const [],
    this.quarters = const [],
    this.isLoading = false,
    this.error,
  });

  StatsState copyWith({
    List<PlayerStatistics>? playerStatistics,
    List<ScorerStats>? scorers,
    List<ScorerStats>? assisters,
    List<MatchSummary>? matches,
    List<QuarterPerformance>? quarters,
    bool? isLoading,
    String? error,
  }) {
    return StatsState(
      playerStatistics: playerStatistics ?? this.playerStatistics,
      scorers: scorers ?? this.scorers,
      assisters: assisters ?? this.assisters,
      matches: matches ?? this.matches,
      quarters: quarters ?? this.quarters,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
        playerStatistics,
        scorers,
        assisters,
        matches,
        quarters,
        isLoading,
        error,
      ];
}
