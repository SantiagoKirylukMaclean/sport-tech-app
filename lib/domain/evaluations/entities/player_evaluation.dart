import 'package:equatable/equatable.dart';

class PlayerEvaluation extends Equatable {
  final String id;
  final String playerId;
  final String evaluatorId;
  final DateTime evaluationDate;
  final String? generalNotes;
  final DateTime createdAt;

  const PlayerEvaluation({
    required this.id,
    required this.playerId,
    required this.evaluatorId,
    required this.evaluationDate,
    this.generalNotes,
    required this.createdAt,
  });

  @override
  List<Object?> get props =>
      [id, playerId, evaluatorId, evaluationDate, generalNotes, createdAt];
}
