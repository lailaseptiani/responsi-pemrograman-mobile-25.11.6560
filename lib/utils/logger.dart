import 'package:flutter/foundation.dart';

/// Tingkat log yang tersedia.
enum LogLevel { debug, info, warning, error }

/// Logger sederhana yang aman.
///
/// Aturan keamanan logging di aplikasi ini:
/// * Log hanya dicetak pada mode debug (`kDebugMode`).
/// * Isi catatan, password, token, dan API key **tidak pernah** dikirim ke
///   logger. Yang boleh dicatat hanya informasi teknis (id catatan, jumlah
///   data, status code).
/// * Sebagai lapisan pengaman tambahan, pola seperti `token=...` atau
///   `api_key: ...` otomatis disamarkan menjadi `***` oleh [mask].
/// * Untuk error, hanya tipe error yang dicetak, bukan isi pesannya.
class Logger {
  Logger._(); // Tidak perlu di-instansiasi.

  /// Level minimum yang akan dicetak.
  static LogLevel minLevel = LogLevel.debug;

  static final RegExp _sensitivePattern = RegExp(
    r'(x-api-key|api[_-]?key|token|password|passwd|secret|authorization|content)'
    r'("?\s*[:=]\s*"?)([^\s",}]+)',
    caseSensitive: false,
  );

  /// Mencetak log level debug.
  static void debug(String message, {String? tag}) =>
      _log(LogLevel.debug, message, tag: tag);

  /// Mencetak log level info.
  static void info(String message, {String? tag}) =>
      _log(LogLevel.info, message, tag: tag);

  /// Mencetak log level warning.
  static void warning(String message, {String? tag}) =>
      _log(LogLevel.warning, message, tag: tag);

  /// Mencetak log level error.
  ///
  /// Hanya tipe dari [error] (misalnya `SocketException`) yang dicetak,
  /// bukan isi pesannya, agar tidak ada data sensitif yang bocor.
  static void error(String message, {Object? error, String? tag}) {
    final suffix = error != null ? ' (${error.runtimeType})' : '';
    _log(LogLevel.error, '$message$suffix', tag: tag);
  }

  /// Menyamarkan nilai sensitif di dalam [input].
  ///
  /// Contoh: `token=abc123` menjadi `token=***`.
  static String mask(String input) {
    return input.replaceAllMapped(
      _sensitivePattern,
      (m) => '${m[1]}${m[2]}***',
    );
  }

  static void _log(LogLevel level, String message, {String? tag}) {
    if (!kDebugMode) return;
    if (level.index < minLevel.index) return;

    final time = DateTime.now().toIso8601String().substring(11, 23);
    final label = level.name.toUpperCase().padRight(7);
    final tagText = tag != null ? '[$tag] ' : '';
    debugPrint('$time $label $tagText${mask(message)}');
  }
}
