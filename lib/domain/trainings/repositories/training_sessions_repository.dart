import '../entities/training_session.dart';

abstract class TrainingSessionsRepository {
  /// Get all training sessions for a team
  Future<List<TrainingSession>> getByTeamId(String teamId);

  /// Get a training session by ID
  Future<TrainingSession?> getById(String id);

  /// Create a new training session
  Future<TrainingSession> create({
    required String teamId,
    required DateTime sessionDate,
    String? notes,
  });

  /// Update an existing training session
  Future<TrainingSession> update(TrainingSession session);

  /// Delete a training session
  Future<void> delete(String id);
}
