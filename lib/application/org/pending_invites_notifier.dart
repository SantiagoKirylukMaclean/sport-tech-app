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
  Future<void> loadInvitesByTeam(int teamId) async {
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

  /// Create a player invite (player must already exist)
  /// [sendEmail] if true, sends email automatically. If false, returns magic link for manual sharing
  Future<bool> createPlayerInvite({
    required String email,
    required int playerId,
    required String createdBy,
    String? displayName,
    bool sendEmail = true,
  }) async {
    final result = await _repository.createPlayerInvite(
      email: email,
      playerId: playerId,
      createdBy: createdBy,
      displayName: displayName,
      sendEmail: sendEmail,
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

  /// Create a staff invite (coach or admin)
  Future<bool> createStaffInvite({
    required String email,
    required List<int> teamIds,
    required String role,
    required String createdBy,
    String? displayName,
  }) async {
    final result = await _repository.createStaffInvite(
      email: email,
      teamIds: teamIds,
      role: role,
      createdBy: createdBy,
      displayName: displayName,
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

  /// Get invite by email
  Future<PendingInvite?> getInviteByEmail(String email) async {
    final result = await _repository.getInviteByEmail(email);

    return result.when(
      success: (invite) => invite,
      failure: (failure) {
        state = state.copyWith(error: failure.message);
        return null;
      },
    );
  }

  /// Mark invite as accepted
  Future<bool> markInviteAccepted(String email) async {
    final result = await _repository.markInviteAccepted(email);

    return result.when(
      success: (updatedInvite) {
        state = state.copyWith(
          invites: state.invites
              .map((i) => i.email == email ? updatedInvite : i)
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
  Future<bool> deleteInvite(int id) async {
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

  /// Cancel an invite
  Future<bool> cancelInvite(int id) async {
    final result = await _repository.cancelInvite(id);

    return result.when(
      success: (updatedInvite) {
        state = state.copyWith(
          invites:
              state.invites.map((i) => i.id == id ? updatedInvite : i).toList(),
        );
        return true;
      },
      failure: (failure) {
        state = state.copyWith(error: failure.message);
        return false;
      },
    );
  }

  /// Resend an invitation email
  /// [sendEmail] if true, sends email automatically. If false, returns magic link
  /// Returns signup URL or confirmation message on success, null on failure
  Future<String?> resendInvite(int id, {bool sendEmail = true}) async {
    final result = await _repository.resendInvite(id, sendEmail: sendEmail);

    return result.when(
      success: (signupUrl) => signupUrl,
      failure: (failure) {
        state = state.copyWith(error: failure.message);
        return null;
      },
    );
  }

  /// Create a staff user directly with password
  Future<bool> createStaffUser({
    required String email,
    required String password,
    required List<int> teamIds,
    required String role,
    required String createdBy,
    String? displayName,
  }) async {
    final result = await _repository.createStaffUser(
      email: email,
      password: password,
      teamIds: teamIds,
      role: role,
      createdBy: createdBy,
      displayName: displayName,
    );

    return result.when(
      success: (_) {
        // We don't add to invitations list because it's a direct user creation
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
