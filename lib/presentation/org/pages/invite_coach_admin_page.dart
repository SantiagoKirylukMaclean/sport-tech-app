// lib/presentation/org/pages/invite_coach_admin_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport_tech_app/application/auth/auth_notifier.dart';
import 'package:sport_tech_app/application/org/pending_invites_notifier.dart';
import 'package:sport_tech_app/application/org/teams_notifier.dart';
import 'package:sport_tech_app/domain/org/entities/team.dart';

class InviteCoachAdminPage extends ConsumerStatefulWidget {
  const InviteCoachAdminPage({super.key});

  @override
  ConsumerState<InviteCoachAdminPage> createState() =>
      _InviteCoachAdminPageState();
}

class _InviteCoachAdminPageState extends ConsumerState<InviteCoachAdminPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _displayNameController = TextEditingController();
  String _selectedRole = 'coach';
  final List<String> _selectedTeams = [];
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Load user's teams
    Future.microtask(() {
      final authState = ref.read(authNotifierProvider);
      if (authState.user != null) {
        ref.read(teamsNotifierProvider.notifier).loadTeamsByUser(authState.user!.id);
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final teamsState = ref.watch(teamsNotifierProvider);
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Invitar Entrenador/Admin'),
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
                                  Icons.person_add_outlined,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Crear Invitación',
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
                                helperText: 'The email address of the person you want to invite',
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
                            // Display Name field
                            TextFormField(
                              controller: _displayNameController,
                              decoration: const InputDecoration(
                                labelText: 'Display Name',
                                helperText: 'Optional display name for the user',
                                prefixIcon: Icon(Icons.badge_outlined),
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Role dropdown
                            DropdownButtonFormField<String>(
                              value: _selectedRole,
                              decoration: const InputDecoration(
                                labelText: 'Role *',
                                helperText: 'The role that will be assigned to the user',
                                prefixIcon: Icon(Icons.work_outline),
                                border: OutlineInputBorder(),
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: 'coach',
                                  child: Text('Coach'),
                                ),
                                DropdownMenuItem(
                                  value: 'admin',
                                  child: Text('Admin'),
                                ),
                              ],
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    _selectedRole = value;
                                  });
                                }
                              },
                            ),
                            const SizedBox(height: 16),
                            // Teams selection
                            Text(
                              'Teams *',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Select one or more teams that the user will be assigned to',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.7),
                                  ),
                            ),
                            const SizedBox(height: 8),
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
                              ...teamsState.teams.map((team) {
                                final isSelected = _selectedTeams.contains(team.id);
                                return CheckboxListTile(
                                  title: Text(team.name),
                                  value: isSelected,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      if (value == true) {
                                        _selectedTeams.add(team.id);
                                      } else {
                                        _selectedTeams.remove(team.id);
                                      }
                                    });
                                  },
                                  controlAffinity: ListTileControlAffinity.leading,
                                );
                              }),
                            if (_selectedTeams.isEmpty && teamsState.teams.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  'At least one team must be selected',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Theme.of(context).colorScheme.error,
                                      ),
                                ),
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
                              '• The system generates a one-time recovery link\n'
                              '• Share this link through any communication channel\n'
                              '• When clicked, the invitee sets their password\n'
                              '• They are automatically assigned to the selected teams with the specified role',
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
                          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
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
                              : const Icon(Icons.person_add),
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

    if (_selectedTeams.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one team'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final authState = ref.read(authNotifierProvider);
    if (authState.user == null) {
      setState(() {
        _isSubmitting = false;
      });
      return;
    }

    // Create an invite for each selected team
    bool allSuccessful = true;
    for (final teamId in _selectedTeams) {
      final success = await ref
          .read(pendingInvitesNotifierProvider.notifier)
          .createStaffInvite(
            email: _emailController.text.trim(),
            teamId: teamId,
            role: _selectedRole,
            invitedBy: authState.user!.id,
          );

      if (!success) {
        allSuccessful = false;
        break;
      }
    }

    setState(() {
      _isSubmitting = false;
    });

    if (!mounted) return;

    if (allSuccessful) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invitation(s) created successfully for ${_emailController.text}'),
          backgroundColor: Colors.green,
        ),
      );
      _formKey.currentState!.reset();
      _emailController.clear();
      _displayNameController.clear();
      setState(() {
        _selectedRole = 'coach';
        _selectedTeams.clear();
      });
    } else {
      final error = ref.read(pendingInvitesNotifierProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creating invitation: ${error ?? "Unknown error"}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
