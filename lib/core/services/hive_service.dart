import 'package:hive_flutter/hive_flutter.dart';
import '../utils/logger.dart';

class HiveService {
  static const String sosQueueBox = 'sos_queue';
  static const String gpsCacheBox = 'gps_cache';
  static const String reportQueueBox = 'report_queue';

  static Future<void> init() async {
    try {
      await Hive.initFlutter();
      await Hive.openBox(sosQueueBox);
      await Hive.openBox(gpsCacheBox);
      await Hive.openBox(reportQueueBox);
      AppLogger.i('Hive initialized successfully');
    } catch (e, stack) {
      AppLogger.e('Failed to initialize Hive', error: e, stackTrace: stack);
    }
  }

  static Box getSosQueueBox() => Hive.box(sosQueueBox);
  static Box getGpsCacheBox() => Hive.box(gpsCacheBox);
  static Box getReportQueueBox() => Hive.box(reportQueueBox);
}
