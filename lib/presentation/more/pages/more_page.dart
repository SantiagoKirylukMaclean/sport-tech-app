// lib/presentation/more/pages/more_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sport_tech_app/application/auth/auth_notifier.dart';
import 'package:sport_tech_app/application/auth/auth_state.dart';
import 'package:sport_tech_app/application/notes/notes_count_provider.dart';
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
    final notesCount = ref.watch(notesCountProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar con título grande
          SliverAppBar.large(
            title: Text(l10n.more),
            automaticallyImplyLeading: false,
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quick Access Section
                  _SectionHeader(
                    icon: Icons.bolt_outlined,
                    title: l10n.quickAccess,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 8),

                  // Championship (for coaches and super admins only)
                  if (role.isAdmin || role == UserRole.coach)
                    _MenuCard(
                      icon: Icons.emoji_events_outlined,
                      title: l10n.championship,
                      subtitle: 'Ver información del campeonato',
                      color: Colors.amber,
                      onTap: () => context.go(AppConstants.championshipRoute),
                    ),

                  // Notes with badge
                  _MenuCard(
                    icon: Icons.sticky_note_2_outlined,
                    title: l10n.notes,
                    subtitle: notesCount > 0
                        ? '$notesCount ${notesCount == 1 ? "nota" : "notas"}'
                        : 'Tus notas personales',
                    color: Colors.orange,
                    badge: notesCount > 0 ? notesCount : null,
                    onTap: () => context.go(AppConstants.notesRoute),
                  ),

                  const SizedBox(height: 24),

                  // Account Section
                  _SectionHeader(
                    icon: Icons.account_circle_outlined,
                    title: 'Cuenta',
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
                  const SizedBox(height: 8),

                  // Profile
                  _MenuCard(
                    icon: Icons.person_outline,
                    title: l10n.profile,
                    subtitle: 'Información de tu cuenta',
                    color: Colors.blue,
                    onTap: () => context.go(AppConstants.profileRoute),
                  ),

                  // Settings
                  _MenuCard(
                    icon: Icons.settings_outlined,
                    title: l10n.settings,
                    subtitle: 'Idioma, tema y preferencias',
                    color: Colors.grey,
                    onTap: () => context.go(AppConstants.settingsRoute),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Section Header Widget
class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;

  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
      ],
    );
  }
}

/// Menu Card Widget
class _MenuCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final int? badge;
  final VoidCallback onTap;

  const _MenuCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Icon with background
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),

              // Title and subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        if (badge != null) ...[
                          const SizedBox(width: 8),
                          Badge(
                            label: Text('$badge'),
                            backgroundColor: color,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                    ),
                  ],
                ),
              ),

              // Chevron
              Icon(
                Icons.chevron_right,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
