// lib/infrastructure/org/mappers/staff_attendance_mapper.dart

import 'package:sport_tech_app/domain/org/entities/staff_attendance.dart';
import 'package:sport_tech_app/domain/trainings/entities/training_attendance.dart';

/// Mapper for converting between Supabase JSON and StaffAttendance entity
class StaffAttendanceMapper {
  /// Convert from Supabase JSON to StaffAttendance entity
  static StaffAttendance fromJson(Map<String, dynamic> json) {
    return StaffAttendance(
      trainingId: json['training_id'].toString(),
      staffId: json['staff_id'].toString(),
      status: AttendanceStatus.fromString(json['status'] as String),
    );
  }

  /// Convert from StaffAttendance entity to Supabase JSON
  static Map<String, dynamic> toJson(StaffAttendance attendance) {
    return {
      'training_id': attendance.trainingId,
      'staff_id': attendance.staffId,
      'status': attendance.status.value,
    };
  }

  /// Convert to JSON for upsert operations
  static Map<String, dynamic> toUpsertJson({
    required String trainingId,
    required String staffId,
    required AttendanceStatus status,
  }) {
    return {
      'training_id': int.tryParse(trainingId) ?? trainingId,
      'staff_id': int.tryParse(staffId) ?? staffId,
      'status': status.value,
    };
  }
}
