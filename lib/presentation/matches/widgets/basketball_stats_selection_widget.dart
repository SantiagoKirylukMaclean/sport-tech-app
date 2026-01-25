import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport_tech_app/application/matches/match_lineup_notifier.dart';
import 'package:sport_tech_app/domain/matches/entities/basketball_match_stat.dart';
import 'package:sport_tech_app/domain/org/entities/player.dart';

class BasketballStatsSelectionWidget extends ConsumerWidget {
  final String matchId;
  final Player player;

  const BasketballStatsSelectionWidget({
    required this.matchId,
    required this.player,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              CircleAvatar(
                child: Text(player.jerseyNumber?.toString() ?? '#'),
              ),
              const SizedBox(width: 16),
              Text(
                player.fullName,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildStatSection(
              context,
              'Points',
              [
                BasketballStatType.point1,
                BasketballStatType.point2,
                BasketballStatType.point3,
              ],
              ref),
          const Divider(),
          _buildStatSection(
              context,
              'Rebounds',
              [
                BasketballStatType.reboundOff,
                BasketballStatType.reboundDef,
              ],
              ref),
          const Divider(),
          _buildStatSection(
              context,
              'Play',
              [
                BasketballStatType.assist,
                BasketballStatType.block,
                BasketballStatType.steal,
                BasketballStatType.turnover,
              ],
              ref),
          const Divider(),
          _buildStatSection(
              context,
              'Fouls',
              [
                BasketballStatType.foul,
              ],
              ref),
        ],
      ),
    );
  }

  Widget _buildStatSection(
    BuildContext context,
    String title,
    List<BasketballStatType> types,
    WidgetRef ref,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: types.map((type) {
            return ActionChip(
              label: Text(type.displayName),
              onPressed: () {
                ref
                    .read(matchLineupNotifierProvider(matchId).notifier)
                    .addBasketballStat(player.id, type);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        'Added ${type.displayName} for ${player.fullName}'),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}
