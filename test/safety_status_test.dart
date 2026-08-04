import 'package:flutter_test/flutter_test.dart';
import 'package:disaster_rescue/data/models/safety_models.dart';

void main() {
  group('Kiểm thử Thay đổi trạng thái an toàn đa nguồn (FR-07.3 & FR-06.3)', () {
    final now = DateTime.now();

    test('TC-SAF-01: Trưởng thôn (70) không thể ghi đè Hộ dân tự báo an toàn (90)', () {
      final current = SafetyStatus(
        status: SafetyState.safe,
        source: SafetySource.selfApp,
        verifiedBy: null,
        verifiedAt: now,
        confidence: SafetySource.selfApp.confidence, // 90
        note: null,
      );

      final update = SafetyStatus(
        status: SafetyState.missingContact,
        source: SafetySource.adminManual,
        verifiedBy: 'village_leader_id',
        verifiedAt: now.add(const Duration(minutes: 5)),
        confidence: SafetySource.adminManual.confidence, // 70
        note: 'Không gọi điện được',
      );

      // Việc cập nhật từ nguồn thấp hơn (70) lên cao hơn (90) phải ném ngoại lệ
      expect(
        () => updateSafetyStatus(current, update),
        throwsA(isA<InvalidSafetyTransitionException>()),
      );
    });

    test('TC-SAF-02: Đội cứu hộ (100) ghi đè thành công Trưởng thôn xác nhận tay (70)', () {
      final current = SafetyStatus(
        status: SafetyState.safe,
        source: SafetySource.adminManual,
        verifiedBy: 'village_leader_id',
        verifiedAt: now,
        confidence: SafetySource.adminManual.confidence, // 70
        note: 'Trưởng thôn thấy đi sơ tán rồi',
      );

      final update = SafetyStatus(
        status: SafetyState.sos,
        source: SafetySource.rescueTeam,
        verifiedBy: 'team_leader_id',
        verifiedAt: now.add(const Duration(minutes: 10)),
        confidence: SafetySource.rescueTeam.confidence, // 100
        note: 'Phát hiện bị ngập sâu tại tọa độ GPS',
      );

      // Cập nhật từ nguồn cao hơn (100) đè lên thấp hơn (70) phải thành công
      final result = updateSafetyStatus(current, update);

      expect(result.status, equals(SafetyState.sos));
      expect(result.source, equals(SafetySource.rescueTeam));
      expect(result.confidence, equals(100));
    });

    test('TC-SAF-04: Sơ tán Check-in (95) giải tỏa thành công trạng thái Mất liên lạc (70)', () {
      final current = SafetyStatus(
        status: SafetyState.missingContact,
        source: SafetySource.adminManual,
        verifiedBy: 'system',
        verifiedAt: now,
        confidence: SafetySource.adminManual.confidence, // 70
        note: 'Mất liên lạc quá 4 giờ',
      );

      final update = SafetyStatus(
        status: SafetyState.evacuated,
        source: SafetySource.evacuationCheckin,
        verifiedBy: 'evac_manager_id',
        verifiedAt: now.add(const Duration(minutes: 30)),
        confidence: SafetySource.evacuationCheckin.confidence, // 95
        note: 'Đã check-in tại trường tiểu học',
      );

      final result = updateSafetyStatus(current, update);

      expect(result.status, equals(SafetyState.evacuated));
      expect(result.source, equals(SafetySource.evacuationCheckin));
      expect(result.confidence, equals(95));
    });
  });
}
