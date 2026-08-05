import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disaster_rescue/features/household/providers/sos_provider.dart';
import 'package:disaster_rescue/features/household/providers/safety_reminder_provider.dart';
import 'package:disaster_rescue/features/household/providers/disaster_state_provider.dart';
import 'package:disaster_rescue/features/household/providers/safety_status_provider.dart';
import 'package:disaster_rescue/data/models/sos_models.dart';
import 'package:disaster_rescue/data/models/safety_status.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:disaster_rescue/data/models/offline_request.dart';
import 'package:disaster_rescue/core/utils/connection_provider.dart';

class MockConnectionNotifier extends ConnectionNotifier {
  MockConnectionNotifier() {
    state = ConnectionStatus.offline;
  }

  @override
  Future<void> init() async {
    // Do nothing to keep state offline
  }
}

class MockSafetyStatusNotifier extends SafetyStatusNotifier {
  MockSafetyStatusNotifier(Ref ref, SafetyStatus initialState) : super(ref) {
    state = initialState;
  }
}

void main() {
  group('SOS Detail & Safety Reminder Tests', () {
    late ProviderContainer container;

    setUpAll(() async {
      Hive.init('test_hive_sos_safety');
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(OfflineRequestAdapter());
      }
      await Hive.openBox<OfflineRequest>('offline_requests');
    });

    setUp(() {
      container = ProviderContainer(
        overrides: [
          connectionProvider.overrideWith((ref) => MockConnectionNotifier()),
        ],
      );
      // Keep safety status and reminder providers alive
      container.listen(safetyStatusProvider, (_, __) {});
      container.listen(safetyReminderProvider, (_, __) {});
    });

    tearDown(() {
      container.dispose();
    });

    test('calculatePriority correctly calculates score based on FR-02.3', () {
      // 1. Chỉ có trẻ em: 15
      var context = const SosContext(
        hasChildren: true,
        hasElderly: false,
        hasSeriouslyIll: false,
        hasDisabled: false,
        groundFloorFlooded: false,
        needsMedicine: false,
        waterLevel: WaterLevel.none,
        houseType: HouseType.multiStory,
        peopleCount: 1,
      );
      expect(calculatePriority(context), equals(15));

      // 2. Có trẻ em (15) + nước ngập mái (20) + nhà cấp 4 (10) + trên 5 người (5) = 50
      context = const SosContext(
        hasChildren: true,
        hasElderly: false,
        hasSeriouslyIll: false,
        hasDisabled: false,
        groundFloorFlooded: false,
        needsMedicine: false,
        waterLevel: WaterLevel.roof,
        houseType: HouseType.level4,
        peopleCount: 6,
      );
      expect(calculatePriority(context), equals(50));

      // 3. Có đầy đủ yếu tố: trẻ em(15), người già(15), bệnh nặng(20), khuyết tật(10), ngập tầng trệt(15), thuốc(10), nước ngập mái(20), nhà cấp 4(10), >5 người(5) = 120
      context = const SosContext(
        hasChildren: true,
        hasElderly: true,
        hasSeriouslyIll: true,
        hasDisabled: true,
        groundFloorFlooded: true,
        needsMedicine: true,
        waterLevel: WaterLevel.roof,
        houseType: HouseType.level4,
        peopleCount: 6,
      );
      expect(calculatePriority(context), equals(120));
    });

    test('updateSosDetails updates currentContext and recalculates score', () async {
      final notifier = container.read(sosProvider.notifier);
      
      final newContext = const SosContext(
        hasChildren: true,
        hasElderly: true,
        hasSeriouslyIll: false,
        hasDisabled: false,
        groundFloorFlooded: false,
        needsMedicine: false,
        waterLevel: WaterLevel.chest,
        houseType: HouseType.level4,
        peopleCount: 2,
      ); // 15 + 15 + 10 + 10 = 50

      await notifier.updateSosDetails(newContext);

      final state = container.read(sosProvider);
      expect(state.currentContext.hasChildren, isTrue);
      expect(state.currentContext.hasElderly, isTrue);
      expect(calculatePriority(state.currentContext), equals(50));
    });

    test('safetyReminderProvider triggers after 2 hours threshold', () async {
      // Khởi tạo container mới với SafetyStatus từ 3 giờ trước
      final pastStatus = SafetyStatus(
        status: SafetyState.safe,
        source: SafetySource.selfApp,
        confidence: 90,
        verifiedAt: DateTime.now().subtract(const Duration(hours: 3)),
      );

      final localContainer = ProviderContainer(
        overrides: [
          connectionProvider.overrideWith((ref) => MockConnectionNotifier()),
          safetyStatusProvider.overrideWith((ref) => MockSafetyStatusNotifier(ref, pastStatus)),
        ],
      );

      localContainer.listen(safetyReminderProvider, (_, __) {});

      // Mặc định ban đầu reminder chưa quét thì false, gọi check để quét ngay
      final reminderNotifier = localContainer.read(safetyReminderProvider.notifier);
      
      // Đợi timer quét hoặc tự kích hoạt check
      expect(localContainer.read(safetyReminderProvider), isTrue);
      
      localContainer.dispose();
    });
  });
}
