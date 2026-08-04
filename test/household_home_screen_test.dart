import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disaster_rescue/features/household/household_home_screen.dart';
import 'package:disaster_rescue/shared/widgets/sos_button.dart';
import 'package:disaster_rescue/features/household/widgets/action_tier_button.dart';
import 'package:disaster_rescue/data/models/offline_request.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() {
  setUpAll(() async {
    Hive.init('test_hive_ui');
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(OfflineRequestAdapter());
    }
    await Hive.openBox<OfflineRequest>('offline_requests');
  });

  testWidgets('HouseholdHomeScreen renders 3 tiers properly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: HouseholdHomeScreen(),
        ),
      ),
    );

    // Header an toàn
    expect(find.text('Trạng thái an toàn của tôi:'), findsOneWidget);

    // Tầng 1: SOS
    expect(find.byType(SosButton), findsOneWidget);
    expect(find.text('BẤM 1 CHẠM ĐỂ GỬI SOS KHẨN CẤP'), findsOneWidget);

    // Tầng 2 & 3: Các nút hành động
    expect(find.byType(ActionTierButton), findsNWidgets(4));
    expect(find.textContaining('Cần hỗ trợ\nsơ tán'), findsOneWidget);
    expect(find.textContaining('Tôi vẫn\nan toàn'), findsOneWidget);
    expect(find.textContaining('Báo giúp\nngười khác'), findsOneWidget);
    expect(find.textContaining('Báo tình hình\nkhu vực'), findsOneWidget);
  });
}
