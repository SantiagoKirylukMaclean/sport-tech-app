import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/trainings/entities/training_session.dart';
import '../../domain/trainings/repositories/training_sessions_repository.dart';
import 'mappers/training_session_mapper.dart';

class SupabaseTrainingSessionsRepository implements TrainingSessionsRepository {
  final SupabaseClient _client;

  SupabaseTrainingSessionsRepository(this._client);

  @override
  Future<List<TrainingSession>> getByTeamId(String teamId) async {
    print('SupabaseTrainingSessionsRepository: Fetching sessions for team $teamId');
    final response = await _client
        .from('training_sessions')
        .select()
        .eq('team_id', teamId)
        .order('session_date', ascending: false);

    print('SupabaseTrainingSessionsRepository: Raw response: $response');
    final sessions = (response as List)
        .map((json) => TrainingSessionMapper.fromJson(json))
        .toList();
    print('SupabaseTrainingSessionsRepository: Mapped ${sessions.length} sessions');
    return sessions;
  }

  @override
  Future<TrainingSession?> getById(String id) async {
    final response = await _client
        .from('training_sessions')
        .select()
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;
    return TrainingSessionMapper.fromJson(response);
  }

  @override
  Future<TrainingSession> create({
    required String teamId,
    required DateTime sessionDate,
    String? notes,
  }) async {
    final json = TrainingSessionMapper.toInsertJson(
      teamId: teamId,
      sessionDate: sessionDate,
      notes: notes,
    );

    final response = await _client
        .from('training_sessions')
        .insert(json)
        .select()
        .single();

    return TrainingSessionMapper.fromJson(response);
  }

  @override
  Future<TrainingSession> update(TrainingSession session) async {
    final json = TrainingSessionMapper.toUpdateJson(session);

    final response = await _client
        .from('training_sessions')
        .update(json)
        .eq('id', session.id)
        .select()
        .single();

    return TrainingSessionMapper.fromJson(response);
  }

  @override
  Future<void> delete(String id) async {
    await _client.from('training_sessions').delete().eq('id', id);
  }
}
