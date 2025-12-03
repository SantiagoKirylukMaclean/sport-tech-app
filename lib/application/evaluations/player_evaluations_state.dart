import 'package:equatable/equatable.dart';
import '../../domain/evaluations/entities/player_evaluation.dart';
import '../../domain/evaluations/entities/evaluation_score.dart';

sealed class PlayerEvaluationsState extends Equatable {
  const PlayerEvaluationsState();

  @override
  List<Object?> get props => [];
}

class PlayerEvaluationsInitial extends PlayerEvaluationsState {
  const PlayerEvaluationsInitial();
}

class PlayerEvaluationsLoading extends PlayerEvaluationsState {
  const PlayerEvaluationsLoading();
}

class PlayerEvaluationsLoaded extends PlayerEvaluationsState {
  final List<PlayerEvaluation> evaluations;
  final PlayerEvaluation? latestEvaluation;
  final List<EvaluationScore> latestScores;

  const PlayerEvaluationsLoaded({
    required this.evaluations,
    this.latestEvaluation,
    this.latestScores = const [],
  });

  @override
  List<Object?> get props => [evaluations, latestEvaluation, latestScores];
}

class PlayerEvaluationsError extends PlayerEvaluationsState {
  final String message;

  const PlayerEvaluationsError(this.message);

  @override
  List<Object?> get props => [message];
}

class PlayerEvaluationSaving extends PlayerEvaluationsState {
  const PlayerEvaluationSaving();
}

class PlayerEvaluationSaved extends PlayerEvaluationsState {
  final PlayerEvaluation evaluation;

  const PlayerEvaluationSaved(this.evaluation);

  @override
  List<Object?> get props => [evaluation];
}
