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
import 'package:sport_tech_app/application/notes/notes_count_provider.dart';
import 'package:sport_tech_app/l10n/app_localizations.dart';
import 'package:sport_tech_app/presentation/app/widgets/app_breadcrumb.dart';

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

    // Check if user should see team selector (Coach, SuperAdmin, OR Player)
    final canSwitchTeams = authState is AuthStateAuthenticated &&
        (authState.profile.role == UserRole.coach ||
         authState.profile.role.isSuperAdmin ||
         authState.profile.role == UserRole.player);

    if (isWideScreen) {
      return Scaffold(
        body: Row(
          children: [
            // Navigation Rail for wide screens
            NavigationRail(
              selectedIndex:
                  _getSelectedIndex(currentLocation, navigationItems),
              onDestinationSelected: (index) {
                if (index < navigationItems.length) {
                  context.go(navigationItems[index].route);
                }
              },
              labelType: NavigationRailLabelType.all,
              leading: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 16),
                  // Team selector for users in wide screen
                  if (canSwitchTeams)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 8),
                      child: _TeamSelectorCompact(),
                    ),
                ],
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
                          tooltip: AppLocalizations.of(context)?.language ??
                              'Language',
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
                            ref.read(themeNotifierProvider.notifier).toggle();
                          },
                          tooltip: AppLocalizations.of(context)?.toggleTheme ??
                              'Toggle theme',
                        ),
                        const SizedBox(height: 8),
                        // Logout button
                        IconButton(
                          icon: const Icon(Icons.logout_outlined),
                          onPressed: () {
                            ref.read(authNotifierProvider.notifier).signOut();
                          },
                          tooltip:
                              AppLocalizations.of(context)?.logout ?? 'Logout',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              destinations: navigationItems
                  .map(
                    (item) => NavigationRailDestination(
                      icon: _buildIconWithBadge(item, ref),
                      selectedIcon:
                          _buildIconWithBadge(item, ref, selected: true),
                      label: Text(item.label),
                    ),
                  )
                  .toList(),
            ),

            const VerticalDivider(thickness: 1, width: 1),

            // Main content
            Expanded(
              child: Column(
                children: [
                  const AppBreadcrumb(),
                  Expanded(child: child),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Mobile layout with bottom navigation
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const _TmsLogo(),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_getPageTitle(currentLocation, context)),
                if (canSwitchTeams)
                  _ActiveTeamSubtitle(),
              ],
            ),
          ],
        ),
        actions: [
          // Team selector button
          if (canSwitchTeams)
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
              ref.read(themeNotifierProvider.notifier).toggle();
            },
            tooltip:
                AppLocalizations.of(context)?.toggleTheme ?? 'Toggle theme',
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
      body: Column(
        children: [
          // Only show breadcrumb in portrait mode or when there's enough vertical space
          if (!isLandscape) const AppBreadcrumb(),
          Expanded(child: child),
        ],
      ),
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
                icon: _buildIconWithBadge(item, ref),
                selectedIcon: _buildIconWithBadge(item, ref, selected: true),
                label: item.label,
              ),
            )
            .toList(),
      ),
    );
  }

  /// Build icon with badge for navigation items
  Widget _buildIconWithBadge(NavigationItem item, WidgetRef ref,
      {bool selected = false}) {
    final icon = Icon(selected ? item.iconFilled : item.iconOutlined);
    final authState = ref.watch(authNotifierProvider);

    // Add badge to "Notes" icon for players
    if (item.route == AppConstants.notesRoute &&
        authState is AuthStateAuthenticated &&
        authState.profile.role == UserRole.player) {
      final notesCount = ref.watch(notesCountProvider);

      if (notesCount > 0) {
        return Badge(
          label: Text('$notesCount'),
          child: icon,
        );
      }
    }

    // Add badge to "More" icon if there are notes (for non-players)
    if (item.route == AppConstants.moreRoute &&
        authState is AuthStateAuthenticated &&
        authState.profile.role != UserRole.player) {
      final notesCount = ref.watch(notesCountProvider);

      if (notesCount > 0) {
        return Badge(
          label: Text('$notesCount'),
          child: icon,
        );
      }
    }

    return icon;
  }

  /// Get navigation items based on user role (Material Design 3 - max 5 items)
  List<NavigationItem> _getNavigationItems(
      AuthState authState, BuildContext context) {
    if (authState is! AuthStateAuthenticated) {
      return [];
    }

    final role = authState.profile.role;
    final l10n = AppLocalizations.of(context)!;

    // PLAYER - 5 items: Home, Notes, Championship, Evaluaciones, More
    if (role == UserRole.player) {
      return [
        NavigationItem(
          label: l10n.home,
          route: AppConstants.dashboardRoute,
          iconOutlined: Icons.home_outlined,
          iconFilled: Icons.home,
        ),
        NavigationItem(
          label: l10n.notes,
          route: AppConstants.notesRoute,
          iconOutlined: Icons.sticky_note_2_outlined,
          iconFilled: Icons.sticky_note_2,
        ),
        NavigationItem(
          label: l10n.championship,
          route: AppConstants.championshipRoute,
          iconOutlined: Icons.emoji_events_outlined,
          iconFilled: Icons.emoji_events,
        ),
        NavigationItem(
          label: l10n.evaluations,
          route: AppConstants.evaluationsRoute,
          iconOutlined: Icons.analytics_outlined,
          iconFilled: Icons.analytics,
        ),
        NavigationItem(
          label: l10n.more,
          route: AppConstants.moreRoute,
          iconOutlined: Icons.more_horiz,
          iconFilled: Icons.more_horiz,
        ),
      ];
    }

    // COACH - 5 items: Dashboard, Mister/Coach, Championship, Evaluations, More
    if (role == UserRole.coach) {
      return [
        NavigationItem(
          label: l10n.dashboard,
          route: AppConstants.dashboardRoute,
          iconOutlined: Icons.dashboard_outlined,
          iconFilled: Icons.dashboard,
        ),
        NavigationItem(
          label: l10n.mister,
          route: AppConstants.coachPanelRoute,
          iconOutlined: Icons.sports_outlined,
          iconFilled: Icons.sports,
        ),
        NavigationItem(
          label: l10n.championship,
          route: AppConstants.championshipRoute,
          iconOutlined: Icons.emoji_events_outlined,
          iconFilled: Icons.emoji_events,
        ),
        NavigationItem(
          label: l10n.evaluations,
          route: AppConstants.evaluationsRoute,
          iconOutlined: Icons.analytics_outlined,
          iconFilled: Icons.analytics,
        ),
        NavigationItem(
          label: l10n.more,
          route: AppConstants.moreRoute,
          iconOutlined: Icons.more_horiz,
          iconFilled: Icons.more_horiz,
        ),
      ];
    }

    // SUPER_ADMIN - 5 items: Home, Mister/Coach, Admin, Stats, More
    if (role.isSuperAdmin) {
      return [
        NavigationItem(
          label: l10n.home,
          route: AppConstants.dashboardRoute,
          iconOutlined: Icons.home_outlined,
          iconFilled: Icons.home,
        ),
        NavigationItem(
          label: l10n.mister,
          route: AppConstants.coachPanelRoute,
          iconOutlined: Icons.sports_soccer_outlined,
          iconFilled: Icons.sports_soccer,
        ),
        NavigationItem(
          label: l10n.admin,
          route: AppConstants.superAdminPanelRoute,
          iconOutlined: Icons.admin_panel_settings_outlined,
          iconFilled: Icons.admin_panel_settings,
        ),
        NavigationItem(
          label: l10n.stats,
          route: AppConstants.evaluationsRoute,
          iconOutlined: Icons.analytics_outlined,
          iconFilled: Icons.analytics,
        ),
        NavigationItem(
          label: l10n.more,
          route: AppConstants.moreRoute,
          iconOutlined: Icons.more_horiz,
          iconFilled: Icons.more_horiz,
        ),
      ];
    }

    // Default fallback (should not happen)
    return [
      NavigationItem(
        label: l10n.home,
        route: AppConstants.dashboardRoute,
        iconOutlined: Icons.home_outlined,
        iconFilled: Icons.home,
      ),
    ];
  }

  /// Get the selected index based on current location
  int _getSelectedIndex(String location, List<NavigationItem> items) {
    // First try exact match
    var index = items.indexWhere((item) => item.route == location);
    if (index >= 0) return index;

    // Check for coach routes (all routes starting with /coach)
    if (location.startsWith('/coach')) {
      index = items
          .indexWhere((item) => item.route == AppConstants.coachPanelRoute);
      if (index >= 0) return index;
    }

    // Check for super admin routes (any route starting with /admin)
    if (location.startsWith('/admin')) {
      index = items.indexWhere(
          (item) => item.route == AppConstants.superAdminPanelRoute);
      if (index >= 0) return index;
    }

    // Check for teams management route (sub-route of super admin)
    if (location.startsWith('/teams/')) {
      index = items.indexWhere(
          (item) => item.route == AppConstants.superAdminPanelRoute);
      if (index >= 0) return index;
    }

    // Check for match routes (these are accessed from Coach Panel)
    if (location.startsWith(AppConstants.matchesRoute)) {
      index = items
          .indexWhere((item) => item.route == AppConstants.coachPanelRoute);
      if (index >= 0) return index;
    }

    // Check for training routes (these are accessed from trainings or coach panel)
    if (location.startsWith(AppConstants.trainingsRoute)) {
      index =
          items.indexWhere((item) => item.route == AppConstants.trainingsRoute);
      if (index >= 0) return index;
    }

    // Check for routes in "More" section (notes, profile, settings)
    if (location == AppConstants.notesRoute ||
        location == AppConstants.profileRoute ||
        location == AppConstants.settingsRoute) {
      index = items.indexWhere((item) => item.route == AppConstants.moreRoute);
      if (index >= 0) return index;
    }

    // Default to home (index 0)
    return 0;
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
      AppConstants.moreRoute => l10n.more,
      AppConstants.settingsRoute => l10n.settings,
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
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.7),
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
    final l10n = AppLocalizations.of(context)!;
    return IconButton(
      icon: const Icon(Icons.groups_outlined),
      tooltip: l10n.selectTeam,
      onPressed: () => _showTeamSelectorDialog(context, ref),
    );
  }

  void _showTeamSelectorDialog(BuildContext context, WidgetRef ref) {
    final activeTeamState = ref.read(activeTeamNotifierProvider);
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.selectTeam),
        content: SizedBox(
          width: double.maxFinite,
          child: activeTeamState.teams.isEmpty
              ? Text(l10n.noTeamsAvailable)
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: activeTeamState.teams.length,
                  itemBuilder: (context, index) {
                    final team = activeTeamState.teams[index];
                    final isSelected =
                        activeTeamState.activeTeam?.id == team.id;

                    return ListTile(
                      title: Text(team.name),
                      leading: Icon(
                        isSelected
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked,
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : null,
                      ),
                      onTap: () {
                        ref
                            .read(activeTeamNotifierProvider.notifier)
                            .selectTeam(team.id);
                        Navigator.of(context).pop();
                      },
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.close),
          ),
        ],
      ),
    );
  }
}

/// Compact team selector for navigation rail
class _TeamSelectorCompact extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeTeamState = ref.watch(activeTeamNotifierProvider);
    final l10n = AppLocalizations.of(context)!;

    return IconButton(
      icon: Icon(
        Icons.groups,
        color: Theme.of(context).colorScheme.primary,
      ),
      tooltip: activeTeamState.activeTeam?.name ?? l10n.selectTeam,
      onPressed: () => _showTeamSelectorDialog(context, ref),
    );
  }

  void _showTeamSelectorDialog(BuildContext context, WidgetRef ref) {
    final activeTeamState = ref.read(activeTeamNotifierProvider);
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.selectTeam),
        content: SizedBox(
          width: double.maxFinite,
          child: activeTeamState.teams.isEmpty
              ? Text(l10n.noTeamsAvailable)
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: activeTeamState.teams.length,
                  itemBuilder: (context, index) {
                    final team = activeTeamState.teams[index];
                    final isSelected =
                        activeTeamState.activeTeam?.id == team.id;

                    return ListTile(
                      title: Text(team.name),
                      leading: Icon(
                        isSelected
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked,
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : null,
                      ),
                      onTap: () {
                        ref
                            .read(activeTeamNotifierProvider.notifier)
                            .selectTeam(team.id);
                        Navigator.of(context).pop();
                      },
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.close),
          ),
        ],
      ),
    );
  }
}

class _TmsLogo extends StatelessWidget {
  const _TmsLogo();

  @override
  Widget build(BuildContext context) {
    final assetPath = 'assets/images/tms_logo_light.png';

    return Image.asset(
      assetPath,
      height: 32, // Adjust height as necessary
      fit: BoxFit.contain,
    );
  }
}
