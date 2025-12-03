import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/trainings/entities/training_attendance.dart';
import '../../domain/trainings/repositories/training_attendance_repository.dart';

class TrainingAttendanceState {
  final List<TrainingAttendance> attendanceRecords;
  final bool isLoading;
  final String? error;

  const TrainingAttendanceState({
    this.attendanceRecords = const [],
    this.isLoading = false,
    this.error,
  });

  TrainingAttendanceState copyWith({
    List<TrainingAttendance>? attendanceRecords,
    bool? isLoading,
    String? error,
  }) {
    return TrainingAttendanceState(
      attendanceRecords: attendanceRecords ?? this.attendanceRecords,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class TrainingAttendanceNotifier extends StateNotifier<TrainingAttendanceState> {
  final TrainingAttendanceRepository _repository;

  TrainingAttendanceNotifier(this._repository)
      : super(const TrainingAttendanceState());

  Future<void> loadAttendance(String sessionId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final records = await _repository.getBySessionId(sessionId);
      state = state.copyWith(
        attendanceRecords: records,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> upsertAttendance({
    required String sessionId,
    required String playerId,
    required AttendanceStatus status,
    String? notes,
  }) async {
    try {
      final record = await _repository.upsert(
        sessionId: sessionId,
        playerId: playerId,
        status: status,
        notes: notes,
      );

      final existingIndex = state.attendanceRecords.indexWhere(
        (r) => r.playerId == playerId && r.trainingId == sessionId,
      );

      List<TrainingAttendance> updatedRecords;
      if (existingIndex != -1) {
        updatedRecords = [...state.attendanceRecords];
        updatedRecords[existingIndex] = record;
      } else {
        updatedRecords = [...state.attendanceRecords, record];
      }

      state = state.copyWith(attendanceRecords: updatedRecords);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  Future<void> deleteAttendance(String trainingId, String playerId) async {
    try {
      // No podemos usar delete porque la tabla usa composite key
      // Tendríamos que implementar un método específico en el repository
      final updatedRecords = state.attendanceRecords
          .where((r) => !(r.trainingId == trainingId && r.playerId == playerId))
          .toList();
      state = state.copyWith(attendanceRecords: updatedRecords);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  AttendanceStatus? getPlayerStatus(String playerId) {
    try {
      final record = state.attendanceRecords.firstWhere(
        (r) => r.playerId == playerId,
      );
      return record.status;
    } catch (e) {
      return null;
    }
  }
}
