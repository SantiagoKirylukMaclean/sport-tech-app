import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../application/org/active_team_notifier.dart';
import '../../../application/trainings/trainings_providers.dart';
import '../../../domain/trainings/entities/training_session.dart';
import '../widgets/training_session_form_dialog.dart';

class TrainingsPage extends ConsumerStatefulWidget {
  const TrainingsPage({super.key});

  @override
  ConsumerState<TrainingsPage> createState() => _TrainingsPageState();
}

class _TrainingsPageState extends ConsumerState<TrainingsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSessions();
    });
  }

  void _loadSessions() {
    final activeTeam = ref.read(activeTeamNotifierProvider).activeTeam;
    if (activeTeam != null) {
      ref
          .read(trainingSessionsNotifierProvider.notifier)
          .loadSessions(activeTeam.id);
    }
  }

  Future<void> _showSessionDialog([TrainingSession? session]) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => TrainingSessionFormDialog(session: session),
    );

    if (result != null && mounted) {
      final activeTeam = ref.read(activeTeamNotifierProvider).activeTeam;
      if (activeTeam == null) return;

      try {
        if (session == null) {
          // Create new session
          await ref.read(trainingSessionsNotifierProvider.notifier).createSession(
                teamId: activeTeam.id,
                sessionDate: result['sessionDate'] as DateTime,
                notes: result['notes'] as String?,
              );
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Training session created')),
            );
          }
        } else {
          // Update existing session
          final updatedSession = session.copyWith(
            sessionDate: result['sessionDate'] as DateTime,
            notes: result['notes'] as String?,
          );
          await ref
              .read(trainingSessionsNotifierProvider.notifier)
              .updateSession(updatedSession);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Training session updated')),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }

  Future<void> _deleteSession(TrainingSession session) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Session'),
        content: const Text('Are you sure you want to delete this training session?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await ref
            .read(trainingSessionsNotifierProvider.notifier)
            .deleteSession(session.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Training session deleted')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }

  void _navigateToAttendance(TrainingSession session) {
    context.push('/trainings/${session.id}/attendance');
  }

  @override
  Widget build(BuildContext context) {
    final activeTeam = ref.watch(activeTeamNotifierProvider).activeTeam;
    final state = ref.watch(trainingSessionsNotifierProvider);

    if (activeTeam == null) {
      return const Scaffold(
        body: Center(
          child: Text('Please select a team first'),
        ),
      );
    }

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async => _loadSessions(),
        child: Column(
          children: [
            if (state.sessions.isNotEmpty) _buildStatsHeader(context, state.sessions),
            Expanded(
              child: state.isLoading && state.sessions.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : state.sessions.isEmpty
                      ? _buildEmptyState(context)
                      : _buildSessionsList(context, state.sessions),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showSessionDialog(),
        icon: const Icon(Icons.add),
        label: const Text('New Session'),
      ),
    );
  }

  Widget _buildStatsHeader(BuildContext context, List<TrainingSession> sessions) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              context,
              icon: Icons.fitness_center,
              label: 'Total Sessions',
              value: sessions.length.toString(),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              context,
              icon: Icons.calendar_month,
              label: 'This Month',
              value: _getSessionsThisMonth(sessions).toString(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  int _getSessionsThisMonth(List<TrainingSession> sessions) {
    final now = DateTime.now();
    return sessions.where((session) {
      return session.sessionDate.year == now.year &&
          session.sessionDate.month == now.month;
    }).length;
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.fitness_center,
            size: 80,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 24),
          Text(
            'No Training Sessions',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          const Text('Create your first training session'),
        ],
      ),
    );
  }

  Widget _buildSessionsList(BuildContext context, List<TrainingSession> sessions) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sessions.length,
      itemBuilder: (context, index) {
        final session = sessions[index];
        return _buildSessionCard(context, session);
      },
    );
  }

  Widget _buildSessionCard(BuildContext context, TrainingSession session) {
    final dateFormat = DateFormat('EEEE, MMM d, yyyy');
    final timeFormat = DateFormat('HH:mm');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dateFormat.format(session.sessionDate),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        timeFormat.format(session.sessionDate),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton(
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 20),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 20),
                          SizedBox(width: 8),
                          Text('Delete'),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showSessionDialog(session);
                    } else if (value == 'delete') {
                      _deleteSession(session);
                    }
                  },
                ),
              ],
            ),
            if (session.notes != null && session.notes!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                session.notes!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => _navigateToAttendance(session),
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Manage Attendance'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
