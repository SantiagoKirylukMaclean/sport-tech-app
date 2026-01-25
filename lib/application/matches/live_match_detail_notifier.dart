import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport_tech_app/core/utils/result.dart';
import 'package:sport_tech_app/domain/matches/entities/basketball_match_stat.dart';
import 'package:sport_tech_app/domain/matches/entities/match.dart';
import 'package:sport_tech_app/domain/matches/entities/match_goal.dart';
import 'package:sport_tech_app/domain/matches/entities/match_quarter_result.dart';
import 'package:sport_tech_app/domain/matches/repositories/basketball_match_stats_repository.dart';
import 'package:sport_tech_app/domain/matches/repositories/match_goals_repository.dart';
import 'package:sport_tech_app/domain/matches/repositories/match_quarter_results_repository.dart';
import 'package:sport_tech_app/domain/matches/repositories/matches_repository.dart';
import 'package:sport_tech_app/domain/org/entities/team.dart';
import 'package:sport_tech_app/domain/org/repositories/teams_repository.dart';

class LiveMatchDetailState {
  final bool isLoading;
  final Match? match;
  final List<MatchQuarterResult> quarterResults;
  final List<MatchGoal> goals;
  final List<BasketballMatchStat> basketballStats;
  final String? sportName;
  final String? error;

  const LiveMatchDetailState({
    this.isLoading = false,
    this.match,
    this.quarterResults = const [],
    this.goals = const [],
    this.basketballStats = const [],
    this.sportName,
    this.error,
  });

  LiveMatchDetailState copyWith({
    bool? isLoading,
    Match? match,
    List<MatchQuarterResult>? quarterResults,
    List<MatchGoal>? goals,
    List<BasketballMatchStat>? basketballStats,
    String? sportName,
    String? error,
  }) {
    return LiveMatchDetailState(
      isLoading: isLoading ?? this.isLoading,
      match: match ?? this.match,
      quarterResults: quarterResults ?? this.quarterResults,
      goals: goals ?? this.goals,
      basketballStats: basketballStats ?? this.basketballStats,
      sportName: sportName ?? this.sportName,
      error: error ?? this.error,
    );
  }

  // Computed property for total score
  int get teamScore =>
      quarterResults.fold(0, (sum, result) => sum + result.teamGoals);
  int get opponentScore =>
      quarterResults.fold(0, (sum, result) => sum + result.opponentGoals);
}

class LiveMatchDetailNotifier extends StateNotifier<LiveMatchDetailState> {
  final MatchesRepository _matchesRepository;
  final MatchQuarterResultsRepository _quarterResultsRepository;
  final MatchGoalsRepository _goalsRepository;
  final BasketballMatchStatsRepository _basketballStatsRepository;
  final TeamsRepository _teamsRepository;

  LiveMatchDetailNotifier(
    this._matchesRepository,
    this._quarterResultsRepository,
    this._goalsRepository,
    this._basketballStatsRepository,
    this._teamsRepository,
  ) : super(const LiveMatchDetailState());

  Future<void> loadMatchDetails(String matchId) async {
    state = state.copyWith(isLoading: true, error: null);

    // 1. Fetch match first to get teamId
    final matchResult = await _matchesRepository.getMatchById(matchId);

    if (matchResult is Failed<Match>) {
      state = state.copyWith(
        isLoading: false,
        error: matchResult.failure.message,
      );
      return;
    }

    final match = (matchResult as Success<Match>).data;

    // 2. Fetch dependencies (Quarter Results, Team -> Sport)
    final results = await Future.wait([
      _quarterResultsRepository.getResultsByMatch(matchId),
      _teamsRepository.getTeamById(match.teamId),
    ]);

    final quartersResult = results[0] as Result<List<MatchQuarterResult>>;
    final teamResult = results[1] as Result<Team>;

    String? sportName;
    if (teamResult is Success<Team>) {
      sportName = teamResult.data.sportName;
    }

    // 3. Fetch specific stats based on sport
    List<MatchGoal> goals = [];
    List<BasketballMatchStat> basketballStats = [];

    // Assuming 'Basketball' or similar from DB.
    // Ideally we should use constants or enum, but string matching is common in MVP.
    // Check if sportName contains "Basket" to be safe or matches specific key.
    final isBasketball =
        sportName != null && sportName.toLowerCase().contains('basket');

    if (isBasketball) {
      final statsResult =
          await _basketballStatsRepository.getStatsByMatch(matchId);
      if (statsResult is Success<List<BasketballMatchStat>>) {
        basketballStats = statsResult.data;
      }
    } else {
      // Default to soccer/goals
      final goalsResult = await _goalsRepository.getGoalsByMatch(matchId);
      if (goalsResult is Success<List<MatchGoal>>) {
        goals = goalsResult.data
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      }
    }

    // Prepare state
    var newState = state.copyWith(
      isLoading: false,
      match: match,
      sportName: sportName,
      basketballStats: basketballStats,
      goals: goals,
    );

    if (quartersResult is Success<List<MatchQuarterResult>>) {
      newState = newState.copyWith(
        quarterResults: quartersResult.data,
      );
    }

    state = newState;
  }
}
