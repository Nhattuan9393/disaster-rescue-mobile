import 'dart:developer' as developer;

class AppLogger {
  static void d(String message, {String name = 'DEBUG', Object? error, StackTrace? stackTrace}) {
    developer.log(message, name: name, level: 500, error: error, stackTrace: stackTrace);
  }

  static void i(String message, {String name = 'INFO', Object? error, StackTrace? stackTrace}) {
    developer.log(message, name: name, level: 800, error: error, stackTrace: stackTrace);
  }

  static void w(String message, {String name = 'WARNING', Object? error, StackTrace? stackTrace}) {
    developer.log(message, name: name, level: 900, error: error, stackTrace: stackTrace);
  }

  static void e(String message, {String name = 'ERROR', Object? error, StackTrace? stackTrace}) {
    developer.log(message, name: name, level: 1000, error: error, stackTrace: stackTrace);
  }
}
