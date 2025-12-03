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
        .eq('training_id', sessionId);

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
        .eq('training_id', sessionId)
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
      trainingId: sessionId,
      playerId: playerId,
      status: status,
    );

    final response = await _client
        .from('training_attendance')
        .upsert(
          json,
          onConflict: 'training_id,player_id',
        )
        .select()
        .single();

    return TrainingAttendanceMapper.fromJson(response);
  }

  @override
  Future<void> delete(String id) async {
    // La tabla no tiene columna id, usa composite key
    // Este método no debería ser usado, pero lo dejamos por compatibilidad
    throw UnimplementedError('Use delete by training_id and player_id instead');
  }

  @override
  Future<List<TrainingAttendance>> getByPlayerId(String playerId) async {
    final response = await _client
        .from('training_attendance')
        .select()
        .eq('player_id', playerId);

    return (response as List)
        .map((json) => TrainingAttendanceMapper.fromJson(json))
        .toList();
  }
}
