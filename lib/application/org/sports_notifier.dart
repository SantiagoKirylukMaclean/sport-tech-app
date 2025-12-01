// lib/application/org/sports_notifier.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport_tech_app/domain/org/entities/sport.dart';
import 'package:sport_tech_app/domain/org/repositories/sports_repository.dart';
import 'package:sport_tech_app/infrastructure/org/providers/org_repositories_providers.dart';

/// State for sports management
class SportsState {
  final List<Sport> sports;
  final bool isLoading;
  final String? error;

  const SportsState({
    this.sports = const [],
    this.isLoading = false,
    this.error,
  });

  SportsState copyWith({
    List<Sport>? sports,
    bool? isLoading,
    String? error,
  }) {
    return SportsState(
      sports: sports ?? this.sports,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Notifier for managing sports state
class SportsNotifier extends StateNotifier<SportsState> {
  final SportsRepository _repository;

  SportsNotifier(this._repository) : super(const SportsState()) {
    loadSports();
  }

  /// Load all sports
  Future<void> loadSports() async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _repository.getAllSports();

    result.when(
      success: (sports) {
        state = state.copyWith(
          sports: sports,
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

  /// Create a new sport
  Future<bool> createSport(String name) async {
    final result = await _repository.createSport(name: name);

    return result.when(
      success: (sport) {
        state = state.copyWith(
          sports: [...state.sports, sport],
        );
        return true;
      },
      failure: (failure) {
        state = state.copyWith(error: failure.message);
        return false;
      },
    );
  }

  /// Update a sport
  Future<bool> updateSport(String id, String name) async {
    final result = await _repository.updateSport(id: id, name: name);

    return result.when(
      success: (updatedSport) {
        state = state.copyWith(
          sports: state.sports
              .map((s) => s.id == id ? updatedSport : s)
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

  /// Delete a sport
  Future<bool> deleteSport(String id) async {
    final result = await _repository.deleteSport(id);

    return result.when(
      success: (_) {
        state = state.copyWith(
          sports: state.sports.where((s) => s.id != id).toList(),
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

/// Provider for sports notifier
final sportsNotifierProvider =
    StateNotifierProvider<SportsNotifier, SportsState>((ref) {
  final repository = ref.watch(sportsRepositoryProvider);
  return SportsNotifier(repository);
});
