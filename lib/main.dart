// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport_tech_app/application/locale/locale_provider.dart';
import 'package:sport_tech_app/config/supabase_config.dart';
import 'package:sport_tech_app/config/theme/theme_provider.dart';
import 'package:sport_tech_app/presentation/app/router/app_router.dart';
import 'package:sport_tech_app/presentation/app/widgets/update_checker.dart';
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

    // Watch club colors and update theme when active team changes
    final clubColors = ref.watch(activeClubColorsProvider);
    
    // Update theme based on club colors
    clubColors.whenData((colors) {
      if (colors != null) {
        final (primaryColor, secondaryColor, tertiaryColor) = colors;
        ref.read(themeNotifierProvider.notifier).updateClubTheme(
          primaryColor: primaryColor,
          secondaryColor: secondaryColor,
          tertiaryColor: tertiaryColor,
        );
      } else {
        // Reset to default theme when no club colors available
        ref.read(themeNotifierProvider.notifier).resetToDefaultTheme();
      }
    });

    // Get current theme state (includes dynamic themes based on club colors)
    final themeState = ref.watch(themeNotifierProvider);

    return UpdateChecker(
      child: MaterialApp.router(
        title: 'Sport Tech',
        debugShowCheckedModeBanner: false,

        // Dynamic theme configuration (updates based on club colors)
        theme: themeState.lightTheme,
        darkTheme: themeState.darkTheme,
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
        supportedLocales: const [
          Locale('en', ''), // English
          Locale('es', ''), // Spanish
        ],
      ),
    );
  }
}
