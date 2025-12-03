import '../../../domain/trainings/entities/training_attendance.dart';

class TrainingAttendanceMapper {
  static TrainingAttendance fromJson(Map<String, dynamic> json) {
    return TrainingAttendance(
      id: json['id'] as String,
      sessionId: json['session_id'] as String,
      playerId: json['player_id'] as String,
      status: AttendanceStatus.fromString(json['status'] as String),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  static Map<String, dynamic> toJson(TrainingAttendance attendance) {
    return {
      'id': attendance.id,
      'session_id': attendance.sessionId,
      'player_id': attendance.playerId,
      'status': attendance.status.value,
      'notes': attendance.notes,
      'created_at': attendance.createdAt.toIso8601String(),
      'updated_at': attendance.updatedAt?.toIso8601String(),
    };
  }

  static Map<String, dynamic> toUpsertJson({
    required String sessionId,
    required String playerId,
    required AttendanceStatus status,
    String? notes,
  }) {
    return {
      'session_id': sessionId,
      'player_id': playerId,
      'status': status.value,
      'notes': notes,
    };
  }
}
