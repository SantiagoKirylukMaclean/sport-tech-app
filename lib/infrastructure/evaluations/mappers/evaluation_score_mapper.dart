import '../../../domain/evaluations/entities/evaluation_score.dart';

class EvaluationScoreMapper {
  static EvaluationScore fromJson(Map<String, dynamic> json) {
    return EvaluationScore(
      id: json['id'] as String,
      evaluationId: json['evaluation_id'] as String,
      criterionId: json['criterion_id'] as String,
      score: json['score'] as int,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  static Map<String, dynamic> toJson(EvaluationScore score) {
    return {
      'evaluation_id': score.evaluationId,
      'criterion_id': score.criterionId,
      'score': score.score,
      'notes': score.notes,
    };
  }
}
