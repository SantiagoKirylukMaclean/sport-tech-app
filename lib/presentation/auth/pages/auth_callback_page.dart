// lib/presentation/auth/pages/auth_callback_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sport_tech_app/core/constants/app_constants.dart';
import 'package:sport_tech_app/l10n/app_localizations.dart';

/// Page that handles authentication callbacks from Supabase
/// This is shown when the user clicks on invitation/password recovery links
class AuthCallbackPage extends ConsumerStatefulWidget {
  const AuthCallbackPage({super.key});

  @override
  ConsumerState<AuthCallbackPage> createState() => _AuthCallbackPageState();
}

class _AuthCallbackPageState extends ConsumerState<AuthCallbackPage> {
  bool _isProcessing = true;
  String? _errorKey;
  String? _rawError;

  @override
  void initState() {
    super.initState();
    _handleAuthCallback();
  }

  Future<void> _handleAuthCallback() async {
    try {
      final supabase = Supabase.instance.client;

      // Wait for Supabase to process the deep link
      // We'll check multiple times with increasing delays
      Session? session;
      int attempts = 0;
      const maxAttempts = 10;

      while (session == null && attempts < maxAttempts) {
        await Future.delayed(Duration(milliseconds: 500 + (attempts * 200)));
        session = supabase.auth.currentSession;
        attempts++;
      }

      if (mounted) {
        if (session != null) {
          // User is authenticated, redirect to dashboard
          // The auth notifier will handle loading the profile
          context.go(AppConstants.dashboardRoute);

          if (mounted) {
            final l10n = AppLocalizations.of(context)!;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.welcomeEmail(session.user.email ?? '')),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        } else {
          // No session found after multiple attempts
          if (mounted) {
             setState(() {
              _errorKey = 'authFailedDetail';
              _isProcessing = false;
            });
          }


          Future.delayed(const Duration(seconds: 5), () {
            if (mounted) {
              context.go(AppConstants.loginRoute);
            }
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _rawError = e.toString();
          _isProcessing = false;
        });

        Future.delayed(const Duration(seconds: 5), () {
          if (mounted) {
            context.go(AppConstants.loginRoute);
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    String errorMessage = '';
    if (_errorKey == 'authFailedDetail') {
      errorMessage = l10n.authFailedDetail;
    } else if (_rawError != null) {
      errorMessage = l10n.errorMessage(_rawError!);
    }

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isProcessing) ...[
                const CircularProgressIndicator(),
                const SizedBox(height: 24),
                Text(
                  l10n.processingAuthentication,
                  style: const TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
              ] else if (_errorKey != null || _rawError != null) ...[
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red,
                ),
                const SizedBox(height: 24),
                Text(
                  errorMessage,
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.redirectingToLogin,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
