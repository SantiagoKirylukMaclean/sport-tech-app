import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sport_tech_app/l10n/app_localizations.dart';
import 'package:sport_tech_app/application/org/active_team_notifier.dart';
import 'package:sport_tech_app/application/trainings/trainings_providers.dart';

/// Read-only page showing all training sessions with details
class TrainingSessionsListPage extends ConsumerStatefulWidget {
  const TrainingSessionsListPage({super.key});

  @override
  ConsumerState<TrainingSessionsListPage> createState() =>
      _TrainingSessionsListPageState();
}

class _TrainingSessionsListPageState
    extends ConsumerState<TrainingSessionsListPage> {
  @override
  void initState() {
    super.initState();
    // Load training sessions when page is opened
    Future.microtask(() {
      final activeTeam = ref.read(activeTeamNotifierProvider).activeTeam;
      if (activeTeam != null) {
        ref
            .read(trainingSessionsNotifierProvider.notifier)
            .loadSessions(activeTeam.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final activeTeamState = ref.watch(activeTeamNotifierProvider);
    final activeTeam = activeTeamState.activeTeam;

    // Show message if no team is selected
    if (activeTeam == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.trainingSessions),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.fitness_center,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                l10n.noTeamSelected,
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  l10n.pleaseSelectTeamFirst,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final state = ref.watch(trainingSessionsNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.trainingSessions),
      ),
      body: state.isLoading && state.sessions.isEmpty
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : state.sessions.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.fitness_center,
                        size: 80,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        l10n.noTrainingSessions,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(l10n.noTrainingSessionsMessage),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    await ref
                        .read(trainingSessionsNotifierProvider.notifier)
                        .loadSessions(activeTeam.id);
                  },
                  child: ListView.builder(
                    itemCount: state.sessions.length,
                    padding: const EdgeInsets.all(16),
                    itemBuilder: (context, index) {
                      final session = state.sessions[index];
                      final dateFormat = DateFormat('dd MMM yyyy', 'es');
                      final timeFormat = DateFormat('HH:mm');

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: () {
                            context.push(
                                '/dashboard/trainings/${session.id}',);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Leading icon
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primaryContainer,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.fitness_center,
                                    size: 24,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimaryContainer,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // Content
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Title
                                      Text(
                                        dateFormat.format(session.sessionDate),
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w500,
                                            ),
                                      ),
                                      const SizedBox(height: 4),
                                      // Time
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.access_time,
                                            size: 16,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurfaceVariant,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            timeFormat.format(session.sessionDate),
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onSurfaceVariant,
                                                ),
                                          ),
                                        ],
                                      ),
                                      // Notes
                                      if (session.notes != null &&
                                          session.notes!.isNotEmpty) ...[
                                        const SizedBox(height: 8),
                                        Text(
                                          session.notes!,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSurfaceVariant,
                                              ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                // Trailing icon
                                Icon(
                                  Icons.chevron_right,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
