// lib/main.dart

import 'package:flutter/material.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport_tech_app/application/locale/locale_provider.dart';
import 'package:sport_tech_app/config/supabase_config.dart';
import 'package:sport_tech_app/config/theme/app_theme.dart';
import 'package:sport_tech_app/config/theme/theme_provider.dart';
import 'package:sport_tech_app/presentation/app/router/app_router.dart';

import 'package:sport_tech_app/l10n/app_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase with deep link support
  await initializeSupabase();

  // Setup deep link listener for auth callbacks
  _setupDeepLinkListener();

  // Run the app wrapped in ProviderScope for Riverpod
  runApp(
    const ProviderScope(
      child: SportTechApp(),
    ),
  );
}

/// Sets up a listener for deep links to handle Supabase auth callbacks
void _setupDeepLinkListener() {
  // Listen to auth state changes
  Supabase.instance.client.auth.onAuthStateChange.listen((data) {
    // Auth state changes are handled silently in production
    // Events: signedIn, tokenRefreshed, signedOut, etc.
  });
}

class SportTechApp extends ConsumerWidget {
  const SportTechApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final locale = ref.watch(localeProvider);

    // Get current theme state
    final themeState = ref.watch(themeNotifierProvider);

    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) {
        // Use dynamic colors if available, otherwise use custom brand colors
        final lightTheme = lightDynamic != null
            ? AppTheme.buildTheme(lightDynamic)
            : themeState.lightTheme;

        final darkTheme = darkDynamic != null
            ? AppTheme.buildTheme(darkDynamic)
            : themeState.darkTheme;

        return MaterialApp.router(
          title: 'Sport Tech',
          debugShowCheckedModeBanner: false,

          // Theme configuration
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: themeState.themeMode,

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
          supportedLocales: AppLocalizations.supportedLocales,
        );
      },
    );
  }
}
