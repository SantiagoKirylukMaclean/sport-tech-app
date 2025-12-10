import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport_tech_app/application/org/active_team_notifier.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ChampionshipPage extends ConsumerStatefulWidget {
  const ChampionshipPage({super.key});

  @override
  ConsumerState<ChampionshipPage> createState() => _ChampionshipPageState();
}

class _ChampionshipPageState extends ConsumerState<ChampionshipPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final activeTeamState = ref.watch(activeTeamNotifierProvider);
    final activeTeam = activeTeamState.activeTeam;

    if (activeTeam == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.warning_outlined,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              const Text(
                'No team selected',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 8),
              const Text(
                'Please select a team first',
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: Column(
        children: [
          Container(
            color: Theme.of(context).colorScheme.surface,
            child: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(
                  icon: Icon(Icons.leaderboard),
                  text: 'Clasificación',
                ),
                Tab(
                  icon: Icon(Icons.sports_score),
                  text: 'Resultados',
                ),
                Tab(
                  icon: Icon(Icons.calendar_month),
                  text: 'Calendario',
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildUrlTab(
                  context,
                  url: activeTeam.standingsUrl,
                  label: 'Clasificación',
                  icon: Icons.leaderboard,
                  description: 'Ver la tabla de clasificación del campeonato',
                ),
                _buildUrlTab(
                  context,
                  url: activeTeam.resultsUrl,
                  label: 'Resultados',
                  icon: Icons.sports_score,
                  description: 'Ver los resultados de los partidos',
                ),
                _buildUrlTab(
                  context,
                  url: activeTeam.calendarUrl,
                  label: 'Calendario',
                  icon: Icons.calendar_month,
                  description: 'Ver el calendario de partidos',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUrlTab(
    BuildContext context, {
    required String? url,
    required String label,
    required IconData icon,
    required String description,
  }) {
    if (url == null || url.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.link_off,
                size: 64,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 16),
              Text(
                'No $label URL configured',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Please contact your administrator to configure the championship URLs',
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar if needed
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
          onHttpError: (HttpResponseError error) {},
          onWebResourceError: (WebResourceError error) {},
        ),
      )
      ..loadRequest(Uri.parse(url));

    return WebViewWidget(controller: controller);
  }
}
