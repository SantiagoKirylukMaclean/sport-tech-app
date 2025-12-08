import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport_tech_app/application/org/active_team_notifier.dart';
import 'package:sport_tech_app/application/org/players_notifier.dart';
import 'package:sport_tech_app/domain/org/entities/player.dart';
import 'package:sport_tech_app/presentation/org/widgets/player_form_dialog.dart';
import 'package:sport_tech_app/presentation/org/widgets/invite_player_dialog.dart';

class CoachPlayersPage extends ConsumerStatefulWidget {
  const CoachPlayersPage({super.key});

  @override
  ConsumerState<CoachPlayersPage> createState() => _CoachPlayersPageState();
}

class _CoachPlayersPageState extends ConsumerState<CoachPlayersPage> {
  @override
  void initState() {
    super.initState();
    // Load players when page initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final activeTeam = ref.read(activeTeamNotifierProvider).activeTeam;
      print('DEBUG CoachPlayersPage: activeTeam = $activeTeam');
      if (activeTeam != null) {
        print('DEBUG CoachPlayersPage: activeTeam.id = "${activeTeam.id}" (type: ${activeTeam.id.runtimeType})');
        print('DEBUG CoachPlayersPage: Loading players for team ID: ${activeTeam.id}');
        // TODO: Get sport ID from team
        // For now, we'll need to fetch this from the team entity or use a default
        ref
            .read(playersNotifierProvider.notifier)
            .loadPlayersByTeam(activeTeam.id, '1'); // Using placeholder sport ID
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final activeTeamState = ref.watch(activeTeamNotifierProvider);
    final activeTeam = activeTeamState.activeTeam;
    final playersState = ref.watch(playersNotifierProvider);

    // Show message if no team is selected
    if (activeTeam == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Players'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.groups,
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
                  'Please select a team from the Dashboard to view players.',
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Players'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            tooltip: 'Invite Player',
            onPressed: () => _showInviteDialog(context, activeTeam.id),
          ),
        ],
      ),
      body: playersState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : playersState.error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Error: ${playersState.error}',
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          ref
                              .read(playersNotifierProvider.notifier)
                              .loadPlayersByTeam(activeTeam.id, '1');
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : playersState.players.isEmpty
                  ? const Center(
                      child: Text('No players found. Add one to get started!'),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: playersState.players.length,
                      itemBuilder: (context, index) {
                        final player = playersState.players[index];
                        return _PlayerListItem(
                          player: player,
                          positions: playersState.positions,
                          teamId: activeTeam.id,
                        );
                      },
                    ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateDialog(context, activeTeam.id),
        icon: const Icon(Icons.add),
        label: const Text('Add Player'),
      ),
    );
  }

  void _showCreateDialog(BuildContext context, String teamId) {
    showDialog(
      context: context,
      builder: (context) => PlayerFormDialog(
        onSubmit: (fullName, jerseyNumber) async {
          final success =
              await ref.read(playersNotifierProvider.notifier).createPlayer(
                    teamId: teamId,
                    fullName: fullName,
                    jerseyNumber: jerseyNumber,
                  );

          if (success && context.mounted) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Player added successfully')),
            );
          }
        },
      ),
    );
  }

  void _showInviteDialog(BuildContext context, String teamId) {
    final positions = ref.read(playersNotifierProvider).positions;

    showDialog(
      context: context,
      builder: (context) => InvitePlayerDialog(
        teamId: teamId,
        positions: positions,
      ),
    );
  }
}

class _PlayerListItem extends ConsumerWidget {
  final Player player;
  final List positions;
  final String teamId;

  const _PlayerListItem({
    required this.player,
    required this.positions,
    required this.teamId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(
            player.jerseyNumber?.toString() ?? '?',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(player.fullName),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _showEditDialog(context, ref),
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              color: Colors.red,
              onPressed: () => _showDeleteConfirmation(context, ref),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => PlayerFormDialog(
        initialFullName: player.fullName,
        initialJerseyNumber: player.jerseyNumber,
        onSubmit: (fullName, jerseyNumber) async {
          final success =
              await ref.read(playersNotifierProvider.notifier).updatePlayer(
                    id: player.id,
                    fullName: fullName,
                    jerseyNumber: jerseyNumber,
                  );

          if (success && context.mounted) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Player updated successfully')),
            );
          }
        },
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Player'),
        content: Text('Are you sure you want to delete "${player.fullName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final success = await ref
                  .read(playersNotifierProvider.notifier)
                  .deletePlayer(player.id);

              if (context.mounted) {
                Navigator.of(context).pop();
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Player deleted successfully'),),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
