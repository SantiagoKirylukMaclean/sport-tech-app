// lib/application/org/clubs_notifier.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport_tech_app/domain/org/entities/club.dart';
import 'package:sport_tech_app/domain/org/repositories/clubs_repository.dart';
import 'package:sport_tech_app/infrastructure/org/providers/org_repositories_providers.dart';

/// State for clubs management
class ClubsState {
  final List<Club> clubs;
  final bool isLoading;
  final String? error;

  const ClubsState({
    this.clubs = const [],
    this.isLoading = false,
    this.error,
  });

  ClubsState copyWith({
    List<Club>? clubs,
    bool? isLoading,
    String? error,
  }) {
    return ClubsState(
      clubs: clubs ?? this.clubs,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Notifier for managing clubs state
class ClubsNotifier extends StateNotifier<ClubsState> {
  final ClubsRepository _repository;

  ClubsNotifier(this._repository) : super(const ClubsState());

  /// Load clubs by sport
  Future<void> loadClubsBySport(String sportId) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _repository.getClubsBySport(sportId);

    result.when(
      success: (clubs) {
        state = state.copyWith(
          clubs: clubs,
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

  /// Create a new club
  Future<bool> createClub(String sportId, String name) async {
    final result = await _repository.createClub(sportId: sportId, name: name);

    return result.when(
      success: (club) {
        state = state.copyWith(
          clubs: [...state.clubs, club],
        );
        return true;
      },
      failure: (failure) {
        state = state.copyWith(error: failure.message);
        return false;
      },
    );
  }

  /// Update a club
  Future<bool> updateClub(String id, String name) async {
    final result = await _repository.updateClub(id: id, name: name);

    return result.when(
      success: (updatedClub) {
        state = state.copyWith(
          clubs: state.clubs
              .map((c) => c.id == id ? updatedClub : c)
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

  /// Delete a club
  Future<bool> deleteClub(String id) async {
    final result = await _repository.deleteClub(id);

    return result.when(
      success: (_) {
        state = state.copyWith(
          clubs: state.clubs.where((c) => c.id != id).toList(),
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

/// Provider for clubs notifier
final clubsNotifierProvider =
    StateNotifierProvider<ClubsNotifier, ClubsState>((ref) {
  final repository = ref.watch(clubsRepositoryProvider);
  return ClubsNotifier(repository);
});
