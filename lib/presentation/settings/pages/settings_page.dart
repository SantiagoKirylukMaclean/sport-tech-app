// lib/presentation/settings/pages/settings_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport_tech_app/application/locale/locale_provider.dart';
import 'package:sport_tech_app/config/theme/theme_provider.dart';
import 'package:sport_tech_app/l10n/app_localizations.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final currentTheme = ref.watch(themeModeProvider);
    final currentLocale = ref.watch(localeProvider);

    return Scaffold(
      body: ListView(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.settings,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.preferences,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                ),
              ],
            ),
          ),

          const Divider(),

          // Appearance Section
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
            child: Text(
              l10n.appearance,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ),

          // Theme Mode
          ListTile(
            leading: Icon(
              currentTheme == ThemeMode.light
                  ? Icons.light_mode_outlined
                  : currentTheme == ThemeMode.dark
                      ? Icons.dark_mode_outlined
                      : Icons.brightness_auto_outlined,
            ),
            title: Text(l10n.toggleTheme),
            subtitle: Text(
              currentTheme == ThemeMode.light
                  ? l10n.lightMode
                  : currentTheme == ThemeMode.dark
                      ? l10n.darkMode
                      : l10n.systemMode,
            ),
            trailing: SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(
                  value: ThemeMode.light,
                  icon: Icon(Icons.light_mode_outlined, size: 16),
                ),
                ButtonSegment(
                  value: ThemeMode.system,
                  icon: Icon(Icons.brightness_auto_outlined, size: 16),
                ),
                ButtonSegment(
                  value: ThemeMode.dark,
                  icon: Icon(Icons.dark_mode_outlined, size: 16),
                ),
              ],
              selected: {currentTheme},
              onSelectionChanged: (Set<ThemeMode> newSelection) {
                ref.read(themeNotifierProvider.notifier).setThemeMode(newSelection.first);
              },
            ),
          ),

          const Divider(),

          // Language Section
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
            child: Text(
              l10n.language,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ),

          // Language Selector
          ListTile(
            leading: const Icon(Icons.language_outlined),
            title: Text(l10n.language),
            subtitle: Text(
              currentLocale?.languageCode == 'es' ? l10n.spanish : l10n.english,
            ),
            trailing: SegmentedButton<String>(
              segments: [
                ButtonSegment(
                  value: 'en',
                  label: Text(l10n.english),
                ),
                ButtonSegment(
                  value: 'es',
                  label: Text(l10n.spanish),
                ),
              ],
              selected: {currentLocale?.languageCode ?? 'en'},
              onSelectionChanged: (Set<String> newSelection) {
                ref.read(localeProvider.notifier).setLocale(
                      Locale(newSelection.first),
                    );
              },
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
