import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/trainings/entities/training_session.dart';
import '../../domain/trainings/repositories/training_sessions_repository.dart';

class TrainingSessionsState {
  final List<TrainingSession> sessions;
  final bool isLoading;
  final String? error;

  const TrainingSessionsState({
    this.sessions = const [],
    this.isLoading = false,
    this.error,
  });

  TrainingSessionsState copyWith({
    List<TrainingSession>? sessions,
    bool? isLoading,
    String? error,
  }) {
    return TrainingSessionsState(
      sessions: sessions ?? this.sessions,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class TrainingSessionsNotifier extends StateNotifier<TrainingSessionsState> {
  final TrainingSessionsRepository _repository;

  TrainingSessionsNotifier(this._repository)
      : super(const TrainingSessionsState());

  Future<void> loadSessions(String teamId) async {
    print('TrainingSessionsNotifier: Loading sessions for team $teamId');
    state = state.copyWith(isLoading: true, error: null);
    try {
      final sessions = await _repository.getByTeamId(teamId);
      print('TrainingSessionsNotifier: Loaded ${sessions.length} sessions');
      state = state.copyWith(
        sessions: sessions,
        isLoading: false,
      );
    } catch (e) {
      print('TrainingSessionsNotifier: Error loading sessions: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> createSession({
    required String teamId,
    required DateTime sessionDate,
    String? notes,
  }) async {
    try {
      final newSession = await _repository.create(
        teamId: teamId,
        sessionDate: sessionDate,
        notes: notes,
      );
      state = state.copyWith(
        sessions: [newSession, ...state.sessions],
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  Future<void> updateSession(TrainingSession session) async {
    try {
      final updatedSession = await _repository.update(session);
      final updatedSessions = state.sessions.map((s) {
        return s.id == updatedSession.id ? updatedSession : s;
      }).toList();
      state = state.copyWith(sessions: updatedSessions);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  Future<void> deleteSession(String id) async {
    try {
      await _repository.delete(id);
      final updatedSessions =
          state.sessions.where((s) => s.id != id).toList();
      state = state.copyWith(sessions: updatedSessions);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}
