// lib/application/locale/locale_provider.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Key for storing locale preference in SharedPreferences
const String _kLocaleKey = 'app_locale';

/// Provider for managing app locale
final localeProvider = StateNotifierProvider<LocaleNotifier, Locale?>((ref) {
  return LocaleNotifier();
});

/// Notifier for managing locale state with persistence
class LocaleNotifier extends StateNotifier<Locale?> {
  LocaleNotifier() : super(null) {
    _loadLocale();
  }

  /// Load saved locale from SharedPreferences
  Future<void> _loadLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString(_kLocaleKey);

      if (languageCode != null) {
        state = Locale(languageCode);
      }
    } catch (e) {
      // If loading fails, keep default (null = system locale)
    }
  }

  /// Set and persist locale
  Future<void> setLocale(Locale locale) async {
    state = locale;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kLocaleKey, locale.languageCode);
    } catch (e) {
      // Silently fail - locale will still be set in memory
    }
  }

  /// Clear locale preference (use system locale)
  Future<void> clearLocale() async {
    state = null;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_kLocaleKey);
    } catch (e) {
      // Silently fail - locale already cleared in memory
    }
  }

  /// Toggle between English and Spanish
  Future<void> toggleLocale() async {
    if (state == null || state!.languageCode == 'en') {
      await setLocale(const Locale('es'));
    } else {
      await setLocale(const Locale('en'));
    }
  }
}
