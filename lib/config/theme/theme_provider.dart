// lib/config/theme/theme_provider.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport_tech_app/config/theme/app_theme.dart';

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

/// Helper provider for theme mode only (for compatibility with existing code)
final themeModeProvider = Provider<ThemeMode>((ref) {
  return ref.watch(themeNotifierProvider).themeMode;
});

/// Provider to check if dark mode is active
final isDarkModeProvider = Provider<bool>((ref) {
  final themeMode = ref.watch(themeModeProvider);
  return themeMode == ThemeMode.dark;
});
