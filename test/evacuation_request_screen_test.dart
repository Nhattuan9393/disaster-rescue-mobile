import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disaster_rescue/features/household/evacuation_request_screen.dart';
import 'package:disaster_rescue/features/household/widgets/assistance_type_chip.dart';
import 'package:disaster_rescue/data/models/offline_request.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() {
  setUpAll(() async {
    Hive.init('test_hive_evac_ui');
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(OfflineRequestAdapter());
    }
    await Hive.openBox<OfflineRequest>('offline_requests');
  });

  testWidgets('EvacuationRequestScreen renders form and validates correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: EvacuationRequestScreen(),
        ),
      ),
    );

    // 1. Kiểm tra Banner cảnh báo xuất hiện
    expect(find.text('Đây KHÔNG PHẢI là SOS khẩn cấp!'), findsOneWidget);
    expect(find.text('Quay lại gửi SOS'), findsOneWidget);

    // 2. Kiểm tra các trường dữ liệu có render không
    expect(find.text('1. Bạn cần hỗ trợ gì?'), findsOneWidget);
    expect(find.byType(AssistanceTypeChip), findsWidgets);
    expect(find.text('2. Số lượng người cần sơ tán'), findsOneWidget);
    expect(find.text('3. Thời gian mong muốn'), findsOneWidget);
    expect(find.text('4. Ghi chú thêm (Không bắt buộc)'), findsOneWidget);

    // 3. Kiểm tra validation error khi bấm gửi mà không chọn gì
    await tester.tap(find.text('GỬI YÊU CẦU SƠ TÁN'));
    await tester.pumpAndSettle();
    expect(find.text('Vui lòng chọn ít nhất 1 loại hỗ trợ.'), findsOneWidget);

    // 4. Chọn 1 loại và kiểm tra submit
    await tester.tap(find.text('Xe chở người'));
    await tester.pumpAndSettle();
    
    // 5. Test tính năng cảnh báo thông minh (emergency warning)
    await tester.enterText(find.byType(TextField), 'Nước sắp chìm nhà');
    await tester.pumpAndSettle();
    expect(find.textContaining('Vui lòng dùng nút SOS'), findsOneWidget);
  });
}
