// lib/presentation/org/pages/invite_player_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport_tech_app/application/auth/auth_notifier.dart';
import 'package:sport_tech_app/application/auth/auth_state.dart';
import 'package:sport_tech_app/application/org/pending_invites_notifier.dart';
import 'package:sport_tech_app/application/org/players_notifier.dart';
import 'package:sport_tech_app/application/org/teams_notifier.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context)!;
    final teamsState = ref.watch(teamsNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.invitePlayer),
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
                                  l10n.createPlayerInvitation,
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            // Email field
                            TextFormField(
                              controller: _emailController,
                              decoration: InputDecoration(
                                labelText: l10n.emailAddress,
                                helperText: l10n.emailAddressDescription,
                                prefixIcon: const Icon(Icons.email_outlined),
                                border: const OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return l10n.emailIsRequired;
                                }
                                if (!value.contains('@')) {
                                  return l10n.enterValidEmail;
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            // Player Name field
                            TextFormField(
                              controller: _playerNameController,
                              decoration: InputDecoration(
                                labelText: l10n.playerName,
                                helperText: l10n.fullNamePlayer,
                                prefixIcon: const Icon(Icons.person_outline),
                                border: const OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return l10n.playerNameIsRequired;
                                }
                                if (value.trim().length < 2) {
                                  return l10n.playerNameMinLength;
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            // Jersey Number field
                            TextFormField(
                              controller: _jerseyNumberController,
                              decoration: InputDecoration(
                                labelText: l10n.jerseyNumber,
                                helperText: l10n.optionalJerseyNumber,
                                prefixIcon: const Icon(Icons.numbers),
                                border: const OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              validator: (value) {
                                if (value != null && value.isNotEmpty) {
                                  final number = int.tryParse(value);
                                  if (number == null || number < 0 || number > 999) {
                                    return l10n.jerseyNumberRange;
                                  }
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            // Team selection
                            if (teamsState.teams.isEmpty)
                              Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Text(l10n.noTeamsAvailableCreateFirst),
                                ),
                              )
                            else
                              DropdownButtonFormField<String>(
                                initialValue: _selectedTeamId,
                                decoration: InputDecoration(
                                  labelText: l10n.team,
                                  helperText: l10n.selectTeamForPlayer,
                                  prefixIcon: const Icon(Icons.groups_outlined),
                                  border: const OutlineInputBorder(),
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
                                    return l10n.pleaseSelectTeam;
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
                                  l10n.howItWorks,
                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                                      ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '• ${l10n.invitationStep1}\n'
                              '• ${l10n.invitationStep2}\n'
                              '• ${l10n.invitationStep3}',
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
                          child: Text(l10n.resetForm),
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
                          label: Text(_isSubmitting ? l10n.creating : l10n.createInvitation),
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
          final l10n = AppLocalizations.of(context)!;
          final error = ref.read(playersNotifierProvider).error;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.failedToCreatePlayer(error ?? "Unknown error")),
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
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.playerCreatedAndInviteSent(_playerNameController.text)),
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
        final l10n = AppLocalizations.of(context)!;
        final error = ref.read(pendingInvitesNotifierProvider).error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.playerCreatedButInviteFailed(error ?? "Unknown error")),
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
