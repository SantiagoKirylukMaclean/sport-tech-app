// lib/application/matches/matches_state.dart

import 'package:sport_tech_app/domain/matches/entities/match.dart';

/// Base state for matches
sealed class MatchesState {
  const MatchesState();
}

/// Initial state
class MatchesStateInitial extends MatchesState {
  const MatchesStateInitial();
}

/// Loading state
class MatchesStateLoading extends MatchesState {
  const MatchesStateLoading();
}

/// Loaded state with matches
class MatchesStateLoaded extends MatchesState {
  final List<Match> matches;

  const MatchesStateLoaded(this.matches);
}

/// Error state
class MatchesStateError extends MatchesState {
  final String message;

  const MatchesStateError(this.message);
}
