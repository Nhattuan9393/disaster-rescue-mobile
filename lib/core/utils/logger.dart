import 'dart:developer' as developer;

class AppLogger {
  static void d(String message, {String name = 'DEBUG'}) {
    developer.log(message, name: name, level: 500);
  }

  static void i(String message, {String name = 'INFO'}) {
    developer.log(message, name: name, level: 800);
  }

  static void w(String message, {String name = 'WARNING'}) {
    developer.log(message, name: name, level: 900);
  }

  static void e(String message, {String name = 'ERROR', Object? error, StackTrace? stackTrace}) {
    developer.log(message, name: name, level: 1000, error: error, stackTrace: stackTrace);
  }
}
