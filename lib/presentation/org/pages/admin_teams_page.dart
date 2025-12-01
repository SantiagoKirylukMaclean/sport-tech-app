// lib/presentation/org/pages/admin_teams_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sport_tech_app/application/org/clubs_notifier.dart';
import 'package:sport_tech_app/application/org/sports_notifier.dart';
import 'package:sport_tech_app/application/org/teams_notifier.dart';
import 'package:sport_tech_app/domain/org/entities/club.dart';
import 'package:sport_tech_app/domain/org/entities/sport.dart';
import 'package:sport_tech_app/domain/org/entities/team.dart';
import 'package:sport_tech_app/presentation/org/widgets/team_form_dialog.dart';

class AdminTeamsPage extends ConsumerStatefulWidget {
  const AdminTeamsPage({super.key});

  @override
  ConsumerState<AdminTeamsPage> createState() => _AdminTeamsPageState();
}

class _AdminTeamsPageState extends ConsumerState<AdminTeamsPage> {
  Sport? _selectedSport;
  Club? _selectedClub;

  @override
  Widget build(BuildContext context) {
    final sportsState = ref.watch(sportsNotifierProvider);
    final clubsState = ref.watch(clubsNotifierProvider);
    final teamsState = ref.watch(teamsNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Teams Management'),
      ),
      body: sportsState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Sport selector
                      DropdownButtonFormField<Sport>(
                        decoration: const InputDecoration(
                          labelText: 'Select Sport',
                          border: OutlineInputBorder(),
                        ),
                        value: _selectedSport,
                        items: sportsState.sports
                            .map((sport) => DropdownMenuItem(
                                  value: sport,
                                  child: Text(sport.name),
                                ))
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
                      const SizedBox(height: 16),
                      // Club selector
                      DropdownButtonFormField<Club>(
                        decoration: const InputDecoration(
                          labelText: 'Select Club',
                          border: OutlineInputBorder(),
                        ),
                        value: _selectedClub,
                        items: clubsState.clubs
                            .map((club) => DropdownMenuItem(
                                  value: club,
                                  child: Text(club.name),
                                ))
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
                // Teams list
                Expanded(
                  child: _selectedClub == null
                      ? const Center(
                          child: Text('Please select a sport and club to view teams'),
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
                                        style: const TextStyle(color: Colors.red),
                                      ),
                                      const SizedBox(height: 16),
                                      ElevatedButton(
                                        onPressed: () {
                                          ref
                                              .read(teamsNotifierProvider.notifier)
                                              .loadTeamsByClub(_selectedClub!.id);
                                        },
                                        child: const Text('Retry'),
                                      ),
                                    ],
                                  ),
                                )
                              : teamsState.teams.isEmpty
                                  ? const Center(
                                      child: Text(
                                          'No teams found. Create one to get started!'),
                                    )
                                  : ListView.builder(
                                      padding: const EdgeInsets.all(16),
                                      itemCount: teamsState.teams.length,
                                      itemBuilder: (context, index) {
                                        final team = teamsState.teams[index];
                                        return _TeamListItem(
                                          team: team,
                                          sportId: _selectedSport!.id,
                                        );
                                      },
                                    ),
                ),
              ],
            ),
      floatingActionButton: _selectedClub != null
          ? FloatingActionButton.extended(
              onPressed: () => _showCreateDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Create Team'),
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
              const SnackBar(content: Text('Team created successfully')),
            );
          }
        },
      ),
    );
  }
}

class _TeamListItem extends ConsumerWidget {
  final Team team;
  final String sportId;

  const _TeamListItem({required this.team, required this.sportId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(team.name[0].toUpperCase()),
        ),
        title: Text(team.name),
        subtitle: Text('Created: ${_formatDate(team.createdAt)}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.people),
              onPressed: () {
                // Navigate to players page
                context.push('/teams/${team.id}/players?sportId=$sportId');
              },
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
              const SnackBar(content: Text('Team updated successfully')),
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
        title: const Text('Delete Team'),
        content: Text('Are you sure you want to delete "${team.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
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
                    const SnackBar(content: Text('Team deleted successfully')),
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
