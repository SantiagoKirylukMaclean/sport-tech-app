// lib/application/org/players_notifier.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport_tech_app/domain/org/entities/player.dart';
import 'package:sport_tech_app/domain/org/entities/position.dart';
import 'package:sport_tech_app/domain/org/entities/pending_invite.dart';
import 'package:sport_tech_app/domain/org/repositories/players_repository.dart';
import 'package:sport_tech_app/domain/org/repositories/positions_repository.dart';
import 'package:sport_tech_app/domain/org/repositories/pending_invites_repository.dart';
import 'package:sport_tech_app/infrastructure/org/providers/org_repositories_providers.dart';

/// State for players management
class PlayersState {
  final List<Player> players;
  final List<Position> positions;
  final List<PendingInvite> pendingInvites;
  final bool isLoading;
  final String? error;

  const PlayersState({
    this.players = const [],
    this.positions = const [],
    this.pendingInvites = const [],
    this.isLoading = false,
    this.error,
  });

  PlayersState copyWith({
    List<Player>? players,
    List<Position>? positions,
    List<PendingInvite>? pendingInvites,
    bool? isLoading,
    String? error,
  }) {
    return PlayersState(
      players: players ?? this.players,
      positions: positions ?? this.positions,
      pendingInvites: pendingInvites ?? this.pendingInvites,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Notifier for managing players state
class PlayersNotifier extends StateNotifier<PlayersState> {
  final PlayersRepository _playersRepository;
  final PositionsRepository _positionsRepository;
  final PendingInvitesRepository _pendingInvitesRepository;

  PlayersNotifier(
    this._playersRepository,
    this._positionsRepository,
    this._pendingInvitesRepository,
  ) : super(const PlayersState());

  /// Load players by team and positions by sport
  Future<void> loadPlayersByTeam(String teamId, String sportId) async {
    state = state.copyWith(isLoading: true, error: null);

    final playersResult = await _playersRepository.getPlayersByTeam(teamId);
    final positionsResult =
        await _positionsRepository.getPositionsBySport(sportId);

    // Load pending invites for this team
    final teamIdInt = int.tryParse(teamId);
    final invitesResult = teamIdInt != null
        ? await _pendingInvitesRepository.getInvitesByTeam(teamIdInt)
        : null;

    playersResult.when(
      success: (players) {
        positionsResult.when(
          success: (positions) {
            // Handle invites result
            final invites = invitesResult?.when(
                  success: (invitesList) => invitesList,
                  failure: (_) => <PendingInvite>[],
                ) ??
                <PendingInvite>[];

            state = state.copyWith(
              players: players,
              positions: positions,
              pendingInvites: invites,
              isLoading: false,
            );
          },
          failure: (failure) {
            state = state.copyWith(
              players: players,
              isLoading: false,
              error: failure.message,
            );
          },
        );
      },
      failure: (failure) {
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

  /// Import an existing player from another team
  Future<bool> importPlayer({
    required String teamId,
    required Player sourcePlayer,
  }) async {
    // Note: sourcePlayer object contains userId and email needed for linking
    final result = await _playersRepository.importPlayer(
      teamId: teamId,
      fullName: sourcePlayer.fullName,
      jerseyNumber: sourcePlayer.jerseyNumber,
      userId: sourcePlayer.userId,
      email: sourcePlayer.email,
    );

    return result.when(
      success: (player) {
        // App state update only, actual DB linking handled by Edge Function
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
          players:
              state.players.map((p) => p.id == id ? updatedPlayer : p).toList(),
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

  /// Assign credentials (email and password) to a player
  Future<bool> assignCredentials({
    required String playerId,
    required String email,
    required String password,
  }) async {
    final result = await _playersRepository.assignCredentials(
      playerId: playerId,
      email: email,
      password: password,
    );

    return result.when(
      success: (updatedPlayer) {
        state = state.copyWith(
          players: state.players
              .map((p) => p.id == playerId ? updatedPlayer : p)
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
}

/// Provider for players notifier
final playersNotifierProvider =
    StateNotifierProvider<PlayersNotifier, PlayersState>((ref) {
  final playersRepo = ref.watch(playersRepositoryProvider);
  final positionsRepo = ref.watch(positionsRepositoryProvider);
  final pendingInvitesRepo = ref.watch(pendingInvitesRepositoryProvider);
  return PlayersNotifier(playersRepo, positionsRepo, pendingInvitesRepo);
});
