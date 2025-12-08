// lib/config/supabase_config.dart

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sport_tech_app/config/env_config.dart';

/// Provider for the Supabase client instance
/// This is a singleton that provides access to the Supabase client throughout the app
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

/// Initializes Supabase
/// Call this in main() before runApp()
Future<void> initializeSupabase() async {
  // Validate environment configuration
  EnvConfig.validate();

  await Supabase.initialize(
    url: EnvConfig.supabaseUrl,
    anonKey: EnvConfig.supabaseAnonKey,
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
      // Auto-refresh the session when it expires
      autoRefreshToken: true,
    ),
    // Enable debug mode to see auth logs
    debug: kDebugMode,
  );

  // Log current auth state
  final session = Supabase.instance.client.auth.currentSession;
  debugPrint('Supabase initialized. Current session: ${session != null ? 'Active' : 'None'}');
}
