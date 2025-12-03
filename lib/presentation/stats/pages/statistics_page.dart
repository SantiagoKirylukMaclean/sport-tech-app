import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sport_tech_app/application/org/active_team_notifier.dart';
import 'package:sport_tech_app/application/stats/stats_providers.dart';
import 'package:sport_tech_app/core/constants/app_constants.dart';
import 'package:sport_tech_app/presentation/stats/widgets/players_tab.dart';
import 'package:sport_tech_app/presentation/stats/widgets/goals_tab.dart';
import 'package:sport_tech_app/presentation/stats/widgets/matches_tab.dart';
import 'package:sport_tech_app/presentation/stats/widgets/quarters_tab.dart';
import 'package:sport_tech_app/presentation/stats/widgets/training_tab.dart';

class StatisticsPage extends ConsumerStatefulWidget {
  const StatisticsPage({super.key});

  @override
  ConsumerState<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends ConsumerState<StatisticsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadStats();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadStats() {
    final activeTeamState = ref.read(activeTeamNotifierProvider);
    if (activeTeamState.activeTeam != null) {
      ref
          .read(statsNotifierProvider.notifier)
          .loadTeamStats(activeTeamState.activeTeam!.id);
    }
  }

  Future<void> _refresh() async {
    final activeTeamState = ref.read(activeTeamNotifierProvider);
    if (activeTeamState.activeTeam != null) {
      await ref
          .read(statsNotifierProvider.notifier)
          .refresh(activeTeamState.activeTeam!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeTeamState = ref.watch(activeTeamNotifierProvider);
    final statsState = ref.watch(statsNotifierProvider);

    if (activeTeamState.activeTeam == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Statistics'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              context.go(AppConstants.coachPanelRoute);
            },
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.warning_outlined,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              const Text(
                'No team selected',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 8),
              const Text(
                'Please select a team from the Dashboard',
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Statistics'),
            Text(
              activeTeamState.activeTeam!.name,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.7),
                  ),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.go(AppConstants.coachPanelRoute);
          },
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Players'),
            Tab(text: 'Goals'),
            Tab(text: 'Matches'),
            Tab(text: 'Quarters'),
            Tab(text: 'Training'),
          ],
        ),
      ),
      body: statsState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : statsState.error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading statistics',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        statsState.error!,
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _refresh,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _refresh,
                  child: TabBarView(
                    controller: _tabController,
                    children: const [
                      PlayersTab(),
                      GoalsTab(),
                      MatchesTab(),
                      QuartersTab(),
                      TrainingTab(),
                    ],
                  ),
                ),
    );
  }
}
