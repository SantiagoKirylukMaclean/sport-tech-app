import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../application/org/active_team_notifier.dart';
import '../../../application/trainings/training_attendance_notifier.dart';
import '../../../application/trainings/trainings_providers.dart';
import '../../../domain/org/entities/player.dart';
import '../../../domain/trainings/entities/training_attendance.dart';
import '../../../domain/trainings/entities/training_session.dart';
import '../../../infrastructure/org/providers/org_repositories_providers.dart';

class TrainingAttendancePage extends ConsumerStatefulWidget {
  final String sessionId;

  const TrainingAttendancePage({
    super.key,
    required this.sessionId,
  });

  @override
  ConsumerState<TrainingAttendancePage> createState() =>
      _TrainingAttendancePageState();
}

class _TrainingAttendancePageState
    extends ConsumerState<TrainingAttendancePage> {
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
                SnackBar(content: Text('Error loading players: ${failure.message}')),
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

  Future<void> _updateAttendance(String playerId, AttendanceStatus status) async {
    try {
      await ref
          .read(trainingAttendanceNotifierProvider.notifier)
          .upsertAttendance(
            sessionId: widget.sessionId,
            playerId: playerId,
            status: status,
          );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating attendance: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final attendanceState = ref.watch(trainingAttendanceNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.trainingAttendance),
            if (_session != null)
              Text(
                DateFormat('MMM d, yyyy - HH:mm').format(_session!.sessionDate),
                style: Theme.of(context).textTheme.bodySmall,
              ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _players.isEmpty
              ? Center(
                  child: Text(l10n.noPlayersFoundForTeam),
                )
              : _buildPlayersList(context, attendanceState),
    );
  }

  Widget _buildPlayersList(
      BuildContext context, TrainingAttendanceState attendanceState) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _players.length,
      itemBuilder: (context, index) {
        final player = _players[index];
        final currentStatus = ref
            .read(trainingAttendanceNotifierProvider.notifier)
            .getPlayerStatus(player.id);

        return _buildPlayerCard(context, player, currentStatus);
      },
    );
  }

  Widget _buildPlayerCard(
      BuildContext context, Player player, AttendanceStatus? currentStatus) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  child: Text(
                    player.jerseyNumber?.toString() ?? '?',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    player.fullName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SegmentedButton<AttendanceStatus>(
              segments: [
                ButtonSegment(
                  value: AttendanceStatus.onTime,
                  label: Text(l10n.onTime),
                  icon: const Icon(Icons.check_circle, size: 18),
                ),
                ButtonSegment(
                  value: AttendanceStatus.late,
                  label: Text(l10n.late),
                  icon: const Icon(Icons.schedule, size: 18),
                ),
                ButtonSegment(
                  value: AttendanceStatus.absent,
                  label: Text(l10n.absent),
                  icon: const Icon(Icons.cancel, size: 18),
                ),
              ],
              selected: currentStatus != null ? {currentStatus} : {},
              emptySelectionAllowed: true,
              onSelectionChanged: (Set<AttendanceStatus> newSelection) {
                if (newSelection.isNotEmpty) {
                  _updateAttendance(player.id, newSelection.first);
                }
              },
              style: ButtonStyle(
                visualDensity: VisualDensity.compact,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
