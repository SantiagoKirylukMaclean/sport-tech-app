// lib/presentation/matches/widgets/quarter_results_section.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport_tech_app/application/matches/match_lineup_notifier.dart';
import 'package:sport_tech_app/l10n/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context)!;
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
                  '${l10n.quarter} ${state.currentQuarter}',
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
                    SnackBar(
                      content: Text(l10n.quarterResultSaved),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                icon: const Icon(Icons.save),
                label: Text(l10n.saveResult),
              ),
            ),

            const SizedBox(height: 24),

            // Goals for this quarter
            Row(
              children: [
                const Icon(Icons.sports_soccer, size: 20),
                const SizedBox(width: 8),
                Text(
                  '${l10n.goals} (${state.currentQuarterGoals.length})',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: state.fieldPlayers.isEmpty
                      ? null
                      : () => _showAddGoalDialog(context),
                  icon: const Icon(Icons.add),
                  label: Text(l10n.addGoal),
                ),
              ],
            ),

            const SizedBox(height: 12),

            if (state.currentQuarterGoals.isEmpty)
              Text(
                l10n.noGoalsRecorded,
                style: const TextStyle(fontStyle: FontStyle.italic),
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
                    leading: Icon(
                      Icons.sports_soccer,
                      color: goal.isOwnGoal ? Colors.orange : null,
                    ),
                    title: Text(
                      goal.isOwnGoal
                          ? l10n.ownGoals
                          : scorer?.fullName ?? l10n.unknownPlayer,
                      style: TextStyle(
                        fontWeight: goal.isOwnGoal ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    subtitle: !goal.isOwnGoal && assister != null
                        ? Text(l10n.assist(assister.fullName))
                        : goal.isOwnGoal
                            ? Text(l10n.ownGoals) // Concept "Gol a favor del equipo"
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
    final l10n = AppLocalizations.of(context)!;
    final state = ref.read(matchLineupNotifierProvider(widget.matchId));
    String? selectedScorerId;
    String? selectedAssisterId;
    bool isOwnGoal = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(l10n.addGoal),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CheckboxListTile(
                  title: Text(l10n.ownGoals),
                  subtitle: Text(l10n.ownGoalDescription),
                  value: isOwnGoal,
                  onChanged: (value) {
                    setState(() {
                      isOwnGoal = value ?? false;
                      // Reset selections when toggling
                      selectedScorerId = null;
                      selectedAssisterId = null;
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                ),
                const SizedBox(height: 16),
                if (!isOwnGoal) ...[
                  // Normal goal - select from our players
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: l10n.scorer,
                      border: const OutlineInputBorder(),
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
                    decoration: InputDecoration(
                      labelText: '${l10n.assists} (${l10n.optional})',
                      border: const OutlineInputBorder(),
                    ),
                    initialValue: selectedAssisterId,
                    items: [
                      DropdownMenuItem(
                        value: null,
                        child: Text(l10n.none),
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
                ] else ...[
                  // Own goal - just pick any player as placeholder (required by DB)
                  // We'll use the first field player
                  if (state.fieldPlayers.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        l10n.ownGoalDescription,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.orange.shade700,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: (!isOwnGoal && selectedScorerId == null) ||
                      (isOwnGoal && state.fieldPlayers.isEmpty)
                  ? null
                  : () {
                      // For own goals, use first field player as placeholder
                      final scorerId = isOwnGoal
                          ? state.fieldPlayers.first.id
                          : selectedScorerId!;

                      ref
                          .read(matchLineupNotifierProvider(widget.matchId).notifier)
                          .addGoal(
                            scorerId: scorerId,
                            assisterId: isOwnGoal ? null : selectedAssisterId,
                            isOwnGoal: isOwnGoal,
                          );
                      Navigator.pop(context);
                    },
              child: Text(l10n.add),
            ),
          ],
        ),
      ),
    );
  }
}
