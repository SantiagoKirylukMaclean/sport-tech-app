// lib/core/constants/app_constants.dart

class AppConstants {
  // App info
  static const String appName = 'Sport Tech';
  static const String appVersion = '1.0.0';

  // Storage keys
  static const String themeKey = 'theme_mode';
  static const String localeKey = 'locale';

  // Timeout durations
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration cacheTimeout = Duration(hours: 24);

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Route names
  static const String loginRoute = '/login';
  static const String dashboardRoute = '/dashboard';
  static const String matchesRoute = '/matches';
  static const String trainingsRoute = '/trainings';
  static const String championshipRoute = '/championship';
  static const String evaluationsRoute = '/evaluations';
  static const String notesRoute = '/notes';
  static const String profileRoute = '/profile';

  // Admin routes
  static const String superAdminPanelRoute = '/admin/panel';
  static const String sportsManagementRoute = '/admin/sports';
  static const String clubsManagementRoute = '/admin/clubs';
  static const String teamsManagementRoute = '/admin/teams';

  // Coach routes
  static const String coachPanelRoute = '/coach/panel';

  // Auth routes
  static const String setPasswordRoute = '/set-password';

  // Error messages
  static const String genericErrorMessage = 'An error occurred. Please try again.';
  static const String networkErrorMessage = 'No internet connection. Please check your network.';
  static const String authErrorMessage = 'Authentication failed. Please login again.';
}

/// User roles in the system
enum UserRole {
  superAdmin('super_admin'),
  admin('admin'),
  coach('coach'),
  player('player');

  final String value;
  const UserRole(this.value);

  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (role) => role.value == value,
      orElse: () => UserRole.player,
    );
  }

  /// Check if this role has admin privileges
  bool get isAdmin => this == UserRole.superAdmin || this == UserRole.admin;

  /// Check if this role can manage teams
  bool get canManageTeams => isAdmin || this == UserRole.coach;

  /// Check if this role is super admin
  bool get isSuperAdmin => this == UserRole.superAdmin;
}
