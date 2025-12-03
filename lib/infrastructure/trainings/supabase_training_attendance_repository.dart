import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/trainings/entities/training_attendance.dart';
import '../../domain/trainings/repositories/training_attendance_repository.dart';
import 'mappers/training_attendance_mapper.dart';

class SupabaseTrainingAttendanceRepository
    implements TrainingAttendanceRepository {
  final SupabaseClient _client;

  SupabaseTrainingAttendanceRepository(this._client);

  @override
  Future<List<TrainingAttendance>> getBySessionId(String sessionId) async {
    final response = await _client
        .from('training_attendance')
        .select()
        .eq('session_id', sessionId)
        .order('created_at', ascending: true);

    return (response as List)
        .map((json) => TrainingAttendanceMapper.fromJson(json))
        .toList();
  }

  @override
  Future<TrainingAttendance?> getBySessionAndPlayer({
    required String sessionId,
    required String playerId,
  }) async {
    final response = await _client
        .from('training_attendance')
        .select()
        .eq('session_id', sessionId)
        .eq('player_id', playerId)
        .maybeSingle();

    if (response == null) return null;
    return TrainingAttendanceMapper.fromJson(response);
  }

  @override
  Future<TrainingAttendance> upsert({
    required String sessionId,
    required String playerId,
    required AttendanceStatus status,
    String? notes,
  }) async {
    final json = TrainingAttendanceMapper.toUpsertJson(
      sessionId: sessionId,
      playerId: playerId,
      status: status,
      notes: notes,
    );

    final response = await _client
        .from('training_attendance')
        .upsert(
          json,
          onConflict: 'session_id,player_id',
        )
        .select()
        .single();

    return TrainingAttendanceMapper.fromJson(response);
  }

  @override
  Future<void> delete(String id) async {
    await _client.from('training_attendance').delete().eq('id', id);
  }

  @override
  Future<List<TrainingAttendance>> getByPlayerId(String playerId) async {
    final response = await _client
        .from('training_attendance')
        .select()
        .eq('player_id', playerId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => TrainingAttendanceMapper.fromJson(json))
        .toList();
  }
}
