// lib/presentation/org/pages/super_admin_clubs_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport_tech_app/application/org/clubs_notifier.dart';
import 'package:sport_tech_app/application/org/sports_notifier.dart';
import 'package:sport_tech_app/domain/org/entities/club.dart';
import 'package:sport_tech_app/domain/org/entities/sport.dart';
import 'package:sport_tech_app/presentation/org/widgets/club_form_dialog.dart';

class SuperAdminClubsPage extends ConsumerStatefulWidget {
  const SuperAdminClubsPage({super.key});

  @override
  ConsumerState<SuperAdminClubsPage> createState() => _SuperAdminClubsPageState();
}

class _SuperAdminClubsPageState extends ConsumerState<SuperAdminClubsPage> {
  Sport? _selectedSport;

  @override
  Widget build(BuildContext context) {
    final sportsState = ref.watch(sportsNotifierProvider);
    final clubsState = ref.watch(clubsNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Clubs Management'),
      ),
      body: sportsState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Sport selector
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: DropdownButtonFormField<Sport>(
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
                      setState(() => _selectedSport = sport);
                      if (sport != null) {
                        ref
                            .read(clubsNotifierProvider.notifier)
                            .loadClubsBySport(sport.id);
                      }
                    },
                  ),
                ),
                // Clubs list
                Expanded(
                  child: _selectedSport == null
                      ? const Center(
                          child: Text('Please select a sport to view clubs'),
                        )
                      : clubsState.isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : clubsState.error != null
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Error: ${clubsState.error}',
                                        style: const TextStyle(color: Colors.red),
                                      ),
                                      const SizedBox(height: 16),
                                      ElevatedButton(
                                        onPressed: () {
                                          ref
                                              .read(clubsNotifierProvider.notifier)
                                              .loadClubsBySport(_selectedSport!.id);
                                        },
                                        child: const Text('Retry'),
                                      ),
                                    ],
                                  ),
                                )
                              : clubsState.clubs.isEmpty
                                  ? const Center(
                                      child: Text(
                                          'No clubs found. Create one to get started!'),
                                    )
                                  : ListView.builder(
                                      padding: const EdgeInsets.all(16),
                                      itemCount: clubsState.clubs.length,
                                      itemBuilder: (context, index) {
                                        final club = clubsState.clubs[index];
                                        return _ClubListItem(club: club);
                                      },
                                    ),
                ),
              ],
            ),
      floatingActionButton: _selectedSport != null
          ? FloatingActionButton.extended(
              onPressed: () => _showCreateDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Create Club'),
            )
          : null,
    );
  }

  void _showCreateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => ClubFormDialog(
        onSubmit: (name) async {
          final success = await ref
              .read(clubsNotifierProvider.notifier)
              .createClub(_selectedSport!.id, name);

          if (success && context.mounted) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Club created successfully')),
            );
          }
        },
      ),
    );
  }
}

class _ClubListItem extends ConsumerWidget {
  final Club club;

  const _ClubListItem({required this.club});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(club.name[0].toUpperCase()),
        ),
        title: Text(club.name),
        subtitle: Text('Created: ${_formatDate(club.createdAt)}'),
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
      builder: (context) => ClubFormDialog(
        initialName: club.name,
        onSubmit: (name) async {
          final success = await ref
              .read(clubsNotifierProvider.notifier)
              .updateClub(club.id, name);

          if (success && context.mounted) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Club updated successfully')),
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
        title: const Text('Delete Club'),
        content: Text('Are you sure you want to delete "${club.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final success = await ref
                  .read(clubsNotifierProvider.notifier)
                  .deleteClub(club.id);

              if (context.mounted) {
                Navigator.of(context).pop();
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Club deleted successfully')),
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
