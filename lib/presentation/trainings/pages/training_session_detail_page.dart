import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sport_tech_app/l10n/app_localizations.dart';
import '../../../application/auth/auth_providers.dart';
import '../../../application/org/active_team_notifier.dart';
import '../../../application/trainings/trainings_providers.dart';
import '../../../domain/org/entities/player.dart';
import '../../../domain/trainings/entities/training_attendance.dart';
import '../../../domain/trainings/entities/training_session.dart';
import '../../../infrastructure/org/providers/org_repositories_providers.dart';

class TrainingSessionDetailPage extends ConsumerStatefulWidget {
  final String sessionId;

  const TrainingSessionDetailPage({
    super.key,
    required this.sessionId,
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

  Map<String, int> _getAttendanceStats() {
    final attendanceNotifier =
        ref.read(trainingAttendanceNotifierProvider.notifier);
    int onTime = 0;
    int late = 0;
    int absent = 0;
    int notMarked = 0;

    for (final player in _players) {
      final status = attendanceNotifier.getPlayerStatus(player.id);
      if (status == null) {
        notMarked++;
      } else {
        switch (status) {
          case AttendanceStatus.onTime:
            onTime++;
            break;
          case AttendanceStatus.late:
            late++;
            break;
          case AttendanceStatus.absent:
            absent++;
            break;
        }
      }
    }

    return {
      'onTime': onTime,
      'late': late,
      'absent': absent,
      'notMarked': notMarked,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentUser = ref.watch(currentUserProfileProvider);
    ref.watch(trainingAttendanceNotifierProvider);

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
                        _buildSessionInfo(context),
                        const SizedBox(height: 24),
                        if (currentUser != null) ...[
                          _buildPlayerAttendance(context, currentUser.userId),
                          const SizedBox(height: 24),
                        ],
                        _buildAttendanceStats(context),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildSessionInfo(BuildContext context) {
    final dateFormat = DateFormat('EEEE, MMMM d, yyyy');
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
                  'Session Information',
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
              label: 'Date',
              value: dateFormat.format(_session!.sessionDate),
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              context,
              icon: Icons.access_time,
              label: 'Time',
              value: timeFormat.format(_session!.sessionDate),
            ),
            if (_session!.notes != null && _session!.notes!.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildInfoRow(
                context,
                icon: Icons.notes,
                label: 'Notes',
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

  Widget _buildPlayerAttendance(BuildContext context, String userId) {
    // Find the player corresponding to this user
    final player = _players.where((p) => p.userId == userId).firstOrNull;

    if (player == null) {
      return const SizedBox.shrink();
    }

    final attendanceNotifier =
        ref.read(trainingAttendanceNotifierProvider.notifier);
    final status = attendanceNotifier.getPlayerStatus(player.id);

    return Card(
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
                  'Your Attendance',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildAttendanceStatus(context, status),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceStatus(
      BuildContext context, AttendanceStatus? status) {
    final l10n = AppLocalizations.of(context)!;
    IconData icon;
    String label;
    Color color;

    if (status == null) {
      icon = Icons.help_outline;
      label = 'Not marked';
      color = Theme.of(context).colorScheme.onSurfaceVariant;
    } else {
      switch (status) {
        case AttendanceStatus.onTime:
          icon = Icons.check_circle;
          label = l10n.onTime;
          color = Colors.green;
          break;
        case AttendanceStatus.late:
          icon = Icons.schedule;
          label = l10n.late;
          color = Colors.orange;
          break;
        case AttendanceStatus.absent:
          icon = Icons.cancel;
          label = l10n.absent;
          color = Colors.red;
          break;
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(width: 12),
          Text(
            label,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceStats(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final stats = _getAttendanceStats();

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
                  'Attendance Summary',
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
                  child: _buildStatItem(
                    context,
                    icon: Icons.check_circle,
                    label: l10n.onTime,
                    value: stats['onTime']!,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatItem(
                    context,
                    icon: Icons.schedule,
                    label: l10n.late,
                    value: stats['late']!,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    context,
                    icon: Icons.cancel,
                    label: l10n.absent,
                    value: stats['absent']!,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatItem(
                    context,
                    icon: Icons.help_outline,
                    label: 'Not Marked',
                    value: stats['notMarked']!,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required int value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value.toString(),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
