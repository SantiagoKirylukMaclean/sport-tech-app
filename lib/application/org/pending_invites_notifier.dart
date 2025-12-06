// lib/application/org/pending_invites_notifier.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport_tech_app/domain/org/entities/pending_invite.dart';
import 'package:sport_tech_app/domain/org/repositories/pending_invites_repository.dart';
import 'package:sport_tech_app/infrastructure/org/providers/org_repositories_providers.dart';

/// State for pending invites management
class PendingInvitesState {
  final List<PendingInvite> invites;
  final bool isLoading;
  final String? error;

  const PendingInvitesState({
    this.invites = const [],
    this.isLoading = false,
    this.error,
  });

  PendingInvitesState copyWith({
    List<PendingInvite>? invites,
    bool? isLoading,
    String? error,
  }) {
    return PendingInvitesState(
      invites: invites ?? this.invites,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Notifier for managing pending invites state
class PendingInvitesNotifier extends StateNotifier<PendingInvitesState> {
  final PendingInvitesRepository _repository;

  PendingInvitesNotifier(this._repository) : super(const PendingInvitesState());

  /// Load all invites (admin only)
  Future<void> loadAllInvites() async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _repository.getAllInvites();

    result.when(
      success: (invites) {
        state = state.copyWith(
          invites: invites,
          isLoading: false,
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

  /// Load invites by team
  Future<void> loadInvitesByTeam(String teamId) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _repository.getInvitesByTeam(teamId);

    result.when(
      success: (invites) {
        state = state.copyWith(
          invites: invites,
          isLoading: false,
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

  /// Create a player invite
  Future<bool> createPlayerInvite({
    required String email,
    required String teamId,
    required String playerName,
    required String invitedBy,
    int? jerseyNumber,
  }) async {
    final result = await _repository.createPlayerInvite(
      email: email,
      teamId: teamId,
      playerName: playerName,
      invitedBy: invitedBy,
      jerseyNumber: jerseyNumber,
    );

    return result.when(
      success: (invite) {
        state = state.copyWith(
          invites: [...state.invites, invite],
        );
        return true;
      },
      failure: (failure) {
        state = state.copyWith(error: failure.message);
        return false;
      },
    );
  }

  /// Create a staff invite
  Future<bool> createStaffInvite({
    required String email,
    required String teamId,
    required String role,
    required String invitedBy,
  }) async {
    final result = await _repository.createStaffInvite(
      email: email,
      teamId: teamId,
      role: role,
      invitedBy: invitedBy,
    );

    return result.when(
      success: (invite) {
        state = state.copyWith(
          invites: [...state.invites, invite],
        );
        return true;
      },
      failure: (failure) {
        state = state.copyWith(error: failure.message);
        return false;
      },
    );
  }

  /// Get invite by token
  Future<PendingInvite?> getInviteByToken(String token) async {
    final result = await _repository.getInviteByToken(token);

    return result.when(
      success: (invite) => invite,
      failure: (failure) {
        state = state.copyWith(error: failure.message);
        return null;
      },
    );
  }

  /// Mark invite as accepted
  Future<bool> markInviteAccepted(String token) async {
    final result = await _repository.markInviteAccepted(token);

    return result.when(
      success: (updatedInvite) {
        state = state.copyWith(
          invites: state.invites
              .map((i) => i.inviteToken == token ? updatedInvite : i)
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

  /// Delete an invite
  Future<bool> deleteInvite(String id) async {
    final result = await _repository.deleteInvite(id);

    return result.when(
      success: (_) {
        state = state.copyWith(
          invites: state.invites.where((i) => i.id != id).toList(),
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

/// Provider for pending invites notifier
final pendingInvitesNotifierProvider =
    StateNotifierProvider<PendingInvitesNotifier, PendingInvitesState>((ref) {
  final repository = ref.watch(pendingInvitesRepositoryProvider);
  return PendingInvitesNotifier(repository);
});
