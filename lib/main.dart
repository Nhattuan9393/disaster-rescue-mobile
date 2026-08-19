import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'core/routing/app_router.dart';
import 'core/services/hive_service.dart';
import 'core/utils/logger.dart';
import 'features/sos/data/sos_sync_service.dart';
import 'features/report/data/report_sync_service.dart';
import 'features/notification/data/push_notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // DR-006: Khởi tạo Hive Offline Infrastructure (chỉ dùng cho queue/cache, không phải shared state)
  await HiveService.init();

  // DR-002, DR-004: Firebase — Auth + Firestore + FCM + Storage
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    AppLogger.i('Firebase initialized');
  } catch (e, stack) {
    AppLogger.e('Firebase initialize thất bại — kiểm tra firebase_options.dart',
        error: e, stackTrace: stack);
  }

  final container = ProviderContainer();

  // DR-020: Đăng ký các service chạy ngầm (offline sync + FCM)
  container.read(sosSyncServiceProvider);
  container.read(reportSyncServiceProvider);
  // FCM push — kích hoạt sớm để nhận token & subscribe topic ngay
  await container.read(pushNotificationServiceProvider).initialize();

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const DisasterRescueApp(),
    ),
  );
}

class DisasterRescueApp extends ConsumerWidget {
  const DisasterRescueApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'DisasterRescue',
      theme: AppTheme.lightTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
