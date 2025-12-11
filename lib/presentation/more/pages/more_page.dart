// lib/presentation/more/pages/more_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sport_tech_app/application/auth/auth_notifier.dart';
import 'package:sport_tech_app/application/auth/auth_state.dart';
import 'package:sport_tech_app/core/constants/app_constants.dart';
import 'package:sport_tech_app/l10n/app_localizations.dart';

class MorePage extends ConsumerWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final authState = ref.watch(authNotifierProvider);

    if (authState is! AuthStateAuthenticated) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final role = authState.profile.role;

    return Scaffold(
      body: ListView(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.more,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.moreOptions,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                ),
              ],
            ),
          ),

          const Divider(),

          // Quick Access Section
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
            child: Text(
              l10n.quickAccess,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ),

          // Championship (for coaches and super admins only - moved from main nav)
          if (role.isAdmin || role == UserRole.coach)
            ListTile(
              leading: Icon(
                Icons.emoji_events_outlined,
                color: Theme.of(context).colorScheme.secondary,
              ),
              title: Text(l10n.championship),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.go(AppConstants.championshipRoute),
            ),

          // Notes
          ListTile(
            leading: Icon(
              Icons.sticky_note_2_outlined,
              color: Theme.of(context).colorScheme.secondary,
            ),
            title: Text(l10n.notes),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.go(AppConstants.notesRoute),
          ),

          // Profile
          ListTile(
            leading: Icon(
              Icons.account_circle_outlined,
              color: Theme.of(context).colorScheme.secondary,
            ),
            title: Text(l10n.profile),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.go(AppConstants.profileRoute),
          ),

          const Divider(),

          // Settings Section
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
            child: Text(
              l10n.preferences,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ),

          // Settings
          ListTile(
            leading: Icon(
              Icons.settings_outlined,
              color: Theme.of(context).colorScheme.secondary,
            ),
            title: Text(l10n.settings),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.go(AppConstants.settingsRoute),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
