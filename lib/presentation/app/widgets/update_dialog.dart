// lib/presentation/app/widgets/update_dialog.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport_tech_app/application/update/update_provider.dart';
import 'package:sport_tech_app/infrastructure/services/app_update_service.dart';

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

    final progress = isDownloading ? (downloadState as UpdateDownloadDownloading).progress : 0.0;
    final errorMessage = isError ? (downloadState as UpdateDownloadError).message : '';

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
}
