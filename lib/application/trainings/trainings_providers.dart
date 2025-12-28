import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/supabase_config.dart';
import '../../domain/trainings/entities/training_attendance.dart';
import '../../domain/trainings/repositories/training_attendance_repository.dart';
import '../../domain/trainings/repositories/training_sessions_repository.dart';
import '../../infrastructure/trainings/supabase_training_attendance_repository.dart';
import '../../infrastructure/trainings/supabase_training_sessions_repository.dart';
import 'training_attendance_notifier.dart';
import 'training_sessions_notifier.dart';

// Repository providers
final trainingSessionsRepositoryProvider =
    Provider<TrainingSessionsRepository>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return SupabaseTrainingSessionsRepository(supabase);
});

final trainingAttendanceRepositoryProvider =
    Provider<TrainingAttendanceRepository>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return SupabaseTrainingAttendanceRepository(supabase);
});

// State notifier providers
final trainingSessionsNotifierProvider =
    StateNotifierProvider<TrainingSessionsNotifier, TrainingSessionsState>(
        (ref) {
  final repository = ref.watch(trainingSessionsRepositoryProvider);
  return TrainingSessionsNotifier(repository);
});

final trainingAttendanceNotifierProvider =
    StateNotifierProvider<TrainingAttendanceNotifier, TrainingAttendanceState>(
        (ref) {
  final repository = ref.watch(trainingAttendanceRepositoryProvider);
  return TrainingAttendanceNotifier(repository);
});

final playerAttendanceProvider =
    FutureProvider.family<List<TrainingAttendance>, String>((ref, playerId) {
  final repository = ref.watch(trainingAttendanceRepositoryProvider);
  return repository.getByPlayerId(playerId);
});
