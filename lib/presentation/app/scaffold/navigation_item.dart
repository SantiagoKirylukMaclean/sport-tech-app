// lib/presentation/app/scaffold/navigation_item.dart

import 'package:flutter/material.dart';

/// Represents a navigation item in the app
class NavigationItem {
  final String label;
  final String route;
  final IconData iconOutlined;
  final IconData iconFilled;

  const NavigationItem({
    required this.label,
    required this.route,
    required this.iconOutlined,
    required this.iconFilled,
  });
}
