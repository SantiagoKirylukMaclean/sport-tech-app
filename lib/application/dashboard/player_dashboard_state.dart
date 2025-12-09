// lib/application/dashboard/player_dashboard_state.dart

import 'package:equatable/equatable.dart';
import 'package:sport_tech_app/domain/stats/entities/player_statistics.dart';
import 'package:sport_tech_app/domain/stats/entities/match_summary.dart';
import 'package:sport_tech_app/domain/org/entities/player.dart';

/// State for the player dashboard
class PlayerDashboardState extends Equatable {
  final Player? player;
  final PlayerStatistics? playerStats;
  final List<MatchSummary> teamMatches;
  final int evaluationsCount;
  final bool isLoading;
  final String? error;

  const PlayerDashboardState({
    this.player,
    this.playerStats,
    this.teamMatches = const [],
    this.evaluationsCount = 0,
    this.isLoading = false,
    this.error,
  });

  PlayerDashboardState copyWith({
    Player? player,
    PlayerStatistics? playerStats,
    List<MatchSummary>? teamMatches,
    int? evaluationsCount,
    bool? isLoading,
    String? error,
  }) {
    return PlayerDashboardState(
      player: player ?? this.player,
      playerStats: playerStats ?? this.playerStats,
      teamMatches: teamMatches ?? this.teamMatches,
      evaluationsCount: evaluationsCount ?? this.evaluationsCount,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
        player,
        playerStats,
        teamMatches,
        evaluationsCount,
        isLoading,
        error,
      ];
}
