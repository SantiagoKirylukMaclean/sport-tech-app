// lib/application/org/players_notifier.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport_tech_app/domain/org/entities/player.dart';
import 'package:sport_tech_app/domain/org/entities/position.dart';
import 'package:sport_tech_app/domain/org/repositories/players_repository.dart';
import 'package:sport_tech_app/domain/org/repositories/positions_repository.dart';
import 'package:sport_tech_app/infrastructure/org/providers/org_repositories_providers.dart';

/// State for players management
class PlayersState {
  final List<Player> players;
  final List<Position> positions;
  final bool isLoading;
  final String? error;

  const PlayersState({
    this.players = const [],
    this.positions = const [],
    this.isLoading = false,
    this.error,
  });

  PlayersState copyWith({
    List<Player>? players,
    List<Position>? positions,
    bool? isLoading,
    String? error,
  }) {
    return PlayersState(
      players: players ?? this.players,
      positions: positions ?? this.positions,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Notifier for managing players state
class PlayersNotifier extends StateNotifier<PlayersState> {
  final PlayersRepository _playersRepository;
  final PositionsRepository _positionsRepository;

  PlayersNotifier(this._playersRepository, this._positionsRepository)
      : super(const PlayersState());

  /// Load players by team and positions by sport
  Future<void> loadPlayersByTeam(String teamId, String sportId) async {
    print('DEBUG PlayersNotifier: loadPlayersByTeam called with teamId: "$teamId" (${teamId.runtimeType}), sportId: "$sportId"');
    state = state.copyWith(isLoading: true, error: null);

    print('DEBUG PlayersNotifier: Calling _playersRepository.getPlayersByTeam');
    final playersResult = await _playersRepository.getPlayersByTeam(teamId);
    print('DEBUG PlayersNotifier: playersResult type: ${playersResult.runtimeType}');
    
    final positionsResult = await _positionsRepository.getPositionsBySport(sportId);

    playersResult.when(
      success: (players) {
        print('DEBUG PlayersNotifier: Players loaded successfully: ${players.length} players');
        positionsResult.when(
          success: (positions) {
            print('DEBUG PlayersNotifier: Positions loaded successfully: ${positions.length} positions');
            state = state.copyWith(
              players: players,
              positions: positions,
              isLoading: false,
            );
          },
          failure: (failure) {
            print('DEBUG PlayersNotifier: Positions failed: ${failure.message}');
            state = state.copyWith(
              players: players,
              isLoading: false,
              error: failure.message,
            );
          },
        );
      },
      failure: (failure) {
        print('DEBUG PlayersNotifier: Players failed: ${failure.message}');
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
      },
    );
  }

  /// Create a new player
  Future<bool> createPlayer({
    required String teamId,
    required String fullName,
    int? jerseyNumber,
  }) async {
    final result = await _playersRepository.createPlayer(
      teamId: teamId,
      fullName: fullName,
      jerseyNumber: jerseyNumber,
    );

    return result.when(
      success: (player) {
        state = state.copyWith(
          players: [...state.players, player],
        );
        return true;
      },
      failure: (failure) {
        state = state.copyWith(error: failure.message);
        return false;
      },
    );
  }

  /// Update a player
  Future<bool> updatePlayer({
    required String id,
    String? fullName,
    int? jerseyNumber,
  }) async {
    final result = await _playersRepository.updatePlayer(
      id: id,
      fullName: fullName,
      jerseyNumber: jerseyNumber,
    );

    return result.when(
      success: (updatedPlayer) {
        state = state.copyWith(
          players: state.players
              .map((p) => p.id == id ? updatedPlayer : p)
              .toList(),
        );
        return true;
      },
      failure: (failure) {
        state = state.copyWith(error: failure.message);
        return false;
      },
    );
  }

  /// Delete a player
  Future<bool> deletePlayer(String id) async {
    final result = await _playersRepository.deletePlayer(id);

    return result.when(
      success: (_) {
        state = state.copyWith(
          players: state.players.where((p) => p.id != id).toList(),
        );
        return true;
      },
      failure: (failure) {
        state = state.copyWith(error: failure.message);
        return false;
      },
    );
  }
}

/// Provider for players notifier
final playersNotifierProvider =
    StateNotifierProvider<PlayersNotifier, PlayersState>((ref) {
  final playersRepo = ref.watch(playersRepositoryProvider);
  final positionsRepo = ref.watch(positionsRepositoryProvider);
  return PlayersNotifier(playersRepo, positionsRepo);
});
