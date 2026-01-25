import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport_tech_app/domain/matches/entities/match.dart';
import 'package:sport_tech_app/domain/matches/repositories/live_match_repository.dart';

// State for the Live Match
class LiveMatchState {
  final bool isLoading;
  final Match? liveMatch;
  final String? error;

  const LiveMatchState({
    this.isLoading = false,
    this.liveMatch,
    this.error,
  });

  LiveMatchState copyWith({
    bool? isLoading,
    Match? liveMatch,
    String? error,
  }) {
    return LiveMatchState(
      isLoading: isLoading ?? this.isLoading,
      liveMatch: liveMatch,
      error: error ?? this.error,
    );
  }
}

// Notifier to manage Live Match state
class LiveMatchNotifier extends StateNotifier<LiveMatchState> {
  final LiveMatchRepository _repository;
  Timer? _pollingTimer;

  LiveMatchNotifier(this._repository) : super(const LiveMatchState());

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> checkLiveMatch(String teamId) async {
    state = state.copyWith(isLoading: true);
    try {
      final match = await _repository.getLiveMatch(teamId);
      state = state.copyWith(isLoading: false, liveMatch: match);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void startPolling(String teamId) {
    _pollingTimer?.cancel();
    // Initial check
    checkLiveMatch(teamId);
    // Poll every 30 seconds
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      checkLiveMatch(teamId);
    });
  }

  void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }
}
