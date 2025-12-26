// lib/config/github_config.dart

/// GitHub repository configuration for auto-updates
class GitHubConfig {
  /// Your GitHub username
  static const String owner = 'SantiagoKirylukMaclean';

  /// Repository name
  static const String repo = 'sport-tech-app';

  /// Full GitHub API URL for releases
  static String get releasesUrl => 'https://api.github.com/repos/$owner/$repo/releases';
}
