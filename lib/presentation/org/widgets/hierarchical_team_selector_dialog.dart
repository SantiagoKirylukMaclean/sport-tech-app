import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport_tech_app/application/org/clubs_notifier.dart';
import 'package:sport_tech_app/application/org/sports_notifier.dart';
import 'package:sport_tech_app/application/org/teams_notifier.dart';
import 'package:sport_tech_app/domain/org/entities/club.dart';
import 'package:sport_tech_app/domain/org/entities/sport.dart';
import 'package:sport_tech_app/domain/org/entities/team.dart';
import 'package:sport_tech_app/l10n/app_localizations.dart';

class HierarchicalTeamSelectorDialog extends ConsumerStatefulWidget {
  final Function(Team) onTeamSelected;

  const HierarchicalTeamSelectorDialog({
    required this.onTeamSelected,
    super.key,
  });

  @override
  ConsumerState<HierarchicalTeamSelectorDialog> createState() =>
      _HierarchicalTeamSelectorDialogState();
}

class _HierarchicalTeamSelectorDialogState
    extends ConsumerState<HierarchicalTeamSelectorDialog> {
  Sport? _selectedSport;
  Club? _selectedClub;
  Team? _selectedTeam;

  @override
  void initState() {
    super.initState();
    // Load sports when dialog opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(sportsNotifierProvider.notifier).loadSports();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final sportsState = ref.watch(sportsNotifierProvider);
    final clubsState = ref.watch(clubsNotifierProvider);
    final teamsState = ref.watch(teamsNotifierProvider);

    return AlertDialog(
      title: Text(l10n.selectTeam),
      content: SizedBox(
        width: 400,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sport Selection
              Text(l10n.sport, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 8),
              if (sportsState.isLoading)
                const LinearProgressIndicator()
              else
                DropdownButtonFormField<Sport>(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  hint: Text(l10n.allSports),
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
                      _selectedTeam = null;
                    });
                    if (sport != null) {
                      ref
                          .read(clubsNotifierProvider.notifier)
                          .loadClubsBySport(sport.id);
                    }
                  },
                ),
              const SizedBox(height: 16),

              // Club Selection
              Text(l10n.club, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 8),
              if (clubsState.isLoading)
                const LinearProgressIndicator()
              else
                DropdownButtonFormField<Club>(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  hint: Text(l10n.allClubs),
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
                          setState(() {
                            _selectedClub = club;
                            _selectedTeam = null;
                          });
                          if (club != null) {
                            ref
                                .read(teamsNotifierProvider.notifier)
                                .loadTeamsByClub(club.id);
                          }
                        },
                ),
              const SizedBox(height: 16),

              // Team Selection
              Text(l10n.team, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 8),
              if (teamsState.isLoading)
                const LinearProgressIndicator()
              else
                DropdownButtonFormField<Team>(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  hint: Text(l10n.teams),
                  value: _selectedTeam,
                  items: _selectedClub == null
                      ? []
                      : teamsState.teams
                          .map(
                            (team) => DropdownMenuItem(
                              value: team,
                              child: Text(team.name),
                            ),
                          )
                          .toList(),
                  onChanged: _selectedClub == null
                      ? null
                      : (team) {
                          setState(() {
                            _selectedTeam = team;
                          });
                        },
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        ElevatedButton(
          onPressed: _selectedTeam != null
              ? () {
                  widget.onTeamSelected(_selectedTeam!);
                  Navigator.of(context).pop();
                }
              : null,
          child: Text(l10n.confirm),
        ),
      ],
    );
  }
}
