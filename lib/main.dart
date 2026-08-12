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
import 'core/services/api_sync_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // DR-006: Khởi tạo Hive Offline Infrastructure
  await HiveService.init();

  // Bắt đầu chạy ngầm đồng bộ hóa thời gian thực qua kvdb.io
  ApiSyncService.startPolling();

  // DR-002, DR-004: Khởi tạo Firebase với cấu hình Dummy (Emulator)
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    AppLogger.i('Firebase initialized successfully');
  } catch (e, stack) {
    AppLogger.e('Failed to initialize Firebase', error: e, stackTrace: stack);
  }

  // Tạo ProviderContainer để khởi tạo các Service chạy ngầm độc lập với UI
  final container = ProviderContainer();

  // DR-020: Đăng ký lắng nghe đồng bộ SOS tự động
  container.read(sosSyncServiceProvider);
  // Đồng bộ báo cáo Flow B/C ngoại tuyến
  container.read(reportSyncServiceProvider);

  // DR-005: Bọc toàn bộ app trong UncontrolledProviderScope để chia sẻ container
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
