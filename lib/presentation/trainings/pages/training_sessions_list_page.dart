import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sport_tech_app/l10n/app_localizations.dart';
import 'package:sport_tech_app/application/org/active_team_notifier.dart';
import 'package:sport_tech_app/application/trainings/trainings_providers.dart';
import 'package:sport_tech_app/application/dashboard/player_dashboard_providers.dart';
import 'package:sport_tech_app/domain/trainings/entities/training_attendance.dart';

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
    final playerDashboardState = ref.watch(playerDashboardNotifierProvider);
    final playerId = playerDashboardState.player?.id;
    final attendanceAsync = playerId != null
        ? ref.watch(playerAttendanceProvider(playerId))
        : const AsyncValue<List<TrainingAttendance>>.data([]);

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
                    if (playerId != null) {
                      // Invalidate attendance provider to reload
                      ref.invalidate(playerAttendanceProvider(playerId));
                    }
                  },
                  child: ListView.builder(
                    itemCount: state.sessions.length,
                    padding: const EdgeInsets.all(16),
                    itemBuilder: (context, index) {
                      final session = state.sessions[index];
                      final dateFormat = DateFormat('dd MMM yyyy', 'es');
                      final timeFormat = DateFormat('HH:mm');

                      // Find attendance record for this session
                      final attendance = attendanceAsync.value
                          ?.cast<TrainingAttendance?>()
                          .firstWhere(
                            (a) => a?.trainingId == session.id,
                            orElse: () => null,
                          );

                      // Determine color based on status
                      Color statusColor = Colors.grey; // Default grey
                      IconData statusIcon = Icons.fitness_center;

                      if (attendance != null) {
                        switch (attendance.status) {
                          case AttendanceStatus.onTime:
                            statusColor = Colors.green;
                            break;
                          case AttendanceStatus.late:
                            statusColor = Colors.amber;
                            break;
                          case AttendanceStatus.absent:
                            statusColor = Colors.red;
                            break;
                        }
                      }

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: () {
                            context.push(
                              '/dashboard/trainings/${session.id}',
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Leading icon with status color
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: statusColor.withValues(
                                        alpha: 0.2), // Light background
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    statusIcon,
                                    size: 24,
                                    color: statusColor, // Icon color
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // Content
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                            timeFormat
                                                .format(session.sessionDate),
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
