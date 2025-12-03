import '../../../domain/trainings/entities/training_attendance.dart';

class TrainingAttendanceMapper {
  static TrainingAttendance fromJson(Map<String, dynamic> json) {
    return TrainingAttendance(
      trainingId: json['training_id'].toString(),
      playerId: json['player_id'].toString(),
      status: AttendanceStatus.fromString(json['status'] as String),
    );
  }

  static Map<String, dynamic> toJson(TrainingAttendance attendance) {
    return {
      'training_id': attendance.trainingId,
      'player_id': attendance.playerId,
      'status': attendance.status.value,
    };
  }

  static Map<String, dynamic> toUpsertJson({
    required String trainingId,
    required String playerId,
    required AttendanceStatus status,
  }) {
    return {
      'training_id': trainingId,
      'player_id': playerId,
      'status': status.value,
    };
  }
}
