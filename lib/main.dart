// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport_tech_app/application/locale/locale_provider.dart';
import 'package:sport_tech_app/config/supabase_config.dart';
import 'package:sport_tech_app/config/theme/app_theme.dart';
import 'package:sport_tech_app/config/theme/theme_provider.dart';
import 'package:sport_tech_app/presentation/app/router/app_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await initializeSupabase();

  // Run the app wrapped in ProviderScope for Riverpod
  runApp(
    const ProviderScope(
      child: SportTechApp(),
    ),
  );
}

class SportTechApp extends ConsumerWidget {
  const SportTechApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      title: 'Sport Tech',
      debugShowCheckedModeBanner: false,

      // Theme configuration
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,

      // Router configuration
      routerConfig: router,

      // Localization
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''), // English
        Locale('es', ''), // Spanish
      ],
    );
  }
}
