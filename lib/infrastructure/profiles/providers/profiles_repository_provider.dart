// lib/infrastructure/profiles/providers/profiles_repository_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport_tech_app/config/supabase_config.dart';
import 'package:sport_tech_app/domain/profiles/repositories/profiles_repository.dart';
import 'package:sport_tech_app/infrastructure/profiles/supabase_profiles_repository.dart';

/// Provider for the ProfilesRepository implementation
/// This provides a singleton instance of SupabaseProfilesRepository
final profilesRepositoryProvider = Provider<ProfilesRepository>((ref) {
  final supabaseClient = ref.watch(supabaseClientProvider);
  return SupabaseProfilesRepository(supabaseClient);
});
