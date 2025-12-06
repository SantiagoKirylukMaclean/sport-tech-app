// lib/application/profiles/profiles_notifier.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport_tech_app/domain/profiles/entities/user_profile.dart';
import 'package:sport_tech_app/domain/profiles/repositories/profiles_repository.dart';
import 'package:sport_tech_app/infrastructure/profiles/providers/profiles_repository_provider.dart';

/// State for profiles management
class ProfilesState {
  final List<UserProfile> profiles;
  final bool isLoading;
  final String? error;

  const ProfilesState({
    this.profiles = const [],
    this.isLoading = false,
    this.error,
  });

  ProfilesState copyWith({
    List<UserProfile>? profiles,
    bool? isLoading,
    String? error,
  }) {
    return ProfilesState(
      profiles: profiles ?? this.profiles,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Notifier for managing user profiles state
class ProfilesNotifier extends StateNotifier<ProfilesState> {
  final ProfilesRepository _repository;

  ProfilesNotifier(this._repository) : super(const ProfilesState());

  /// Load all user profiles
  Future<void> loadAllProfiles() async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _repository.getAllProfiles();

    result.when(
      success: (profiles) {
        state = state.copyWith(
          profiles: profiles,
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

  /// Update a user's role
  Future<bool> updateUserRole(String userId, String role) async {
    final result = await _repository.updateUserRole(
      userId: userId,
      role: role,
    );

    return result.when(
      success: (updatedProfile) {
        state = state.copyWith(
          profiles: state.profiles
              .map((p) => p.userId == userId ? updatedProfile : p)
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

  /// Reset a user's password
  Future<bool> resetUserPassword(String userId) async {
    final result = await _repository.resetUserPassword(userId: userId);

    return result.when(
      success: (_) => true,
      failure: (failure) {
        state = state.copyWith(error: failure.message);
        return false;
      },
    );
  }
}

/// Provider for profiles notifier
final profilesNotifierProvider =
    StateNotifierProvider<ProfilesNotifier, ProfilesState>((ref) {
  final repository = ref.watch(profilesRepositoryProvider);
  return ProfilesNotifier(repository);
});
