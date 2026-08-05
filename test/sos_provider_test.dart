import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disaster_rescue/features/household/providers/sos_provider.dart';
import 'package:disaster_rescue/shared/widgets/sos_button.dart';
import 'package:disaster_rescue/data/models/sos_models.dart';
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

void main() {
  group('SosNotifier Tests', () {
    late ProviderContainer container;

    setUpAll(() async {
      Hive.init('test_hive_sos');
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
    });

    tearDown(() {
      container.dispose();
    });

    test('Initial state is idle', () {
      final state = container.read(sosProvider);
      expect(state.buttonState, equals(SosButtonState.idle));
    });

    test('sendSos changes state to sending then sent', () async {
      final notifier = container.read(sosProvider.notifier);
      
      // Kích hoạt sendSos
      final future = notifier.sendSos();
      
      // Ngay sau khi gọi, state phải là sending
      expect(container.read(sosProvider).buttonState, equals(SosButtonState.sending));
      
      // Chờ hoàn thành logic (mock delay 1000ms)
      await future;
      
      // Sau khi xong, state phải là sent
      expect(container.read(sosProvider).buttonState, equals(SosButtonState.sent));
    });
    
    test('calculatePriority returns correct score based on FR-02.3', () {
      final context = const SosContext(
        hasChildren: true,
        hasElderly: false,
        hasSeriouslyIll: false,
        hasDisabled: false,
        groundFloorFlooded: true,
        needsMedicine: false,
        waterLevel: WaterLevel.chest, // +10
        houseType: HouseType.level4, // +10
        peopleCount: 4,
      );
      
      final score = calculatePriority(context);
      // hasChildren (15) + groundFloorFlooded (15) + chest (10) + level4 (10) = 50
      expect(score, 50);
      
      final level = getPriorityLevel(score);
      expect(level, PriorityLevel.orange);
    });
  });
}
