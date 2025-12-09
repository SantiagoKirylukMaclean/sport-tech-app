// lib/application/org/staff_attendance_notifier.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport_tech_app/domain/org/entities/staff_attendance.dart';
import 'package:sport_tech_app/domain/org/repositories/staff_attendance_repository.dart';
import 'package:sport_tech_app/domain/trainings/entities/training_attendance.dart';
import 'package:sport_tech_app/infrastructure/org/providers/org_repositories_providers.dart';

/// State for staff attendance management
class StaffAttendanceState {
  final List<StaffAttendance> attendances;
  final bool isLoading;
  final String? error;

  const StaffAttendanceState({
    this.attendances = const [],
    this.isLoading = false,
    this.error,
  });

  StaffAttendanceState copyWith({
    List<StaffAttendance>? attendances,
    bool? isLoading,
    String? error,
  }) {
    return StaffAttendanceState(
      attendances: attendances ?? this.attendances,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Notifier for managing staff attendance state
class StaffAttendanceNotifier extends StateNotifier<StaffAttendanceState> {
  final StaffAttendanceRepository _repository;

  StaffAttendanceNotifier(this._repository)
      : super(const StaffAttendanceState());

  /// Load staff attendance by session
  Future<void> loadBySession(String sessionId) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _repository.getBySessionId(sessionId);

    result.when(
      success: (attendances) {
        state = state.copyWith(
          attendances: attendances,
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

  /// Load staff attendance by staff member
  Future<void> loadByStaffMember(String staffId) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _repository.getByStaffId(staffId);

    result.when(
      success: (attendances) {
        state = state.copyWith(
          attendances: attendances,
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

  /// Upsert attendance record
  Future<bool> upsertAttendance({
    required String sessionId,
    required String staffId,
    required AttendanceStatus status,
  }) async {
    final result = await _repository.upsert(
      sessionId: sessionId,
      staffId: staffId,
      status: status,
    );

    return result.when(
      success: (attendance) {
        // Update the state by replacing or adding the attendance
        final updatedAttendances = [...state.attendances];
        final existingIndex = updatedAttendances.indexWhere(
          (a) => a.trainingId == sessionId && a.staffId == staffId,
        );

        if (existingIndex != -1) {
          updatedAttendances[existingIndex] = attendance;
        } else {
          updatedAttendances.add(attendance);
        }

        state = state.copyWith(attendances: updatedAttendances);
        return true;
      },
      failure: (failure) {
        state = state.copyWith(error: failure.message);
        return false;
      },
    );
  }
}

/// Provider for staff attendance notifier
final staffAttendanceNotifierProvider =
    StateNotifierProvider<StaffAttendanceNotifier, StaffAttendanceState>((ref) {
  final repository = ref.watch(staffAttendanceRepositoryProvider);
  return StaffAttendanceNotifier(repository);
});
