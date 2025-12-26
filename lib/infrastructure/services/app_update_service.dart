// lib/infrastructure/services/app_update_service.dart

import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:sport_tech_app/config/github_config.dart';

/// Service to check for app updates from GitHub Releases
class AppUpdateService {
  static String get githubApiUrl => '${GitHubConfig.releasesUrl}';

  /// Check if there's a new version available
  Future<UpdateInfo?> checkForUpdate() async {
    try {
      // Get current app version
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;
      final currentBuildNumber = int.parse(packageInfo.buildNumber);

      // Fetch latest release from GitHub
      final response = await http.get(
        Uri.parse('$githubApiUrl/latest'),
        headers: {'Accept': 'application/vnd.github.v3+json'},
      );

      if (response.statusCode != 200) {
        debugPrint('Failed to fetch updates: ${response.statusCode}');
        return null;
      }

      final releaseData = json.decode(response.body) as Map<String, dynamic>;

      // Extract version from tag_name (e.g., "stage-v1.0.0+1-123" -> "1.0.0+1")
      final tagName = releaseData['tag_name'] as String;
      final versionMatch = RegExp(r'v(\d+\.\d+\.\d+\+\d+)').firstMatch(tagName);

      if (versionMatch == null) {
        debugPrint('Could not parse version from tag: $tagName');
        return null;
      }

      final latestVersionString = versionMatch.group(1)!;
      final versionParts = latestVersionString.split('+');
      final latestVersion = versionParts[0];
      final latestBuildNumber = int.parse(versionParts[1]);

      // Find APK asset in release
      final assets = releaseData['assets'] as List<dynamic>;
      final apkAsset = assets.firstWhere(
        (asset) => (asset['name'] as String).endsWith('.apk'),
        orElse: () => null,
      );

      if (apkAsset == null) {
        debugPrint('No APK found in release');
        return null;
      }

      // Check if update is available (compare build numbers)
      if (latestBuildNumber > currentBuildNumber) {
        return UpdateInfo(
          currentVersion: currentVersion,
          latestVersion: latestVersion,
          downloadUrl: apkAsset['browser_download_url'] as String,
          releaseNotes: releaseData['body'] as String? ?? '',
          releaseName: releaseData['name'] as String,
        );
      }

      return null; // No update available
    } catch (e) {
      debugPrint('Error checking for updates: $e');
      return null;
    }
  }

  /// Download and install APK update
  Future<bool> downloadAndInstall(String downloadUrl, {
    Function(double)? onProgress,
  }) async {
    try {
      // Download APK
      final response = await http.get(Uri.parse(downloadUrl));

      if (response.statusCode != 200) {
        debugPrint('Failed to download APK: ${response.statusCode}');
        return false;
      }

      // Save APK to downloads directory
      final dir = await getExternalStorageDirectory();
      final apkPath = '${dir!.path}/sport_tech_app_update.apk';
      final file = File(apkPath);
      await file.writeAsBytes(response.bodyBytes);

      // Open APK for installation
      final result = await OpenFilex.open(apkPath);
      debugPrint('APK installation result: ${result.message}');

      return result.type == ResultType.done;
    } catch (e) {
      debugPrint('Error downloading/installing update: $e');
      return false;
    }
  }
}

/// Information about an available update
class UpdateInfo {
  final String currentVersion;
  final String latestVersion;
  final String downloadUrl;
  final String releaseNotes;
  final String releaseName;

  UpdateInfo({
    required this.currentVersion,
    required this.latestVersion,
    required this.downloadUrl,
    required this.releaseNotes,
    required this.releaseName,
  });

  bool get isUpdateAvailable => latestVersion != currentVersion;
}
