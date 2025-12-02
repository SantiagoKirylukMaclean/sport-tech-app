// lib/application/matches/matches_notifier.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport_tech_app/application/matches/matches_state.dart';
import 'package:sport_tech_app/domain/matches/repositories/matches_repository.dart';
import 'package:sport_tech_app/infrastructure/matches/providers/matches_repositories_providers.dart';

/// Provider for matches notifier
final matchesNotifierProvider =
    StateNotifierProvider.family<MatchesNotifier, MatchesState, String>(
  (ref, teamId) {
    final repository = ref.watch(matchesRepositoryProvider);
    return MatchesNotifier(repository, teamId);
  },
);

/// Notifier for managing matches state
class MatchesNotifier extends StateNotifier<MatchesState> {
  final MatchesRepository _repository;
  final String _teamId;

  MatchesNotifier(this._repository, this._teamId)
      : super(const MatchesStateInitial());

  /// Load all matches for the team
  Future<void> loadMatches() async {
    state = const MatchesStateLoading();

    final result = await _repository.getMatchesByTeam(_teamId);

    result.when(
      success: (matches) => state = MatchesStateLoaded(matches),
      failure: (failure) => state = MatchesStateError(failure.message),
    );
  }

  /// Create a new match
  Future<void> createMatch({
    required String opponent,
    required DateTime matchDate,
    String? location,
    String? notes,
  }) async {
    if (opponent.trim().isEmpty) {
      state = const MatchesStateError('Opponent name cannot be empty');
      return;
    }

    final result = await _repository.createMatch(
      teamId: _teamId,
      opponent: opponent,
      matchDate: matchDate,
      location: location,
      notes: notes,
    );

    result.when(
      success: (_) => loadMatches(), // Reload matches after creation
      failure: (failure) => state = MatchesStateError(failure.message),
    );
  }

  /// Update an existing match
  Future<void> updateMatch({
    required String id,
    String? opponent,
    DateTime? matchDate,
    String? location,
    String? notes,
  }) async {
    final result = await _repository.updateMatch(
      id: id,
      opponent: opponent,
      matchDate: matchDate,
      location: location,
      notes: notes,
    );

    result.when(
      success: (_) => loadMatches(), // Reload matches after update
      failure: (failure) => state = MatchesStateError(failure.message),
    );
  }

  /// Delete a match
  Future<void> deleteMatch(String id) async {
    final result = await _repository.deleteMatch(id);

    result.when(
      success: (_) => loadMatches(), // Reload matches after deletion
      failure: (failure) => state = MatchesStateError(failure.message),
    );
  }
}
