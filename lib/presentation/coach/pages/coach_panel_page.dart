import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sport_tech_app/application/org/active_team_notifier.dart';
import 'package:sport_tech_app/core/constants/app_constants.dart';
import 'package:sport_tech_app/l10n/app_localizations.dart';

class CoachPanelPage extends ConsumerWidget {
  const CoachPanelPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final activeTeamState = ref.watch(activeTeamNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.panelCoach),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.go(AppConstants.dashboardRoute);
          },
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Active team display
          if (activeTeamState.activeTeam != null)
            Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.groups,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.activeTeamLabel,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
                            ),
                          ),
                          Text(
                            activeTeamState.activeTeam!.name,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Card(
              color: Theme.of(context).colorScheme.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning,
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        l10n.noTeamSelectedSelectFromDashboard,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16),
          _CoachOptionTile(
            icon: Icons.groups_outlined,
            title: l10n.players,
            subtitle: l10n.manageTeamPlayers,
            onTap: () {
              context.go('/coach-players');
            },
          ),
          const SizedBox(height: 12),
          _CoachOptionTile(
            icon: Icons.fitness_center_outlined,
            title: l10n.trainings,
            subtitle: l10n.manageTrainingsAndAttendance,
            onTap: () {
              context.go(AppConstants.trainingsRoute);
            },
          ),
          const SizedBox(height: 12),
          _CoachOptionTile(
            icon: Icons.sports_soccer_outlined,
            title: l10n.matches,
            subtitle: l10n.manageMatchesLineupsResults,
            onTap: () {
              context.go(AppConstants.matchesRoute);
            },
          ),
          const SizedBox(height: 12),
          _CoachOptionTile(
            icon: Icons.assessment_outlined,
            title: l10n.evaluations,
            subtitle: l10n.evaluatePlayerPerformance,
            onTap: () {
              context.go('/coach-evaluations');
            },
          ),
        ],
      ),
    );
  }
}

class _CoachOptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _CoachOptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.7),
                          ),
                    ),
                  ],
                ),
              ),
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
