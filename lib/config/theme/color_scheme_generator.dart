// lib/config/theme/color_scheme_generator.dart

import 'package:flutter/material.dart';

/// Generates Material Design 3 color schemes from seed colors
///
/// This class uses Flutter's built-in ColorScheme.fromSeed() to generate
/// complete MD3 color schemes that guarantee proper contrast ratios and
/// harmonious color relationships.
class ColorSchemeGenerator {
  /// Default primary color (Blue 500) when no custom color is provided
  static const Color defaultPrimary = Color(0xFF2196F3);

  /// Default secondary color (Green 500) when no custom color is provided
  static const Color defaultSecondary = Color(0xFF4CAF50);

  /// Default tertiary color (Orange 500) when no custom color is provided
  static const Color defaultTertiary = Color(0xFFFF9800);

  /// Generate a light color scheme from seed colors
  ///
  /// Uses [primarySeed] as the main seed color for generating the scheme.
  /// [secondarySeed] and [tertiarySeed] override specific color families.
  ///
  /// Returns a complete ColorScheme with all MD3 color roles defined.
  static ColorScheme generateLightScheme({
    required Color primarySeed,
    Color? secondarySeed,
    Color? tertiarySeed,
  }) {
    // Start with primary-based scheme
    final baseScheme = ColorScheme.fromSeed(
      seedColor: primarySeed,
      brightness: Brightness.light,
    );

    // If we have secondary/tertiary seeds, generate separate schemes and merge
    if (secondarySeed != null || tertiarySeed != null) {
      final secondaryScheme = secondarySeed != null
          ? ColorScheme.fromSeed(
              seedColor: secondarySeed,
              brightness: Brightness.light,
            )
          : null;

      final tertiaryScheme = tertiarySeed != null
          ? ColorScheme.fromSeed(
              seedColor: tertiarySeed,
              brightness: Brightness.light,
            )
          : null;

      return baseScheme.copyWith(
        secondary: secondaryScheme?.primary ?? baseScheme.secondary,
        onSecondary: secondaryScheme?.onPrimary ?? baseScheme.onSecondary,
        secondaryContainer:
            secondaryScheme?.primaryContainer ?? baseScheme.secondaryContainer,
        onSecondaryContainer: secondaryScheme?.onPrimaryContainer ??
            baseScheme.onSecondaryContainer,
        tertiary: tertiaryScheme?.primary ?? baseScheme.tertiary,
        onTertiary: tertiaryScheme?.onPrimary ?? baseScheme.onTertiary,
        tertiaryContainer:
            tertiaryScheme?.primaryContainer ?? baseScheme.tertiaryContainer,
        onTertiaryContainer: tertiaryScheme?.onPrimaryContainer ??
            baseScheme.onTertiaryContainer,
      );
    }

    return baseScheme;
  }

  /// Generate a dark color scheme from seed colors
  ///
  /// Uses [primarySeed] as the main seed color for generating the scheme.
  /// [secondarySeed] and [tertiarySeed] override specific color families.
  ///
  /// Returns a complete ColorScheme with all MD3 color roles defined for dark mode.
  static ColorScheme generateDarkScheme({
    required Color primarySeed,
    Color? secondarySeed,
    Color? tertiarySeed,
  }) {
    final baseScheme = ColorScheme.fromSeed(
      seedColor: primarySeed,
      brightness: Brightness.dark,
    );

    if (secondarySeed != null || tertiarySeed != null) {
      final secondaryScheme = secondarySeed != null
          ? ColorScheme.fromSeed(
              seedColor: secondarySeed,
              brightness: Brightness.dark,
            )
          : null;

      final tertiaryScheme = tertiarySeed != null
          ? ColorScheme.fromSeed(
              seedColor: tertiarySeed,
              brightness: Brightness.dark,
            )
          : null;

      return baseScheme.copyWith(
        secondary: secondaryScheme?.primary ?? baseScheme.secondary,
        onSecondary: secondaryScheme?.onPrimary ?? baseScheme.onSecondary,
        secondaryContainer:
            secondaryScheme?.primaryContainer ?? baseScheme.secondaryContainer,
        onSecondaryContainer: secondaryScheme?.onPrimaryContainer ??
            baseScheme.onSecondaryContainer,
        tertiary: tertiaryScheme?.primary ?? baseScheme.tertiary,
        onTertiary: tertiaryScheme?.onPrimary ?? baseScheme.onTertiary,
        tertiaryContainer:
            tertiaryScheme?.primaryContainer ?? baseScheme.tertiaryContainer,
        onTertiaryContainer: tertiaryScheme?.onPrimaryContainer ??
            baseScheme.onTertiaryContainer,
      );
    }

    return baseScheme;
  }
}
