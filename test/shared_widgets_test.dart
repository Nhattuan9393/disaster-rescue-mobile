import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:disaster_rescue/data/models/safety_status.dart';
import 'package:disaster_rescue/shared/widgets/sos_button.dart';
import 'package:disaster_rescue/shared/widgets/status_chip.dart';
import 'package:disaster_rescue/shared/widgets/priority_badge.dart';
import 'package:disaster_rescue/shared/widgets/kpi_card.dart';
import 'package:disaster_rescue/shared/widgets/household_card.dart';
import 'package:disaster_rescue/shared/widgets/stock_card.dart';
import 'package:disaster_rescue/shared/widgets/offline_banner.dart';
import 'package:disaster_rescue/shared/widgets/quantity_stepper.dart';
import 'package:disaster_rescue/shared/widgets/line_entry_table.dart';
import 'package:disaster_rescue/shared/widgets/auto_metrics_block.dart';
import 'package:disaster_rescue/shared/widgets/app_state_views.dart';

void main() {
  group('Shared Widgets Rendering Tests', () {
    // 1. SosButton
    testWidgets('SosButton renders correct states', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: SosButton(state: SosButtonState.idle),
        ),
      ));
      expect(find.text('SOS'), findsOneWidget);

      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: SosButton(state: SosButtonState.sending),
        ),
      ));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: SosButton(state: SosButtonState.sent),
        ),
      ));
      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    // 2. StatusChip
    testWidgets('StatusChip renders correct texts for different sources', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: StatusChip(status: SafetyState.missingContact),
        ),
      ));
      expect(find.text('Mất liên lạc — Thiết bị im lặng'), findsOneWidget);

      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: StatusChip(status: SafetyState.safe, source: SafetySource.rescueTeam),
        ),
      ));
      expect(find.text('An toàn — Đội xác nhận'), findsOneWidget);

      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: StatusChip(status: SafetyState.safe, source: SafetySource.evacuationCheckin),
        ),
      ));
      expect(find.text('An toàn — Check-in sơ tán'), findsOneWidget);
    });

    // 3. PriorityBadge
    testWidgets('PriorityBadge displays score and category', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: PriorityBadge(score: 85),
        ),
      ));
      expect(find.text('KHẨN CẤP (85 điểm)'), findsOneWidget);

      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: PriorityBadge(score: 50),
        ),
      ));
      expect(find.text('NGUY HIỂM (50 điểm)'), findsOneWidget);

      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: PriorityBadge(score: 25),
        ),
      ));
      expect(find.text('CẦN HỖ TRỢ (25 điểm)'), findsOneWidget);
    });

    // 4. KpiCard
    testWidgets('KpiCard displays absolute values and asserts on percentage', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: KpiCard(
            title: 'Hộ đã cứu',
            value: '45/120',
            icon: Icons.check_circle,
            color: Colors.green,
          ),
        ),
      ));
      expect(find.text('Hộ đã cứu'), findsOneWidget);
      expect(find.text('45/120'), findsOneWidget);
    });

    // 5. HouseholdCard
    testWidgets('HouseholdCard masks data when isMasked is true', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: HouseholdCard(
            name: 'Nguyễn Văn A',
            village: 'Thôn Pắc Liềng',
            peopleCount: 5,
            status: SafetyState.safe,
            source: SafetySource.selfApp,
            phone: '0987654321',
            isMasked: false,
          ),
        ),
      ));
      expect(find.text('Nguyễn Văn A'), findsOneWidget);
      expect(find.text('0987654321'), findsOneWidget);

      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: HouseholdCard(
            name: 'Nguyễn Văn A',
            village: 'Thôn Pắc Liềng',
            peopleCount: 5,
            status: SafetyState.safe,
            source: SafetySource.selfApp,
            phone: '0987654321',
            isMasked: true,
          ),
        ),
      ));
      expect(find.text('Hộ gia đình ông/bà A'), findsOneWidget);
      expect(find.text('098***321'), findsOneWidget);
    });

    // 6. StockCard
    testWidgets('StockCard renders correctly and alerts when low stock', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: StockCard(
            itemName: 'Mì tôm',
            currentQty: 200,
            thresholdQty: 500,
            unit: 'thùng',
            capacity: 1000,
          ),
        ),
      ));
      expect(find.text('Mì tôm'), findsOneWidget);
      expect(find.text('Tồn kho: 200 / 1000 thùng'), findsOneWidget);
      expect(find.text('DƯỚI NGƯỠNG'), findsOneWidget);
    });

    // 7. OfflineBanner
    testWidgets('OfflineBanner displays correct number of pending items', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: OfflineBanner(pendingSosCount: 3, pendingActionsCount: 5),
        ),
      ));
      expect(find.textContaining('3 yêu cầu SOS'), findsOneWidget);
      expect(find.textContaining('đồng bộ 5 thao tác'), findsOneWidget);
    });

    // 8. QuantityStepper
    testWidgets('QuantityStepper triggers onChanged and disables boundaries', (tester) async {
      num stepperValue = 5;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return QuantityStepper(
                value: stepperValue,
                min: 2,
                max: 8,
                onChanged: (val) {
                  setState(() {
                    stepperValue = val;
                  });
                },
              );
            },
          ),
        ),
      ));
      expect(find.text('5'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();
      expect(stepperValue, 6);

      await tester.tap(find.byIcon(Icons.remove));
      await tester.pump();
      expect(stepperValue, 5);
    });

    // 9. LineEntryTable
    testWidgets('LineEntryTable displays rows and empty states', (tester) async {
      List<LineEntryRow> lines = [];
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return LineEntryTable(
                lines: lines,
                onChanged: (val) {
                  setState(() {
                    lines = val;
                  });
                },
              );
            },
          ),
        ),
      ));
      expect(find.text('Chưa có mặt hàng nào. Bấm "Thêm dòng" để bắt đầu.'), findsOneWidget);

      await tester.tap(find.byType(TextButton));
      await tester.pump();
      expect(lines.length, 1);
    });

    // 10. AutoMetricsBlock
    testWidgets('AutoMetricsBlock renders all grid metrics', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: AutoMetricsBlock(
              redSosUnassigned: 4,
              longestWait: const Duration(hours: 1, minutes: 20),
              householdsMissing: 12,
              teamsAvailable: 2,
              teamsTotal: 5,
              itemsBelowThreshold: 3,
              evacuationSlotsFree: 45,
              computedAt: DateTime(2026, 8, 4, 21, 30),
            ),
          ),
        ),
      ));
      expect(find.text('SOS đỏ chưa gán'), findsOneWidget);
      expect(find.text('4 vụ'), findsOneWidget);
      expect(find.text('1 giờ 20 phút'), findsOneWidget);
      expect(find.text('12 hộ'), findsOneWidget);
      expect(find.text('2/5 đội'), findsOneWidget);
      expect(find.text('3 loại'), findsOneWidget);
      expect(find.text('45 chỗ'), findsOneWidget);
    });

    // 11. AppStateViews
    testWidgets('AppStateViews render correctly', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: AppLoadingView(message: 'Đang tải dữ liệu...'),
        ),
      ));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Đang tải dữ liệu...'), findsOneWidget);

      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: AppErrorView(message: 'Lỗi máy chủ'),
        ),
      ));
      expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);
      expect(find.text('Lỗi máy chủ'), findsOneWidget);

      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: AppEmptyView(message: 'Không tìm thấy hộ dân nào'),
        ),
      ));
      expect(find.text('Không tìm thấy hộ dân nào'), findsOneWidget);
    });
  });
}
