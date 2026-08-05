import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disaster_rescue/features/sos/providers/report_to_commune_provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:disaster_rescue/data/models/offline_request.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  group('ReportToCommuneNotifier Tests', () {
    late ProviderContainer container;

    setUpAll(() async {
      Hive.init('test_hive_report');
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(OfflineRequestAdapter());
      }
      await Hive.openBox<OfflineRequest>('offline_requests');
    });

    setUp(() {
      container = ProviderContainer();
      // Keep provider alive
      container.listen(reportToCommuneProvider, (_, __) {});
    });

    tearDown(() {
      container.dispose();
    });

    test('Initial state is correct', () {
      final state = container.read(reportToCommuneProvider);
      expect(state.isSubmitting, isFalse);
      expect(state.errorMessage, isNull);
      expect(state.successMessage, isNull);
    });

    test('submitReportB fails if address is empty', () async {
      final notifier = container.read(reportToCommuneProvider.notifier);
      
      final result = await notifier.submitReportB(address: '   ', description: 'desc');
      
      expect(result, isFalse);
      expect(container.read(reportToCommuneProvider).errorMessage, 'Vui lòng nhập địa chỉ / vị trí.');
    });

    test('submitReportB succeeds if address is provided', () async {
      final notifier = container.read(reportToCommuneProvider.notifier);
      
      final result = await notifier.submitReportB(address: 'Hanoi', description: 'desc');
      
      expect(result, isTrue);
      expect(container.read(reportToCommuneProvider).errorMessage, isNull);
      expect(container.read(reportToCommuneProvider).successMessage, isNotNull);
    });

    test('submitReportC fails if location is empty', () async {
      final notifier = container.read(reportToCommuneProvider.notifier);
      
      final result = await notifier.submitReportC(incidentType: 'Fire', location: '', description: 'desc');
      
      expect(result, isFalse);
      expect(container.read(reportToCommuneProvider).errorMessage, 'Vui lòng nhập vị trí.');
    });

    test('submitReportC succeeds if valid', () async {
      final notifier = container.read(reportToCommuneProvider.notifier);
      
      final result = await notifier.submitReportC(incidentType: 'Fire', location: 'Street 1', description: 'desc');
      
      expect(result, isTrue);
      expect(container.read(reportToCommuneProvider).errorMessage, isNull);
      expect(container.read(reportToCommuneProvider).successMessage, isNotNull);
    });
  });
}
