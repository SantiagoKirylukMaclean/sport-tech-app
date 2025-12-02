// lib/presentation/matches/pages/match_lineup_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport_tech_app/application/matches/match_lineup_notifier.dart';
import 'package:sport_tech_app/presentation/matches/widgets/convocatoria_section.dart';
import 'package:sport_tech_app/presentation/matches/widgets/lineup_section.dart';
import 'package:sport_tech_app/presentation/matches/widgets/quarter_results_section.dart';

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
      ref.read(matchLineupNotifierProvider(widget.matchId).notifier).loadMatchData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(matchLineupNotifierProvider(widget.matchId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Match Lineup'),
        actions: [
          if (state.hasMinimumCallUps)
            PopupMenuButton<int>(
              initialValue: state.currentQuarter,
              tooltip: 'Select Quarter',
              icon: Badge(
                label: Text('Q${state.currentQuarter}'),
                child: const Icon(Icons.filter_list),
              ),
              itemBuilder: (context) => [
                for (int i = 1; i <= 4; i++)
                  PopupMenuItem(
                    value: i,
                    child: Text('Quarter $i'),
                    onTap: () {
                      ref
                          .read(matchLineupNotifierProvider(widget.matchId).notifier)
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
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
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
                              .read(matchLineupNotifierProvider(widget.matchId).notifier)
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

                        // Lineup Section
                        LineupSection(matchId: widget.matchId),

                        const Divider(height: 32),

                        // Quarter Results Section
                        QuarterResultsSection(matchId: widget.matchId),
                      ],
                    ],
                  ),
                ),
    );
  }
}
