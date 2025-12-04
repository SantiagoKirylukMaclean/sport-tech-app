import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport_tech_app/application/auth/auth_notifier.dart';
import 'package:sport_tech_app/application/auth/auth_state.dart';
import 'package:sport_tech_app/application/org/active_team_notifier.dart';
import 'package:sport_tech_app/application/stats/stats_providers.dart';
import 'package:sport_tech_app/core/constants/app_constants.dart';
import 'package:sport_tech_app/presentation/stats/widgets/players_tab.dart';
import 'package:sport_tech_app/presentation/stats/widgets/goals_tab.dart';
import 'package:sport_tech_app/presentation/stats/widgets/matches_tab.dart';
import 'package:sport_tech_app/presentation/stats/widgets/quarters_tab.dart';
import 'package:sport_tech_app/presentation/stats/widgets/training_tab.dart';
import 'package:sport_tech_app/presentation/stats/widgets/team_stats_overview.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _hasLoadedStats = false;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    // Load teams when dashboard initializes if user is authenticated
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = ref.read(authNotifierProvider);
      if (authState is AuthStateAuthenticated) {
        ref.read(activeTeamNotifierProvider.notifier).loadUserTeams(authState.profile.userId);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
    final authState = ref.watch(authNotifierProvider);
    final activeTeamState = ref.watch(activeTeamNotifierProvider);
    final statsState = ref.watch(statsNotifierProvider);

    // Check if user is coach or super admin
    final isCoach = authState is AuthStateAuthenticated &&
        (authState.profile.role == UserRole.coach ||
            authState.profile.role == UserRole.superAdmin);

    // Load stats on first build when we have a team and user is coach
    if (isCoach && !_hasLoadedStats && activeTeamState.activeTeam != null) {
      _hasLoadedStats = true;
      // Use addPostFrameCallback to load after build is complete
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref
              .read(statsNotifierProvider.notifier)
              .loadTeamStats(activeTeamState.activeTeam!.id);
        }
      });
    }

    // If user is coach and has an active team, show statistics
    if (isCoach && activeTeamState.activeTeam != null) {
      return statsState.isLoading
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
              : Column(
                  children: [
                    // Stats overview cards
                    TeamStatsOverview(matches: statsState.matches),
                    // Tab bar
                    Container(
                      color: Theme.of(context).colorScheme.surface,
                      child: TabBar(
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
                    // Tab content
                    Expanded(
                      child: RefreshIndicator(
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
                    ),
                  ],
                );
    }

    // Default dashboard for non-coach users or coach without active team
    return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.dashboard,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                'Dashboard',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 16),
              if (authState is AuthStateAuthenticated) ...[
                Text(
                  'Welcome, ${authState.profile.displayName}!',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Role: ${authState.profile.role.value}',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 32),
                if (activeTeamState.isLoading)
                  const CircularProgressIndicator()
                else if (activeTeamState.error != null)
                  Text(
                    'Error loading teams: ${activeTeamState.error}',
                    style: const TextStyle(color: Colors.red),
                  )
                else if (activeTeamState.teams.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: activeTeamState.activeTeam?.id,
                        hint: const Text('Select Team'),
                        isExpanded: true,
                        items: activeTeamState.teams.map((team) {
                          return DropdownMenuItem<String>(
                            value: team.id,
                            child: Text(
                              team.name,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          );
                        }).toList(),
                        onChanged: (String? teamId) {
                          if (teamId != null) {
                            ref
                                .read(activeTeamNotifierProvider.notifier)
                                .selectTeam(teamId);
                          }
                        },
                      ),
                    ),
                  ),
                  if (activeTeamState.activeTeam != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Active Team: ${activeTeamState.activeTeam!.name}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                  ],
                ] else
                  const Text('No teams assigned.'),
              ],
            ],
          ),
        ),
      );
  }
}
