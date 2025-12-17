import 'package:flutter/foundation.dart';

/// Logger utility that only logs in debug mode
class Logger {
  /// Logs a message only in debug mode
  static void log(String message, {String? tag}) {
    if (kDebugMode) {
      final prefix = tag != null ? '[$tag] ' : '';
      debugPrint('$prefix$message');
    }
  }

  /// Logs an error only in debug mode
  static void error(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    if (kDebugMode) {
      final prefix = tag != null ? '[$tag] ' : '';
      debugPrint('$prefix ERROR: $message');
      if (error != null) {
        debugPrint('$prefix Error details: $error');
      }
      if (stackTrace != null) {
        debugPrint('$prefix Stack trace: $stackTrace');
      }
    }
  }
}
