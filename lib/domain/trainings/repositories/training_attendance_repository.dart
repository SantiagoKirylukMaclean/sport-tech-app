import '../entities/training_attendance.dart';

abstract class TrainingAttendanceRepository {
  /// Get all attendance records for a session
  Future<List<TrainingAttendance>> getBySessionId(String sessionId);

  /// Get attendance for a specific player in a session
  Future<TrainingAttendance?> getBySessionAndPlayer({
    required String sessionId,
    required String playerId,
  });

  /// Create or update attendance record
  Future<TrainingAttendance> upsert({
    required String sessionId,
    required String playerId,
    required AttendanceStatus status,
    String? notes,
  });

  /// Delete an attendance record
  Future<void> delete(String id);

  /// Get all attendance records for a player
  Future<List<TrainingAttendance>> getByPlayerId(String playerId);
}
