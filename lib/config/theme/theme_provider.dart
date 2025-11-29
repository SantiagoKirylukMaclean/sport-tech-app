// lib/config/theme/theme_provider.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Notifier for managing theme mode
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.system);

  /// Toggle between light and dark mode
  void toggle() {
    state = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
  }

  /// Set theme mode explicitly
  void setThemeMode(ThemeMode mode) {
    state = mode;
  }

  /// Set to light mode
  void setLight() => state = ThemeMode.light;

  /// Set to dark mode
  void setDark() => state = ThemeMode.dark;

  /// Set to system mode
  void setSystem() => state = ThemeMode.system;
}

/// Provider for theme mode
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

/// Provider to check if dark mode is active
final isDarkModeProvider = Provider<bool>((ref) {
  final themeMode = ref.watch(themeModeProvider);
  // This is a simplified check; in production, you'd want to check system theme too
  return themeMode == ThemeMode.dark;
});
