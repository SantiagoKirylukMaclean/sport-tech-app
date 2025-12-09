import '../entities/player_evaluation.dart';
import '../entities/evaluation_score.dart';

abstract class PlayerEvaluationsRepository {
  Future<PlayerEvaluation> createEvaluation(PlayerEvaluation evaluation);
  Future<void> createScores(List<EvaluationScore> scores);
  Future<PlayerEvaluation?> getLatestEvaluationForPlayer(String playerId);
  Future<List<PlayerEvaluation>> listEvaluationsForPlayer(String playerId);
  Future<int> getEvaluationsCount(String playerId);
  Future<List<EvaluationScore>> getScoresForEvaluation(String evaluationId);
  Future<PlayerEvaluation?> getEvaluationById(String evaluationId);
  Future<void> deleteEvaluation(String evaluationId);
}
