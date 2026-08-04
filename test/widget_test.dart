import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disaster_rescue/main.dart';
import 'package:disaster_rescue/features/auth/login_screen.dart';

void main() {
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
