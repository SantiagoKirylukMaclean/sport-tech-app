import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport_tech_app/application/auth/auth_notifier.dart';
import 'package:sport_tech_app/application/auth/auth_state.dart';
import 'package:sport_tech_app/application/org/active_team_notifier.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  @override
  void initState() {
    super.initState();
    // Load teams when dashboard initializes if user is authenticated
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = ref.read(authNotifierProvider);
      if (authState is AuthStateAuthenticated) {
        ref.read(activeTeamNotifierProvider.notifier).loadUserTeams(authState.profile.userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final activeTeamState = ref.watch(activeTeamNotifierProvider);

    return Scaffold(
      body: Center(
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
      ),
    );
  }
}
