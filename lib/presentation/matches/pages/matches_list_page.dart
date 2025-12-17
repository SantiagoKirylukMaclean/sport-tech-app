import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sport_tech_app/l10n/app_localizations.dart';
import 'package:sport_tech_app/application/matches/matches_notifier.dart';
import 'package:sport_tech_app/application/matches/matches_state.dart';
import 'package:sport_tech_app/application/org/active_team_notifier.dart';

/// Read-only page showing all played matches with details
class MatchesListPage extends ConsumerStatefulWidget {
  const MatchesListPage({super.key});

  @override
  ConsumerState<MatchesListPage> createState() => _MatchesListPageState();
}

class _MatchesListPageState extends ConsumerState<MatchesListPage> {
  @override
  void initState() {
    super.initState();
    // Load matches when team is selected
    Future.microtask(() {
      final activeTeam = ref.read(activeTeamNotifierProvider).activeTeam;
      if (activeTeam != null) {
        ref.read(matchesNotifierProvider(activeTeam.id).notifier).loadMatches();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final activeTeamState = ref.watch(activeTeamNotifierProvider);
    final activeTeam = activeTeamState.activeTeam;

    // Show message if no team is selected
    if (activeTeam == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Partidos Jugados'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.sports_soccer,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                l10n.noTeamSelected,
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  'Por favor selecciona un equipo para ver los partidos.',
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final state = ref.watch(matchesNotifierProvider(activeTeam.id));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Partidos Jugados'),
      ),
      body: switch (state) {
        MatchesStateInitial() || MatchesStateLoading() => const Center(
            child: CircularProgressIndicator(),
          ),
        MatchesStateError(:final message) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  message,
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    ref
                        .read(matchesNotifierProvider(activeTeam.id).notifier)
                        .loadMatches();
                  },
                  icon: const Icon(Icons.refresh),
                  label: Text(l10n.retry),
                ),
              ],
            ),
          ),
        MatchesStateLoaded(:final matches) => matches.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.sports_soccer,
                      size: 80,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'No hay partidos jugados',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('Los partidos jugados aparecerán aquí'),
                  ],
                ),
              )
            : RefreshIndicator(
                onRefresh: () async {
                  await ref
                      .read(matchesNotifierProvider(activeTeam.id).notifier)
                      .loadMatches();
                },
                child: ListView.builder(
                  itemCount: matches.length,
                  padding: const EdgeInsets.all(16),
                  itemBuilder: (context, index) {
                    final match = matches[index];
                    final dateFormat = DateFormat('dd MMM yyyy', 'es');

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: CircleAvatar(
                          radius: 28,
                          backgroundColor:
                              Theme.of(context).colorScheme.primaryContainer,
                          child: Icon(
                            Icons.sports_soccer,
                            size: 28,
                            color:
                                Theme.of(context).colorScheme.onPrimaryContainer,
                          ),
                        ),
                        title: Text(
                          match.opponent,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  size: 14,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  dateFormat.format(match.matchDate),
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                            if (match.location != null) ...[
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    size: 14,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      match.location!,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                        trailing: Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        onTap: () {
                          // Navigate to match detail page
                          context.push('/dashboard/matches/${match.id}');
                        },
                      ),
                    );
                  },
                ),
              ),
      },
    );
  }
}
