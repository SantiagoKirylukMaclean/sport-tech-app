// lib/application/dashboard/player_dashboard_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport_tech_app/application/dashboard/player_dashboard_notifier.dart';
import 'package:sport_tech_app/application/dashboard/player_dashboard_state.dart';
import 'package:sport_tech_app/application/stats/stats_providers.dart';
import 'package:sport_tech_app/application/evaluations/evaluations_providers.dart';
import 'package:sport_tech_app/infrastructure/org/providers/org_repositories_providers.dart';

/// Provider for PlayerDashboardNotifier
final playerDashboardNotifierProvider =
    StateNotifierProvider<PlayerDashboardNotifier, PlayerDashboardState>((ref) {
  final playersRepository = ref.watch(playersRepositoryProvider);
  final statsRepository = ref.watch(statsRepositoryProvider);
  final evaluationsRepository = ref.watch(playerEvaluationsRepositoryProvider);

  return PlayerDashboardNotifier(
    playersRepository,
    statsRepository,
    evaluationsRepository,
  );
});
