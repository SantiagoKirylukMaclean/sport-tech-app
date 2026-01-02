import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport_tech_app/application/org/active_team_notifier.dart';
import 'package:sport_tech_app/l10n/app_localizations.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

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
    final l10n = AppLocalizations.of(context)!;
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
              Text(
                l10n.noTeamSelected,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.pleaseSelectTeamFirst,
                style: const TextStyle(fontSize: 14),
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
              tabs: [
                Tab(
                  icon: const Icon(Icons.leaderboard),
                  text: l10n.standings,
                ),
                Tab(
                  icon: const Icon(Icons.sports_score),
                  text: l10n.results,
                ),
                Tab(
                  icon: const Icon(Icons.calendar_month),
                  text: l10n.calendar,
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
                  label: l10n.standings,
                  icon: Icons.leaderboard,
                  description: l10n.standingsDescription,
                ),
                _buildUrlTab(
                  context,
                  url: activeTeam.resultsUrl,
                  label: l10n.results,
                  icon: Icons.sports_score,
                  description: l10n.resultsDescription,
                ),
                _buildUrlTab(
                  context,
                  url: activeTeam.calendarUrl,
                  label: l10n.calendar,
                  icon: Icons.calendar_month,
                  description: l10n.calendarDescription,
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
    final l10n = AppLocalizations.of(context)!;
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
                l10n.noUrlAvailable(label),
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.contactAdminForUrls,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // WebView is not supported on web platform
    if (kIsWeb) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.open_in_new,
                size: 64,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                label,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.webViewNotSupported,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () async {
                  final uri = Uri.parse(url);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(
                      uri,
                      mode: LaunchMode.externalApplication,
                    );
                  }
                },
                icon: const Icon(Icons.open_in_new),
                label: Text(l10n.openInNewTab),
              ),
              const SizedBox(height: 8),
              Text(
                url,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      );
    }

    // Use WebView for mobile and desktop platforms
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
