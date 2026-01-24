// lib/presentation/org/pages/users_management_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport_tech_app/application/auth/auth_notifier.dart';
import 'package:sport_tech_app/application/auth/auth_state.dart';
import 'package:sport_tech_app/application/org/user_team_roles_notifier.dart';
import 'package:sport_tech_app/application/org/teams_notifier.dart';
import 'package:sport_tech_app/application/profiles/profiles_notifier.dart';
import 'package:sport_tech_app/domain/org/entities/user_team_role.dart';
import 'package:sport_tech_app/domain/profiles/entities/user_profile.dart';
import 'package:sport_tech_app/core/constants/app_constants.dart';
import 'package:sport_tech_app/domain/org/entities/club.dart';
import 'package:sport_tech_app/domain/org/entities/sport.dart';
import 'package:sport_tech_app/infrastructure/org/providers/org_repositories_providers.dart';
import 'package:intl/intl.dart';

class UsersManagementPage extends ConsumerStatefulWidget {
  const UsersManagementPage({super.key});

  @override
  ConsumerState<UsersManagementPage> createState() =>
      _UsersManagementPageState();
}

class _UsersManagementPageState extends ConsumerState<UsersManagementPage> {
  String _searchQuery = '';
  String _roleFilter = 'all';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(profilesNotifierProvider.notifier).loadAllProfiles();
    });
  }

  @override
  Widget build(BuildContext context) {
    final profilesState = ref.watch(profilesNotifierProvider);

    final filteredProfiles = _filterProfiles(profilesState.profiles);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Usuarios'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(profilesNotifierProvider.notifier).loadAllProfiles();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and filters
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.search),
                      const SizedBox(width: 8),
                      Text(
                        'Filtros y Búsqueda',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Search field
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Buscar por email o nombre',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  // Role filter
                  DropdownButtonFormField<String>(
                    initialValue: _roleFilter,
                    decoration: const InputDecoration(
                      labelText: 'Rol',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'all',
                        child: Text('Todos los roles'),
                      ),
                      DropdownMenuItem(
                        value: 'player',
                        child: Text('Jugador'),
                      ),
                      DropdownMenuItem(
                        value: 'coach',
                        child: Text('Entrenador'),
                      ),
                      DropdownMenuItem(
                        value: 'admin',
                        child: Text('Administrador'),
                      ),
                      DropdownMenuItem(
                        value: 'super_admin',
                        child: Text('Super Admin'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _roleFilter = value;
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          // Users list
          Expanded(
            child: profilesState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : profilesState.error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Error: ${profilesState.error}',
                              style: const TextStyle(color: Colors.red),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                ref
                                    .read(profilesNotifierProvider.notifier)
                                    .loadAllProfiles();
                              },
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : filteredProfiles.isEmpty
                        ? const Center(
                            child: Text('No se encontraron usuarios'),
                          )
                        : SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: DataTable(
                              columns: const [
                                DataColumn(label: Text('Email')),
                                DataColumn(label: Text('Nombre')),
                                DataColumn(label: Text('Rol')),
                                DataColumn(label: Text('Fecha de Registro')),
                                DataColumn(label: Text('Acciones')),
                              ],
                              rows: filteredProfiles.map((profile) {
                                return DataRow(
                                  cells: [
                                    DataCell(Text(profile.userId)),
                                    DataCell(Text(profile.displayName)),
                                    DataCell(
                                        _buildRoleChip(context, profile.role)),
                                    DataCell(
                                      Text(
                                        DateFormat('dd/MM/yyyy')
                                            .format(profile.createdAt),
                                      ),
                                    ),
                                    DataCell(
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit,
                                                size: 20),
                                            onPressed: () => _showEditDialog(
                                                context, profile),
                                            tooltip: 'Editar',
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.lock_reset,
                                                size: 20),
                                            onPressed: () =>
                                                _showResetPasswordDialog(
                                                    context, profile),
                                            tooltip: 'Reset Password',
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  List<UserProfile> _filterProfiles(List<UserProfile> profiles) {
    return profiles.where((profile) {
      // Search filter
      if (_searchQuery.isNotEmpty &&
          !profile.userId.toLowerCase().contains(_searchQuery.toLowerCase()) &&
          !profile.displayName
              .toLowerCase()
              .contains(_searchQuery.toLowerCase())) {
        return false;
      }

      // Role filter
      if (_roleFilter != 'all' && profile.role.value != _roleFilter) {
        return false;
      }

      return true;
    }).toList();
  }

  Widget _buildRoleChip(BuildContext context, UserRole role) {
    Color color;
    String label;

    switch (role) {
      case UserRole.player:
        color = Colors.blue;
        label = 'Player';
        break;
      case UserRole.coach:
        color = Colors.green;
        label = 'Coach';
        break;
      case UserRole.admin:
        color = Colors.orange;
        label = 'Admin';
        break;
      case UserRole.superAdmin:
        color = Colors.red;
        label = 'Super Admin';
        break;
    }

    return Chip(
      label: Text(label),
      backgroundColor: color,
      labelStyle: const TextStyle(color: Colors.white, fontSize: 12),
    );
  }

  void _showEditDialog(BuildContext context, UserProfile profile) {
    showDialog(
      context: context,
      builder: (context) => UserEditDialog(profile: profile),
    );
  }

  void _showResetPasswordDialog(BuildContext context, UserProfile profile) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Password'),
        content: Text(
          '¿Estás seguro de que quieres resetear la contraseña para "${profile.displayName}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              final success = await ref
                  .read(profilesNotifierProvider.notifier)
                  .resetUserPassword(profile.userId);

              if (context.mounted) {
                Navigator.of(context).pop();
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Password reset enviado exitosamente'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}

class UserEditDialog extends ConsumerStatefulWidget {
  final UserProfile profile;

  const UserEditDialog({super.key, required this.profile});

  @override
  ConsumerState<UserEditDialog> createState() => _UserEditDialogState();
}

class _UserEditDialogState extends ConsumerState<UserEditDialog> {
  late String _selectedRole;
  bool _isLoading = true;
  final Set<String> _initialTeamIds = {};
  final Set<String> _selectedTeamIds = {};

  // Context selection
  String? _selectedSportId;
  String? _selectedClubId;
  List<Sport> _sports = [];
  List<Club> _clubs = [];

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.profile.role.value;
    Future.microtask(() => _loadData());
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      // 1. Load user's current roles
      final userRolesNotifier =
          ref.read(userTeamRolesNotifierProvider.notifier);
      await userRolesNotifier.loadRolesByUser(widget.profile.userId);

      // 2. Load available Sports
      final sportsRepo = ref.read(sportsRepositoryProvider);
      final sportsResult = await sportsRepo.getAllSports();

      sportsResult.when(
        success: (sports) => _sports = sports,
        failure: (_) {},
      );

      // 3. Populate initial state from user roles
      final userRoles = ref.read(userTeamRolesNotifierProvider).roles;
      final teamIds = userRoles.map((r) => r.teamId).toSet();
      _initialTeamIds.addAll(teamIds);
      _selectedTeamIds.addAll(teamIds);

      // 4. Try to auto-detect context from first team
      if (teamIds.isNotEmpty) {
        final firstTeamId = teamIds.first;
        final teamsRepo = ref.read(teamsRepositoryProvider);
        final teamResult = await teamsRepo.getTeamById(firstTeamId);

        await teamResult.when(
          success: (team) async {
            // Found team, get its club
            final clubId = team.clubId;
            final clubsRepo = ref.read(clubsRepositoryProvider);
            final clubResult = await clubsRepo.getClubById(clubId);

            await clubResult.when(
              success: (club) async {
                // Found club, set context
                _selectedSportId = club.sportId;
                _selectedClubId = club.id;

                // Reuse logic to load lists
                await _loadClubs(club.sportId);
                await _loadTeamsForClub(club.id);
              },
              failure: (_) {},
            );
          },
          failure: (_) {},
        );
      } else {
        // No teams assigned yet.
        // If we have sports, maybe select first?
        if (_sports.isNotEmpty) {
          _selectedSportId = _sports.first.id;
          await _loadClubs(_selectedSportId!);
        }
      }
    } catch (e) {
      debugPrint('Error loading user edit data: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadClubs(String sportId) async {
    final clubsRepo = ref.read(clubsRepositoryProvider);
    final result = await clubsRepo.getClubsBySport(sportId);

    result.when(
      success: (clubs) {
        setState(() {
          _clubs = clubs;
          // If current selection is invalid, reset
          if (_selectedClubId != null &&
              !clubs.any((c) => c.id == _selectedClubId)) {
            _selectedClubId = null;
            // If we changed sport, teams list should probably clear or change?
            // But we want to keep selected teams visible if they are from other context?
            // Actually, the UI only shows "Available Teams" for the current context.
            // But we persist _selectedTeamIds across context switches.
          }

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
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const AlertDialog(
        content: SizedBox(
            height: 100, child: Center(child: CircularProgressIndicator())),
      );
    }

    final teamsState = ref.watch(teamsNotifierProvider);

    return AlertDialog(
      title: Text('Editar Usuario: ${widget.profile.displayName}'),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Email: ${widget.profile.userId}'),
              const SizedBox(height: 16),
              // Role Dropdown
              DropdownButtonFormField<String>(
                initialValue: _selectedRole,
                decoration: const InputDecoration(
                  labelText: 'Rol',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'player', child: Text('Player')),
                  DropdownMenuItem(value: 'coach', child: Text('Coach')),
                  DropdownMenuItem(value: 'admin', child: Text('Admin')),
                  DropdownMenuItem(
                      value: 'super_admin', child: Text('Super Admin')),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _selectedRole = value);
                },
              ),
              const SizedBox(height: 16),
              Divider(),
              const SizedBox(height: 8),

              // Context Selection
              Text(
                'Seleccionar Contexto',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              // Sport
              DropdownButtonFormField<String>(
                value: _selectedSportId,
                decoration: const InputDecoration(
                  labelText: 'Deporte',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.sports_basketball),
                ),
                items: _sports
                    .map((s) =>
                        DropdownMenuItem(value: s.id, child: Text(s.name)))
                    .toList(),
                onChanged: (val) async {
                  if (val != null && val != _selectedSportId) {
                    setState(() {
                      _selectedSportId = val;
                      _selectedClubId = null;
                    });
                    await _loadClubs(val);
                  }
                },
              ),
              const SizedBox(height: 12),
              // Club
              DropdownButtonFormField<String>(
                value: _selectedClubId,
                decoration: const InputDecoration(
                  labelText: 'Club',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.business),
                ),
                items: _clubs
                    .map((c) =>
                        DropdownMenuItem(value: c.id, child: Text(c.name)))
                    .toList(),
                onChanged: (val) {
                  if (val != null && val != _selectedClubId) {
                    setState(() => _selectedClubId = val);
                    _loadTeamsForClub(val);
                  }
                },
              ),
              const SizedBox(height: 24),

              // Teams List
              Text(
                'Equipos disponibles',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              if (teamsState.teams.isEmpty && _selectedClubId != null)
                const Text('No hay equipos en este club.')
              else if (_selectedClubId == null)
                const Text('Selecciona un club para ver equipos.')
              else
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: SingleChildScrollView(
                    child: Column(
                      children: teamsState.teams.map((team) {
                        final isChecked = _selectedTeamIds.contains(team.id);
                        return CheckboxListTile(
                          title: Text(team.name),
                          value: isChecked,
                          onChanged: (bool? value) {
                            setState(() {
                              if (value == true) {
                                _selectedTeamIds.add(team.id);
                              } else {
                                _selectedTeamIds.remove(team.id);
                              }
                            });
                          },
                          dense: true,
                          controlAffinity: ListTileControlAffinity.leading,
                        );
                      }).toList(),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: _handleSave,
          child: const Text('Guardar'),
        ),
      ],
    );
  }

  Future<void> _handleSave() async {
    setState(() => _isLoading = true);

    // 1. Update Global Role
    if (_selectedRole != widget.profile.role.value) {
      await ref
          .read(profilesNotifierProvider.notifier)
          .updateUserRole(widget.profile.userId, _selectedRole);
    }

    // 2. Handle Team Assignments
    final toAdd = _selectedTeamIds.difference(_initialTeamIds);
    final toRemove = _initialTeamIds.difference(_selectedTeamIds);
    final userRolesNotifier = ref.read(userTeamRolesNotifierProvider.notifier);

    // Map global role to team role (best effort)
    TeamRole teamRole;
    switch (_selectedRole) {
      case 'admin':
      case 'super_admin':
        teamRole = TeamRole.admin;
        break;
      case 'coach':
        teamRole = TeamRole.coach;
        break;
      default:
        teamRole = TeamRole.player;
    }

    // Check if we can assign this role
    bool canAssignToTeams =
        ['admin', 'coach', 'super_admin'].contains(_selectedRole);

    if (canAssignToTeams) {
      for (final teamId in toAdd) {
        await userRolesNotifier.assignRole(
            userId: widget.profile.userId, teamId: teamId, role: teamRole);
      }

      for (final teamId in toRemove) {
        final existingRoles = ref.read(userTeamRolesNotifierProvider).roles;
        // Handle edge case where role might not be found if we reloaded
        final roleRecord =
            existingRoles.where((r) => r.teamId == teamId).firstOrNull;
        if (roleRecord != null) {
          await userRolesNotifier.removeRole(
              userId: widget.profile.userId,
              teamId: teamId,
              role: roleRecord.role);
        }
      }
    } else {
      // If downgrading to Player, remove all team roles
      for (final teamId in _initialTeamIds) {
        final existingRoles = ref.read(userTeamRolesNotifierProvider).roles;
        final roleRecord =
            existingRoles.where((r) => r.teamId == teamId).firstOrNull;

        if (roleRecord != null) {
          await userRolesNotifier.removeRole(
              userId: widget.profile.userId,
              teamId: teamId,
              role: roleRecord.role);
        }
      }
    }

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Usuario actualizado exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}
