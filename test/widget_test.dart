import 'dart:io';
import 'package:hive/hive.dart';
import 'package:disaster_rescue/data/models/offline_request.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disaster_rescue/main.dart';
import 'package:disaster_rescue/features/auth/login_screen.dart';

void main() {
  late Directory tempDir;
  late Box<OfflineRequest> box;

  setUpAll(() {
    try {
      Hive.registerAdapter(OfflineRequestAdapter());
    } catch (_) {}
  });

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('hive_widget_test');
    Hive.init(tempDir.path);
    box = await Hive.openBox<OfflineRequest>('offline_requests');
  });

  tearDown(() async {
    await box.clear();
    await box.close();
    try {
      await tempDir.delete(recursive: true);
    } catch (_) {}
  });
  testWidgets('App launch smoke test', (WidgetTester tester) async {
    // Khởi chạy ứng dụng bọc trong ProviderScope
    await tester.pumpWidget(
      const ProviderScope(
        child: MyApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Xác minh ứng dụng mở màn hình Login mặc định
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.text('ĐĂNG NHẬP THỬ NGHIỆM'), findsOneWidget);
  });
}
