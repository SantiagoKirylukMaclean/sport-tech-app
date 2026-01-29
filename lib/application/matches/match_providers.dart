import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport_tech_app/application/matches/live_match_detail_notifier.dart';
import 'package:sport_tech_app/application/matches/live_match_notifier.dart';
import 'package:sport_tech_app/domain/matches/repositories/live_match_repository.dart';
import 'package:sport_tech_app/infrastructure/matches/repositories/supabase_live_match_repository.dart';
import 'package:sport_tech_app/infrastructure/matches/providers/matches_repositories_providers.dart';
import 'package:sport_tech_app/infrastructure/org/providers/org_repositories_providers.dart';
import 'package:sport_tech_app/config/supabase_config.dart';

final liveMatchRepositoryProvider = Provider<LiveMatchRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseLiveMatchRepository(client);
});

final liveMatchNotifierProvider =
    StateNotifierProvider<LiveMatchNotifier, LiveMatchState>((ref) {
  final repository = ref.watch(liveMatchRepositoryProvider);
  return LiveMatchNotifier(repository);
});

final liveMatchDetailNotifierProvider = StateNotifierProvider.autoDispose<
    LiveMatchDetailNotifier, LiveMatchDetailState>((ref) {
  final matchesRepository = ref.watch(matchesRepositoryProvider);
  final quarterResultsRepository =
      ref.watch(matchQuarterResultsRepositoryProvider);
  final goalsRepository = ref.watch(matchGoalsRepositoryProvider);
  final basketballStatsRepository =
      ref.watch(basketballMatchStatsRepositoryProvider);
  final callUpsRepository = ref.watch(matchCallUpsRepositoryProvider);
  final teamsRepository = ref.watch(teamsRepositoryProvider);

  return LiveMatchDetailNotifier(
    matchesRepository,
    quarterResultsRepository,
    goalsRepository,
    basketballStatsRepository,
    callUpsRepository,
    teamsRepository,
  );
});
