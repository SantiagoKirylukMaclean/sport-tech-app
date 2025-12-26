// lib/application/update/update_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport_tech_app/infrastructure/services/app_update_service.dart';

/// Provider for the AppUpdateService
final appUpdateServiceProvider = Provider<AppUpdateService>((ref) {
  return AppUpdateService();
});

/// Provider to check for updates
final updateCheckProvider = FutureProvider<UpdateInfo?>((ref) async {
  final updateService = ref.watch(appUpdateServiceProvider);
  return await updateService.checkForUpdate();
});

/// State notifier for managing update download progress
class UpdateDownloadNotifier extends StateNotifier<UpdateDownloadState> {
  final AppUpdateService _updateService;

  UpdateDownloadNotifier(this._updateService)
      : super(const UpdateDownloadState.idle());

  Future<void> downloadAndInstall(String downloadUrl) async {
    state = const UpdateDownloadState.downloading(0.0);

    try {
      final success = await _updateService.downloadAndInstall(
        downloadUrl,
        onProgress: (progress) {
          state = UpdateDownloadState.downloading(progress);
        },
      );

      if (success) {
        state = const UpdateDownloadState.completed();
      } else {
        state = const UpdateDownloadState.error('Failed to install update');
      }
    } catch (e) {
      state = UpdateDownloadState.error(e.toString());
    }
  }

  void reset() {
    state = const UpdateDownloadState.idle();
  }
}

/// Provider for update download state
final updateDownloadProvider =
    StateNotifierProvider<UpdateDownloadNotifier, UpdateDownloadState>((ref) {
  final updateService = ref.watch(appUpdateServiceProvider);
  return UpdateDownloadNotifier(updateService);
});

/// State for update download
sealed class UpdateDownloadState {
  const UpdateDownloadState();

  const factory UpdateDownloadState.idle() = UpdateDownloadIdle;
  const factory UpdateDownloadState.downloading(double progress) = UpdateDownloadDownloading;
  const factory UpdateDownloadState.completed() = UpdateDownloadCompleted;
  const factory UpdateDownloadState.error(String message) = UpdateDownloadError;
}

class UpdateDownloadIdle extends UpdateDownloadState {
  const UpdateDownloadIdle();
}

class UpdateDownloadDownloading extends UpdateDownloadState {
  final double progress;
  const UpdateDownloadDownloading(this.progress);
}

class UpdateDownloadCompleted extends UpdateDownloadState {
  const UpdateDownloadCompleted();
}

class UpdateDownloadError extends UpdateDownloadState {
  final String message;
  const UpdateDownloadError(this.message);
}
