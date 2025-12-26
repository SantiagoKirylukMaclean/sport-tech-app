// lib/presentation/app/widgets/update_checker.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport_tech_app/presentation/app/widgets/update_dialog.dart';

/// Widget that checks for updates when the app starts
class UpdateChecker extends ConsumerStatefulWidget {
  final Widget child;

  const UpdateChecker({
    required this.child,
    super.key,
  });

  @override
  ConsumerState<UpdateChecker> createState() => _UpdateCheckerState();
}

class _UpdateCheckerState extends ConsumerState<UpdateChecker> {
  @override
  void initState() {
    super.initState();
    // Check for updates after the first frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForUpdates();
    });
  }

  Future<void> _checkForUpdates() async {
    // Wait a bit before checking (to let the app load first)
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // Check and show update dialog if available
    await UpdateDialog.checkAndShow(context, ref);
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
