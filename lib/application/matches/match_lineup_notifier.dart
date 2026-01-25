// lib/application/matches/match_lineup_notifier.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport_tech_app/application/matches/match_lineup_state.dart';
import 'package:sport_tech_app/domain/matches/entities/field_zone.dart';
import 'package:sport_tech_app/domain/matches/entities/match_player_period.dart';
import 'package:sport_tech_app/domain/matches/entities/basketball_match_stat.dart';
import 'package:sport_tech_app/domain/matches/repositories/basketball_match_stats_repository.dart';
import 'package:sport_tech_app/domain/matches/repositories/match_call_ups_repository.dart';
import 'package:sport_tech_app/domain/matches/repositories/match_goals_repository.dart';
import 'package:sport_tech_app/domain/matches/repositories/match_player_periods_repository.dart';
import 'package:sport_tech_app/domain/matches/repositories/match_quarter_results_repository.dart';
import 'package:sport_tech_app/domain/matches/repositories/match_substitutions_repository.dart';
import 'package:sport_tech_app/domain/matches/repositories/matches_repository.dart';
import 'package:sport_tech_app/domain/org/entities/player.dart';
import 'package:sport_tech_app/domain/org/repositories/players_repository.dart';
import 'package:sport_tech_app/infrastructure/matches/providers/matches_repositories_providers.dart';
import 'package:sport_tech_app/infrastructure/org/providers/org_repositories_providers.dart';

/// Provider for match lineup notifier
final matchLineupNotifierProvider =
    StateNotifierProvider.family<MatchLineupNotifier, MatchLineupState, String>(
  (ref, matchId) {
    final callUpsRepo = ref.watch(matchCallUpsRepositoryProvider);
    final periodsRepo = ref.watch(matchPlayerPeriodsRepositoryProvider);
    final substitutionsRepo = ref.watch(matchSubstitutionsRepositoryProvider);
    final resultsRepo = ref.watch(matchQuarterResultsRepositoryProvider);
    final goalsRepo = ref.watch(matchGoalsRepositoryProvider);
    final statsRepo = ref.watch(basketballMatchStatsRepositoryProvider);
    final playersRepo = ref.watch(playersRepositoryProvider);
    final matchesRepo = ref.watch(matchesRepositoryProvider);

    return MatchLineupNotifier(
      matchId: matchId,
      callUpsRepository: callUpsRepo,
      periodsRepository: periodsRepo,
      substitutionsRepository: substitutionsRepo,
      resultsRepository: resultsRepo,
      goalsRepository: goalsRepo,
      statsRepository: statsRepo,
      playersRepository: playersRepo,
      matchesRepository: matchesRepo,
    );
  },
);

/// Notifier for managing match lineup state
class MatchLineupNotifier extends StateNotifier<MatchLineupState> {
  final String matchId;
  final MatchCallUpsRepository _callUpsRepository;
  final MatchPlayerPeriodsRepository _periodsRepository;
  final MatchSubstitutionsRepository _substitutionsRepository;
  final MatchQuarterResultsRepository _resultsRepository;
  final MatchGoalsRepository _goalsRepository;
  final BasketballMatchStatsRepository _statsRepository;
  final PlayersRepository _playersRepository;
  final MatchesRepository _matchesRepository;

  MatchLineupNotifier({
    required this.matchId,
    required MatchCallUpsRepository callUpsRepository,
    required MatchPlayerPeriodsRepository periodsRepository,
    required MatchSubstitutionsRepository substitutionsRepository,
    required MatchQuarterResultsRepository resultsRepository,
    required MatchGoalsRepository goalsRepository,
    required BasketballMatchStatsRepository statsRepository,
    required PlayersRepository playersRepository,
    required MatchesRepository matchesRepository,
  })  : _callUpsRepository = callUpsRepository,
        _periodsRepository = periodsRepository,
        _substitutionsRepository = substitutionsRepository,
        _resultsRepository = resultsRepository,
        _goalsRepository = goalsRepository,
        _statsRepository = statsRepository,
        _playersRepository = playersRepository,
        _matchesRepository = matchesRepository,
        super(const MatchLineupState());

  /// Load all data for the match
  Future<void> loadMatchData() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      // Load match details to get teamId
      final matchResult = await _matchesRepository.getMatchById(matchId);
      if (matchResult.isFailure) {
        state = state.copyWith(
          isLoading: false,
          error: matchResult.failureOrNull?.message ??
              'Failed to load match details',
        );
        return;
      }
      final match = matchResult.dataOrNull!;

      // Load all team players
      final teamPlayersResult =
          await _playersRepository.getPlayersByTeam(match.teamId);
      final teamPlayers = teamPlayersResult.dataOrNull ?? [];

      // Load call-ups
      final callUpsResult = await _callUpsRepository.getCallUpsByMatch(matchId);
      if (callUpsResult.isFailure) {
        state = state.copyWith(
          isLoading: false,
          error:
              callUpsResult.failureOrNull?.message ?? 'Failed to load call-ups',
        );
        return;
      }

      final callUps = callUpsResult.dataOrNull ?? [];

      // Load full player objects for called-up players
      final playerIds = callUps.map((c) => c.playerId).toSet();

      // For each player ID, fetch the player
      final calledUpPlayers = <Player>[];
      for (final playerId in playerIds) {
        // First check if player is in teamPlayers to avoid extra API call
        final existingPlayer =
            teamPlayers.where((p) => p.id == playerId).firstOrNull;
        if (existingPlayer != null) {
          calledUpPlayers.add(existingPlayer);
        } else {
          // If not in team list (maybe transferred?), fetch individually
          final playerResult = await _playersRepository.getPlayerById(playerId);
          final player = playerResult.dataOrNull;
          if (player != null) {
            calledUpPlayers.add(player);
          }
        }
      }

      // Load periods
      final periodsResult = await _periodsRepository.getPeriodsByMatch(matchId);
      if (periodsResult.isFailure) {
        state = state.copyWith(
          isLoading: false,
          error:
              periodsResult.failureOrNull?.message ?? 'Failed to load periods',
        );
        return;
      }

      final allPeriods = periodsResult.dataOrNull ?? [];

      // Filter periods for current quarter
      final currentQuarterPeriods =
          allPeriods.where((p) => p.period == state.currentQuarter).toList();

      // Load quarter results
      final resultsResult = await _resultsRepository.getResultsByMatch(matchId);
      final quarterResults = resultsResult.dataOrNull ?? [];

      final currentQuarterResult = quarterResults
          .where((r) => r.quarter == state.currentQuarter)
          .firstOrNull;

      // Load goals
      final goalsResult = await _goalsRepository.getGoalsByMatch(matchId);
      final allGoals = goalsResult.dataOrNull ?? [];

      final currentQuarterGoals =
          allGoals.where((g) => g.quarter == state.currentQuarter).toList();

      // Load substitutions
      final substitutionsResult =
          await _substitutionsRepository.getSubstitutionsByMatch(matchId);
      final allSubstitutions = substitutionsResult.dataOrNull ?? [];

      final currentQuarterSubstitutions = allSubstitutions
          .where((s) => s.period == state.currentQuarter)
          .toList();

      // Load basketball stats
      final statsResult = await _statsRepository.getStatsByMatch(matchId);
      final basketballStats = statsResult.dataOrNull ?? [];

      final currentQuarterBasketballStats = basketballStats
          .where((s) => s.quarter == state.currentQuarter)
          .toList();

      state = state.copyWith(
        isLoading: false,
        callUps: callUps,
        calledUpPlayers: calledUpPlayers,
        allPeriods: allPeriods,
        currentQuarterPeriods: currentQuarterPeriods,
        quarterResults: quarterResults,
        currentQuarterResult: currentQuarterResult,
        allGoals: allGoals,
        currentQuarterGoals: currentQuarterGoals,
        allSubstitutions: allSubstitutions,
        currentQuarterSubstitutions: currentQuarterSubstitutions,
        teamPlayers: teamPlayers,
        numberOfPeriods: match.numberOfPeriods ?? 4,
        basketballStats: basketballStats,
        currentQuarterBasketballStats: currentQuarterBasketballStats,
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error loading match data: $e',
      );
    }
  }

  /// Select a quarter (1-numberOfPeriods)
  void selectQuarter(int quarter) {
    if (quarter < 1 || quarter > state.numberOfPeriods) return;

    final currentQuarterPeriods =
        state.allPeriods.where((p) => p.period == quarter).toList();

    final currentQuarterResult =
        state.quarterResults.where((r) => r.quarter == quarter).firstOrNull;

    final currentQuarterGoals =
        state.allGoals.where((g) => g.quarter == quarter).toList();

    final currentQuarterSubstitutions =
        state.allSubstitutions.where((s) => s.period == quarter).toList();

    final currentQuarterBasketballStats =
        state.basketballStats.where((s) => s.quarter == quarter).toList();

    state = state.copyWith(
      currentQuarter: quarter,
      currentQuarterPeriods: currentQuarterPeriods,
      currentQuarterResult: currentQuarterResult,
      clearCurrentQuarterResult: currentQuarterResult == null,
      currentQuarterGoals: currentQuarterGoals,
      currentQuarterSubstitutions: currentQuarterSubstitutions,
      currentQuarterBasketballStats: currentQuarterBasketballStats,
      substitutionMode: false, // Exit substitution mode when changing quarter
      statsMode: false, // Exit stats mode when changing quarter
      clearSelectedPlayerOut: true,
      clearSelectedPlayerIn: true,
    );
  }

  /// Toggle substitution mode
  void toggleSubstitutionMode() {
    state = state.copyWith(
      substitutionMode: !state.substitutionMode,
      clearSelectedPlayerOut: true,
      clearSelectedPlayerIn: true,
    );
  }

  /// Add player to call-up
  Future<void> addPlayerToCallUp(String playerId) async {
    final result = await _callUpsRepository.addPlayerToCallUp(
      matchId: matchId,
      playerId: playerId,
    );

    result.when(
      success: (_) => loadMatchData(),
      failure: (failure) => state = state.copyWith(error: failure.message),
    );
  }

  /// Remove player from call-up
  Future<void> removePlayerFromCallUp(String playerId) async {
    final result = await _callUpsRepository.removePlayerFromCallUp(
      matchId: matchId,
      playerId: playerId,
    );

    result.when(
      success: (_) => loadMatchData(),
      failure: (failure) => state = state.copyWith(error: failure.message),
    );
  }

  /// Add player to field for current quarter
  Future<void> addPlayerToField(String playerId) async {
    if (state.isFieldFull) {
      state = state.copyWith(
        error: 'Field is full (maximum 7 players)',
      );
      return;
    }

    final result = await _periodsRepository.setPlayerPeriod(
      matchId: matchId,
      playerId: playerId,
      period: state.currentQuarter,
      fraction: Fraction.full,
    );

    result.when(
      success: (_) => loadMatchData(),
      failure: (failure) => state = state.copyWith(error: failure.message),
    );
  }

  /// Add player to field for current quarter with a specific field zone
  Future<void> addPlayerToFieldWithZone(
      String playerId, FieldZone fieldZone) async {
    if (state.isFieldFull) {
      state = state.copyWith(
        error: 'Field is full (maximum 7 players)',
      );
      return;
    }

    final result = await _periodsRepository.setPlayerPeriod(
      matchId: matchId,
      playerId: playerId,
      period: state.currentQuarter,
      fraction: Fraction.full,
      fieldZone: fieldZone,
    );

    result.when(
      success: (_) => loadMatchData(),
      failure: (failure) => state = state.copyWith(error: failure.message),
    );
  }

  /// Remove player from field for current quarter
  Future<void> removePlayerFromField(String playerId) async {
    final result = await _periodsRepository.removePlayerPeriod(
      matchId: matchId,
      playerId: playerId,
      period: state.currentQuarter,
    );

    result.when(
      success: (_) => loadMatchData(),
      failure: (failure) => state = state.copyWith(error: failure.message),
    );
  }

  /// Apply a substitution
  Future<void> applySubstitution(String playerOut, String playerIn) async {
    final result = await _substitutionsRepository.applySubstitution(
      matchId: matchId,
      period: state.currentQuarter,
      playerOut: playerOut,
      playerIn: playerIn,
    );

    result.when(
      success: (_) {
        state = state.copyWith(
          substitutionMode: false,
          clearSelectedPlayerOut: true,
          clearSelectedPlayerIn: true,
        );
        loadMatchData();
      },
      failure: (failure) => state = state.copyWith(error: failure.message),
    );
  }

  /// Save quarter result
  Future<void> saveQuarterResult(int teamGoals, int opponentGoals) async {
    final result = await _resultsRepository.upsertQuarterResult(
      matchId: matchId,
      quarter: state.currentQuarter,
      teamGoals: teamGoals,
      opponentGoals: opponentGoals,
    );

    result.when(
      success: (_) => loadMatchData(),
      failure: (failure) => state = state.copyWith(error: failure.message),
    );
  }

  /// Add a goal
  Future<void> addGoal({
    required String scorerId,
    String? assisterId,
    bool isOwnGoal = false,
  }) async {
    final result = await _goalsRepository.createGoal(
      matchId: matchId,
      quarter: state.currentQuarter,
      scorerId: scorerId,
      assisterId: assisterId,
      isOwnGoal: isOwnGoal,
    );

    result.when(
      success: (_) => loadMatchData(),
      failure: (failure) => state = state.copyWith(error: failure.message),
    );
  }

  /// Delete a goal
  Future<void> deleteGoal(String goalId) async {
    final result = await _goalsRepository.deleteGoal(goalId);

    result.when(
      success: (_) => loadMatchData(),
      failure: (failure) => state = state.copyWith(error: failure.message),
    );
  }

  /// Update a player's field zone for the current quarter
  Future<void> updatePlayerFieldZone({
    required String playerId,
    required FieldZone fieldZone,
  }) async {
    final result = await _periodsRepository.updatePlayerFieldZone(
      matchId: matchId,
      playerId: playerId,
      period: state.currentQuarter,
      fieldZone: fieldZone,
    );

    result.when(
      success: (_) => loadMatchData(),
      failure: (failure) => state = state.copyWith(error: failure.message),
    );
  }

  /// Select player to be substituted out
  void selectPlayerOut(String? playerId) {
    if (playerId == null) {
      state = state.copyWith(clearSelectedPlayerOut: true);
    } else {
      state = state.copyWith(selectedPlayerOut: playerId);
    }
  }

  /// Select player to substitute in
  void selectPlayerIn(String? playerId) {
    if (playerId == null) {
      state = state.copyWith(clearSelectedPlayerIn: true);
    } else {
      state = state.copyWith(selectedPlayerIn: playerId);
    }
  }

  // Basketball Stats Methods

  void toggleStatsMode() {
    state = state.copyWith(
      statsMode: !state.statsMode,
      substitutionMode: false, // mutually exclusive
      clearStatsSelectedPlayerId: true,
    );
  }

  void selectStatsPlayer(String playerId) {
    state = state.copyWith(statsSelectedPlayerId: playerId);
  }

  void clearStatsSelectedPlayer() {
    state = state.copyWith(clearStatsSelectedPlayerId: true);
  }

  Future<void> addBasketballStat(
      String playerId, BasketballStatType type) async {
    final result = await _statsRepository.createStat(
      matchId: matchId,
      playerId: playerId,
      quarter: state.currentQuarter,
      statType: type,
    );

    result.when(
      success: (_) {
        loadMatchData();
        state = state.copyWith(clearStatsSelectedPlayerId: true);
      },
      failure: (failure) => state = state.copyWith(error: failure.message),
    );
  }

  Future<void> deleteBasketballStat(String statId) async {
    final result = await _statsRepository.deleteStat(statId);

    result.when(
      success: (_) => loadMatchData(),
      failure: (failure) => state = state.copyWith(error: failure.message),
    );
  }
}
