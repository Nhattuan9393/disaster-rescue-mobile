import 'package:flutter_test/flutter_test.dart';
import 'package:disaster_rescue/features/evacuation/domain/evacuation_point_model.dart';
import 'package:disaster_rescue/features/evacuation/domain/evacuation_order_model.dart';

void main() {
  group('Evacuation & Logistics Inventory Engine', () {
    test('1. Evacuation Order Broadcast with Tày Translation', () {
      final order = EvacuationOrderModel(
        id: 'ord_01',
        targetVillages: ['Thôn Pắc Liềng', 'Thôn Nà Lầu'],
        targetPointId: 'point_01',
        targetPointName: 'Trường TH Bình Liêu',
        contentVi: 'Yêu cầu toàn bộ hộ dân Thôn Pắc Liềng và Nà Lầu khẩn trương di chuyển đến Trường TH Bình Liêu.',
        contentTay: 'Khẩn: Slống bản Pắc Liềng, Nà Lầu pây d\'ú Trường TH Bình Liêu phạ tấu sló!',
        senderId: 'admin_01',
        timestamp: DateTime.now(),
      );

      expect(order.targetVillages, contains('Thôn Pắc Liềng'));
      expect(order.contentTay, contains('Slống bản Pắc Liềng'));
    });

    test('2. Evacuation Point Capacity Calculation & Check-in Increments', () {
      final point = EvacuationPointModel(
        id: 'point_01',
        name: 'Trường TH Bình Liêu',
        latitude: 21.5430,
        longitude: 107.3990,
        capacity: 200,
        currentCount: 180,
        status: 'open',
        supplies: ['🦺 Áo phao', '🛏️ Chăn'],
        inChargeName: 'Nguyễn Văn Quản',
        inChargePhone: '0203.123.456',
        checkedInHouseholdIds: [],
      );

      // Check-in cho 5 người hộ mới tới
      final updatedPoint = point.copyWith(
        currentCount: point.currentCount + 5,
      );

      expect(updatedPoint.currentCount, equals(185));
      expect(updatedPoint.capacity - updatedPoint.currentCount, equals(15));
    });
  });
}
