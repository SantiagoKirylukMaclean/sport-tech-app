// lib/config/theme/app_theme.dart

import 'package:flutter/material.dart';

/// Application theme configuration using Material 3
///
/// This class provides both static default themes and a method to build
/// themes dynamically from color schemes (for club-based theming).
class AppTheme {
  // Default color scheme for light theme
  static const ColorScheme _defaultLightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF171C1F), // Primary Application Color
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFD0E4FF), // Lighter variation for container
    onPrimaryContainer: Color(0xFF001D35),
    secondary: Color(0xFFFFFFFF), // Secondary Application Color
    onSecondary: Color(0xFF000000), // Black text on white secondary
    secondaryContainer:
        Color(0xFFEFEFEF), // Slightly darker white for container
    onSecondaryContainer: Color(0xFF171C1F),
    tertiary: Color(0xFF9BBA8F), // Tertiary Application Color
    onTertiary: Color(0xFF000000), // Black text on tertiary
    tertiaryContainer: Color(0xFFC7EBCB), // Lighter aligned container
    onTertiaryContainer: Color(0xFF0E1F07),
    error: Color(0xFFBA1A1A),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFFFDAD6),
    onErrorContainer: Color(0xFF410002),
    surface: Color(0xFFF9FAFB), // Very light grey, almost white
    onSurface: Color(0xFF171C1F),
    surfaceContainerHighest: Color(0xFFE1E2E4),
    onSurfaceVariant: Color(0xFF444749),
    outline: Color(0xFF747779),
    outlineVariant: Color(0xFFC4C7C9),
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    inverseSurface: Color(0xFF2E3133),
    onInverseSurface: Color(0xFFF0F1F3),
    inversePrimary: Color(0xFF99CBFF), // Lighter blue/grey inverse
  );

  // Default color scheme for dark theme
  static const ColorScheme _defaultDarkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(
        0xFFFFFFFF), // Using Secondary (White) as Primary in Dark implementation?
    // Or maybe just a light grey.
    // Let's stick to a safe dark theme derived from the brand.
    onPrimary: Color(0xFF171C1F),
    primaryContainer: Color(0xFF00497D), // Keep generic or adjust?
    onPrimaryContainer: Color(0xFFD0E4FF),
    secondary: Color(0xFF9BBA8F), // Use tertiary as secondary in dark?
    onSecondary: Color(0xFF0E1F07),
    secondaryContainer: Color(0xFF354B2F),
    onSecondaryContainer: Color(0xFFC7EBCB),
    tertiary: Color(0xFF9BBA8F), // Keep tertiary
    onTertiary: Color(0xFF0E1F07),
    tertiaryContainer: Color(0xFF354B2F),
    onTertiaryContainer: Color(0xFFC7EBCB),
    error: Color(0xFFFFB4AB),
    onError: Color(0xFF690005),
    errorContainer: Color(0xFF93000A),
    onErrorContainer: Color(0xFFFFDAD6),
    surface: Color(
        0xFF171C1F), // Use the Brand Primary as the Surface color for Dark Mode!
    onSurface: Color(0xFFE2E2E6),
    surfaceContainerHighest: Color(0xFF444749),
    onSurfaceVariant: Color(0xFFC4C7C9),
    outline: Color(0xFF8E9193),
    outlineVariant: Color(0xFF444749),
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    inverseSurface: Color(0xFFE2E2E6),
    onInverseSurface: Color(0xFF2E3133),
    inversePrimary: Color(0xFF171C1F),
  );

  /// Build a complete theme from a color scheme
  ///
  /// This allows dynamic theme generation while maintaining consistent
  /// component styling across all themes.
  static ThemeData buildTheme(ColorScheme colorScheme) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
      ),
      cardTheme: const CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: colorScheme.surface,
        selectedIconTheme: IconThemeData(
          color: colorScheme.primary,
        ),
        selectedLabelTextStyle: TextStyle(
          color: colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        indicatorColor: colorScheme.primaryContainer,
      ),
    );
  }

  /// Default light theme (for backward compatibility)
  static ThemeData get lightTheme => buildTheme(_defaultLightColorScheme);

  /// Default dark theme (for backward compatibility)
  static ThemeData get darkTheme => buildTheme(_defaultDarkColorScheme);
}
