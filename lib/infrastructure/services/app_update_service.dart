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

      debugPrint(
          'AppUpdateService: Current version: $currentVersion, build: $currentBuildNumber');

      // Fetch all releases from GitHub (including pre-releases)
      final response = await http.get(
        Uri.parse(githubApiUrl),
        headers: {
          'Accept': 'application/vnd.github.v3+json',
          'User-Agent': 'SportTechApp',
        },
      );

      if (response.statusCode != 200) {
        debugPrint(
            'AppUpdateService: Failed to fetch updates. Status: ${response.statusCode}, Body: ${response.body}');
        return null;
      }

      final releases = json.decode(response.body) as List<dynamic>;

      if (releases.isEmpty) {
        debugPrint('AppUpdateService: No releases found in repository');
        return null;
      }

      // Find the latest release with a valid version and APK
      Map<String, dynamic>? latestRelease;
      int latestBuildNumber = currentBuildNumber;

      for (final release in releases) {
        final releaseData = release as Map<String, dynamic>;
        final tagName = releaseData['tag_name'] as String;

        // Extract version from tag_name (e.g., "stage-v1.0.0+2-5" -> "1.0.0+2")
        final versionMatch =
            RegExp(r'v(\d+\.\d+\.\d+\+\d+)').firstMatch(tagName);

        if (versionMatch == null) {
          debugPrint(
              'AppUpdateService: Skipping release with invalid tag format: $tagName');
          continue;
        }

        final versionString = versionMatch.group(1)!;
        final versionParts = versionString.split('+');
        if (versionParts.length < 2) {
          debugPrint(
              'AppUpdateService: Skipping release with invalid version string: $versionString');
          continue;
        }
        final buildNumber = int.parse(versionParts[1]);

        // Check if this release has an APK
        final assets = releaseData['assets'] as List<dynamic>;
        final hasApk =
            assets.any((asset) => (asset['name'] as String).endsWith('.apk'));

        if (!hasApk) {
          debugPrint(
              'AppUpdateService: Skipping release without APK: $tagName');
          continue;
        }

        // Keep track of the latest build number
        if (buildNumber > latestBuildNumber) {
          latestBuildNumber = buildNumber;
          latestRelease = releaseData;
          debugPrint(
              'AppUpdateService: Found potential update: build $buildNumber (Tag: $tagName)');
        }
      }

      // Check if we found a newer version
      if (latestRelease == null || latestBuildNumber <= currentBuildNumber) {
        debugPrint(
            'AppUpdateService: No update available. Current: $currentBuildNumber, Latest found: $latestBuildNumber');
        return null;
      }

      // Extract version info from the latest release
      final tagName = latestRelease['tag_name'] as String;
      final versionMatch = RegExp(r'v(\d+\.\d+\.\d+\+\d+)').firstMatch(tagName);
      final latestVersionString = versionMatch!.group(1)!;
      final versionParts = latestVersionString.split('+');
      final latestVersion = versionParts[0];

      // Find APK asset
      final assets = latestRelease['assets'] as List<dynamic>;
      final apkAsset = assets.firstWhere(
        (asset) => (asset['name'] as String).endsWith('.apk'),
      );

      debugPrint(
          'AppUpdateService: Update confirmed! New version: $latestVersion+$latestBuildNumber');

      return UpdateInfo(
        currentVersion: currentVersion,
        latestVersion: latestVersion,
        downloadUrl: apkAsset['browser_download_url'] as String,
        releaseNotes: latestRelease['body'] as String? ?? '',
        releaseName: latestRelease['name'] as String,
      );
    } catch (e, stackTrace) {
      debugPrint(
          'AppUpdateService: Error checking for updates: $e\n$stackTrace');
      return null;
    }
  }

  /// Download and install APK update
  Future<bool> downloadAndInstall(
    String downloadUrl, {
    Function(double)? onProgress,
  }) async {
    final client = http.Client();
    try {
      // Download APK with progress
      final request = http.Request('GET', Uri.parse(downloadUrl));
      final response = await client.send(request);

      if (response.statusCode != 200) {
        debugPrint('Failed to download APK: ${response.statusCode}');
        return false;
      }

      // Save APK to downloads directory
      final dir = await getExternalStorageDirectory();
      final apkPath = '${dir!.path}/sport_tech_app_update.apk';
      final file = File(apkPath);

      final contentLength = response.contentLength ?? 0;
      var bytesDownloaded = 0;
      final sink = file.openWrite();

      await response.stream.listen(
        (chunk) {
          bytesDownloaded += chunk.length;
          sink.add(chunk);
          if (contentLength > 0 && onProgress != null) {
            onProgress(bytesDownloaded / contentLength);
          }
        },
        onDone: () async {
          await sink.close();
        },
        onError: (e) {
          debugPrint('Error downloading stream: $e');
          sink.close();
        },
        cancelOnError: true,
      ).asFuture();

      // Open APK for installation
      final result = await OpenFilex.open(apkPath);
      debugPrint('APK installation result: ${result.message}');

      return result.type == ResultType.done;
    } catch (e) {
      debugPrint('Error downloading/installing update: $e');
      return false;
    } finally {
      client.close();
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
