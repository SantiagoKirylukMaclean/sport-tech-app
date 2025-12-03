// lib/presentation/app/scaffold/app_scaffold.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sport_tech_app/application/auth/auth_notifier.dart';
import 'package:sport_tech_app/application/auth/auth_state.dart';
import 'package:sport_tech_app/application/locale/locale_provider.dart';
import 'package:sport_tech_app/config/theme/theme_provider.dart';
import 'package:sport_tech_app/core/constants/app_constants.dart';
import 'package:sport_tech_app/presentation/app/scaffold/navigation_item.dart';
import 'package:sport_tech_app/application/org/active_team_notifier.dart';
import 'package:sport_tech_app/l10n/app_localizations.dart';

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
    final navigationItems = _getNavigationItems(authState, context);

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
                        // Language toggle button
                        IconButton(
                          icon: const Icon(Icons.language_outlined),
                          onPressed: () {
                            ref.read(localeProvider.notifier).toggleLocale();
                          },
                          tooltip: AppLocalizations.of(context)?.language ?? 'Language',
                        ),
                        const SizedBox(height: 8),
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
                          tooltip: AppLocalizations.of(context)?.toggleTheme ?? 'Toggle theme',
                        ),
                        const SizedBox(height: 8),
                        // Logout button
                        IconButton(
                          icon: const Icon(Icons.logout_outlined),
                          onPressed: () {
                            ref.read(authNotifierProvider.notifier).signOut();
                          },
                          tooltip: AppLocalizations.of(context)?.logout ?? 'Logout',
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_getPageTitle(currentLocation, context)),
            if (authState is AuthStateAuthenticated && 
                (authState.profile.role == UserRole.coach || authState.profile.role.isSuperAdmin))
              _ActiveTeamSubtitle(),
          ],
        ),
        actions: [
          // Team selector button for coaches
          if (authState is AuthStateAuthenticated && 
              (authState.profile.role == UserRole.coach || authState.profile.role.isSuperAdmin))
            _TeamSelectorButton(),
          // Language toggle
          IconButton(
            icon: const Icon(Icons.language_outlined),
            onPressed: () {
              ref.read(localeProvider.notifier).toggleLocale();
            },
            tooltip: AppLocalizations.of(context)?.language ?? 'Language',
          ),
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
            tooltip: AppLocalizations.of(context)?.toggleTheme ?? 'Toggle theme',
          ),
          // Logout
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            onPressed: () {
              ref.read(authNotifierProvider.notifier).signOut();
            },
            tooltip: AppLocalizations.of(context)?.logout ?? 'Logout',
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
  List<NavigationItem> _getNavigationItems(AuthState authState, BuildContext context) {
    if (authState is! AuthStateAuthenticated) {
      return [];
    }

    final role = authState.profile.role;
    final l10n = AppLocalizations.of(context)!;

    // Base items for all users
    final items = <NavigationItem>[
      NavigationItem(
        label: l10n.dashboard,
        route: AppConstants.dashboardRoute,
        iconOutlined: Icons.dashboard_outlined,
        iconFilled: Icons.dashboard,
      ),
    ];

    // Coach panel (grouped modules for coaches and super admins)
    if (role == UserRole.coach || role.isSuperAdmin) {
      items.add(
        NavigationItem(
          label: l10n.coach,
          route: AppConstants.coachPanelRoute,
          iconOutlined: Icons.sports_outlined,
          iconFilled: Icons.sports,
        ),
      );
    }

    // Super admin panel (only for super admins)
    if (role.isSuperAdmin) {
      items.add(
        NavigationItem(
          label: l10n.superAdmin,
          route: AppConstants.superAdminPanelRoute,
          iconOutlined: Icons.admin_panel_settings_outlined,
          iconFilled: Icons.admin_panel_settings,
        ),
      );
    }

    // Player-facing items
    items.addAll([
      NavigationItem(
        label: l10n.evaluations,
        route: AppConstants.evaluationsRoute,
        iconOutlined: Icons.assessment_outlined,
        iconFilled: Icons.assessment,
      ),
      NavigationItem(
        label: l10n.notes,
        route: AppConstants.notesRoute,
        iconOutlined: Icons.note_outlined,
        iconFilled: Icons.note,
      ),
      NavigationItem(
        label: l10n.profile,
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
  String _getPageTitle(String location, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return switch (location) {
      AppConstants.dashboardRoute => l10n.dashboard,
      AppConstants.matchesRoute => l10n.matches,
      AppConstants.trainingsRoute => l10n.trainings,
      AppConstants.championshipRoute => l10n.championship,
      AppConstants.evaluationsRoute => l10n.evaluations,
      AppConstants.notesRoute => l10n.notes,
      AppConstants.profileRoute => l10n.profile,
      AppConstants.coachPanelRoute => l10n.coachPanel,
      AppConstants.superAdminPanelRoute => l10n.superAdminPanel,
      AppConstants.teamsManagementRoute => l10n.teamsManagement,
      AppConstants.clubsManagementRoute => l10n.clubsManagement,
      AppConstants.sportsManagementRoute => l10n.sportsManagement,
      _ => l10n.appName,
    };
  }
}

/// Widget to display active team name as subtitle
class _ActiveTeamSubtitle extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeTeamState = ref.watch(activeTeamNotifierProvider);
    
    if (activeTeamState.activeTeam != null) {
      return Text(
        activeTeamState.activeTeam!.name,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
        ),
      );
    }
    
    return const SizedBox.shrink();
  }
}

/// Button to open team selector dialog
class _TeamSelectorButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      icon: const Icon(Icons.groups_outlined),
      tooltip: 'Select Team',
      onPressed: () => _showTeamSelectorDialog(context, ref),
    );
  }

  void _showTeamSelectorDialog(BuildContext context, WidgetRef ref) {
    final activeTeamState = ref.read(activeTeamNotifierProvider);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Team'),
        content: SizedBox(
          width: double.maxFinite,
          child: activeTeamState.teams.isEmpty
              ? const Text('No teams available')
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: activeTeamState.teams.length,
                  itemBuilder: (context, index) {
                    final team = activeTeamState.teams[index];
                    final isSelected = activeTeamState.activeTeam?.id == team.id;
                    
                    return ListTile(
                      title: Text(team.name),
                      leading: Icon(
                        isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                        color: isSelected ? Theme.of(context).colorScheme.primary : null,
                      ),
                      onTap: () {
                        ref.read(activeTeamNotifierProvider.notifier).selectTeam(team.id);
                        Navigator.of(context).pop();
                      },
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
