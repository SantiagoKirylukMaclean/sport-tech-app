// lib/application/org/user_team_roles_notifier.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport_tech_app/domain/org/entities/user_team_role.dart';
import 'package:sport_tech_app/domain/org/repositories/user_team_roles_repository.dart';
import 'package:sport_tech_app/infrastructure/org/providers/org_repositories_providers.dart';

/// State for user team roles
class UserTeamRolesState {
  final List<UserTeamRole> roles;
  final bool isLoading;
  final String? error;

  const UserTeamRolesState({
    this.roles = const [],
    this.isLoading = false,
    this.error,
  });

  UserTeamRolesState copyWith({
    List<UserTeamRole>? roles,
    bool? isLoading,
    String? error,
  }) {
    return UserTeamRolesState(
      roles: roles ?? this.roles,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Notifier for managing user team roles
class UserTeamRolesNotifier extends StateNotifier<UserTeamRolesState> {
  final UserTeamRolesRepository _repository;

  UserTeamRolesNotifier(this._repository) : super(const UserTeamRolesState());

  /// Load roles by user
  Future<void> loadRolesByUser(String userId) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _repository.getRolesByUser(userId);

    result.when(
      success: (roles) {
        state = state.copyWith(
          roles: roles,
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

  /// Assign a role (team) to a user
  Future<bool> assignRole({
    required String userId,
    required String teamId,
    required TeamRole role,
  }) async {
    final result = await _repository.assignRole(
      userId: userId,
      teamId: teamId,
      role: role,
    );

    return result.when(
      success: (newRole) {
        state = state.copyWith(
          roles: [...state.roles, newRole],
        );
        return true;
      },
      failure: (failure) {
        state = state.copyWith(error: failure.message);
        return false;
      },
    );
  }

  /// Remove a role (team) from a user
  Future<bool> removeRole({
    required String userId,
    required String teamId,
    required TeamRole role,
  }) async {
    final result = await _repository.removeRole(
      userId: userId,
      teamId: teamId,
      role: role,
    );

    return result.when(
      success: (_) {
        state = state.copyWith(
          roles: state.roles
              .where((r) =>
                  !(r.userId == userId && r.teamId == teamId && r.role == role))
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

/// Provider for user team roles notifier
final userTeamRolesNotifierProvider =
    StateNotifierProvider<UserTeamRolesNotifier, UserTeamRolesState>((ref) {
  final repository = ref.watch(userTeamRolesRepositoryProvider);
  return UserTeamRolesNotifier(repository);
});
