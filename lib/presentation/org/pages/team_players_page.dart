// lib/presentation/org/pages/team_players_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport_tech_app/application/org/players_notifier.dart';
import 'package:sport_tech_app/domain/org/entities/player.dart';
import 'package:sport_tech_app/domain/org/entities/position.dart';
import 'package:sport_tech_app/presentation/org/widgets/player_form_dialog.dart';
import 'package:sport_tech_app/presentation/org/widgets/invite_player_dialog.dart';

class TeamPlayersPage extends ConsumerStatefulWidget {
  final String teamId;
  final String sportId;

  const TeamPlayersPage({
    required this.teamId,
    required this.sportId,
    super.key,
  });

  @override
  ConsumerState<TeamPlayersPage> createState() => _TeamPlayersPageState();
}

class _TeamPlayersPageState extends ConsumerState<TeamPlayersPage> {
  @override
  void initState() {
    super.initState();
    // Load players when page initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(playersNotifierProvider.notifier)
          .loadPlayersByTeam(widget.teamId, widget.sportId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final playersState = ref.watch(playersNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Team Players'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            tooltip: 'Invite Player',
            onPressed: () => _showInviteDialog(context),
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
                              .loadPlayersByTeam(widget.teamId, widget.sportId);
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
                          teamId: widget.teamId,
                        );
                      },
                    ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Player'),
      ),
    );
  }

  void _showCreateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => PlayerFormDialog(
        onSubmit: (fullName, jerseyNumber) async {
          final success =
              await ref.read(playersNotifierProvider.notifier).createPlayer(
                    teamId: widget.teamId,
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

  void _showInviteDialog(BuildContext context) {
    final positions = ref.read(playersNotifierProvider).positions;

    showDialog(
      context: context,
      builder: (context) => InvitePlayerDialog(
        teamId: widget.teamId,
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
                        content: Text('Player deleted successfully')),
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
