// lib/presentation/app/widgets/update_dialog.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport_tech_app/application/update/update_provider.dart';
import 'package:sport_tech_app/infrastructure/services/app_update_service.dart';
import 'package:sport_tech_app/l10n/app_localizations.dart';

/// Dialog to prompt user about available update
class UpdateDialog extends ConsumerWidget {
  final UpdateInfo updateInfo;

  const UpdateDialog({
    required this.updateInfo,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final downloadState = ref.watch(updateDownloadProvider);

    final isDownloading = downloadState is UpdateDownloadDownloading;
    final isCompleted = downloadState is UpdateDownloadCompleted;
    final isError = downloadState is UpdateDownloadError;

    final progress = isDownloading
        ? (downloadState as UpdateDownloadDownloading).progress
        : 0.0;
    final errorMessage =
        isError ? (downloadState as UpdateDownloadError).message : '';

    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.system_update, color: Colors.blue),
          SizedBox(width: 8),
          Text('Nueva versión disponible'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              updateInfo.releaseName,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Versión actual: ${updateInfo.currentVersion}\n'
              'Nueva versión: ${updateInfo.latestVersion}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            if (updateInfo.releaseNotes.isNotEmpty) ...[
              const Text(
                'Novedades:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(updateInfo.releaseNotes),
              const SizedBox(height: 16),
            ],
            if (isDownloading) ...[
              LinearProgressIndicator(value: progress),
              const SizedBox(height: 8),
              Text('Descargando... ${(progress * 100).toInt()}%'),
            ],
            if (isError)
              Text(
                'Error: $errorMessage',
                style: const TextStyle(color: Colors.red),
              ),
            if (isCompleted)
              const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green),
                  SizedBox(width: 8),
                  Text('Instalando actualización...'),
                ],
              ),
          ],
        ),
      ),
      actions: [
        if (!isDownloading && !isCompleted)
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Más tarde'),
          ),
        if (!isDownloading && !isCompleted)
          FilledButton.icon(
            onPressed: () {
              ref
                  .read(updateDownloadProvider.notifier)
                  .downloadAndInstall(updateInfo.downloadUrl);
            },
            icon: const Icon(Icons.download),
            label: const Text('Actualizar ahora'),
          ),
      ],
    );
  }

  /// Show update dialog if update is available
  static Future<void> checkAndShow(BuildContext context, WidgetRef ref) async {
    final updateInfo = await ref.read(updateCheckProvider.future);

    if (updateInfo != null && context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => UpdateDialog(updateInfo: updateInfo),
      );
    }
  }

  /// Check for updates and show feedback (for manual checks)
  static Future<void> checkAndShowWithFeedback(
      BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    // Show loading snackbar
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 8),
            Text(l10n.checkingForUpdates ?? 'Checking for updates...'),
          ],
        ),
        duration: const Duration(seconds: 1),
      ),
    );

    try {
      // Force a fresh check
      final updateInfo =
          await ref.read(appUpdateServiceProvider).checkForUpdate();

      if (!context.mounted) return;

      if (updateInfo != null) {
        // Update available
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => UpdateDialog(updateInfo: updateInfo),
        );
      } else {
        // No update available
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(l10n.noUpdatesAvailable ?? 'No updates available'),
          ),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(
              '${l10n.errorCheckingUpdates ?? 'Error checking for updates'}: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
