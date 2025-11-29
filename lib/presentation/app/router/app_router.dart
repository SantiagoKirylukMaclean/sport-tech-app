// lib/presentation/app/router/app_router.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sport_tech_app/application/auth/auth_notifier.dart';
import 'package:sport_tech_app/application/auth/auth_state.dart';
import 'package:sport_tech_app/core/constants/app_constants.dart';
import 'package:sport_tech_app/presentation/app/scaffold/app_scaffold.dart';
import 'package:sport_tech_app/presentation/auth/pages/login_page.dart';
import 'package:sport_tech_app/presentation/dashboard/pages/dashboard_page.dart';
import 'package:sport_tech_app/presentation/matches/pages/matches_page.dart';
import 'package:sport_tech_app/presentation/trainings/pages/trainings_page.dart';
import 'package:sport_tech_app/presentation/championship/pages/championship_page.dart';
import 'package:sport_tech_app/presentation/evaluations/pages/evaluations_page.dart';
import 'package:sport_tech_app/presentation/notes/pages/notes_page.dart';
import 'package:sport_tech_app/presentation/profile/pages/profile_page.dart';

/// Provider for the GoRouter instance
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authNotifierProvider);

  return GoRouter(
    initialLocation: AppConstants.dashboardRoute,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isAuthenticated = authState is AuthStateAuthenticated;
      final isLoggingIn = state.matchedLocation == AppConstants.loginRoute;

      // If not authenticated and not on login page, redirect to login
      if (!isAuthenticated && !isLoggingIn) {
        return AppConstants.loginRoute;
      }

      // If authenticated and on login page, redirect to dashboard
      if (isAuthenticated && isLoggingIn) {
        return AppConstants.dashboardRoute;
      }

      // No redirect needed
      return null;
    },
    routes: [
      // Login route (no scaffold)
      GoRoute(
        path: AppConstants.loginRoute,
        name: 'login',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const LoginPage(),
        ),
      ),

      // Shell route for authenticated pages (with scaffold)
      ShellRoute(
        builder: (context, state, child) {
          return AppScaffold(child: child);
        },
        routes: [
          GoRoute(
            path: AppConstants.dashboardRoute,
            name: 'dashboard',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const DashboardPage(),
            ),
          ),
          GoRoute(
            path: AppConstants.matchesRoute,
            name: 'matches',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const MatchesPage(),
            ),
          ),
          GoRoute(
            path: AppConstants.trainingsRoute,
            name: 'trainings',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const TrainingsPage(),
            ),
          ),
          GoRoute(
            path: AppConstants.championshipRoute,
            name: 'championship',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const ChampionshipPage(),
            ),
          ),
          GoRoute(
            path: AppConstants.evaluationsRoute,
            name: 'evaluations',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const EvaluationsPage(),
            ),
          ),
          GoRoute(
            path: AppConstants.notesRoute,
            name: 'notes',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const NotesPage(),
            ),
          ),
          GoRoute(
            path: AppConstants.profileRoute,
            name: 'profile',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const ProfilePage(),
            ),
          ),
        ],
      ),
    ],
  );
});
