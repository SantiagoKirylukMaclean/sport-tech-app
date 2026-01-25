// lib/presentation/matches/pages/match_lineup_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport_tech_app/application/matches/match_lineup_notifier.dart';
import 'package:sport_tech_app/application/org/active_team_notifier.dart';
import 'package:sport_tech_app/presentation/matches/widgets/basketball_court_widget.dart';
import 'package:sport_tech_app/presentation/matches/widgets/basketball_lineup_list_widget.dart';
import 'package:sport_tech_app/presentation/matches/widgets/basketball_stats_summary_widget.dart';
import 'package:sport_tech_app/presentation/matches/widgets/convocatoria_section.dart';
import 'package:sport_tech_app/presentation/matches/widgets/draggable_field_widget.dart';
import 'package:sport_tech_app/presentation/matches/widgets/quarter_results_section.dart';
import 'package:sport_tech_app/presentation/matches/widgets/substitutions_section.dart';

class MatchLineupPage extends ConsumerStatefulWidget {
  final String matchId;

  const MatchLineupPage({required this.matchId, super.key});

  @override
  ConsumerState<MatchLineupPage> createState() => _MatchLineupPageState();
}

class _MatchLineupPageState extends ConsumerState<MatchLineupPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref
          .read(matchLineupNotifierProvider(widget.matchId).notifier)
          .loadMatchData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(matchLineupNotifierProvider(widget.matchId));
    final activeTeam = ref.watch(activeTeamNotifierProvider).activeTeam;
    final isBasketball =
        activeTeam?.sportName?.toLowerCase().contains('bask') == true ||
            activeTeam?.sportName?.toLowerCase().contains('básq') == true ||
            activeTeam?.sportName?.toLowerCase().contains('baloncesto') == true;
    final isPhone = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Match Lineup'),
        actions: [
          if (state.hasMinimumCallUps && isBasketball)
            IconButton(
              icon: Icon(
                Icons.analytics,
                color: state.statsMode ? Colors.orange : null,
              ),
              onPressed: () {
                ref
                    .read(matchLineupNotifierProvider(widget.matchId).notifier)
                    .toggleStatsMode();
              },
              tooltip: state.statsMode ? 'Exit Stats Mode' : 'Enter Stats Mode',
            ),
          if (state.hasMinimumCallUps)
            PopupMenuButton<int>(
              initialValue: state.currentQuarter,
              tooltip: 'Select Quarter',
              icon: Badge(
                label: Text('Q${state.currentQuarter}'),
                child: const Icon(Icons.filter_list),
              ),
              itemBuilder: (context) => [
                for (int i = 1; i <= state.numberOfPeriods; i++)
                  PopupMenuItem(
                    value: i,
                    child: Text('Quarter $i'),
                    onTap: () {
                      ref
                          .read(matchLineupNotifierProvider(widget.matchId)
                              .notifier)
                          .selectQuarter(i);
                    },
                  ),
              ],
            ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        state.error!,
                        style: Theme.of(context).textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          ref
                              .read(matchLineupNotifierProvider(widget.matchId)
                                  .notifier)
                              .loadMatchData();
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      // Convocatoria Section
                      ConvocatoriaSection(matchId: widget.matchId),

                      if (state.hasMinimumCallUps) ...[
                        const Divider(height: 32),

                        // Field Formation (Conditional)
                        if (isBasketball)
                          if (isPhone)
                            BasketballLineupListWidget(matchId: widget.matchId)
                          else
                            BasketballCourtWidget(matchId: widget.matchId)
                        else
                          DraggableFieldWidget(matchId: widget.matchId),

                        const Divider(height: 32),

                        // Substitutions Section
                        SubstitutionsSection(matchId: widget.matchId),

                        const Divider(height: 32),

                        // Quarter Results / Stats Section
                        if (isBasketball)
                          BasketballStatsSummaryWidget(matchId: widget.matchId)
                        else
                          QuarterResultsSection(matchId: widget.matchId),
                      ],
                    ],
                  ),
                ),
    );
  }
}
