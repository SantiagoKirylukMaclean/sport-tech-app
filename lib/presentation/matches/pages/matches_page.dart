import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sport_tech_app/application/matches/matches_notifier.dart';
import 'package:sport_tech_app/application/matches/matches_state.dart';
import 'package:sport_tech_app/application/org/active_team_notifier.dart';
import 'package:sport_tech_app/presentation/matches/widgets/match_form_dialog.dart';

class MatchesPage extends ConsumerStatefulWidget {
  const MatchesPage({super.key});

  @override
  ConsumerState<MatchesPage> createState() => _MatchesPageState();
}

class _MatchesPageState extends ConsumerState<MatchesPage> {
  @override
  void initState() {
    super.initState();
    // Load matches when team is selected
    Future.microtask(() {
      final activeTeam = ref.read(activeTeamNotifierProvider).activeTeam;
      if (activeTeam != null) {
        ref.read(matchesNotifierProvider(activeTeam.id).notifier).loadMatches();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final activeTeamState = ref.watch(activeTeamNotifierProvider);
    final activeTeam = activeTeamState.activeTeam;

    // Show message if no team is selected
    if (activeTeam == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Matches'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.sports_soccer,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                'No Team Selected',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  'Please select a team from the Dashboard to view and manage matches.',
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final state = ref.watch(matchesNotifierProvider(activeTeam.id));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Matches'),
      ),
      body: switch (state) {
        MatchesStateInitial() || MatchesStateLoading() => const Center(
            child: CircularProgressIndicator(),
          ),
        MatchesStateError(:final message) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  message,
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    ref
                        .read(matchesNotifierProvider(activeTeam.id).notifier)
                        .loadMatches();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        MatchesStateLoaded(:final matches) => matches.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.sports_soccer,
                      size: 80,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'No matches yet',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    const Text('Create your first match using the + button'),
                  ],
                ),
              )
            : RefreshIndicator(
                onRefresh: () async {
                  await ref
                      .read(matchesNotifierProvider(activeTeam.id).notifier)
                      .loadMatches();
                },
                child: ListView.builder(
                  itemCount: matches.length,
                  padding: const EdgeInsets.all(16),
                  itemBuilder: (context, index) {
                    final match = matches[index];
                    final dateFormat = DateFormat('MMM dd, yyyy');

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              Theme.of(context).colorScheme.primaryContainer,
                          child: Icon(
                            Icons.sports_soccer,
                            color:
                                Theme.of(context).colorScheme.onPrimaryContainer,
                          ),
                        ),
                        title: Text(
                          match.opponent,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(dateFormat.format(match.matchDate)),
                            if (match.location != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                match.location!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                              ),
                            ],
                          ],
                        ),
                        trailing: PopupMenuButton(
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              child: const Row(
                                children: [
                                  Icon(Icons.groups),
                                  SizedBox(width: 8),
                                  Text('Manage Lineup'),
                                ],
                              ),
                              onTap: () {
                                Future.delayed(
                                  Duration.zero,
                                  () => context.push('/matches/${match.id}/lineup'),
                                );
                              },
                            ),
                            PopupMenuItem(
                              child: const Row(
                                children: [
                                  Icon(Icons.edit),
                                  SizedBox(width: 8),
                                  Text('Edit'),
                                ],
                              ),
                              onTap: () {
                                Future.delayed(Duration.zero, () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => MatchFormDialog(
                                      teamId: activeTeam.id,
                                      matchToEdit: match,
                                    ),
                                  );
                                });
                              },
                            ),
                            PopupMenuItem(
                              child: const Row(
                                children: [
                                  Icon(Icons.delete, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text(
                                    'Delete',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ],
                              ),
                              onTap: () {
                                Future.delayed(Duration.zero, () {
                                  _showDeleteConfirmation(context, match.id);
                                });
                              },
                            ),
                          ],
                        ),
                        onTap: () {
                          context.push('/matches/${match.id}/lineup');
                        },
                      ),
                    );
                  },
                ),
              ),
      },
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => MatchFormDialog(teamId: activeTeam.id),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('New Match'),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, String matchId) {
    final activeTeam = ref.read(activeTeamNotifierProvider).activeTeam;
    if (activeTeam == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Match'),
        content: const Text(
          'Are you sure you want to delete this match? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              ref
                  .read(matchesNotifierProvider(activeTeam.id).notifier)
                  .deleteMatch(matchId);
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
