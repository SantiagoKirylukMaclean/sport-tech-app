import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sport_tech_app/l10n/app_localizations.dart';
import '../../../application/auth/auth_notifier.dart';
import '../../../application/auth/auth_state.dart';
import '../../../application/org/active_team_notifier.dart';
import '../../../application/trainings/trainings_providers.dart';
import '../../../application/trainings/training_attendance_notifier.dart';
import '../../../core/constants/app_constants.dart';
import '../../../domain/org/entities/player.dart';
import '../../../domain/trainings/entities/training_attendance.dart';
import '../../../domain/trainings/entities/training_session.dart';
import '../../../infrastructure/org/providers/org_repositories_providers.dart';

class TrainingSessionDetailPage extends ConsumerStatefulWidget {
  final String sessionId;

  const TrainingSessionDetailPage({
    required this.sessionId,
    super.key,
  });

  @override
  ConsumerState<TrainingSessionDetailPage> createState() =>
      _TrainingSessionDetailPageState();
}

class _TrainingSessionDetailPageState
    extends ConsumerState<TrainingSessionDetailPage> {
  TrainingSession? _session;
  List<Player> _players = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      // Load session
      final sessionsRepo = ref.read(trainingSessionsRepositoryProvider);
      final session = await sessionsRepo.getById(widget.sessionId);

      if (session == null) {
        if (mounted) {
          final l10n = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.sessionNotFound)),
          );
          Navigator.of(context).pop();
        }
        return;
      }

      // Load attendance
      await ref
          .read(trainingAttendanceNotifierProvider.notifier)
          .loadAttendance(widget.sessionId);

      // Load players for the team
      final activeTeam = ref.read(activeTeamNotifierProvider).activeTeam;
      if (activeTeam != null) {
        final playersRepo = ref.read(playersRepositoryProvider);
        final result = await playersRepo.getPlayersByTeam(activeTeam.id);

        result.when(
          success: (players) {
            if (mounted) {
              setState(() {
                _session = session;
                _players = players;
                _isLoading = false;
              });
            }
          },
          failure: (failure) {
            if (mounted) {
              setState(() => _isLoading = false);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text('Error loading players: ${failure.message}')),
              );
            }
          },
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final attendanceState = ref.watch(trainingAttendanceNotifierProvider);
    final authState = ref.watch(authNotifierProvider);

    // Check if user is coach or admin to show full statistics and attendance list
    final bool isCoachOrAdmin = authState is AuthStateAuthenticated &&
        (authState.profile.role == UserRole.coach ||
         authState.profile.role.isAdmin);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.trainingSessionDetails),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _session == null
              ? Center(child: Text(l10n.sessionNotFound))
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Session Info Card
                        _buildSessionInfo(context),
                        const SizedBox(height: 24),

                        // Attendance Summary - shown for all users
                        _buildAttendanceSummary(context, attendanceState, isCoachOrAdmin),
                        const SizedBox(height: 24),

                        // Full Attendance Statistics and List (only for coaches and admins)
                        if (isCoachOrAdmin) ...[
                          // Attendance List Section
                          Text(
                            l10n.attendanceList,
                            style:
                                Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                          ),
                          const SizedBox(height: 12),
                          _buildAttendanceList(context, attendanceState),
                        ],
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildSessionInfo(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final dateFormat = DateFormat('EEEE, MMMM d, yyyy', 'es');
    final timeFormat = DateFormat('HH:mm');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 24,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  l10n.sessionInformation,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildInfoRow(
              context,
              icon: Icons.event,
              label: l10n.date,
              value: dateFormat.format(_session!.sessionDate),
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              context,
              icon: Icons.access_time,
              label: l10n.time,
              value: timeFormat.format(_session!.sessionDate),
            ),
            if (_session!.notes != null && _session!.notes!.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildInfoRow(
                context,
                icon: Icons.notes,
                label: l10n.notes,
                value: _session!.notes!,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAttendanceSummary(
    BuildContext context,
    TrainingAttendanceState attendanceState,
    bool isCoachOrAdmin,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final attendanceNotifier =
        ref.read(trainingAttendanceNotifierProvider.notifier);

    // Count attendance by status
    int onTimeCount = 0;
    int lateCount = 0;
    int absentCount = 0;
    int notMarkedCount = 0;

    for (final player in _players) {
      final status = attendanceNotifier.getPlayerStatus(player.id);
      if (status == null) {
        notMarkedCount++;
      } else {
        switch (status) {
          case AttendanceStatus.onTime:
            onTimeCount++;
            break;
          case AttendanceStatus.late:
            lateCount++;
            break;
          case AttendanceStatus.absent:
            absentCount++;
            break;
        }
      }
    }

    final totalPlayers = _players.length;
    final attendedCount = onTimeCount + lateCount;
    final attendancePercentage = totalPlayers > 0
        ? (attendedCount / totalPlayers * 100).toStringAsFixed(1)
        : '0.0';

    // For players: show only summary count and their own attendance
    if (!isCoachOrAdmin) {
      // Get current user's player ID and attendance status
      final authState = ref.read(authNotifierProvider);
      String? currentUserId;
      if (authState is AuthStateAuthenticated) {
        currentUserId = authState.user.id;
      }

      // Find the player record for the current user
      Player? currentPlayer;
      if (currentUserId != null) {
        currentPlayer = _players.cast<Player?>().firstWhere(
          (p) => p?.userId == currentUserId,
          orElse: () => null,
        );
      }

      // Get the player's attendance status
      AttendanceStatus? myStatus;
      if (currentPlayer != null) {
        myStatus = attendanceNotifier.getPlayerStatus(currentPlayer.id);
      }

      return Column(
        children: [
          // My Attendance Status Card
          if (currentPlayer != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.person,
                          size: 24,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          l10n.myAttendance,
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    _buildMyAttendanceStatus(context, myStatus, l10n),
                  ],
                ),
              ),
            ),
          if (currentPlayer != null) const SizedBox(height: 16),
          // Team Attendance Summary Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.people,
                        size: 24,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        l10n.teamAttendance,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildSimpleStat(
                        context,
                        label: l10n.attended,
                        value: '$attendedCount/$totalPlayers',
                        icon: Icons.check_circle,
                        color: Colors.green,
                      ),
                      Container(
                        height: 60,
                        width: 1,
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                      _buildSimpleStat(
                        context,
                        label: l10n.attendanceRate,
                        value: '$attendancePercentage%',
                        icon: Icons.percent,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    // For coaches/admins: show detailed statistics
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.bar_chart,
                  size: 24,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  l10n.attendanceStatistics,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildStatChip(
                    context,
                    label: l10n.totalPlayers,
                    value: totalPlayers.toString(),
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatChip(
                    context,
                    label: l10n.attendanceRate,
                    value: '$attendancePercentage%',
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatChip(
                    context,
                    label: l10n.onTime,
                    value: onTimeCount.toString(),
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatChip(
                    context,
                    label: l10n.late,
                    value: lateCount.toString(),
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildStatChip(
                    context,
                    label: l10n.absent,
                    value: absentCount.toString(),
                    color: Colors.red,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatChip(
                    context,
                    label: l10n.notMarked,
                    value: notMarkedCount.toString(),
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMyAttendanceStatus(
    BuildContext context,
    AttendanceStatus? status,
    AppLocalizations l10n,
  ) {
    IconData icon;
    String statusLabel;
    Color color;

    if (status == null) {
      icon = Icons.help_outline;
      statusLabel = l10n.notMarked;
      color = Theme.of(context).colorScheme.onSurfaceVariant;
    } else {
      switch (status) {
        case AttendanceStatus.onTime:
          icon = Icons.check_circle;
          statusLabel = l10n.onTime;
          color = Colors.green;
          break;
        case AttendanceStatus.late:
          icon = Icons.schedule;
          statusLabel = l10n.late;
          color = Colors.orange;
          break;
        case AttendanceStatus.absent:
          icon = Icons.cancel;
          statusLabel = l10n.absent;
          color = Colors.red;
          break;
      }
    }

    return Center(
      child: Column(
        children: [
          Icon(
            icon,
            size: 64,
            color: color,
          ),
          const SizedBox(height: 16),
          Text(
            statusLabel,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleStat(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          size: 32,
          color: color,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildStatChip(
    BuildContext context, {
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: color,
                ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceList(
      BuildContext context, TrainingAttendanceState attendanceState) {
    final l10n = AppLocalizations.of(context)!;
    final attendanceNotifier =
        ref.read(trainingAttendanceNotifierProvider.notifier);

    if (_players.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Text(l10n.noPlayersInTeam),
          ),
        ),
      );
    }

    // Sort players: attended first (on time, then late), then not marked, then absent
    final sortedPlayers = List<Player>.from(_players)
      ..sort((a, b) {
        final statusA = attendanceNotifier.getPlayerStatus(a.id);
        final statusB = attendanceNotifier.getPlayerStatus(b.id);

        // Helper function to get sort priority
        int getPriority(AttendanceStatus? status) {
          if (status == AttendanceStatus.onTime) return 0;
          if (status == AttendanceStatus.late) return 1;
          if (status == null) return 2;
          return 3; // absent
        }

        final priorityA = getPriority(statusA);
        final priorityB = getPriority(statusB);

        if (priorityA != priorityB) {
          return priorityA.compareTo(priorityB);
        }

        // If same priority, sort alphabetically
        return a.fullName.compareTo(b.fullName);
      });

    return Card(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: sortedPlayers.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final player = sortedPlayers[index];
          final status = attendanceNotifier.getPlayerStatus(player.id);

          return _buildPlayerAttendanceTile(context, player, status, l10n);
        },
      ),
    );
  }

  Widget _buildPlayerAttendanceTile(
    BuildContext context,
    Player player,
    AttendanceStatus? status,
    AppLocalizations l10n,
  ) {
    IconData icon;
    String statusLabel;
    Color color;

    if (status == null) {
      icon = Icons.help_outline;
      statusLabel = l10n.notMarked;
      color = Theme.of(context).colorScheme.onSurfaceVariant;
    } else {
      switch (status) {
        case AttendanceStatus.onTime:
          icon = Icons.check_circle;
          statusLabel = l10n.onTime;
          color = Colors.green;
          break;
        case AttendanceStatus.late:
          icon = Icons.schedule;
          statusLabel = l10n.late;
          color = Colors.orange;
          break;
        case AttendanceStatus.absent:
          icon = Icons.cancel;
          statusLabel = l10n.absent;
          color = Colors.red;
          break;
      }
    }

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.1),
        child: Text(
          player.jerseyNumber?.toString() ?? '?',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(
        player.fullName,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 4),
          Text(
            statusLabel,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
