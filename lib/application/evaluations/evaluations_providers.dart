import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/evaluations/repositories/evaluation_categories_repository.dart';
import '../../domain/evaluations/repositories/player_evaluations_repository.dart';
import '../../infrastructure/evaluations/supabase_evaluation_categories_repository.dart';
import '../../infrastructure/evaluations/supabase_player_evaluations_repository.dart';
import 'evaluation_categories_notifier.dart';
import 'evaluation_categories_state.dart';
import 'player_evaluations_notifier.dart';
import 'player_evaluations_state.dart';

// Supabase client provider
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

// Repository providers
final evaluationCategoriesRepositoryProvider =
    Provider<EvaluationCategoriesRepository>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return SupabaseEvaluationCategoriesRepository(supabase);
});

final playerEvaluationsRepositoryProvider =
    Provider<PlayerEvaluationsRepository>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return SupabasePlayerEvaluationsRepository(supabase);
});

// State notifier providers
final evaluationCategoriesNotifierProvider = StateNotifierProvider.autoDispose<
    EvaluationCategoriesNotifier, EvaluationCategoriesState>((ref) {
  final repository = ref.watch(evaluationCategoriesRepositoryProvider);
  return EvaluationCategoriesNotifier(repository);
});

final playerEvaluationsNotifierProvider =
    StateNotifierProvider<PlayerEvaluationsNotifier, PlayerEvaluationsState>(
        (ref) {
  final repository = ref.watch(playerEvaluationsRepositoryProvider);
  return PlayerEvaluationsNotifier(repository);
});
