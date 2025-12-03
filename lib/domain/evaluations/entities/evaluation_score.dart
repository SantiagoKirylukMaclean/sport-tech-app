import 'package:equatable/equatable.dart';

class EvaluationScore extends Equatable {
  final String id;
  final String evaluationId;
  final String criterionId;
  final int score;
  final String? notes;
  final DateTime createdAt;

  const EvaluationScore({
    required this.id,
    required this.evaluationId,
    required this.criterionId,
    required this.score,
    this.notes,
    required this.createdAt,
  });

  @override
  List<Object?> get props =>
      [id, evaluationId, criterionId, score, notes, createdAt];
}
