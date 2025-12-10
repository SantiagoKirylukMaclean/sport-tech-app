// lib/presentation/org/pages/team_players_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport_tech_app/application/org/players_notifier.dart';
import 'package:sport_tech_app/domain/org/entities/player.dart';
import 'package:sport_tech_app/domain/org/entities/pending_invite.dart';
import 'package:sport_tech_app/domain/org/entities/player_invite_status.dart';
import 'package:sport_tech_app/domain/org/utils/player_invite_utils.dart';
import 'package:sport_tech_app/presentation/org/widgets/player_form_dialog.dart';
import 'package:sport_tech_app/presentation/org/widgets/invite_player_dialog.dart';
import 'package:sport_tech_app/presentation/org/widgets/assign_credentials_dialog.dart';
import 'package:sport_tech_app/presentation/org/widgets/user_credentials_dialog.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sport_tech_app/l10n/app_localizations.dart';

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
                          pendingInvites: playersState.pendingInvites,
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
              SnackBar(content: Text(AppLocalizations.of(context)!.playerAddedSuccessfully)),
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
  final List<PendingInvite> pendingInvites;

  const _PlayerListItem({
    required this.player,
    required this.positions,
    required this.teamId,
    required this.pendingInvites,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Determine player invite status
    final inviteStatus = PlayerInviteUtils.getPlayerStatus(player, pendingInvites);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(
            player.jerseyNumber?.toString() ?? '?',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        title: Row(
          children: [
            Expanded(child: Text(player.fullName)),
            const SizedBox(width: 8),
            _buildStatusBadge(inviteStatus, context, ref),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Show "Assign Credentials" button if player doesn't have a user account
            if (player.userId == null)
              IconButton(
                icon: const Icon(Icons.key),
                tooltip: 'Asignar Credenciales',
                color: Colors.blue,
                onPressed: () => _showAssignCredentialsDialog(context, ref),
              ),
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

  Widget _buildStatusBadge(PlayerInviteStatus status, BuildContext context, WidgetRef ref) {
    Color backgroundColor;
    Color textColor;
    IconData icon;

    switch (status) {
      case PlayerInviteStatus.accepted:
        backgroundColor = Colors.green.shade100;
        textColor = Colors.green.shade800;
        icon = Icons.check_circle;
        break;
      case PlayerInviteStatus.invited:
        backgroundColor = Colors.orange.shade100;
        textColor = Colors.orange.shade800;
        icon = Icons.mail_outline;
        break;
      case PlayerInviteStatus.noInvite:
        backgroundColor = Colors.grey.shade200;
        textColor = Colors.grey.shade700;
        icon = Icons.person_outline;
        break;
    }

    // Make badge clickable only if player has an account (accepted status)
    final isClickable = status == PlayerInviteStatus.accepted && player.userId != null;

    return InkWell(
      onTap: isClickable ? () => _showUserCredentialsDialog(context, ref) : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: isClickable ? Border.all(color: textColor.withValues(alpha: 0.3), width: 1.5) : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: textColor),
            const SizedBox(width: 4),
            Text(
              status.shortLabel,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            if (isClickable) ...[
              const SizedBox(width: 4),
              Icon(Icons.settings, size: 12, color: textColor),
            ],
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
              SnackBar(content: Text(AppLocalizations.of(context)!.playerUpdatedSuccessfully)),
            );
          }
        },
      ),
    );
  }

  void _showAssignCredentialsDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AssignCredentialsDialog(
        playerName: player.fullName,
        onAssign: (email, password) async {
          // Show loading
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Row(
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 16),
                    Text('Creando cuenta...'),
                  ],
                ),
                duration: Duration(seconds: 30),
              ),
            );
          }

          final success = await ref
              .read(playersNotifierProvider.notifier)
              .assignCredentials(
                playerId: player.id,
                email: email,
                password: password,
              );

          if (context.mounted) {
            // Remove loading snackbar
            ScaffoldMessenger.of(context).removeCurrentSnackBar();

            if (success) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Cuenta creada para ${player.fullName}'),
                  backgroundColor: Colors.green,
                ),
              );
            } else {
              // Error is already shown by the notifier
              throw Exception('Failed to assign credentials');
            }
          }
        },
      ),
    );
  }

  void _showUserCredentialsDialog(BuildContext context, WidgetRef ref) {
    if (player.userId == null) return;

    final supabase = Supabase.instance.client;

    // Show credentials dialog with player's email
    showDialog(
      context: context,
      builder: (context) => UserCredentialsDialog(
        playerName: player.fullName,
        email: player.email ?? 'No disponible',
        onChangePassword: (newPassword) async {
          // Call edge function to change password
          final result = await supabase.functions.invoke(
            'change-player-password',
            body: {
              'userId': player.userId,
              'newPassword': newPassword,
            },
          );

          if (result.status != 200) {
            final errorData = result.data as Map<String, dynamic>?;
            throw Exception(errorData?['error'] ?? 'Error al cambiar contraseña');
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
