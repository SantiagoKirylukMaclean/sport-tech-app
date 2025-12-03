// lib/application/org/active_team_state.dart

import 'package:equatable/equatable.dart';
import 'package:sport_tech_app/domain/org/entities/team.dart';

class ActiveTeamState extends Equatable {
  final bool isLoading;
  final List<Team> teams;
  final Team? activeTeam;
  final String? error;

  const ActiveTeamState({
    this.isLoading = false,
    this.teams = const [],
    this.activeTeam,
    this.error,
  });

  ActiveTeamState copyWith({
    bool? isLoading,
    List<Team>? teams,
    Team? activeTeam,
    String? error,
    bool clearError = false,
  }) {
    return ActiveTeamState(
      isLoading: isLoading ?? this.isLoading,
      teams: teams ?? this.teams,
      activeTeam: activeTeam ?? this.activeTeam,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [isLoading, teams, activeTeam, error];
}
