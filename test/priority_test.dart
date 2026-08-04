import 'package:flutter_test/flutter_test.dart';
import 'package:disaster_rescue/data/models/sos_models.dart';

void main() {
  group('Kiểm thử Tính điểm ưu tiên SOS (FR-02.3)', () {
    test('TC-PRI-01: SOS Trắng (Nhà cấp 4, người già, trẻ em) -> 40 điểm (Cam)', () {
      const context = SosContext(
        hasChildren: true,        // +15
        hasElderly: true,         // +15
        hasSeriouslyIll: false,
        hasDisabled: false,
        groundFloorFlooded: false,
        needsMedicine: false,
        waterLevel: WaterLevel.none,
        houseType: HouseType.level4, // +10
        peopleCount: 3,
      );

      final score = calculatePriority(context);
      final level = getPriorityLevel(score);

      expect(score, equals(40));
      expect(level, equals(PriorityLevel.orange));
    });

    test('TC-PRI-02: SOS Trắng hộ thường -> 0 điểm (Vàng)', () {
      const context = SosContext(
        hasChildren: false,
        hasElderly: false,
        hasSeriouslyIll: false,
        hasDisabled: false,
        groundFloorFlooded: false,
        needsMedicine: false,
        waterLevel: WaterLevel.none,
        houseType: HouseType.multiStory,
        peopleCount: 3,
      );

      final score = calculatePriority(context);
      final level = getPriorityLevel(score);

      expect(score, equals(0));
      expect(level, equals(PriorityLevel.yellow));
    });

    test('TC-PRI-03: SOS bổ sung thông tin khẩn cấp tối đa -> 80 điểm (Đỏ)', () {
      const context = SosContext(
        hasChildren: false,
        hasElderly: false,
        hasSeriouslyIll: true,     // +20
        hasDisabled: false,
        groundFloorFlooded: true,  // +15
        needsMedicine: true,       // +10
        waterLevel: WaterLevel.roof, // +20
        houseType: HouseType.level4, // +10
        peopleCount: 6,            // +5
      );

      final score = calculatePriority(context);
      final level = getPriorityLevel(score);

      expect(score, equals(80));
      expect(level, equals(PriorityLevel.red));
    });

    test('TC-PRI-04: Kiểm tra điểm biên (Cam tối thiểu: 40 điểm)', () {
      const context = SosContext(
        hasChildren: true,  // +15
        hasElderly: true,   // +15
        hasSeriouslyIll: false,
        hasDisabled: false,
        groundFloorFlooded: false,
        needsMedicine: false,
        waterLevel: WaterLevel.none,
        houseType: HouseType.level4, // +10
        peopleCount: 2,
      );

      final score = calculatePriority(context);
      final level = getPriorityLevel(score);

      expect(score, equals(40));
      expect(level, equals(PriorityLevel.orange));
    });

    test('TC-PRI-05: Kiểm tra điểm biên (Cam tối đa: 65 điểm)', () {
      const context = SosContext(
        hasChildren: true,        // +15
        hasElderly: true,         // +15
        hasSeriouslyIll: false,
        hasDisabled: true,         // +10
        groundFloorFlooded: true,  // +15
        needsMedicine: true,       // +10
        waterLevel: WaterLevel.none,
        houseType: HouseType.multiStory,
        peopleCount: 2,
      );

      final score = calculatePriority(context);
      final level = getPriorityLevel(score);

      expect(score, equals(65));
      expect(level, equals(PriorityLevel.orange));
    });

    test('TC-PRI-06: Kiểm tra điểm biên (Đỏ tối thiểu: 70 điểm)', () {
      const context = SosContext(
        hasChildren: true,         // +15
        hasElderly: true,          // +15
        hasSeriouslyIll: true,      // +20
        hasDisabled: false,
        groundFloorFlooded: false,
        needsMedicine: true,        // +10
        waterLevel: WaterLevel.none,
        houseType: HouseType.level4, // +10
        peopleCount: 2,
      );

      final score = calculatePriority(context);
      final level = getPriorityLevel(score);

      expect(score, equals(70));
      expect(level, equals(PriorityLevel.red));
    });
  });
}
