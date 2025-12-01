// lib/application/org/teams_notifier.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport_tech_app/domain/org/entities/team.dart';
import 'package:sport_tech_app/domain/org/repositories/teams_repository.dart';
import 'package:sport_tech_app/infrastructure/org/providers/org_repositories_providers.dart';

/// State for teams management
class TeamsState {
  final List<Team> teams;
  final bool isLoading;
  final String? error;

  const TeamsState({
    this.teams = const [],
    this.isLoading = false,
    this.error,
  });

  TeamsState copyWith({
    List<Team>? teams,
    bool? isLoading,
    String? error,
  }) {
    return TeamsState(
      teams: teams ?? this.teams,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Notifier for managing teams state
class TeamsNotifier extends StateNotifier<TeamsState> {
  final TeamsRepository _repository;

  TeamsNotifier(this._repository) : super(const TeamsState());

  /// Load teams by club
  Future<void> loadTeamsByClub(String clubId) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _repository.getTeamsByClub(clubId);

    result.when(
      success: (teams) {
        state = state.copyWith(
          teams: teams,
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

  /// Load teams by user
  Future<void> loadTeamsByUser(String userId) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _repository.getTeamsByUser(userId);

    result.when(
      success: (teams) {
        state = state.copyWith(
          teams: teams,
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

  /// Create a new team
  Future<bool> createTeam(String clubId, String name) async {
    final result = await _repository.createTeam(clubId: clubId, name: name);

    return result.when(
      success: (team) {
        state = state.copyWith(
          teams: [...state.teams, team],
        );
        return true;
      },
      failure: (failure) {
        state = state.copyWith(error: failure.message);
        return false;
      },
    );
  }

  /// Update a team
  Future<bool> updateTeam(String id, String name) async {
    final result = await _repository.updateTeam(id: id, name: name);

    return result.when(
      success: (updatedTeam) {
        state = state.copyWith(
          teams: state.teams
              .map((t) => t.id == id ? updatedTeam : t)
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

  /// Delete a team
  Future<bool> deleteTeam(String id) async {
    final result = await _repository.deleteTeam(id);

    return result.when(
      success: (_) {
        state = state.copyWith(
          teams: state.teams.where((t) => t.id != id).toList(),
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

/// Provider for teams notifier
final teamsNotifierProvider =
    StateNotifierProvider<TeamsNotifier, TeamsState>((ref) {
  final repository = ref.watch(teamsRepositoryProvider);
  return TeamsNotifier(repository);
});
