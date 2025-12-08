// lib/presentation/org/widgets/invite_player_dialog.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport_tech_app/application/auth/auth_notifier.dart';
import 'package:sport_tech_app/application/auth/auth_state.dart';
import 'package:sport_tech_app/application/org/pending_invites_notifier.dart';
import 'package:sport_tech_app/application/org/players_notifier.dart';
import 'package:sport_tech_app/domain/org/entities/position.dart';

class InvitePlayerDialog extends ConsumerStatefulWidget {
  final String teamId;
  final List<Position> positions;

  const InvitePlayerDialog({
    required this.teamId,
    required this.positions,
    super.key,
  });

  @override
  ConsumerState<InvitePlayerDialog> createState() => _InvitePlayerDialogState();
}

class _InvitePlayerDialogState extends ConsumerState<InvitePlayerDialog> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  final _jerseyController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _jerseyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Invite Player'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                autofocus: true,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter an email';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Player Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter player name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _jerseyController,
                decoration: const InputDecoration(
                  labelText: 'Jersey Number (Optional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.tag),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(height: 16),
              const Text(
                'Choose how to send the invitation: via email or get a shareable link.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        if (_isSubmitting)
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          )
        else
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'email') {
                _submit(sendEmail: true);
              } else if (value == 'link') {
                _submit(sendEmail: false);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'email',
                child: Row(
                  children: [
                    Icon(Icons.email, size: 20),
                    SizedBox(width: 8),
                    Text('Enviar Email'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'link',
                child: Row(
                  children: [
                    Icon(Icons.link, size: 20),
                    SizedBox(width: 8),
                    Text('Obtener Enlace'),
                  ],
                ),
              ),
            ],
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Send Invite',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_drop_down,
                    size: 20,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _submit({bool sendEmail = true}) async {
    if (!_formKey.currentState!.validate()) return;

    final authState = ref.read(authNotifierProvider);
    if (authState is! AuthStateAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to send invites')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final jerseyNumber = _jerseyController.text.trim().isEmpty
          ? null
          : int.parse(_jerseyController.text.trim());

      // Step 1: Create the player first
      final playerCreated = await ref
          .read(playersNotifierProvider.notifier)
          .createPlayer(
            teamId: widget.teamId,
            fullName: _nameController.text.trim(),
            jerseyNumber: jerseyNumber,
          );

      if (!playerCreated) {
        if (mounted) {
          final error = ref.read(playersNotifierProvider).error;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to create player: ${error ?? "Unknown error"}'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Step 2: Get the created player ID
      final players = ref.read(playersNotifierProvider).players;
      final createdPlayer = players.firstWhere(
        (p) => p.fullName == _nameController.text.trim(),
      );

      // Step 3: Create the invitation linked to the player
      final inviteCreated = await ref
          .read(pendingInvitesNotifierProvider.notifier)
          .createPlayerInvite(
            email: _emailController.text.trim(),
            playerId: int.parse(createdPlayer.id),
            createdBy: authState.user.id,
            displayName: _nameController.text.trim(),
            sendEmail: sendEmail,
          );

      if (inviteCreated && mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              sendEmail
                  ? 'Player created and invitation sent successfully'
                  : 'Player created. Share the invitation link with them.',
            ),
          ),
        );
      } else if (mounted) {
        final error = ref.read(pendingInvitesNotifierProvider).error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Player created but failed to send invite: ${error ?? "Unknown error"}'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}
