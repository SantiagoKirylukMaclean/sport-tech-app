import '../../../domain/trainings/entities/training_session.dart';

class TrainingSessionMapper {
  static TrainingSession fromJson(Map<String, dynamic> json) {
    return TrainingSession(
      id: json['id'].toString(),
      teamId: json['team_id'].toString(),
      sessionDate: DateTime.parse(json['session_date'] as String),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  static Map<String, dynamic> toJson(TrainingSession session) {
    return {
      'id': session.id,
      'team_id': session.teamId,
      'session_date': session.sessionDate.toIso8601String(),
      'notes': session.notes,
      'created_at': session.createdAt.toIso8601String(),
      'updated_at': session.updatedAt?.toIso8601String(),
    };
  }

  static Map<String, dynamic> toInsertJson({
    required String teamId,
    required DateTime sessionDate,
    String? notes,
  }) {
    return {
      'team_id': teamId,
      'session_date': sessionDate.toIso8601String(),
      'notes': notes,
    };
  }

  static Map<String, dynamic> toUpdateJson(TrainingSession session) {
    return {
      'session_date': session.sessionDate.toIso8601String(),
      'notes': session.notes,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }
}
