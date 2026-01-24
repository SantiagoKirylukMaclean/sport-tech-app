// lib/presentation/org/pages/invite_coach_admin_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport_tech_app/application/auth/auth_notifier.dart';
import 'package:sport_tech_app/application/auth/auth_state.dart';
import 'package:sport_tech_app/application/org/pending_invites_notifier.dart';
import 'package:sport_tech_app/application/org/teams_notifier.dart';
import 'package:sport_tech_app/domain/org/entities/club.dart';
import 'package:sport_tech_app/domain/org/entities/sport.dart';
import 'package:sport_tech_app/infrastructure/org/providers/org_repositories_providers.dart';
import 'package:sport_tech_app/l10n/app_localizations.dart';

class InviteCoachAdminPage extends ConsumerStatefulWidget {
  const InviteCoachAdminPage({super.key});

  @override
  ConsumerState<InviteCoachAdminPage> createState() =>
      _InviteCoachAdminPageState();
}

enum CreationMethod { invite, create }

class _InviteCoachAdminPageState extends ConsumerState<InviteCoachAdminPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _displayNameController = TextEditingController();

  String _selectedRole = 'coach';
  final List<String> _selectedTeams = [];
  bool _isSubmitting = false;
  CreationMethod _creationMethod = CreationMethod.invite;
  bool _obscurePassword = true;

  // Sport and Club selection
  String? _selectedSportId;
  String? _selectedClubId;
  List<Sport> _sports = [];
  List<Club> _clubs = [];
  bool _isLoadingContext = true;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _loadInitialData());
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoadingContext = true);

    final authState = ref.read(authNotifierProvider);
    if (authState is! AuthStateAuthenticated) return;
    final userId = authState.user.id;

    // 1. Load Sports
    final sportsRepo = ref.read(sportsRepositoryProvider);
    final sportsResult = await sportsRepo.getAllSports();

    sportsResult.when(
      success: (sports) {
        if (sports.isNotEmpty) {
          _sports = sports;
        }
      },
      failure: (_) {},
    );

    // 2. Try to auto-detect context from Staff Member
    final staffRepo = ref.read(staffMembersRepositoryProvider);
    final staffResult = await staffRepo.getStaffMembersByUser(userId);

    await staffResult.when(
      success: (staffMembers) async {
        if (staffMembers.isNotEmpty) {
          final teamId = staffMembers.first.teamId;
          final teamRepo = ref.read(teamsRepositoryProvider);
          final teamResult = await teamRepo.getTeamById(teamId);

          await teamResult.when(
            success: (team) async {
              _selectedClubId = team.clubId;

              // Get club to get sport
              final clubsRepo = ref.read(clubsRepositoryProvider);
              final clubResult = await clubsRepo.getClubById(team.clubId);

              clubResult.when(
                success: (club) {
                  _selectedSportId = club.sportId;
                  // Load clubs for this sport
                  _loadClubs(club.sportId);
                  // Load teams for this club
                  _loadTeamsForClub(team.clubId);
                },
                failure: (_) {},
              );
            },
            failure: (_) {},
          );
        } else {
          // Fallback: If no staff context, maybe load first sport clubs if available?
          // Or allow user to select.
          // Try fetching all clubs if no sport selected?
          // For now, if _sports has items, select first and load its clubs?
          if (_sports.isNotEmpty && _selectedSportId == null) {
            _selectedSportId = _sports.first.id;
            await _loadClubs(_selectedSportId!);
          }
        }
      },
      failure: (_) {
        if (_sports.isNotEmpty && _selectedSportId == null) {
          // Try basic fallback
          _selectedSportId = _sports.first.id;
          _loadClubs(_selectedSportId!);
        }
      },
    );

    setState(() => _isLoadingContext = false);
  }

  Future<void> _loadClubs(String sportId) async {
    final clubsRepo = ref.read(clubsRepositoryProvider);
    final result = await clubsRepo.getClubsBySport(sportId);

    result.when(
      success: (clubs) {
        setState(() {
          _clubs = clubs;
          // If selected club is not in list (e.g. sport changed), reset it
          if (_selectedClubId != null &&
              !clubs.any((c) => c.id == _selectedClubId)) {
            _selectedClubId = null;
            // Also clear teams?
            ref.read(teamsNotifierProvider.notifier).clearTeams();
            _selectedTeams.clear();
          }

          // If no club selected and we have clubs, maybe select first?
          if (_selectedClubId == null && clubs.isNotEmpty) {
            _selectedClubId = clubs.first.id;
            _loadTeamsForClub(clubs.first.id);
          }
        });
      },
      failure: (_) {},
    );
  }

  Future<void> _loadTeamsForClub(String clubId) async {
    await ref.read(teamsNotifierProvider.notifier).loadTeamsByClub(clubId);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // We'll use teamsState for teams list loading status,
    // but we have _isLoadingContext for our initial sport/club loading
    final teamsState = ref.watch(teamsNotifierProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.inviteCoachAdmin),
      ),
      body: _isLoadingContext
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
                                  Icons.settings_outlined,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Context Selection',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Sport Dropdown
                            DropdownButtonFormField<String>(
                              value: _selectedSportId,
                              decoration: InputDecoration(
                                labelText: l10n.sport,
                                prefixIcon: const Icon(Icons.sports_basketball),
                                border: const OutlineInputBorder(),
                              ),
                              items: _sports.map((sport) {
                                return DropdownMenuItem(
                                  value: sport.id,
                                  child: Text(sport.name),
                                );
                              }).toList(),
                              onChanged: (value) async {
                                if (value != null &&
                                    value != _selectedSportId) {
                                  setState(() {
                                    _selectedSportId = value;
                                    _selectedClubId = null;
                                  });
                                  await _loadClubs(value);
                                }
                              },
                            ),
                            const SizedBox(height: 16),
                            // Club Dropdown
                            DropdownButtonFormField<String>(
                              value: _selectedClubId,
                              decoration: InputDecoration(
                                labelText: l10n.club,
                                prefixIcon: const Icon(Icons.business),
                                border: const OutlineInputBorder(),
                              ),
                              items: _clubs.map((club) {
                                return DropdownMenuItem(
                                  value: club.id,
                                  child: Text(club.name),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null && value != _selectedClubId) {
                                  setState(() {
                                    _selectedClubId = value;
                                  });
                                  _loadTeamsForClub(value);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

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
                                  l10n.createInvitation,
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Creation Method Toggle
                            Text(
                              l10n.creationMethod,
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            const SizedBox(height: 8),
                            SegmentedButton<CreationMethod>(
                              segments: [
                                ButtonSegment<CreationMethod>(
                                  value: CreationMethod.invite,
                                  label: Text(l10n.sendInviteViaEmail),
                                  icon: const Icon(Icons.email_outlined),
                                ),
                                ButtonSegment<CreationMethod>(
                                  value: CreationMethod.create,
                                  label: Text(l10n.createUserDirectly),
                                  icon: const Icon(
                                      Icons.person_add_alt_1_outlined),
                                ),
                              ],
                              selected: {_creationMethod},
                              onSelectionChanged:
                                  (Set<CreationMethod> newSelection) {
                                setState(() {
                                  _creationMethod = newSelection.first;
                                });
                              },
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

                            // Password field (only visible if creating user directly)
                            if (_creationMethod == CreationMethod.create) ...[
                              TextFormField(
                                controller: _passwordController,
                                decoration: InputDecoration(
                                  labelText: '${l10n.password} *',
                                  prefixIcon: const Icon(Icons.lock_outlined),
                                  border: const OutlineInputBorder(),
                                  suffixIcon: IconButton(
                                    icon: Icon(_obscurePassword
                                        ? Icons.visibility
                                        : Icons.visibility_off),
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                  ),
                                ),
                                obscureText: _obscurePassword,
                                validator: (value) {
                                  if (_creationMethod ==
                                      CreationMethod.create) {
                                    if (value == null || value.isEmpty) {
                                      return l10n.passwordIsRequired;
                                    }
                                    if (value.length < 6) {
                                      return l10n.passwordTooShort;
                                    }
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                            ],

                            // Display Name field
                            TextFormField(
                              controller: _displayNameController,
                              decoration: const InputDecoration(
                                labelText: 'Display Name',
                                helperText:
                                    'Optional display name for the user',
                                prefixIcon: Icon(Icons.badge_outlined),
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Role dropdown
                            DropdownButtonFormField<String>(
                              initialValue: _selectedRole,
                              decoration: const InputDecoration(
                                labelText: 'Role *',
                                helperText:
                                    'The role that will be assigned to the user',
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
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.7),
                                  ),
                            ),
                            const SizedBox(height: 8),
                            if (teamsState.teams.isEmpty)
                              Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Text(
                                    _selectedClubId == null
                                        ? 'Please select a club above to see teams.'
                                        : l10n.noTeamsAvailableCreateFirst,
                                  ),
                                ),
                              )
                            else
                              ...teamsState.teams.map((team) {
                                final isSelected =
                                    _selectedTeams.contains(team.id);
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
                                  controlAffinity:
                                      ListTileControlAffinity.leading,
                                );
                              }),
                            if (_selectedTeams.isEmpty &&
                                teamsState.teams.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  'At least one team must be selected',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color:
                                            Theme.of(context).colorScheme.error,
                                      ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Info card
                    if (_creationMethod == CreationMethod.invite)
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
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimaryContainer,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    l10n.howItWorks,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onPrimaryContainer,
                                        ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '• ${l10n.invitationStep1}\n'
                                '• ${l10n.invitationStep2}\n'
                                '• ${l10n.invitationStep3}',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimaryContainer,
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
                              : () => Navigator.of(context).pop(),
                          child: Text(l10n.resetForm),
                        ),
                        const SizedBox(width: 16),
                        FilledButton.icon(
                          onPressed: _isSubmitting ? null : _handleSubmit,
                          icon: _isSubmitting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Icon(_creationMethod == CreationMethod.create
                                  ? Icons.person_add_alt_1
                                  : Icons.send),
                          label: Text(_isSubmitting
                              ? l10n.creating
                              : (_creationMethod == CreationMethod.create
                                  ? l10n.createUser
                                  : l10n.createInvitation)),
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
    if (authState is! AuthStateAuthenticated) {
      setState(() {
        _isSubmitting = false;
      });
      return;
    }

    final l10n = AppLocalizations.of(context)!;
    bool success = false;
    String? errorMessage;

    if (_creationMethod == CreationMethod.create) {
      // Direct creation logic
      success = await ref
          .read(pendingInvitesNotifierProvider.notifier)
          .createStaffUser(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            teamIds: _selectedTeams.map((id) => int.parse(id)).toList(),
            role: _selectedRole,
            createdBy: authState.user.id,
            displayName: _displayNameController.text.isNotEmpty
                ? _displayNameController.text
                : null,
          );
      if (!success) {
        errorMessage = ref.read(pendingInvitesNotifierProvider).error;
      }
    } else {
      // Invitation logic
      success = await ref
          .read(pendingInvitesNotifierProvider.notifier)
          .createStaffInvite(
            email: _emailController.text.trim(),
            teamIds: _selectedTeams.map((id) => int.parse(id)).toList(),
            role: _selectedRole,
            createdBy: authState.user.id,
            displayName: _displayNameController.text.isNotEmpty
                ? _displayNameController.text
                : null,
          );
      if (!success) {
        errorMessage = ref.read(pendingInvitesNotifierProvider).error;
      }
    }

    setState(() {
      _isSubmitting = false;
    });

    if (!mounted) return;

    if (success) {
      final message = _creationMethod == CreationMethod.create
          ? l10n.userCreatedSuccessfully
          : 'Invitation(s) created successfully for ${_emailController.text}';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
        ),
      );
      _formKey.currentState!.reset();
      _emailController.clear();
      _passwordController.clear();
      _displayNameController.clear();
      setState(() {
        _selectedRole = 'coach';
        _selectedTeams.clear();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${errorMessage ?? "Unknown error"}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
