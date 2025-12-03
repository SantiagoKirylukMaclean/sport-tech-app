import '../../../domain/evaluations/entities/player_evaluation.dart';

class PlayerEvaluationMapper {
  static PlayerEvaluation fromJson(Map<String, dynamic> json) {
    return PlayerEvaluation(
      id: json['id'] as String,
      playerId: json['player_id'].toString(),
      evaluatorId: json['coach_id'] as String,
      evaluationDate: DateTime.parse(json['evaluation_date'] as String),
      generalNotes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  static Map<String, dynamic> toJson(PlayerEvaluation evaluation) {
    return {
      'player_id': int.parse(evaluation.playerId),
      'coach_id': evaluation.evaluatorId,
      'evaluation_date': evaluation.evaluationDate.toIso8601String().split('T')[0],
      'notes': evaluation.generalNotes,
    };
  }
}
