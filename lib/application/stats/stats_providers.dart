import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport_tech_app/application/stats/stats_notifier.dart';
import 'package:sport_tech_app/application/stats/stats_state.dart';
import 'package:sport_tech_app/domain/stats/repositories/stats_repository.dart';
import 'package:sport_tech_app/infrastructure/stats/repositories/supabase_stats_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Provider for StatsRepository
final statsRepositoryProvider = Provider<StatsRepository>((ref) {
  return SupabaseStatsRepository(Supabase.instance.client);
});

/// Provider for StatsNotifier
final statsNotifierProvider = StateNotifierProvider<StatsNotifier, StatsState>((ref) {
  final repository = ref.watch(statsRepositoryProvider);
  return StatsNotifier(repository);
});
