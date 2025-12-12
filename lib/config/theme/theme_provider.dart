// lib/config/theme/theme_provider.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport_tech_app/application/org/active_team_notifier.dart';
import 'package:sport_tech_app/config/theme/app_theme.dart';
import 'package:sport_tech_app/config/theme/color_scheme_generator.dart';
import 'package:sport_tech_app/infrastructure/org/providers/org_repositories_providers.dart';

/// State for theme configuration
///
/// Contains the current theme mode and the actual ThemeData objects
/// for light and dark modes. This allows dynamic theme generation
/// based on club colors.
class ThemeState {
  final ThemeMode themeMode;
  final ThemeData lightTheme;
  final ThemeData darkTheme;

  const ThemeState({
    required this.themeMode,
    required this.lightTheme,
    required this.darkTheme,
  });

  ThemeState copyWith({
    ThemeMode? themeMode,
    ThemeData? lightTheme,
    ThemeData? darkTheme,
  }) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
      lightTheme: lightTheme ?? this.lightTheme,
      darkTheme: darkTheme ?? this.darkTheme,
    );
  }
}

/// Notifier for managing theme with club-based color schemes
class ThemeNotifier extends StateNotifier<ThemeState> {
  ThemeNotifier()
      : super(ThemeState(
          themeMode: ThemeMode.system,
          lightTheme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
        ));

  /// Toggle between light and dark mode
  void toggle() {
    state = state.copyWith(
      themeMode:
          state.themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light,
    );
  }

  /// Set theme mode explicitly
  void setThemeMode(ThemeMode mode) {
    state = state.copyWith(themeMode: mode);
  }

  /// Set to light mode
  void setLight() => setThemeMode(ThemeMode.light);

  /// Set to dark mode
  void setDark() => setThemeMode(ThemeMode.dark);

  /// Set to system mode
  void setSystem() => setThemeMode(ThemeMode.system);

  /// Update themes based on club colors
  ///
  /// Generates new light and dark themes from the provided seed colors.
  /// If colors are null, uses the default colors from ColorSchemeGenerator.
  void updateClubTheme({
    Color? primaryColor,
    Color? secondaryColor,
    Color? tertiaryColor,
  }) {
    // Use club colors or fallback to defaults
    final primary = primaryColor ?? ColorSchemeGenerator.defaultPrimary;
    final secondary = secondaryColor ?? ColorSchemeGenerator.defaultSecondary;
    final tertiary = tertiaryColor ?? ColorSchemeGenerator.defaultTertiary;

    // Generate color schemes
    final lightColorScheme = ColorSchemeGenerator.generateLightScheme(
      primarySeed: primary,
      secondarySeed: secondary,
      tertiarySeed: tertiary,
    );

    final darkColorScheme = ColorSchemeGenerator.generateDarkScheme(
      primarySeed: primary,
      secondarySeed: secondary,
      tertiarySeed: tertiary,
    );

    // Build complete themes using AppTheme configuration
    state = state.copyWith(
      lightTheme: AppTheme.buildTheme(lightColorScheme),
      darkTheme: AppTheme.buildTheme(darkColorScheme),
    );
  }

  /// Reset to default app theme
  void resetToDefaultTheme() {
    state = state.copyWith(
      lightTheme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
    );
  }
}

/// Main theme provider
final themeNotifierProvider =
    StateNotifierProvider<ThemeNotifier, ThemeState>((ref) {
  return ThemeNotifier();
});

/// Provider that computes club colors based on active team
///
/// This provider:
/// - Watches for changes in the active team
/// - Fetches the club data for the active team
/// - Returns the club colors (or null if no team/club)
final activeClubColorsProvider = FutureProvider<(Color?, Color?, Color?)?>((ref) async {
  // Watch active team state
  final activeTeamState = ref.watch(activeTeamNotifierProvider);

  // If no active team, return null
  if (activeTeamState.activeTeam == null) {
    return null;
  }

  // Get club ID from active team
  final clubId = activeTeamState.activeTeam!.clubId;

  // Fetch club data
  final clubsRepo = ref.watch(clubsRepositoryProvider);
  final result = await clubsRepo.getClubById(clubId);

  return result.when(
    success: (club) => (club.primaryColor, club.secondaryColor, club.tertiaryColor),
    failure: (_) => null,
  );
});

/// Helper provider for theme mode only (for compatibility with existing code)
final themeModeProvider = Provider<ThemeMode>((ref) {
  return ref.watch(themeNotifierProvider).themeMode;
});

/// Provider to check if dark mode is active
final isDarkModeProvider = Provider<bool>((ref) {
  final themeMode = ref.watch(themeModeProvider);
  return themeMode == ThemeMode.dark;
});
