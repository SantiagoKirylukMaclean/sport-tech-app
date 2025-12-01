// lib/presentation/app/scaffold/app_scaffold.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sport_tech_app/application/auth/auth_notifier.dart';
import 'package:sport_tech_app/application/auth/auth_state.dart';
import 'package:sport_tech_app/config/theme/theme_provider.dart';
import 'package:sport_tech_app/core/constants/app_constants.dart';
import 'package:sport_tech_app/presentation/app/scaffold/navigation_item.dart';

class AppScaffold extends ConsumerWidget {
  final Widget child;

  const AppScaffold({required this.child, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final isWideScreen = MediaQuery.of(context).size.width >= 640;

    // Get current location for highlighting active nav item
    final currentLocation = GoRouterState.of(context).matchedLocation;

    // Get navigation items based on user role
    final navigationItems = _getNavigationItems(authState);

    if (isWideScreen) {
      return Scaffold(
        body: Row(
          children: [
            // Navigation Rail for wide screens
            NavigationRail(
              selectedIndex: _getSelectedIndex(currentLocation, navigationItems),
              onDestinationSelected: (index) {
                if (index < navigationItems.length) {
                  context.go(navigationItems[index].route);
                }
              },
              labelType: NavigationRailLabelType.all,
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Icon(
                  Icons.sports_soccer,
                  size: 32,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              trailing: Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Theme toggle button
                        IconButton(
                          icon: Icon(
                            ref.watch(themeModeProvider) == ThemeMode.light
                                ? Icons.dark_mode_outlined
                                : Icons.light_mode_outlined,
                          ),
                          onPressed: () {
                            ref.read(themeModeProvider.notifier).toggle();
                          },
                          tooltip: 'Toggle theme',
                        ),
                        const SizedBox(height: 8),
                        // Logout button
                        IconButton(
                          icon: const Icon(Icons.logout_outlined),
                          onPressed: () {
                            ref.read(authNotifierProvider.notifier).signOut();
                          },
                          tooltip: 'Logout',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              destinations: navigationItems
                  .map(
                    (item) => NavigationRailDestination(
                      icon: Icon(item.iconOutlined),
                      selectedIcon: Icon(item.iconFilled),
                      label: Text(item.label),
                    ),
                  )
                  .toList(),
            ),

            const VerticalDivider(thickness: 1, width: 1),

            // Main content
            Expanded(child: child),
          ],
        ),
      );
    }

    // Mobile layout with bottom navigation
    return Scaffold(
      appBar: AppBar(
        title: Text(_getPageTitle(currentLocation)),
        actions: [
          // Theme toggle
          IconButton(
            icon: Icon(
              ref.watch(themeModeProvider) == ThemeMode.light
                  ? Icons.dark_mode_outlined
                  : Icons.light_mode_outlined,
            ),
            onPressed: () {
              ref.read(themeModeProvider.notifier).toggle();
            },
          ),
          // Logout
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            onPressed: () {
              ref.read(authNotifierProvider.notifier).signOut();
            },
          ),
        ],
      ),
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _getSelectedIndex(currentLocation, navigationItems),
        onDestinationSelected: (index) {
          if (index < navigationItems.length) {
            context.go(navigationItems[index].route);
          }
        },
        destinations: navigationItems
            .map(
              (item) => NavigationDestination(
                icon: Icon(item.iconOutlined),
                selectedIcon: Icon(item.iconFilled),
                label: item.label,
              ),
            )
            .toList(),
      ),
    );
  }

  /// Get navigation items based on user role
  List<NavigationItem> _getNavigationItems(AuthState authState) {
    if (authState is! AuthStateAuthenticated) {
      return [];
    }

    final role = authState.profile.role;

    // Base items for all users
    final items = <NavigationItem>[
      const NavigationItem(
        label: 'Dashboard',
        route: AppConstants.dashboardRoute,
        iconOutlined: Icons.dashboard_outlined,
        iconFilled: Icons.dashboard,
      ),
    ];

    // Coach panel (grouped modules for coaches and super admins)
    if (role == UserRole.coach || role.isSuperAdmin) {
      items.add(
        const NavigationItem(
          label: 'Coach',
          route: AppConstants.coachPanelRoute,
          iconOutlined: Icons.sports_outlined,
          iconFilled: Icons.sports,
        ),
      );
    }

    // Super admin panel (only for super admins)
    if (role.isSuperAdmin) {
      items.add(
        const NavigationItem(
          label: 'Super Admin',
          route: AppConstants.superAdminPanelRoute,
          iconOutlined: Icons.admin_panel_settings_outlined,
          iconFilled: Icons.admin_panel_settings,
        ),
      );
    }

    // Player-facing items
    items.addAll([
      const NavigationItem(
        label: 'Evaluaciones',
        route: AppConstants.evaluationsRoute,
        iconOutlined: Icons.assessment_outlined,
        iconFilled: Icons.assessment,
      ),
      const NavigationItem(
        label: 'Notes',
        route: AppConstants.notesRoute,
        iconOutlined: Icons.note_outlined,
        iconFilled: Icons.note,
      ),
      const NavigationItem(
        label: 'Profile',
        route: AppConstants.profileRoute,
        iconOutlined: Icons.person_outline,
        iconFilled: Icons.person,
      ),
    ]);

    return items;
  }

  /// Get the selected index based on current location
  int _getSelectedIndex(String location, List<NavigationItem> items) {
    final index = items.indexWhere((item) => item.route == location);
    return index >= 0 ? index : 0;
  }

  /// Get page title based on current location
  String _getPageTitle(String location) {
    return switch (location) {
      AppConstants.dashboardRoute => 'Dashboard',
      AppConstants.matchesRoute => 'Partidos',
      AppConstants.trainingsRoute => 'Entrenamiento',
      AppConstants.championshipRoute => 'Campeonato',
      AppConstants.evaluationsRoute => 'Mis Evaluaciones',
      AppConstants.notesRoute => 'Notes',
      AppConstants.profileRoute => 'Profile',
      AppConstants.coachPanelRoute => 'Panel Coach',
      AppConstants.superAdminPanelRoute => 'Panel de Administración',
      AppConstants.teamsManagementRoute => 'Gestión de Equipos',
      AppConstants.clubsManagementRoute => 'Gestión de Clubes',
      AppConstants.sportsManagementRoute => 'Gestión de Deportes',
      _ => 'Sport Tech',
    };
  }
}
