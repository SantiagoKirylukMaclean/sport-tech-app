import 'package:flutter/material.dart';

/// A card widget displaying a statistic with an icon
class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color? valueColor;
  final VoidCallback? onTap;

  const StatCard({
    required this.title,
    required this.value,
    required this.icon,
    this.subtitle,
    this.valueColor,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      color: isDark ? const Color(0xFF1E1E1E) : theme.cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Value
              Text(
                value,
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: valueColor ??
                      (isDark
                          ? const Color(0xFF4CAF50)
                          : theme.colorScheme.primary),
                  fontSize: 36,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              // Title
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w400,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Divider(height: 24),
              // Subtitle
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    fontSize: 11,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                )
              else
                const SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }
}
