import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/evaluations/entities/player_evaluation.dart';
import '../../domain/evaluations/entities/evaluation_score.dart';
import '../../domain/evaluations/repositories/player_evaluations_repository.dart';
import 'mappers/player_evaluation_mapper.dart';
import 'mappers/evaluation_score_mapper.dart';

class SupabasePlayerEvaluationsRepository
    implements PlayerEvaluationsRepository {
  final SupabaseClient _client;

  SupabasePlayerEvaluationsRepository(this._client);

  @override
  Future<PlayerEvaluation> createEvaluation(PlayerEvaluation evaluation) async {
    final json = PlayerEvaluationMapper.toJson(evaluation);

    final response = await _client
        .from('player_evaluations')
        .insert(json)
        .select()
        .single();

    return PlayerEvaluationMapper.fromJson(response);
  }

  @override
  Future<void> createScores(List<EvaluationScore> scores) async {
    final jsonList = scores.map((s) => EvaluationScoreMapper.toJson(s)).toList();

    await _client.from('evaluation_scores').insert(jsonList);
  }

  @override
  Future<PlayerEvaluation?> getLatestEvaluationForPlayer(
      String playerId) async {
    final response = await _client
        .from('player_evaluations')
        .select()
        .eq('player_id', int.parse(playerId))
        .order('evaluation_date', ascending: false)
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();

    if (response == null) return null;
    return PlayerEvaluationMapper.fromJson(response);
  }

  @override
  Future<List<PlayerEvaluation>> listEvaluationsForPlayer(
      String playerId) async {
    final response = await _client
        .from('player_evaluations')
        .select()
        .eq('player_id', int.parse(playerId))
        .order('evaluation_date', ascending: false)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => PlayerEvaluationMapper.fromJson(json))
        .toList();
  }

  @override
  Future<List<EvaluationScore>> getScoresForEvaluation(
      String evaluationId) async {
    final response = await _client
        .from('evaluation_scores')
        .select()
        .eq('evaluation_id', evaluationId);

    return (response as List)
        .map((json) => EvaluationScoreMapper.fromJson(json))
        .toList();
  }

  @override
  Future<PlayerEvaluation?> getEvaluationById(String evaluationId) async {
    final response = await _client
        .from('player_evaluations')
        .select()
        .eq('id', evaluationId)
        .maybeSingle();

    if (response == null) return null;
    return PlayerEvaluationMapper.fromJson(response);
  }

  @override
  Future<void> deleteEvaluation(String evaluationId) async {
    await _client.from('player_evaluations').delete().eq('id', evaluationId);
  }
}
