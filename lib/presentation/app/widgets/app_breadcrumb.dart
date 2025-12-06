import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sport_tech_app/presentation/app/config/breadcrumb_config.dart';

/// A breadcrumb navigation widget that displays the current navigation path
class AppBreadcrumb extends StatelessWidget {
  const AppBreadcrumb({super.key});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final breadcrumbs = BreadcrumbConfig.getBreadcrumbs(location, context);

    if (breadcrumbs.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.home_outlined,
            size: 16,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _buildBreadcrumbItems(context, breadcrumbs),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildBreadcrumbItems(BuildContext context, List<BreadcrumbItem> breadcrumbs) {
    final items = <Widget>[];

    for (int i = 0; i < breadcrumbs.length; i++) {
      final breadcrumb = breadcrumbs[i];
      final isLast = i == breadcrumbs.length - 1;

      // Add separator if not first item
      if (i > 0) {
        items.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Icon(
              Icons.chevron_right,
              size: 16,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          ),
        );
      }

      // Add breadcrumb item
      items.add(
        _BreadcrumbButton(
          label: breadcrumb.label,
          route: breadcrumb.route,
          isLast: isLast,
        ),
      );
    }

    return items;
  }
}

/// A single breadcrumb button
class _BreadcrumbButton extends StatelessWidget {
  final String label;
  final String? route;
  final bool isLast;

  const _BreadcrumbButton({
    required this.label,
    this.route,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
          color: isLast
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
          fontWeight: isLast ? FontWeight.w600 : FontWeight.normal,
        );

    if (isLast || route == null) {
      return Text(label, style: textStyle);
    }

    return InkWell(
      onTap: () => context.go(route!),
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Text(
          label,
          style: textStyle?.copyWith(
            decoration: TextDecoration.underline,
            decorationColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
          ),
        ),
      ),
    );
  }
}
