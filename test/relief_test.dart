import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disaster_rescue/features/relief/providers/relief_provider.dart';
import 'package:disaster_rescue/data/models/relief_models.dart';

void main() {
  group('Relief Stock & Warehouse Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('Initial stock lists standard items and packages correctly', () {
      final state = container.read(reliefProvider);
      
      expect(state.items.length, equals(4)); // Gạo, Mì, Nước, Phao
      expect(state.packages.length, equals(1)); // GCT-2025-0001
      
      final water = state.items.firstWhere((item) => item.id == 'i3');
      expect(isBelowThreshold(water), isTrue); // Nước (80 < 100)
    });

    test('receiveItemStock increases item quantity', () {
      final notifier = container.read(reliefProvider.notifier);
      
      // Nhập thêm 200kg Gạo (Gạo ban đầu: 500)
      notifier.receiveItemStock('i1', 200);

      final state = container.read(reliefProvider);
      final rice = state.items.firstWhere((item) => item.id == 'i1');
      expect(rice.quantity, equals(700));
    });

    test('receiveReliefPackage adds a new mixed package (Tầng 2)', () {
      final notifier = container.read(reliefProvider.notifier);

      final lines = const [
        PackageLine(rawName: 'Lương khô quân nhu', quantity: 100, unit: 'hộp', mappedItemId: null),
      ];

      notifier.receiveReliefPackage('Đoàn MTTQ tỉnh Quảng Ninh', '0988888888', lines);

      final state = container.read(reliefProvider);
      expect(state.packages.length, equals(2));
      expect(state.packages.last.code, equals('GCT-2025-0003'));
      expect(state.packages.last.donorName, equals('Đoàn MTTQ tỉnh Quảng Ninh'));
    });

    test('dispatchStock deducts inventory and handles below threshold', () {
      final notifier = container.read(reliefProvider.notifier);

      // Xuất 300kg Gạo (Tồn 500) -> Còn 200kg (Bằng Threshold -> Không dưới)
      final success = notifier.dispatchStock('i1', 300);
      expect(success, isTrue);

      var state = container.read(reliefProvider);
      var rice = state.items.firstWhere((item) => item.id == 'i1');
      expect(rice.quantity, equals(200));
      expect(isBelowThreshold(rice), isFalse);

      // Xuất tiếp 50kg Gạo -> Còn 150kg (Dưới ngưỡng 200)
      notifier.dispatchStock('i1', 50);
      state = container.read(reliefProvider);
      rice = state.items.firstWhere((item) => item.id == 'i1');
      expect(isBelowThreshold(rice), isTrue);
    });

    test('dispatchStock fails and returns error when quantity exceeds stock', () {
      final notifier = container.read(reliefProvider.notifier);

      // Xuất 600kg Gạo (Tồn 500) -> Thất bại
      final success = notifier.dispatchStock('i1', 600);
      expect(success, isFalse);

      final state = container.read(reliefProvider);
      expect(state.error, contains('Số lượng xuất vượt quá tồn kho hiện tại'));
      
      final rice = state.items.firstWhere((item) => item.id == 'i1');
      expect(rice.quantity, equals(500)); // Vẫn giữ nguyên 500
    });

    test('createReceipt records receipt and deducts stock if from warehouse', () {
      final notifier = container.read(reliefProvider.notifier);

      final receipt = ReliefReceipt(
        id: 'r1',
        householdId: 'h1',
        distributedAt: DateTime.now(),
        distributedBy: 'Cán bộ Minh',
        source: SupplySource.communeWarehouse,
        items: const {'i1': 50}, // Phát 50kg Gạo
        packageCode: null,
        note: 'Phát tại nhà văn hóa',
      );

      notifier.createReceipt(receipt);

      final state = container.read(reliefProvider);
      expect(state.receipts.length, equals(1));
      
      final rice = state.items.firstWhere((item) => item.id == 'i1');
      expect(rice.quantity, equals(450)); // Đã trừ 50kg (500 -> 450)
    });
  });
}
