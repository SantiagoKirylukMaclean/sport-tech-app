import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sport_tech_app/application/auth/auth_notifier.dart';
import 'package:sport_tech_app/application/auth/auth_state.dart';
import 'package:sport_tech_app/application/org/active_team_notifier.dart';
import 'package:sport_tech_app/application/org/clubs_notifier.dart';
import 'package:sport_tech_app/application/org/sports_notifier.dart';
import 'package:sport_tech_app/application/org/teams_notifier.dart';
import 'package:sport_tech_app/core/constants/app_constants.dart';
import 'package:sport_tech_app/domain/org/entities/club.dart';
import 'package:sport_tech_app/domain/org/entities/sport.dart';
import 'package:sport_tech_app/domain/org/entities/team.dart';
import 'package:sport_tech_app/presentation/org/widgets/team_form_dialog.dart';
import 'package:intl/intl.dart';

class AdminTeamsPage extends ConsumerStatefulWidget {
  const AdminTeamsPage({super.key});

  @override
  ConsumerState<AdminTeamsPage> createState() => _AdminTeamsPageState();
}

class _AdminTeamsPageState extends ConsumerState<AdminTeamsPage> {
  Sport? _selectedSport;
  Club? _selectedClub;

  @override
  void initState() {
    super.initState();
    // Redirect coaches to their active team's players page
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = ref.read(authNotifierProvider);
      if (authState is AuthStateAuthenticated && 
          authState.profile.role == UserRole.coach) {
        final activeTeam = ref.read(activeTeamNotifierProvider).activeTeam;
        if (activeTeam != null) {
          // Redirect to players page for the active team
          // We need to get the sport ID for this team
          context.go('/coach-players');
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final sportsState = ref.watch(sportsNotifierProvider);
    final clubsState = ref.watch(clubsNotifierProvider);
    final teamsState = ref.watch(teamsNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de equipos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refrescar',
            onPressed: () {
              if (_selectedClub != null) {
                ref
                    .read(teamsNotifierProvider.notifier)
                    .loadTeamsByClub(_selectedClub!.id);
              }
            },
          ),
        ],
      ),
      body: sportsState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Filtros',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Deporte'),
                                const SizedBox(height: 8),
                                DropdownButtonFormField<Sport>(
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    isDense: true,
                                  ),
                                  hint: const Text('Todos los deportes'),
                                  value: _selectedSport,
                                  items: sportsState.sports
                                      .map(
                                        (sport) => DropdownMenuItem(
                                          value: sport,
                                          child: Text(sport.name),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (sport) {
                                    setState(() {
                                      _selectedSport = sport;
                                      _selectedClub = null;
                                    });
                                    if (sport != null) {
                                      ref
                                          .read(clubsNotifierProvider.notifier)
                                          .loadClubsBySport(sport.id);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Club'),
                                const SizedBox(height: 8),
                                DropdownButtonFormField<Club>(
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    isDense: true,
                                  ),
                                  hint: const Text('Todos los clubes'),
                                  value: _selectedClub,
                                  items: clubsState.clubs
                                      .map(
                                        (club) => DropdownMenuItem(
                                          value: club,
                                          child: Text(club.name),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: _selectedSport == null
                                      ? null
                                      : (club) {
                                          setState(() => _selectedClub = club);
                                          if (club != null) {
                                            ref
                                                .read(teamsNotifierProvider.notifier)
                                                .loadTeamsByClub(club.id);
                                          }
                                        },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Teams table
                Expanded(
                  child: _selectedClub == null
                      ? const Center(
                          child: Text(
                              'Selecciona un deporte y un club para ver los equipos'),
                        )
                      : teamsState.isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : teamsState.error != null
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Error: ${teamsState.error}',
                                        style:
                                            const TextStyle(color: Colors.red),
                                      ),
                                      const SizedBox(height: 16),
                                      ElevatedButton(
                                        onPressed: () {
                                          ref
                                              .read(teamsNotifierProvider
                                                  .notifier)
                                              .loadTeamsByClub(
                                                  _selectedClub!.id);
                                        },
                                        child: const Text('Reintentar'),
                                      ),
                                    ],
                                  ),
                                )
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      child: Text(
                                        'Equipos (${teamsState.teams.length})',
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Expanded(
                                      child: teamsState.teams.isEmpty
                                          ? const Center(
                                              child: Text(
                                                'No se encontraron equipos. ¡Crea uno para comenzar!',
                                              ),
                                            )
                                          : SingleChildScrollView(
                                              padding: const EdgeInsets.all(16),
                                              child: DataTable(
                                                columns: const [
                                                  DataColumn(label: Text('Nombre')),
                                                  DataColumn(label: Text('Club')),
                                                  DataColumn(label: Text('Creado')),
                                                  DataColumn(label: Text('Acciones')),
                                                ],
                                                rows: teamsState.teams.map((team) {
                                                  return DataRow(
                                                    cells: [
                                                      DataCell(Text(team.name)),
                                                      DataCell(Text(_selectedClub?.name ?? '')),
                                                      DataCell(
                                                        Text(
                                                          DateFormat('dd sept yyyy').format(team.createdAt),
                                                        ),
                                                      ),
                                                      DataCell(
                                                        _TeamActions(
                                                          team: team,
                                                          sportId: _selectedSport!.id,
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
                ),
              ],
            ),
      floatingActionButton: _selectedClub != null
          ? FloatingActionButton.extended(
              onPressed: () => _showCreateDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Nuevo equipo'),
            )
          : null,
    );
  }

  void _showCreateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => TeamFormDialog(
        onSubmit: (name) async {
          final success = await ref
              .read(teamsNotifierProvider.notifier)
              .createTeam(_selectedClub!.id, name);

          if (success && context.mounted) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Equipo creado exitosamente')),
            );
          }
        },
      ),
    );
  }
}

class _TeamActions extends ConsumerWidget {
  final Team team;
  final String sportId;

  const _TeamActions({required this.team, required this.sportId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.edit_outlined, size: 20),
          tooltip: 'Editar',
          onPressed: () => _showEditDialog(context, ref),
        ),
        IconButton(
          icon: const Icon(Icons.group_outlined, size: 20),
          tooltip: 'Asignar',
          onPressed: () {
            // Navigate to players page
            context.push('/teams/${team.id}/players?sportId=$sportId');
          },
        ),
        IconButton(
          icon: const Icon(Icons.delete_outline, size: 20),
          tooltip: 'Borrar',
          color: Theme.of(context).colorScheme.error,
          onPressed: () => _showDeleteConfirmation(context, ref),
        ),
      ],
    );
  }

  void _showEditDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => TeamFormDialog(
        initialName: team.name,
        onSubmit: (name) async {
          final success = await ref
              .read(teamsNotifierProvider.notifier)
              .updateTeam(team.id, name);

          if (success && context.mounted) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Equipo actualizado exitosamente')),
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
        title: const Text('Eliminar Equipo'),
        content: Text('¿Estás seguro de que quieres eliminar "${team.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              final success = await ref
                  .read(teamsNotifierProvider.notifier)
                  .deleteTeam(team.id);

              if (context.mounted) {
                Navigator.of(context).pop();
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Equipo eliminado exitosamente')),
                  );
                }
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
