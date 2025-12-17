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
import 'package:sport_tech_app/presentation/matches/pages/match_lineup_page.dart';
import 'package:sport_tech_app/presentation/matches/pages/matches_list_page.dart';
import 'package:sport_tech_app/presentation/matches/pages/match_detail_page.dart';
import 'package:sport_tech_app/presentation/trainings/pages/trainings_page.dart';
import 'package:sport_tech_app/presentation/trainings/pages/training_attendance_page.dart';
import 'package:sport_tech_app/presentation/trainings/pages/training_session_detail_page.dart';
import 'package:sport_tech_app/presentation/trainings/pages/training_sessions_list_page.dart';
import 'package:sport_tech_app/presentation/championship/pages/championship_page.dart';
import 'package:sport_tech_app/presentation/stats/pages/statistics_page.dart';
import 'package:sport_tech_app/presentation/evaluations/pages/evaluations_page.dart';
import 'package:sport_tech_app/presentation/evaluations/pages/player_evaluation_detail_page.dart';
import 'package:sport_tech_app/presentation/notes/pages/notes_page.dart';
import 'package:sport_tech_app/presentation/profile/pages/profile_page.dart';
import 'package:sport_tech_app/presentation/more/pages/more_page.dart';
import 'package:sport_tech_app/presentation/settings/pages/settings_page.dart';
import 'package:sport_tech_app/presentation/org/pages/super_admin_panel_page.dart';
import 'package:sport_tech_app/presentation/org/pages/super_admin_sports_page.dart';
import 'package:sport_tech_app/presentation/org/pages/super_admin_clubs_page.dart';
import 'package:sport_tech_app/presentation/org/pages/admin_teams_page.dart';
import 'package:sport_tech_app/presentation/org/pages/invite_coach_admin_page.dart';
import 'package:sport_tech_app/presentation/org/pages/invite_player_page.dart';
import 'package:sport_tech_app/presentation/org/pages/invitations_management_page.dart';
import 'package:sport_tech_app/presentation/org/pages/users_management_page.dart';
import 'package:sport_tech_app/presentation/org/pages/team_players_page.dart';
import 'package:sport_tech_app/presentation/org/pages/coach_players_page.dart';
import 'package:sport_tech_app/presentation/coach/pages/coach_panel_page.dart';
import 'package:sport_tech_app/presentation/coach/pages/coach_evaluations_page.dart';
import 'package:sport_tech_app/presentation/coach/pages/new_evaluation_page.dart';
import 'package:sport_tech_app/presentation/coach/pages/evaluation_detail_page.dart';
import 'package:sport_tech_app/presentation/auth/pages/set_password_page.dart';
import 'package:sport_tech_app/presentation/auth/pages/auth_callback_page.dart';

/// Provider for the GoRouter instance
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authNotifierProvider);

  return GoRouter(
    initialLocation: AppConstants.dashboardRoute,
    debugLogDiagnostics: true,
    errorBuilder: (context, state) {
      // Handle route errors by redirecting to dashboard or login
      final isAuthenticated = authState is AuthStateAuthenticated;
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 80, color: Colors.red),
              const SizedBox(height: 24),
              const Text(
                'Page Not Found',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text('Could not find route: ${state.uri}'),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  if (isAuthenticated) {
                    context.go(AppConstants.dashboardRoute);
                  } else {
                    context.go(AppConstants.loginRoute);
                  }
                },
                child: const Text('Go to Home'),
              ),
            ],
          ),
        ),
      );
    },
    redirect: (context, state) {
      final isAuthenticated = authState is AuthStateAuthenticated;
      final isLoggingIn = state.matchedLocation == AppConstants.loginRoute;
      final isSettingPassword = state.matchedLocation.startsWith(AppConstants.setPasswordRoute);
      final isAuthCallback = state.matchedLocation == '/auth-callback';

      // Redirect root to dashboard or login
      if (state.matchedLocation == '/') {
        return isAuthenticated ? AppConstants.dashboardRoute : AppConstants.loginRoute;
      }

      // Allow access to auth callback page without authentication
      if (isAuthCallback) {
        return null;
      }

      // Allow access to set password page without authentication
      if (isSettingPassword) {
        return null;
      }

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

      // Set password route (no scaffold, no auth required)
      GoRoute(
        path: '${AppConstants.setPasswordRoute}/:token',
        name: 'set-password',
        pageBuilder: (context, state) {
          final token = state.pathParameters['token'] ?? '';
          return MaterialPage(
            key: state.pageKey,
            child: SetPasswordPage(inviteToken: token),
          );
        },
      ),

      // Auth callback route for handling deep links (no scaffold, no auth required)
      GoRoute(
        path: '/auth-callback',
        name: 'auth-callback',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const AuthCallbackPage(),
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
            path: AppConstants.statisticsRoute,
            name: 'statistics',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const StatisticsPage(),
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
            path: '/evaluations/player/:playerId',
            name: 'player-evaluation-detail',
            pageBuilder: (context, state) {
              final playerId = state.pathParameters['playerId'] ?? '';
              final extra = state.extra as Map<String, dynamic>?;
              final playerName = extra?['playerName'] ?? '';
              return MaterialPage(
                key: state.pageKey,
                child: PlayerEvaluationDetailPage(
                  playerId: playerId,
                  playerName: playerName,
                ),
              );
            },
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
          GoRoute(
            path: AppConstants.moreRoute,
            name: 'more',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const MorePage(),
            ),
          ),
          GoRoute(
            path: AppConstants.settingsRoute,
            name: 'settings',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const SettingsPage(),
            ),
          ),
          // Coach routes
          GoRoute(
            path: AppConstants.coachPanelRoute,
            name: 'coach-panel',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const CoachPanelPage(),
            ),
          ),
          GoRoute(
            path: '/coach-players',
            name: 'coach-players',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const CoachPlayersPage(),
            ),
          ),
          GoRoute(
            path: '/coach-evaluations',
            name: 'coach-evaluations',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const CoachEvaluationsPage(),
            ),
          ),
          GoRoute(
            path: '/coach-evaluations/new',
            name: 'new-evaluation',
            pageBuilder: (context, state) {
              final playerId = state.uri.queryParameters['playerId'] ?? '';
              return MaterialPage(
                key: state.pageKey,
                child: NewEvaluationPage(playerId: playerId),
              );
            },
          ),
          GoRoute(
            path: '/coach-evaluations/:evaluationId',
            name: 'evaluation-detail',
            pageBuilder: (context, state) {
              final evaluationId = state.pathParameters['evaluationId'] ?? '';
              final playerId = state.uri.queryParameters['playerId'] ?? '';
              return MaterialPage(
                key: state.pageKey,
                child: EvaluationDetailPage(
                  evaluationId: evaluationId,
                  playerId: playerId,
                ),
              );
            },
          ),
          // Admin routes
          GoRoute(
            path: AppConstants.superAdminPanelRoute,
            name: 'super-admin-panel',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const SuperAdminPanelPage(),
            ),
          ),
          GoRoute(
            path: AppConstants.sportsManagementRoute,
            name: 'sports-management',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const SuperAdminSportsPage(),
            ),
          ),
          GoRoute(
            path: AppConstants.clubsManagementRoute,
            name: 'clubs-management',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const SuperAdminClubsPage(),
            ),
          ),
          GoRoute(
            path: AppConstants.teamsManagementRoute,
            name: 'teams-management',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const AdminTeamsPage(),
            ),
          ),
          GoRoute(
            path: AppConstants.inviteCoachAdminRoute,
            name: 'invite-coach-admin',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const InviteCoachAdminPage(),
            ),
          ),
          GoRoute(
            path: AppConstants.invitePlayerRoute,
            name: 'invite-player',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const InvitePlayerPage(),
            ),
          ),
          GoRoute(
            path: AppConstants.invitationsManagementRoute,
            name: 'invitations-management',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const InvitationsManagementPage(),
            ),
          ),
          GoRoute(
            path: AppConstants.usersManagementRoute,
            name: 'users-management',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const UsersManagementPage(),
            ),
          ),
          GoRoute(
            path: '/teams/:teamId/players',
            name: 'team-players',
            pageBuilder: (context, state) {
              final teamId = state.pathParameters['teamId'] ?? '';
              final sportId = state.uri.queryParameters['sportId'] ?? '';
              return NoTransitionPage(
                key: state.pageKey,
                child: TeamPlayersPage(teamId: teamId, sportId: sportId),
              );
            },
          ),
          GoRoute(
            path: '/dashboard/matches',
            name: 'matches-list',
            pageBuilder: (context, state) => MaterialPage(
              key: state.pageKey,
              child: const MatchesListPage(),
            ),
          ),
          GoRoute(
            path: '/dashboard/matches/:matchId',
            name: 'match-detail',
            pageBuilder: (context, state) {
              final matchId = state.pathParameters['matchId'] ?? '';
              return MaterialPage(
                key: state.pageKey,
                child: MatchDetailPage(matchId: matchId),
              );
            },
          ),
          GoRoute(
            path: '/matches/:matchId/lineup',
            name: 'match-lineup',
            pageBuilder: (context, state) {
              final matchId = state.pathParameters['matchId'] ?? '';
              return MaterialPage(
                key: state.pageKey,
                child: MatchLineupPage(matchId: matchId),
              );
            },
          ),
          GoRoute(
            path: '/dashboard/trainings',
            name: 'trainings-list',
            pageBuilder: (context, state) => MaterialPage(
              key: state.pageKey,
              child: const TrainingSessionsListPage(),
            ),
          ),
          GoRoute(
            path: '/dashboard/trainings/:sessionId',
            name: 'training-detail',
            pageBuilder: (context, state) {
              final sessionId = state.pathParameters['sessionId'] ?? '';
              return MaterialPage(
                key: state.pageKey,
                child: TrainingSessionDetailPage(sessionId: sessionId),
              );
            },
          ),
          GoRoute(
            path: '/trainings/:sessionId/attendance',
            name: 'training-attendance',
            pageBuilder: (context, state) {
              final sessionId = state.pathParameters['sessionId'] ?? '';
              return MaterialPage(
                key: state.pageKey,
                child: TrainingAttendancePage(sessionId: sessionId),
              );
            },
          ),
          GoRoute(
            path: '/trainings/:sessionId/detail',
            name: 'training-session-detail',
            pageBuilder: (context, state) {
              final sessionId = state.pathParameters['sessionId'] ?? '';
              return MaterialPage(
                key: state.pageKey,
                child: TrainingSessionDetailPage(sessionId: sessionId),
              );
            },
          ),
        ],
      ),
    ],
  );
});
