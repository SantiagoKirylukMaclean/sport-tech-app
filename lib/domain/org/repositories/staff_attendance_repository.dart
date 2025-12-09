// lib/domain/org/repositories/staff_attendance_repository.dart

import 'package:sport_tech_app/core/utils/result.dart';
import 'package:sport_tech_app/domain/org/entities/staff_attendance.dart';
import 'package:sport_tech_app/domain/trainings/entities/training_attendance.dart';

/// Repository interface for staff attendance operations
/// This is the contract that infrastructure layer must implement
abstract class StaffAttendanceRepository {
  /// Get all attendance records for a session
  /// Returns list of [StaffAttendance] on success, [Failure] on error
  Future<Result<List<StaffAttendance>>> getBySessionId(String sessionId);

  /// Get attendance for a specific staff member in a session
  /// Returns [StaffAttendance] on success, null if not found, [Failure] on error
  Future<Result<StaffAttendance?>> getBySessionAndStaff({
    required String sessionId,
    required String staffId,
  });

  /// Create or update attendance record
  /// Returns [StaffAttendance] on success, [Failure] on error
  Future<Result<StaffAttendance>> upsert({
    required String sessionId,
    required String staffId,
    required AttendanceStatus status,
  });

  /// Get all attendance records for a staff member
  /// Returns list of [StaffAttendance] on success, [Failure] on error
  Future<Result<List<StaffAttendance>>> getByStaffId(String staffId);
}
