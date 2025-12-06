// lib/presentation/org/pages/super_admin_clubs_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport_tech_app/application/org/clubs_notifier.dart';
import 'package:sport_tech_app/application/org/sports_notifier.dart';
import 'package:sport_tech_app/domain/org/entities/club.dart';
import 'package:sport_tech_app/domain/org/entities/sport.dart';
import 'package:sport_tech_app/presentation/org/widgets/club_form_dialog.dart';
import 'package:intl/intl.dart';

class SuperAdminClubsPage extends ConsumerStatefulWidget {
  const SuperAdminClubsPage({super.key});

  @override
  ConsumerState<SuperAdminClubsPage> createState() =>
      _SuperAdminClubsPageState();
}

class _SuperAdminClubsPageState extends ConsumerState<SuperAdminClubsPage> {
  Sport? _selectedSport;

  @override
  Widget build(BuildContext context) {
    final sportsState = ref.watch(sportsNotifierProvider);
    final clubsState = ref.watch(clubsNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Clubes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refrescar',
            onPressed: () {
              if (_selectedSport != null) {
                ref
                    .read(clubsNotifierProvider.notifier)
                    .loadClubsBySport(_selectedSport!.id);
              }
            },
          ),
        ],
      ),
      body: sportsState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Header and filter
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Administración de clubes deportivos (${clubsState.clubs.length} clubes)',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.7),
                            ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Text('Filtrar por deporte:'),
                          const SizedBox(width: 16),
                          SizedBox(
                            width: 300,
                            child: DropdownButtonFormField<Sport>(
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
                                setState(() => _selectedSport = sport);
                                if (sport != null) {
                                  ref
                                      .read(clubsNotifierProvider.notifier)
                                      .loadClubsBySport(sport.id);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Clubs table
                Expanded(
                  child: _selectedSport == null
                      ? const Center(
                          child: Text('Selecciona un deporte para ver los clubes'),
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
                                        style:
                                            const TextStyle(color: Colors.red),
                                      ),
                                      const SizedBox(height: 16),
                                      ElevatedButton(
                                        onPressed: () {
                                          ref
                                              .read(clubsNotifierProvider
                                                  .notifier)
                                              .loadClubsBySport(
                                                  _selectedSport!.id);
                                        },
                                        child: const Text('Reintentar'),
                                      ),
                                    ],
                                  ),
                                )
                              : clubsState.clubs.isEmpty
                                  ? const Center(
                                      child: Text(
                                        'No se encontraron clubes. ¡Crea uno para comenzar!',
                                      ),
                                    )
                                  : SingleChildScrollView(
                                      padding: const EdgeInsets.all(16),
                                      child: DataTable(
                                        columns: const [
                                          DataColumn(label: Text('Nombre')),
                                          DataColumn(label: Text('Deporte')),
                                          DataColumn(label: Text('Creado')),
                                          DataColumn(label: Text('Acciones')),
                                        ],
                                        rows: clubsState.clubs.map((club) {
                                          return DataRow(
                                            cells: [
                                              DataCell(Text(club.name)),
                                              DataCell(Text(_selectedSport?.name ?? '')),
                                              DataCell(
                                                Text(
                                                  DateFormat('dd sept yyyy, HH:mm').format(club.createdAt),
                                                ),
                                              ),
                                              DataCell(
                                                _ClubActions(club: club),
                                              ),
                                            ],
                                          );
                                        }).toList(),
                                      ),
                                    ),
                ),
              ],
            ),
      floatingActionButton: _selectedSport != null
          ? FloatingActionButton.extended(
              onPressed: () => _showCreateDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Nuevo club'),
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
              const SnackBar(content: Text('Club creado exitosamente')),
            );
          }
        },
      ),
    );
  }
}

class _ClubActions extends ConsumerWidget {
  final Club club;

  const _ClubActions({required this.club});

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
          icon: const Icon(Icons.delete_outline, size: 20),
          tooltip: 'Eliminar',
          color: Theme.of(context).colorScheme.error,
          onPressed: () => _showDeleteConfirmation(context, ref),
        ),
      ],
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
              const SnackBar(content: Text('Club actualizado exitosamente')),
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
        title: const Text('Eliminar Club'),
        content: Text('¿Estás seguro de que quieres eliminar "${club.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
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
                    const SnackBar(content: Text('Club eliminado exitosamente')),
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
