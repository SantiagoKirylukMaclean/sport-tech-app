// lib/infrastructure/auth/providers/auth_repository_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport_tech_app/config/supabase_config.dart';
import 'package:sport_tech_app/domain/auth/repositories/auth_repository.dart';
import 'package:sport_tech_app/infrastructure/auth/supabase_auth_repository.dart';

/// Provider for the AuthRepository implementation
/// This provides a singleton instance of SupabaseAuthRepository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final supabaseClient = ref.watch(supabaseClientProvider);
  return SupabaseAuthRepository(supabaseClient);
});
