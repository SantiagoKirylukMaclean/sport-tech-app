// lib/application/dashboard/player_dashboard_notifier.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport_tech_app/application/dashboard/player_dashboard_state.dart';
import 'package:sport_tech_app/core/utils/result.dart';
import 'package:sport_tech_app/domain/org/repositories/players_repository.dart';
import 'package:sport_tech_app/domain/stats/repositories/stats_repository.dart';
import 'package:sport_tech_app/domain/stats/entities/player_statistics.dart';
import 'package:sport_tech_app/domain/evaluations/repositories/player_evaluations_repository.dart';

/// Notifier for managing player dashboard state
class PlayerDashboardNotifier extends StateNotifier<PlayerDashboardState> {
  final PlayersRepository _playersRepository;
  final StatsRepository _statsRepository;
  final PlayerEvaluationsRepository _evaluationsRepository;

  PlayerDashboardNotifier(
    this._playersRepository,
    this._statsRepository,
    this._evaluationsRepository,
  ) : super(const PlayerDashboardState());

  /// Load dashboard data for the authenticated player
  Future<void> loadPlayerDashboard(String userId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // 1. Get player record from userId
      final playerResult = await _playersRepository.getPlayerByUserId(userId);

      if (playerResult is! Success || (playerResult as Success).data == null) {
        state = state.copyWith(
          isLoading: false,
          error: 'No se encontró un registro de jugador para esta cuenta',
        );
        return;
      }

      final player = (playerResult as Success).data!;

      // 2. Load all data in parallel
      final results = await Future.wait([
        _statsRepository.getPlayerStatistics(player.id, player.teamId),
        _statsRepository.getMatchesSummary(player.teamId),
        _evaluationsRepository.getEvaluationsCount(player.id),
        _statsRepository.getTeamTrainingAttendance(player.teamId),
      ]);

      state = state.copyWith(
        player: player,
        playerStats: results[0] as PlayerStatistics?,
        teamMatches: (results[1] as List).cast(),
        evaluationsCount: results[2] as int,
        teamTrainingAttendance: results[3] as double,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error cargando datos: $e',
      );
    }
  }

  /// Load dashboard for a specific player (for coaches viewing player dashboards)
  Future<void> loadPlayerDashboardById(String playerId, String teamId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Load player info
      final playerResult = await _playersRepository.getPlayerById(playerId);

      if (playerResult is! Success) {
        state = state.copyWith(
          isLoading: false,
          error: 'Error al cargar jugador',
        );
        return;
      }

      final player = (playerResult as Success).data;

      // Load stats, matches, and evaluations in parallel
      final results = await Future.wait([
        _statsRepository.getPlayerStatistics(playerId, teamId),
        _statsRepository.getMatchesSummary(teamId),
        _evaluationsRepository.getEvaluationsCount(playerId),
        _statsRepository.getTeamTrainingAttendance(teamId),
      ]);

      state = state.copyWith(
        player: player,
        playerStats: results[0] as PlayerStatistics?,
        teamMatches: (results[1] as List).cast(),
        evaluationsCount: results[2] as int,
        teamTrainingAttendance: results[3] as double,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error cargando datos del jugador: $e',
      );
    }
  }

  /// Refresh dashboard data
  Future<void> refresh() async {
    if (state.player != null) {
      // Use the player's user_id if available, otherwise reload by player ID
      if (state.player!.userId != null) {
        await loadPlayerDashboard(state.player!.userId!);
      } else {
        await loadPlayerDashboardById(state.player!.id, state.player!.teamId);
      }
    }
  }
}
