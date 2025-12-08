// lib/presentation/org/pages/invite_player_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport_tech_app/application/auth/auth_notifier.dart';
import 'package:sport_tech_app/application/auth/auth_state.dart';
import 'package:sport_tech_app/application/org/pending_invites_notifier.dart';
import 'package:sport_tech_app/application/org/players_notifier.dart';
import 'package:sport_tech_app/application/org/teams_notifier.dart';

class InvitePlayerPage extends ConsumerStatefulWidget {
  const InvitePlayerPage({super.key});

  @override
  ConsumerState<InvitePlayerPage> createState() => _InvitePlayerPageState();
}

class _InvitePlayerPageState extends ConsumerState<InvitePlayerPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _playerNameController = TextEditingController();
  final _jerseyNumberController = TextEditingController();
  String? _selectedTeamId;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Load user's teams
    Future.microtask(() {
      final authState = ref.read(authNotifierProvider);
      if (authState is AuthStateAuthenticated) {
        ref.read(teamsNotifierProvider.notifier).loadTeamsByUser(authState.user.id);
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _playerNameController.dispose();
    _jerseyNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final teamsState = ref.watch(teamsNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Invitar Jugador'),
      ),
      body: teamsState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.group_add_outlined,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Crear Invitación de Jugador',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            // Email field
                            TextFormField(
                              controller: _emailController,
                              decoration: const InputDecoration(
                                labelText: 'Email Address *',
                                helperText: 'The email address of the player you want to invite',
                                prefixIcon: Icon(Icons.email_outlined),
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Email is required';
                                }
                                if (!value.contains('@')) {
                                  return 'Please enter a valid email';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            // Player Name field
                            TextFormField(
                              controller: _playerNameController,
                              decoration: const InputDecoration(
                                labelText: 'Player Name *',
                                helperText: 'Full name of the player',
                                prefixIcon: Icon(Icons.person_outline),
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Player name is required';
                                }
                                if (value.trim().length < 2) {
                                  return 'Player name must be at least 2 characters';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            // Jersey Number field
                            TextFormField(
                              controller: _jerseyNumberController,
                              decoration: const InputDecoration(
                                labelText: 'Jersey Number',
                                helperText: 'Optional jersey/shirt number',
                                prefixIcon: Icon(Icons.numbers),
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              validator: (value) {
                                if (value != null && value.isNotEmpty) {
                                  final number = int.tryParse(value);
                                  if (number == null || number < 0 || number > 999) {
                                    return 'Jersey number must be between 0 and 999';
                                  }
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            // Team selection
                            if (teamsState.teams.isEmpty)
                              const Card(
                                child: Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Text(
                                    'No teams available. Please create a team first.',
                                  ),
                                ),
                              )
                            else
                              DropdownButtonFormField<String>(
                                initialValue: _selectedTeamId,
                                decoration: const InputDecoration(
                                  labelText: 'Team *',
                                  helperText: 'Select the team for this player',
                                  prefixIcon: Icon(Icons.groups_outlined),
                                  border: OutlineInputBorder(),
                                ),
                                items: teamsState.teams.map((team) {
                                  return DropdownMenuItem(
                                    value: team.id.toString(),
                                    child: Text(team.name),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedTeamId = value;
                                  });
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please select a team';
                                  }
                                  return null;
                                },
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Info card
                    Card(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'How it works:',
                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                                      ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '• A player record is created in the team\n'
                              '• An invitation is sent to the email address\n'
                              '• When the player signs up, their account is linked to the player record\n'
                              '• They can then access their evaluations and team information',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Action buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: _isSubmitting
                              ? null
                              : () {
                                  _formKey.currentState!.reset();
                                  _emailController.clear();
                                  _playerNameController.clear();
                                  _jerseyNumberController.clear();
                                  setState(() {
                                    _selectedTeamId = null;
                                  });
                                },
                          child: const Text('Reset Form'),
                        ),
                        const SizedBox(width: 16),
                        FilledButton.icon(
                          onPressed: _isSubmitting ? null : _handleSubmit,
                          icon: _isSubmitting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.group_add),
                          label: Text(_isSubmitting ? 'Creating...' : 'Create Invitation'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final authState = ref.read(authNotifierProvider);
    if (authState is! AuthStateAuthenticated) {
      setState(() {
        _isSubmitting = false;
      });
      return;
    }

    try {
      final jerseyNumber = _jerseyNumberController.text.isEmpty
          ? null
          : int.tryParse(_jerseyNumberController.text);

      // Step 1: Create the player first
      final playerCreated = await ref
          .read(playersNotifierProvider.notifier)
          .createPlayer(
            teamId: _selectedTeamId!,
            fullName: _playerNameController.text.trim(),
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
        (p) => p.fullName == _playerNameController.text.trim(),
      );

      // Step 3: Create the invitation linked to the player
      final inviteCreated = await ref
          .read(pendingInvitesNotifierProvider.notifier)
          .createPlayerInvite(
            email: _emailController.text.trim(),
            playerId: int.parse(createdPlayer.id),
            createdBy: authState.user.id,
            displayName: _playerNameController.text.trim(),
          );

      if (!mounted) return;

      if (inviteCreated) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Player ${_playerNameController.text} created and invitation sent successfully'),
            backgroundColor: Colors.green,
          ),
        );
        _formKey.currentState!.reset();
        _emailController.clear();
        _playerNameController.clear();
        _jerseyNumberController.clear();
        setState(() {
          _selectedTeamId = null;
        });
      } else {
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
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}
