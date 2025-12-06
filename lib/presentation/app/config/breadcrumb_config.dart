import 'package:flutter/material.dart';
import 'package:sport_tech_app/core/constants/app_constants.dart';
import 'package:sport_tech_app/l10n/app_localizations.dart';

/// Represents a single breadcrumb item
class BreadcrumbItem {
  final String label;
  final String? route;

  const BreadcrumbItem({
    required this.label,
    this.route,
  });
}

/// Configuration for breadcrumbs navigation
class BreadcrumbConfig {
  /// Get breadcrumbs for a given route
  static List<BreadcrumbItem> getBreadcrumbs(String location, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final breadcrumbs = <BreadcrumbItem>[];

    // Parse the location to build breadcrumb trail
    if (location == AppConstants.dashboardRoute || location == '/') {
      return breadcrumbs; // No breadcrumbs for home page
    }

    // Coach Panel routes (all routes starting with /coach-)
    if (location.startsWith('/coach')) {
      // Don't show breadcrumb on main coach panel page
      if (location != AppConstants.coachPanelRoute) {
        breadcrumbs.add(
          BreadcrumbItem(
            label: l10n.coachPanel,
            route: AppConstants.coachPanelRoute,
          ),
        );
      }

      // Coach sub-routes
      if (location == '/coach-players') {
        breadcrumbs.add(const BreadcrumbItem(label: 'Jugadores'));
      } else if (location.startsWith('/coach-evaluations')) {
        breadcrumbs.add(
          const BreadcrumbItem(
            label: 'Evaluaciones',
            route: '/coach-evaluations',
          ),
        );

        if (location == '/coach-evaluations/new') {
          breadcrumbs.add(const BreadcrumbItem(label: 'Nueva Evaluación'));
        } else if (location.contains('/coach-evaluations/') &&
                   location != '/coach-evaluations') {
          breadcrumbs.add(const BreadcrumbItem(label: 'Detalle'));
        }
      }
    }
    // Super Admin Panel routes
    else if (location.startsWith(AppConstants.superAdminPanelRoute)) {
      // Don't show breadcrumb on main super admin panel page
      if (location != AppConstants.superAdminPanelRoute) {
        breadcrumbs.add(
          BreadcrumbItem(
            label: l10n.superAdminPanel,
            route: AppConstants.superAdminPanelRoute,
          ),
        );
      }

      if (location == AppConstants.sportsManagementRoute) {
        breadcrumbs.add(BreadcrumbItem(label: l10n.sportsManagement));
      } else if (location == AppConstants.clubsManagementRoute) {
        breadcrumbs.add(BreadcrumbItem(label: l10n.clubsManagement));
      } else if (location == AppConstants.teamsManagementRoute) {
        breadcrumbs.add(BreadcrumbItem(label: l10n.teamsManagement));
      }
    }
    // Teams management with team ID
    else if (location.startsWith('/teams/') && location.contains('/players')) {
      breadcrumbs.add(
        BreadcrumbItem(
          label: l10n.superAdminPanel,
          route: AppConstants.superAdminPanelRoute,
        ),
      );
      breadcrumbs.add(
        BreadcrumbItem(
          label: l10n.teamsManagement,
          route: AppConstants.teamsManagementRoute,
        ),
      );
      breadcrumbs.add(const BreadcrumbItem(label: 'Jugadores del Equipo'));
    }
    // Matches routes (accessed from Coach Panel)
    else if (location.startsWith(AppConstants.matchesRoute)) {
      // Always show Coach Panel as parent
      breadcrumbs.add(
        BreadcrumbItem(
          label: l10n.coachPanel,
          route: AppConstants.coachPanelRoute,
        ),
      );

      // Add Matches breadcrumb
      breadcrumbs.add(
        BreadcrumbItem(
          label: l10n.matches,
          route: AppConstants.matchesRoute,
        ),
      );

      // Add detail pages
      if (location.contains('/lineup')) {
        breadcrumbs.add(const BreadcrumbItem(label: 'Alineación'));
      }
    }
    // Trainings routes (accessed from Coach Panel)
    else if (location.startsWith(AppConstants.trainingsRoute)) {
      // Always show Coach Panel as parent
      breadcrumbs.add(
        BreadcrumbItem(
          label: l10n.coachPanel,
          route: AppConstants.coachPanelRoute,
        ),
      );

      // Add Trainings breadcrumb
      breadcrumbs.add(
        BreadcrumbItem(
          label: l10n.trainings,
          route: AppConstants.trainingsRoute,
        ),
      );

      // Add detail pages
      if (location.contains('/attendance')) {
        breadcrumbs.add(const BreadcrumbItem(label: 'Asistencia'));
      }
    }

    return breadcrumbs;
  }
}
