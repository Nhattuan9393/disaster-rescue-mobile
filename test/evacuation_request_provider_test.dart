import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disaster_rescue/features/household/providers/evacuation_request_provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:disaster_rescue/data/models/offline_request.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  group('EvacuationRequestNotifier Tests', () {
    late ProviderContainer container;

    setUpAll(() async {
      Hive.init('test_hive_evac');
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(OfflineRequestAdapter());
      }
      await Hive.openBox<OfflineRequest>('offline_requests');
    });

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('Initial state is empty', () {
      final state = container.read(evacuationRequestProvider);
      expect(state.selectedAssistanceTypes.isEmpty, isTrue);
      expect(state.memberCount, 1);
      expect(state.timeframe, 'trong 3 giờ');
      expect(state.isEmergencyWarning, isFalse);
    });

    test('toggleAssistanceType works', () {
      final notifier = container.read(evacuationRequestProvider.notifier);
      
      notifier.toggleAssistanceType('vehicle');
      expect(container.read(evacuationRequestProvider).selectedAssistanceTypes.contains('vehicle'), isTrue);
      
      notifier.toggleAssistanceType('vehicle');
      expect(container.read(evacuationRequestProvider).selectedAssistanceTypes.contains('vehicle'), isFalse);
    });
    
    test('updateNote triggers emergency warning for specific keywords', () {
      final notifier = container.read(evacuationRequestProvider.notifier);
      
      notifier.updateNote('Cần xe ô tô để chở đồ');
      expect(container.read(evacuationRequestProvider).isEmergencyWarning, isFalse);
      
      notifier.updateNote('Nước ngập lụt quá đầu gối rồi cứu với');
      expect(container.read(evacuationRequestProvider).isEmergencyWarning, isTrue);
    });

    test('submitRequest fails if no assistance type selected', () async {
      final notifier = container.read(evacuationRequestProvider.notifier);
      
      final result = await notifier.submitRequest();
      
      expect(result, isFalse);
      expect(container.read(evacuationRequestProvider).errorMessage, isNotNull);
    });
    
    test('submitRequest succeeds if valid', () async {
      final notifier = container.read(evacuationRequestProvider.notifier);
      
      notifier.toggleAssistanceType('vehicle');
      final result = await notifier.submitRequest();
      
      expect(result, isTrue);
      expect(container.read(evacuationRequestProvider).errorMessage, isNull);
    });
  });
}
