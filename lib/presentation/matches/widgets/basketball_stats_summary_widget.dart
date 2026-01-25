import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport_tech_app/application/matches/match_lineup_notifier.dart';
import 'package:sport_tech_app/domain/matches/entities/basketball_match_stat.dart';

class BasketballStatsSummaryWidget extends ConsumerWidget {
  final String matchId;

  const BasketballStatsSummaryWidget({required this.matchId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(matchLineupNotifierProvider(matchId));
    final notifier = ref.read(matchLineupNotifierProvider(matchId).notifier);

    final stats = state.currentQuarterBasketballStats;

    // Calculate Scores
    final totalTeamScore = state.basketballStats.fold<int>(
      0,
      (sum, stat) => sum + stat.statType.pointsValue,
    );

    final totalRivalScore = state.quarterResults.fold<int>(
      0,
      (sum, result) => sum + result.opponentGoals,
    );

    // Current Quarter Rival Score
    final currentQuarterRivalScore =
        state.currentQuarterResult?.opponentGoals ?? 0;

    return Column(
      children: [
        // Scoreboard Card
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: Theme.of(context).colorScheme.surfaceVariant,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  'MATCH SCORE',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // Team Score
                    Column(
                      children: [
                        Text(
                          'US',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          totalTeamScore.toString(),
                          style: Theme.of(context)
                              .textTheme
                              .displayMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                      ],
                    ),
                    // VS
                    Text(
                      'vs',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: const Color(0xFFE5E5E5),
                          ),
                    ),
                    // Rival Score
                    GestureDetector(
                      onTap: () => _showUpdateRivalScoreDialog(
                        context,
                        ref,
                        currentQuarterRivalScore,
                        state.currentQuarter,
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Text(
                                'RIVAL',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.edit, size: 14),
                            ],
                          ),
                          Text(
                            totalRivalScore.toString(),
                            style: Theme.of(context)
                                .textTheme
                                .displayMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.error,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (state.currentQuarterResult == null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      'Tap Rival score to update Q${state.currentQuarter}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
              ],
            ),
          ),
        ),

        // Stats Log Card
        if (stats.isEmpty)
          const Card(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: Text('No stats recorded for this quarter.'),
              ),
            ),
          )
        else
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.list,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Stats Log (Q${state.currentQuarter})',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: stats.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final stat = stats[index];
                      final player = state.teamPlayers
                          .where((p) => p.id == stat.playerId)
                          .firstOrNull;

                      return ListTile(
                        leading: CircleAvatar(
                          child: Text(
                            player?.jerseyNumber?.toString() ?? '#',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                        title: Text(player?.fullName ?? 'Unknown Player'),
                        subtitle: Text(stat.statType.displayName),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            notifier.deleteBasketballStat(stat.id);
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  void _showUpdateRivalScoreDialog(
    BuildContext context,
    WidgetRef ref,
    int currentScore,
    int quarter,
  ) {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text('Add Rival Points (Q$quarter)'),
        children: [
          SimpleDialogOption(
            onPressed: () => _updateRivalScore(context, ref, currentScore + 1),
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  CircleAvatar(child: Text('1')),
                  SizedBox(width: 16),
                  Text('Free Throw (+1)'),
                ],
              ),
            ),
          ),
          SimpleDialogOption(
            onPressed: () => _updateRivalScore(context, ref, currentScore + 2),
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  CircleAvatar(child: Text('2')),
                  SizedBox(width: 16),
                  Text('Field Goal (+2)'),
                ],
              ),
            ),
          ),
          SimpleDialogOption(
            onPressed: () => _updateRivalScore(context, ref, currentScore + 3),
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  CircleAvatar(child: Text('3')),
                  SizedBox(width: 16),
                  Text('Three Pointer (+3)'),
                ],
              ),
            ),
          ),
          const Divider(),
          SimpleDialogOption(
            onPressed: () {
              Navigator.pop(context);
              _showManualUpdateRivalScoreDialog(
                  context, ref, currentScore, quarter);
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Icon(Icons.edit),
                  SizedBox(width: 16),
                  Text('Manual Correction'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _updateRivalScore(BuildContext context, WidgetRef ref, int newScore) {
    final notifier = ref.read(matchLineupNotifierProvider(matchId).notifier);
    final state = ref.read(matchLineupNotifierProvider(matchId));

    // Calculate team points for this quarter to keep syncing
    final teamPointsQ = state.currentQuarterBasketballStats.fold<int>(
      0,
      (sum, stat) => sum + stat.statType.pointsValue,
    );

    notifier.saveQuarterResult(teamPointsQ, newScore);
    Navigator.pop(context);
  }

  void _showManualUpdateRivalScoreDialog(
    BuildContext context,
    WidgetRef ref,
    int currentScore,
    int quarter,
  ) {
    final controller = TextEditingController(text: currentScore.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Correct Rival Score (Q$quarter)'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: const InputDecoration(
            labelText: 'Total Opponent Points',
            border: OutlineInputBorder(),
            suffixText: 'pts',
            helperText: 'Set the absolute total for this quarter',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final newScore = int.tryParse(controller.text) ?? 0;
              _updateRivalScore(context, ref, newScore);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
