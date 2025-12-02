// lib/application/matches/match_lineup_notifier.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport_tech_app/application/matches/match_lineup_state.dart';
import 'package:sport_tech_app/domain/matches/entities/match_player_period.dart';
import 'package:sport_tech_app/domain/matches/repositories/match_call_ups_repository.dart';
import 'package:sport_tech_app/domain/matches/repositories/match_goals_repository.dart';
import 'package:sport_tech_app/domain/matches/repositories/match_player_periods_repository.dart';
import 'package:sport_tech_app/domain/matches/repositories/match_quarter_results_repository.dart';
import 'package:sport_tech_app/domain/matches/repositories/match_substitutions_repository.dart';
import 'package:sport_tech_app/domain/org/repositories/players_repository.dart';
import 'package:sport_tech_app/infrastructure/matches/providers/matches_repositories_providers.dart';
import 'package:sport_tech_app/infrastructure/org/providers/org_repositories_providers.dart';

/// Provider for match lineup notifier
final matchLineupNotifierProvider = StateNotifierProvider.family<
    MatchLineupNotifier, MatchLineupState, String>(
  (ref, matchId) {
    final callUpsRepo = ref.watch(matchCallUpsRepositoryProvider);
    final periodsRepo = ref.watch(matchPlayerPeriodsRepositoryProvider);
    final substitutionsRepo = ref.watch(matchSubstitutionsRepositoryProvider);
    final resultsRepo = ref.watch(matchQuarterResultsRepositoryProvider);
    final goalsRepo = ref.watch(matchGoalsRepositoryProvider);
    final playersRepo = ref.watch(playersRepositoryProvider);

    return MatchLineupNotifier(
      matchId: matchId,
      callUpsRepository: callUpsRepo,
      periodsRepository: periodsRepo,
      substitutionsRepository: substitutionsRepo,
      resultsRepository: resultsRepo,
      goalsRepository: goalsRepo,
      playersRepository: playersRepo,
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
  final PlayersRepository _playersRepository;

  MatchLineupNotifier({
    required this.matchId,
    required MatchCallUpsRepository callUpsRepository,
    required MatchPlayerPeriodsRepository periodsRepository,
    required MatchSubstitutionsRepository substitutionsRepository,
    required MatchQuarterResultsRepository resultsRepository,
    required MatchGoalsRepository goalsRepository,
    required PlayersRepository playersRepository,
  })  : _callUpsRepository = callUpsRepository,
        _periodsRepository = periodsRepository,
        _substitutionsRepository = substitutionsRepository,
        _resultsRepository = resultsRepository,
        _goalsRepository = goalsRepository,
        _playersRepository = playersRepository,
        super(const MatchLineupState());

  /// Load all data for the match
  Future<void> loadMatchData() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      // Load call-ups
      final callUpsResult = await _callUpsRepository.getCallUpsByMatch(matchId);
      if (callUpsResult.isFailure) {
        state = state.copyWith(
          isLoading: false,
          error: callUpsResult.failureOrNull?.message ?? 'Failed to load call-ups',
        );
        return;
      }

      final callUps = callUpsResult.dataOrNull ?? [];

      // Load full player objects for called-up players
      final playerIds = callUps.map((c) => c.playerId).toSet();

      // For each player ID, fetch the player
      final calledUpPlayers = [];
      for (final playerId in playerIds) {
        final playerResult = await _playersRepository.getPlayerById(playerId);
        final player = playerResult.dataOrNull;
        if (player != null) {
          calledUpPlayers.add(player);
        }
      }

      // Load periods
      final periodsResult = await _periodsRepository.getPeriodsByMatch(matchId);
      if (periodsResult.isFailure) {
        state = state.copyWith(
          isLoading: false,
          error: periodsResult.failureOrNull?.message ?? 'Failed to load periods',
        );
        return;
      }

      final allPeriods = periodsResult.dataOrNull ?? [];

      // Filter periods for current quarter
      final currentQuarterPeriods = allPeriods
          .where((p) => p.period == state.currentQuarter)
          .toList();

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

      state = state.copyWith(
        isLoading: false,
        callUps: callUps,
        calledUpPlayers: List.from(calledUpPlayers),
        allPeriods: allPeriods,
        currentQuarterPeriods: currentQuarterPeriods,
        quarterResults: quarterResults,
        currentQuarterResult: currentQuarterResult,
        allGoals: allGoals,
        currentQuarterGoals: currentQuarterGoals,
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error loading match data: $e',
      );
    }
  }

  /// Select a quarter (1-4)
  void selectQuarter(int quarter) {
    if (quarter < 1 || quarter > 4) return;

    final currentQuarterPeriods =
        state.allPeriods.where((p) => p.period == quarter).toList();

    final currentQuarterResult =
        state.quarterResults.where((r) => r.quarter == quarter).firstOrNull;

    final currentQuarterGoals =
        state.allGoals.where((g) => g.quarter == quarter).toList();

    state = state.copyWith(
      currentQuarter: quarter,
      currentQuarterPeriods: currentQuarterPeriods,
      currentQuarterResult: currentQuarterResult,
      clearCurrentQuarterResult: currentQuarterResult == null,
      currentQuarterGoals: currentQuarterGoals,
      substitutionMode: false, // Exit substitution mode when changing quarter
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
  }) async {
    final result = await _goalsRepository.createGoal(
      matchId: matchId,
      quarter: state.currentQuarter,
      scorerId: scorerId,
      assisterId: assisterId,
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
}
