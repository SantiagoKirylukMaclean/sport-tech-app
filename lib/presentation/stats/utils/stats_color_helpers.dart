import 'package:flutter/material.dart';

/// Returns the color corresponding to the statistics percentage.
///
/// * >= 90%: Green
/// * >= 75% and < 90%: Orange/Yellow (Colors.orange)
/// * < 75%: Red (Error color)
Color getStatsPercentageColor(BuildContext context, double percentage) {
  if (percentage >= 90) {
    return Colors.green;
  } else if (percentage >= 75) {
    // Using orange as a good "warning/yellow" representation that helps visibility on white/dark backgrounds
    return Colors.orange;
  } else {
    return Theme.of(context).colorScheme.error;
  }
}
