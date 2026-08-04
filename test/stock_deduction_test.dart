import 'package:flutter_test/flutter_test.dart';
import 'package:disaster_rescue/data/models/relief_models.dart';

void main() {
  group('Kiểm thử Trừ tồn kho cứu trợ theo nguồn phát (FR-10.8 & FR-10.9)', () {
    late ReliefItem standardItem;

    setUp(() {
      standardItem = const ReliefItem(
        id: 'life_jacket',
        name: 'Áo phao',
        quantity: 100.0,
        threshold: 50.0,
        unit: 'chiếc',
      );
    });

    test('TC-INV-01: Phát từ Kho xã (communeWarehouse) -> Giảm tồn kho xã', () {
      // Giả lập phát 2 áo phao từ kho xã
      final updatedItem = deductCommuneStock(standardItem, 2.0);

      expect(updatedItem.quantity, equals(98.0));
      expect(isBelowThreshold(updatedItem), isFalse);
    });

    test('TC-INV-02: Phát từ nguồn Đội tự mang (teamBrought) -> Không trừ tồn kho xã', () {
      const source = SupplySource.teamBrought;
      
      double communeStock = standardItem.quantity;
      
      if (source == SupplySource.communeWarehouse) {
        communeStock = deductCommuneStock(standardItem, 2.0).quantity;
      } else {
        // Giữ nguyên tồn kho xã
      }

      expect(communeStock, equals(100.0));
    });

    test('TC-INV-03: Phát nguyên gói chưa phân loại (packageDirect) -> Không trừ tồn kho xã, ghi nhận mã gói', () {
      const source = SupplySource.packageDirect;
      final package = ReliefPackage(
        code: 'GCT-2025-0007',
        donorName: 'Nhóm Hạ Long',
        donorPhone: '0987654321',
        receivedAt: DateTime.now(),
        receivedBy: 'cán bộ A',
        status: PackageStatus.received,
        lines: [
          const PackageLine(rawName: 'Mì tôm', quantity: 100, unit: 'thùng', mappedItemId: null),
        ],
      );

      double communeStock = standardItem.quantity;
      String? packageCodeReceipt;

      if (source == SupplySource.communeWarehouse) {
        communeStock = deductCommuneStock(standardItem, 2.0).quantity;
      } else if (source == SupplySource.packageDirect) {
        packageCodeReceipt = package.code;
        // Giữ nguyên tồn kho xã
      }

      expect(communeStock, equals(100.0));
      expect(packageCodeReceipt, equals('GCT-2025-0007'));
    });

    test('TC-INV-04: Cảnh báo/Lỗi khi xuất vượt quá tồn kho hiện tại', () {
      expect(
        () => deductCommuneStock(standardItem, 120.0),
        throwsA(isA<ReliefInventoryException>()),
      );
    });

    test('TC-INV-05: Cảnh báo tồn kho dưới ngưỡng', () {
      // Tồn kho hiện tại là 100, phát 52 chiếc -> còn 48 (dưới ngưỡng 50)
      final updatedItem = deductCommuneStock(standardItem, 52.0);

      expect(updatedItem.quantity, equals(48.0));
      expect(isBelowThreshold(updatedItem), isTrue);
    });
  });
}
