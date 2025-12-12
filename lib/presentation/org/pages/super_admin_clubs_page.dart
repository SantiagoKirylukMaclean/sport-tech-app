// lib/presentation/org/pages/super_admin_clubs_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport_tech_app/application/org/clubs_notifier.dart';
import 'package:sport_tech_app/application/org/sports_notifier.dart';
import 'package:sport_tech_app/domain/org/entities/club.dart';
import 'package:sport_tech_app/domain/org/entities/sport.dart';
import 'package:sport_tech_app/presentation/org/widgets/club_form_dialog.dart';
import 'package:intl/intl.dart';
import 'package:sport_tech_app/l10n/app_localizations.dart';

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
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Administración de clubes deportivos (${clubsState.clubs.length} clubes)',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.7),
                                  ),
                            ),
                          ),
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
                      const SizedBox(height: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Filtrar por deporte:'),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<Sport>(
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            hint: const Text('Todos los deportes'),
                            initialValue: _selectedSport,
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
                                                  .notifier,)
                                              .loadClubsBySport(
                                                  _selectedSport!.id,);
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
                                  : ListView.builder(
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      itemCount: clubsState.clubs.length,
                                      itemBuilder: (context, index) {
                                        final club = clubsState.clubs[index];
                                        return _ClubCard(
                                          club: club,
                                          sportName: _selectedSport?.name ?? '',
                                        );
                                      },
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
        onSubmit: (
          name, {
          primaryColor,
          secondaryColor,
          tertiaryColor,
        }) async {
          final success = await ref
              .read(clubsNotifierProvider.notifier)
              .createClub(
                _selectedSport!.id,
                name,
                primaryColor: primaryColor,
                secondaryColor: secondaryColor,
                tertiaryColor: tertiaryColor,
              );

          if (success && context.mounted) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  AppLocalizations.of(context)!.clubCreatedSuccessfully,
                ),
              ),
            );
          }
        },
      ),
    );
  }
}

class _ClubCard extends ConsumerWidget {
  final Club club;
  final String sportName;

  const _ClubCard({required this.club, required this.sportName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.sports_outlined,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        club.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$sportName • Creado: ${DateFormat('dd MMM yyyy, HH:mm').format(club.createdAt)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.6),
                            ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      tooltip: 'Editar',
                      onPressed: () => _showEditDialog(context, ref),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      tooltip: 'Eliminar',
                      color: Theme.of(context).colorScheme.error,
                      onPressed: () => _showDeleteConfirmation(context, ref),
                    ),
                  ],
                ),
              ],
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
        initialPrimaryColor: club.primaryColor,
        initialSecondaryColor: club.secondaryColor,
        initialTertiaryColor: club.tertiaryColor,
        onSubmit: (
          name, {
          primaryColor,
          secondaryColor,
          tertiaryColor,
        }) async {
          final success = await ref
              .read(clubsNotifierProvider.notifier)
              .updateClub(
                club.id,
                name,
                primaryColor: primaryColor,
                secondaryColor: secondaryColor,
                tertiaryColor: tertiaryColor,
              );

          if (success && context.mounted) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  AppLocalizations.of(context)!.clubUpdatedSuccessfully,
                ),
              ),
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
                    SnackBar(content: Text(AppLocalizations.of(context)!.clubDeletedSuccessfully)),
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
