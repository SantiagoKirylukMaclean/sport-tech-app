// lib/domain/org/entities/staff_attendance.dart

import 'package:equatable/equatable.dart';
import 'package:sport_tech_app/domain/trainings/entities/training_attendance.dart';

/// Represents staff attendance to a training session
/// Maps to the public.staff_attendance table in Supabase
class StaffAttendance extends Equatable {
  final String trainingId;
  final String staffId;
  final AttendanceStatus status;

  const StaffAttendance({
    required this.trainingId,
    required this.staffId,
    required this.status,
  });

  StaffAttendance copyWith({
    String? trainingId,
    String? staffId,
    AttendanceStatus? status,
  }) {
    return StaffAttendance(
      trainingId: trainingId ?? this.trainingId,
      staffId: staffId ?? this.staffId,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [
        trainingId,
        staffId,
        status,
      ];
}
