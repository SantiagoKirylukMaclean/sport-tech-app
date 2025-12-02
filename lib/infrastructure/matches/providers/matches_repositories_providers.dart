// lib/infrastructure/matches/providers/matches_repositories_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport_tech_app/config/supabase_config.dart';
import 'package:sport_tech_app/domain/matches/repositories/match_call_ups_repository.dart';
import 'package:sport_tech_app/domain/matches/repositories/match_goals_repository.dart';
import 'package:sport_tech_app/domain/matches/repositories/match_player_periods_repository.dart';
import 'package:sport_tech_app/domain/matches/repositories/match_quarter_results_repository.dart';
import 'package:sport_tech_app/domain/matches/repositories/match_substitutions_repository.dart';
import 'package:sport_tech_app/domain/matches/repositories/match_validation_repository.dart';
import 'package:sport_tech_app/domain/matches/repositories/matches_repository.dart';
import 'package:sport_tech_app/infrastructure/matches/supabase_match_call_ups_repository.dart';
import 'package:sport_tech_app/infrastructure/matches/supabase_match_goals_repository.dart';
import 'package:sport_tech_app/infrastructure/matches/supabase_match_player_periods_repository.dart';
import 'package:sport_tech_app/infrastructure/matches/supabase_match_quarter_results_repository.dart';
import 'package:sport_tech_app/infrastructure/matches/supabase_match_substitutions_repository.dart';
import 'package:sport_tech_app/infrastructure/matches/supabase_match_validation_repository.dart';
import 'package:sport_tech_app/infrastructure/matches/supabase_matches_repository.dart';

/// Provider for Matches Repository
final matchesRepositoryProvider = Provider<MatchesRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseMatchesRepository(client);
});

/// Provider for Match Call-ups Repository
final matchCallUpsRepositoryProvider =
    Provider<MatchCallUpsRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseMatchCallUpsRepository(client);
});

/// Provider for Match Player Periods Repository
final matchPlayerPeriodsRepositoryProvider =
    Provider<MatchPlayerPeriodsRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseMatchPlayerPeriodsRepository(client);
});

/// Provider for Match Substitutions Repository
final matchSubstitutionsRepositoryProvider =
    Provider<MatchSubstitutionsRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseMatchSubstitutionsRepository(client);
});

/// Provider for Match Quarter Results Repository
final matchQuarterResultsRepositoryProvider =
    Provider<MatchQuarterResultsRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseMatchQuarterResultsRepository(client);
});

/// Provider for Match Goals Repository
final matchGoalsRepositoryProvider = Provider<MatchGoalsRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseMatchGoalsRepository(client);
});

/// Provider for Match Validation Repository
final matchValidationRepositoryProvider =
    Provider<MatchValidationRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseMatchValidationRepository(client);
});
