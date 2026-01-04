import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport_tech_app/l10n/app_localizations.dart';
import 'package:sport_tech_app/application/auth/auth_notifier.dart';
import 'package:sport_tech_app/application/auth/auth_state.dart';
import 'package:sport_tech_app/application/org/active_team_notifier.dart';
import 'package:sport_tech_app/application/stats/stats_providers.dart';
import 'package:sport_tech_app/application/dashboard/player_dashboard_providers.dart';
import 'package:sport_tech_app/core/constants/app_constants.dart';
import 'package:sport_tech_app/presentation/stats/widgets/players_tab.dart';
import 'package:sport_tech_app/presentation/stats/widgets/goals_tab.dart';
import 'package:sport_tech_app/presentation/stats/widgets/quarters_tab.dart';
import 'package:sport_tech_app/presentation/stats/widgets/training_tab.dart';
import 'package:sport_tech_app/presentation/stats/widgets/team_stats_overview.dart';
import 'package:sport_tech_app/presentation/dashboard/widgets/player_dashboard_content.dart';
import 'package:sport_tech_app/presentation/stats/widgets/lineups_tab.dart';

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
        ref
            .read(activeTeamNotifierProvider.notifier)
            .loadUserTeams(authState.profile.userId);
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
    final playerDashboardState = ref.watch(playerDashboardNotifierProvider);

    // Check if user is coach or super admin
    final isCoach = authState is AuthStateAuthenticated &&
        (authState.profile.role == UserRole.coach ||
            authState.profile.role == UserRole.superAdmin);

    // Check if user is player
    final isPlayer = authState is AuthStateAuthenticated &&
        authState.profile.role == UserRole.player;

    // Load player dashboard for players on first build
    if (isPlayer && !_hasLoadedStats) {
      _hasLoadedStats = true;
      final userId = authState.profile.userId;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref
              .read(playerDashboardNotifierProvider.notifier)
              .loadPlayerDashboard(userId);
        }
      });
    }

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

    // Player Dashboard
    if (isPlayer) {
      if (playerDashboardState.isLoading) {
        return const Center(child: CircularProgressIndicator());
      }

      if (playerDashboardState.error != null) {
        final l10n = AppLocalizations.of(context)!;
        return Center(
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
                l10n.errorLoadingStatistics,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                playerDashboardState.error!,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  ref.read(playerDashboardNotifierProvider.notifier).refresh();
                },
                icon: const Icon(Icons.refresh),
                label: Text(l10n.retry),
              ),
            ],
          ),
        );
      }

      if (playerDashboardState.player == null ||
          playerDashboardState.playerStats == null) {
        final l10n = AppLocalizations.of(context)!;
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.person_off,
                size: 64,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.noPlayerData,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.noPlayerRecordFound,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }

      final playerTeamId = playerDashboardState.player?.teamId;
      final teamName = activeTeamState.teams
              .where((t) => t.id == playerTeamId)
              .firstOrNull
              ?.name ??
          '';

      return RefreshIndicator(
        onRefresh: () =>
            ref.read(playerDashboardNotifierProvider.notifier).refresh(),
        child: PlayerDashboardContent(
          playerStats: playerDashboardState.playerStats!,
          teamMatches: playerDashboardState.teamMatches,
          evaluationsCount: playerDashboardState.evaluationsCount,
          teamTrainingAttendance: playerDashboardState.teamTrainingAttendance,
          playerName: playerDashboardState.playerStats!.playerName,
          teamName: teamName,
        ),
      );
    }

    // If user is coach and has an active team, show statistics
    if (isCoach && activeTeamState.activeTeam != null) {
      final l10n = AppLocalizations.of(context)!;
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
                        l10n.errorLoadingStatistics,
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
                        label: Text(l10n.retry),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Stats overview cards
                    TeamStatsOverview(
                      matches: statsState.matches,
                      teamTrainingAttendance: statsState.teamTrainingAttendance,
                    ),
                    // Statistics section with title
                    Container(
                      color: Theme.of(context).colorScheme.surface,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                            child: Text(
                              l10n.statistics,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                          // Tab bar
                          TabBar(
                            controller: _tabController,
                            isScrollable: true,
                            tabs: [
                              Tab(text: l10n.general),
                              Tab(text: l10n.goals),
                              Tab(text: l10n.quarters),
                              Tab(text: l10n.training),
                              Tab(text: l10n.lineup),
                            ],
                          ),
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
                            QuartersTab(),
                            TrainingTab(),
                            LineupsTab(),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
    }

    // Default dashboard for non-coach users or coach without active team
    final l10n = AppLocalizations.of(context)!;
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
              l10n.dashboard,
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 16),
            if (authState is AuthStateAuthenticated) ...[
              Text(
                l10n.welcomeUser(authState.profile.displayName),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.roleUser(authState.profile.role.value),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 32),
              if (activeTeamState.isLoading)
                const CircularProgressIndicator()
              else if (activeTeamState.error != null)
                Text(
                  l10n.errorLoadingTeams(activeTeamState.error!),
                  style: const TextStyle(color: Colors.red),
                )
              else if (activeTeamState.teams.isNotEmpty) ...[
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: activeTeamState.activeTeam?.id,
                      hint: Text(l10n.selectTeam),
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
                    l10n.activeTeam(activeTeamState.activeTeam!.name),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                ],
              ] else
                Text(l10n.noTeamsAssigned),
            ],
          ],
        ),
      ),
    );
  }
}
