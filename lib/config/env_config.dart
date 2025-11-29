// lib/config/env_config.dart

/// Environment configuration for the application
/// In production, these should be loaded from environment variables or a secure config file
class EnvConfig {
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '', // Add your Supabase URL here or use --dart-define
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '', // Add your Supabase anon key here or use --dart-define
  );

  /// Validates that all required environment variables are set
  static void validate() {
    if (supabaseUrl.isEmpty) {
      throw Exception(
        'SUPABASE_URL is not configured. '
        'Please set it using --dart-define=SUPABASE_URL=your_url',
      );
    }

    if (supabaseAnonKey.isEmpty) {
      throw Exception(
        'SUPABASE_ANON_KEY is not configured. '
        'Please set it using --dart-define=SUPABASE_ANON_KEY=your_key',
      );
    }
  }

  /// Check if the environment is properly configured
  static bool get isConfigured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}
