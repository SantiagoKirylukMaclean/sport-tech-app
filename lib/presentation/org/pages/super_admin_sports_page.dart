// lib/presentation/org/pages/super_admin_sports_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport_tech_app/application/org/sports_notifier.dart';
import 'package:sport_tech_app/domain/org/entities/sport.dart';
import 'package:sport_tech_app/presentation/org/widgets/sport_form_dialog.dart';

class SuperAdminSportsPage extends ConsumerWidget {
  const SuperAdminSportsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sportsState = ref.watch(sportsNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sports Management'),
      ),
      body: sportsState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : sportsState.error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Error: ${sportsState.error}',
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          ref.read(sportsNotifierProvider.notifier).loadSports();
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : sportsState.sports.isEmpty
                  ? const Center(
                      child: Text('No sports found. Create one to get started!'),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: sportsState.sports.length,
                      itemBuilder: (context, index) {
                        final sport = sportsState.sports[index];
                        return _SportListItem(sport: sport);
                      },
                    ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Create Sport'),
      ),
    );
  }

  void _showCreateDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => SportFormDialog(
        onSubmit: (name) async {
          final success = await ref
              .read(sportsNotifierProvider.notifier)
              .createSport(name);

          if (success && context.mounted) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Sport created successfully')),
            );
          }
        },
      ),
    );
  }
}

class _SportListItem extends ConsumerWidget {
  final Sport sport;

  const _SportListItem({required this.sport});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(sport.name[0].toUpperCase()),
        ),
        title: Text(sport.name),
        subtitle: Text('Created: ${_formatDate(sport.createdAt)}'),
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
      builder: (context) => SportFormDialog(
        initialName: sport.name,
        onSubmit: (name) async {
          final success = await ref
              .read(sportsNotifierProvider.notifier)
              .updateSport(sport.id, name);

          if (success && context.mounted) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Sport updated successfully')),
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
        title: const Text('Delete Sport'),
        content: Text('Are you sure you want to delete "${sport.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final success = await ref
                  .read(sportsNotifierProvider.notifier)
                  .deleteSport(sport.id);

              if (context.mounted) {
                Navigator.of(context).pop();
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Sport deleted successfully')),
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
