import 'package:flutter/material.dart';
import 'package:sport_tech_app/domain/matches/entities/basketball_match_stat.dart';
import 'package:sport_tech_app/domain/matches/entities/match_call_up.dart';
import 'package:sport_tech_app/l10n/app_localizations.dart';

class BasketballStatsTable extends StatelessWidget {
  final List<MatchCallUp> callUps;
  final List<BasketballMatchStat> stats;

  const BasketballStatsTable({
    super.key,
    required this.callUps,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    if (callUps.isEmpty) {
      return const SizedBox.shrink();
    }

    final l10n = AppLocalizations.of(context)!;

    // Calculate aggregated stats per player
    final Map<String, Map<String, int>> playerStats = {};

    for (final player in callUps) {
      playerStats[player.playerId] = {
        'PTS': 0,
        'OR': 0,
        'DR': 0,
        'AST': 0,
        'BLK': 0,
        'STL': 0, // Steals
        'TO': 0, // Turnovers
        'PF': 0, // Personal Fouls
      };
    }

    for (final stat in stats) {
      if (!playerStats.containsKey(stat.playerId)) {
        // Should ideally not happen if callUps are in sync, but handle safely
        playerStats[stat.playerId] = {
          'PTS': 0,
          'OR': 0,
          'DR': 0,
          'AST': 0,
          'BLK': 0,
          'STL': 0,
          'TO': 0,
          'PF': 0,
        };
      }

      final current = playerStats[stat.playerId]!;

      current['PTS'] = (current['PTS'] ?? 0) + stat.statType.pointsValue;

      switch (stat.statType) {
        case BasketballStatType.reboundOff:
          current['OR'] = (current['OR'] ?? 0) + 1;
          break;
        case BasketballStatType.reboundDef:
          current['DR'] = (current['DR'] ?? 0) + 1;
          break;
        case BasketballStatType.assist:
          current['AST'] = (current['AST'] ?? 0) + 1;
          break;
        case BasketballStatType.block:
          current['BLK'] = (current['BLK'] ?? 0) + 1;
          break;
        case BasketballStatType.steal:
          current['STL'] = (current['STL'] ?? 0) + 1;
          break;
        case BasketballStatType.turnover:
          current['TO'] = (current['TO'] ?? 0) + 1;
          break;
        case BasketballStatType.foul:
          current['PF'] = (current['PF'] ?? 0) + 1;
          break;
        default:
          break;
      }
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints:
            BoxConstraints(minWidth: MediaQuery.of(context).size.width),
        child: DataTable(
          columnSpacing: 10,
          horizontalMargin: 10,
          columns: [
            DataColumn(label: Text(l10n.player)),
            const DataColumn(label: Text('PTS'), numeric: true),
            const DataColumn(label: Text('OR'), numeric: true),
            const DataColumn(label: Text('DR'), numeric: true),
            const DataColumn(label: Text('AST'), numeric: true),
            const DataColumn(label: Text('BLK'), numeric: true),
            const DataColumn(label: Text('STL'), numeric: true),
            const DataColumn(label: Text('TO'), numeric: true),
            const DataColumn(label: Text('PF'), numeric: true),
          ],
          rows: callUps.map((player) {
            final pStats = playerStats[player.playerId] ?? {};
            final names = (player.playerName ?? 'Player').split(' ');
            final displayName = names.isNotEmpty
                ? (names.length > 1 ? '${names[0]} ${names[1][0]}.' : names[0])
                : 'Player';

            final name = player.playerJerseyNumber != null
                ? '#${player.playerJerseyNumber} $displayName'
                : displayName;

            return DataRow(cells: [
              DataCell(Text(name,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 12))),
              DataCell(Text('${pStats['PTS'] ?? 0}')),
              DataCell(Text('${pStats['OR'] ?? 0}')),
              DataCell(Text('${pStats['DR'] ?? 0}')),
              DataCell(Text('${pStats['AST'] ?? 0}')),
              DataCell(Text('${pStats['BLK'] ?? 0}')),
              DataCell(Text('${pStats['STL'] ?? 0}')),
              DataCell(Text('${pStats['TO'] ?? 0}')),
              DataCell(Text('${pStats['PF'] ?? 0}')),
            ]);
          }).toList(),
        ),
      ),
    );
  }
}
