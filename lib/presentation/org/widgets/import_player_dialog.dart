// lib/presentation/org/widgets/import_player_dialog.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport_tech_app/application/org/players_notifier.dart';
import 'package:sport_tech_app/domain/org/entities/player.dart';
import 'package:sport_tech_app/domain/org/entities/team.dart';
import 'package:sport_tech_app/infrastructure/org/providers/org_repositories_providers.dart';

class ImportPlayerDialog extends ConsumerStatefulWidget {
  final String currentTeamId;

  const ImportPlayerDialog({
    required this.currentTeamId,
    super.key,
  });

  @override
  ConsumerState<ImportPlayerDialog> createState() => _ImportPlayerDialogState();
}

class _ImportPlayerDialogState extends ConsumerState<ImportPlayerDialog> {
  bool _isLoading = true;
  String? _error;

  List<Team> _teams = [];
  Team? _selectedTeam;

  List<Player> _players = [];
  Player? _selectedPlayer;

  bool _isImporting = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final teamsRepo = ref.read(teamsRepositoryProvider);

      // 1. Get current team to find clubId
      final currentTeamResult =
          await teamsRepo.getTeamById(widget.currentTeamId);

      currentTeamResult.when(
        success: (currentTeam) async {
          // 2. Get all teams for the club
          final teamsResult =
              await teamsRepo.getTeamsByClub(currentTeam.clubId);

          teamsResult.when(
            success: (teams) {
              if (mounted) {
                setState(() {
                  // Filter out current team
                  _teams =
                      teams.where((t) => t.id != widget.currentTeamId).toList();
                  _isLoading = false;
                });
              }
            },
            failure: (f) => _setError(f.message),
          );
        },
        failure: (f) => _setError(f.message),
      );
    } catch (e) {
      _setError(e.toString());
    }
  }

  void _setError(String message) {
    if (mounted) {
      setState(() {
        _error = message;
        _isLoading = false;
      });
    }
  }

  Future<void> _loadPlayers(Team team) async {
    setState(() {
      _selectedTeam = team;
      _players = [];
      _selectedPlayer = null; // Reset selected player
      _isLoading = true; // Show loading while fetching players
    });

    final playersRepo = ref.read(playersRepositoryProvider);
    final result = await playersRepo.getPlayersByTeam(team.id);

    result.when(
      success: (players) {
        if (mounted) {
          setState(() {
            _players = players;
            _isLoading = false;
          });
        }
      },
      failure: (f) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error loading players: ${f.message}')),
          );
          setState(() => _isLoading = false);
        }
      },
    );
  }

  Future<void> _importPlayer() async {
    if (_selectedPlayer == null) return;

    setState(() => _isImporting = true);

    try {
      final success =
          await ref.read(playersNotifierProvider.notifier).importPlayer(
                teamId: widget.currentTeamId,
                sourcePlayer: _selectedPlayer!,
              );

      if (mounted) {
        if (success) {
          Navigator.of(context).pop(true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Jugador importado correctamente'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          setState(() => _isImporting = false);
          // Error is handled in notifier state usually, but let's show generic if needed
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al importar jugador'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isImporting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // We can inject L10n later, for now hardcoded spanish as requested or generic english
    // User asked in Spanish, so I will prioritize keeping it consistent or using l10n if keys exist.
    // Since I don't know if "Import Player" keys exist, I'll use hardcoded strings for now or look up keys.
    // Given the previous files used AppLocalizations, I should try to use it if suitable, but custom strings likely needed.

    return AlertDialog(
      title: const Text('Importar Jugador'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  _error!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            if (_isLoading && _teams.isEmpty)
              const Center(child: CircularProgressIndicator())
            else if (_teams.isEmpty)
              const Text('No existen otros equipos en este club.')
            else ...[
              // Team Selector
              DropdownButtonFormField<Team>(
                decoration: const InputDecoration(
                  labelText: 'Seleccionar Equipo Origen',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.group),
                ),
                value: _selectedTeam,
                items: _teams.map((team) {
                  return DropdownMenuItem(
                    value: team,
                    child: Text(team.name),
                  );
                }).toList(),
                onChanged: (team) {
                  if (team != null) _loadPlayers(team);
                },
              ),

              const SizedBox(height: 16),

              // Player Selector
              if (_selectedTeam != null)
                _isLoading
                    ? const Center(
                        child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(),
                      ))
                    : DropdownButtonFormField<Player>(
                        decoration: const InputDecoration(
                          labelText: 'Seleccionar Jugador',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                        value: _selectedPlayer,
                        items: _players.map((player) {
                          return DropdownMenuItem(
                            value: player,
                            child: Text(
                              '${player.fullName} (${player.jerseyNumber ?? "?"})' +
                                  (player.userId != null
                                      ? ' ✅'
                                      : ''), // Indicate if they have user account
                            ),
                          );
                        }).toList(),
                        onChanged: (player) {
                          setState(() => _selectedPlayer = player);
                        },
                        hint: const Text('elegir jugador...'),
                      ),

              if (_selectedPlayer != null && _selectedPlayer!.userId != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle,
                          color: Colors.green, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        'Este jugador tiene cuenta de usuario vinculada.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green[800],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isImporting ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed:
              (_selectedPlayer == null || _isImporting) ? null : _importPlayer,
          child: _isImporting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Importar'),
        ),
      ],
    );
  }
}
