// lib/presentation/matches/widgets/quarter_results_section.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport_tech_app/application/matches/match_lineup_notifier.dart';

class QuarterResultsSection extends ConsumerStatefulWidget {
  final String matchId;

  const QuarterResultsSection({required this.matchId, super.key});

  @override
  ConsumerState<QuarterResultsSection> createState() => _QuarterResultsSectionState();
}

class _QuarterResultsSectionState extends ConsumerState<QuarterResultsSection> {
  late TextEditingController _teamGoalsController;
  late TextEditingController _opponentGoalsController;

  @override
  void initState() {
    super.initState();
    _teamGoalsController = TextEditingController();
    _opponentGoalsController = TextEditingController();
  }

  @override
  void dispose() {
    _teamGoalsController.dispose();
    _opponentGoalsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(matchLineupNotifierProvider(widget.matchId));
    final notifier = ref.read(matchLineupNotifierProvider(widget.matchId).notifier);

    // Auto-calculate team goals from added goals
    final calculatedTeamGoals = state.currentQuarterGoals.length;
    _teamGoalsController.text = calculatedTeamGoals.toString();

    // Update opponent goals controller when quarter result changes
    if (state.currentQuarterResult != null) {
      _opponentGoalsController.text = state.currentQuarterResult!.opponentGoals.toString();
    } else {
      _opponentGoalsController.text = '0';
    }

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.scoreboard,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Quarter ${state.currentQuarter} Result',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Score inputs
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _teamGoalsController,
                    decoration: const InputDecoration(
                      labelText: 'Team Goals',
                      border: OutlineInputBorder(),
                      helperText: 'Calculated from goals',
                    ),
                    enabled: false,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _opponentGoalsController,
                    decoration: const InputDecoration(
                      labelText: 'Opponent Goals',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  final teamGoals = state.currentQuarterGoals.length;
                  final opponentGoals = int.tryParse(_opponentGoalsController.text) ?? 0;

                  notifier.saveQuarterResult(teamGoals, opponentGoals);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Quarter result saved'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                icon: const Icon(Icons.save),
                label: const Text('Save Result'),
              ),
            ),

            const SizedBox(height: 24),

            // Goals for this quarter
            Row(
              children: [
                const Icon(Icons.sports_soccer, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Goals (${state.currentQuarterGoals.length})',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: state.fieldPlayers.isEmpty
                      ? null
                      : () => _showAddGoalDialog(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Goal'),
                ),
              ],
            ),

            const SizedBox(height: 12),

            if (state.currentQuarterGoals.isEmpty)
              const Text(
                'No goals recorded for this quarter',
                style: TextStyle(fontStyle: FontStyle.italic),
              )
            else
              Column(
                children: state.currentQuarterGoals.map((goal) {
                  final scorer = state.calledUpPlayers
                      .where((p) => p.id == goal.scorerId)
                      .firstOrNull;
                  final assister = goal.assisterId != null
                      ? state.calledUpPlayers
                          .where((p) => p.id == goal.assisterId)
                          .firstOrNull
                      : null;

                  return ListTile(
                    leading: const Icon(Icons.sports_soccer),
                    title: Text(scorer?.fullName ?? 'Unknown Player'),
                    subtitle: assister != null
                        ? Text('Assist: ${assister.fullName}')
                        : null,
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        notifier.deleteGoal(goal.id);
                      },
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  void _showAddGoalDialog(BuildContext context) {
    final state = ref.read(matchLineupNotifierProvider(widget.matchId));
    String? selectedScorerId;
    String? selectedAssisterId;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Goal'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Scorer',
                  border: OutlineInputBorder(),
                ),
                initialValue: selectedScorerId,
                items: state.fieldPlayers.map((player) {
                  return DropdownMenuItem(
                    value: player.id,
                    child: Text('${player.jerseyNumber ?? '?'} - ${player.fullName}'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedScorerId = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Assister (Optional)',
                  border: OutlineInputBorder(),
                ),
                initialValue: selectedAssisterId,
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('None'),
                  ),
                  ...state.fieldPlayers
                      .where((p) => p.id != selectedScorerId)
                      .map((player) {
                    return DropdownMenuItem(
                      value: player.id,
                      child: Text('${player.jerseyNumber ?? '?'} - ${player.fullName}'),
                    );
                  }),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedAssisterId = value;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: selectedScorerId == null
                  ? null
                  : () {
                      ref
                          .read(matchLineupNotifierProvider(widget.matchId).notifier)
                          .addGoal(
                            scorerId: selectedScorerId!,
                            assisterId: selectedAssisterId,
                          );
                      Navigator.pop(context);
                    },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}
