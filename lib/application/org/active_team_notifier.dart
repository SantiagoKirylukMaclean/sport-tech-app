// lib/application/org/active_team_notifier.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport_tech_app/application/org/active_team_state.dart';
import 'package:sport_tech_app/domain/org/entities/team.dart';
import 'package:sport_tech_app/domain/org/repositories/teams_repository.dart';
import 'package:sport_tech_app/infrastructure/org/providers/org_repositories_providers.dart';

final activeTeamNotifierProvider =
    StateNotifierProvider<ActiveTeamNotifier, ActiveTeamState>((ref) {
  final teamsRepository = ref.watch(teamsRepositoryProvider);
  return ActiveTeamNotifier(teamsRepository);
});

class ActiveTeamNotifier extends StateNotifier<ActiveTeamState> {
  final TeamsRepository _teamsRepository;

  ActiveTeamNotifier(this._teamsRepository) : super(const ActiveTeamState());

  Future<void> loadUserTeams(String userId) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _teamsRepository.getTeamsByUser(userId);

    result.when(
      success: (teams) {
        // If we already have an active team, check if it's still in the list
        Team? activeTeam = state.activeTeam;
        
        if (teams.isNotEmpty) {
           if (activeTeam == null || !teams.any((t) => t.id == activeTeam!.id)) {
             // Default to first team if no active team or active team no longer valid
             activeTeam = teams.first;
           }
        } else {
          activeTeam = null;
        }

        state = state.copyWith(
          isLoading: false,
          teams: teams,
          activeTeam: activeTeam,
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

  void selectTeam(String teamId) {
    final team = state.teams.where((t) => t.id == teamId).firstOrNull;
    if (team != null) {
      state = state.copyWith(activeTeam: team);
    }
  }
}
