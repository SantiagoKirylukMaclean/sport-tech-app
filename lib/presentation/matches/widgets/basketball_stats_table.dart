import 'package:flutter/material.dart';
import 'package:sport_tech_app/domain/matches/entities/basketball_match_stat.dart';
import 'package:sport_tech_app/domain/matches/entities/match_call_up.dart';
import 'package:sport_tech_app/l10n/app_localizations.dart';

class BasketballStatsTable extends StatefulWidget {
  final List<MatchCallUp> callUps;
  final List<BasketballMatchStat> stats;

  const BasketballStatsTable({
    required this.callUps,
    required this.stats,
    super.key,
  });

  @override
  State<BasketballStatsTable> createState() => _BasketballStatsTableState();
}

class _BasketballStatsTableState extends State<BasketballStatsTable> {
  int _sortColumnIndex = 0;
  bool _isAscending = true;

  void _onSort(int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _isAscending = ascending;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.callUps.isEmpty) {
      return const SizedBox.shrink();
    }

    final l10n = AppLocalizations.of(context)!;

    // Calculate aggregated stats per player
    final Map<String, Map<String, int>> playerStats = {};

    for (final player in widget.callUps) {
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

    for (final stat in widget.stats) {
      if (!playerStats.containsKey(stat.playerId)) {
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

    // Prepare data for sorting
    final List<Map<String, dynamic>> tableData = widget.callUps.map((player) {
      final pStats = playerStats[player.playerId] ?? {};
      return {
        'player': player,
        'name': player.playerName ?? 'Player',
        'number': player.playerJerseyNumber,
        ...pStats,
      };
    }).toList();

    // Sort data
    tableData.sort((a, b) {
      int compareResult = 0;
      switch (_sortColumnIndex) {
        case 0: // Player Name / Number
          // Sort by number first if available, then name
          final numA = a['number'] as int?;
          final numB = b['number'] as int?;
          if (numA != null && numB != null) {
            compareResult = numA.compareTo(numB);
          } else {
            compareResult =
                (a['name'] as String).compareTo(b['name'] as String);
          }
          break;
        case 1: // PTS
          compareResult = (a['PTS'] as int).compareTo(b['PTS'] as int);
          break;
        case 2: // OR
          compareResult = (a['OR'] as int).compareTo(b['OR'] as int);
          break;
        case 3: // DR
          compareResult = (a['DR'] as int).compareTo(b['DR'] as int);
          break;
        case 4: // AST
          compareResult = (a['AST'] as int).compareTo(b['AST'] as int);
          break;
        case 5: // BLK
          compareResult = (a['BLK'] as int).compareTo(b['BLK'] as int);
          break;
        case 6: // STL
          compareResult = (a['STL'] as int).compareTo(b['STL'] as int);
          break;
        case 7: // TO
          compareResult = (a['TO'] as int).compareTo(b['TO'] as int);
          break;
        case 8: // PF
          compareResult = (a['PF'] as int).compareTo(b['PF'] as int);
          break;
      }
      return _isAscending ? compareResult : -compareResult;
    });

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        sortColumnIndex: _sortColumnIndex,
        sortAscending: _isAscending,
        columnSpacing: 20,
        horizontalMargin: 10,
        columns: [
          DataColumn(
            label: Text(l10n.player),
            onSort: _onSort,
          ),
          DataColumn(
            label: const Text('PTS'),
            numeric: true,
            onSort: _onSort,
          ),
          DataColumn(
            label: const Text('OR'),
            numeric: true,
            onSort: _onSort,
          ),
          DataColumn(
            label: const Text('DR'),
            numeric: true,
            onSort: _onSort,
          ),
          DataColumn(
            label: const Text('AST'),
            numeric: true,
            onSort: _onSort,
          ),
          DataColumn(
            label: const Text('BLK'),
            numeric: true,
            onSort: _onSort,
          ),
          DataColumn(
            label: const Text('STL'),
            numeric: true,
            onSort: _onSort,
          ),
          DataColumn(
            label: const Text('TO'),
            numeric: true,
            onSort: _onSort,
          ),
          DataColumn(
            label: const Text('PF'),
            numeric: true,
            onSort: _onSort,
          ),
        ],
        rows: tableData.map((data) {
          final player = data['player'] as MatchCallUp;
          final names = (player.playerName ?? 'Player').split(' ');
          final displayName = names.isNotEmpty
              ? (names.length > 1 ? '${names[0]} ${names[1][0]}.' : names[0])
              : 'Player';

          return DataRow(
            cells: [
              DataCell(
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (player.playerJerseyNumber != null)
                      Container(
                        margin: const EdgeInsets.only(right: 12),
                        child: CircleAvatar(
                          radius: 14,
                          backgroundColor:
                              Theme.of(context).colorScheme.primaryContainer,
                          child: Text(
                            '${player.playerJerseyNumber}',
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      )
                    else
                      const SizedBox(width: 40),
                    Text(
                      displayName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              DataCell(Text('${data['PTS']}')),
              DataCell(Text('${data['OR']}')),
              DataCell(Text('${data['DR']}')),
              DataCell(Text('${data['AST']}')),
              DataCell(Text('${data['BLK']}')),
              DataCell(Text('${data['STL']}')),
              DataCell(Text('${data['TO']}')),
              DataCell(Text('${data['PF']}')),
            ],
          );
        }).toList(),
      ),
    );
  }
}
