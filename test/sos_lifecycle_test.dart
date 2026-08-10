import 'package:flutter_test/flutter_test.dart';
import 'package:disaster_rescue/features/sos/domain/sos_model.dart';
import 'package:disaster_rescue/features/sos/domain/sos_status.dart';

void main() {
  group('SOS Lifecycle & Priority Score Verification', () {
    test('1. SOS Request Creation & Initial State', () {
      final sos = SosRequestEntity(
        id: 'sos_test_01',
        householdId: 'hh_100',
        latitude: 21.5430,
        longitude: 107.3990,
        priorityScore: 85,
        status: SosStatus.pending,
        assignedTeamId: null,
        createdAt: DateTime.now(),
      );

      expect(sos.id, equals('sos_test_01'));
      expect(sos.status, equals(SosStatus.pending));
      expect(sos.assignedTeamId, isNull);
      expect(sos.priorityScore, equals(85));
    });

    test('2. Atomic SOS Team Assignment Transition', () {
      final initialSos = SosRequestEntity(
        id: 'sos_test_01',
        householdId: 'hh_100',
        latitude: 21.5430,
        longitude: 107.3990,
        priorityScore: 85,
        status: SosStatus.pending,
        assignedTeamId: null,
        createdAt: DateTime.now(),
      );

      // Admin gán Đội Dân quân Pắc Liềng (team_01)
      final assignedSos = initialSos.copyWith(
        status: SosStatus.assigned,
        assignedTeamId: 'team_01',
      );

      expect(assignedSos.status, equals(SosStatus.assigned));
      expect(assignedSos.assignedTeamId, equals('team_01'));
    });

    test('3. Rescue Team Acceptance & In-Progress State', () {
      final assignedSos = SosRequestEntity(
        id: 'sos_test_01',
        householdId: 'hh_100',
        latitude: 21.5430,
        longitude: 107.3990,
        priorityScore: 85,
        status: SosStatus.assigned,
        assignedTeamId: 'team_01',
        createdAt: DateTime.now(),
      );

      // Đội cứu hộ bấm "Tôi đi"
      final inProgressSos = assignedSos.copyWith(
        status: SosStatus.inProgress,
      );

      expect(inProgressSos.status, equals(SosStatus.inProgress));
    });

    test('4. Rescue Completion Transition', () {
      final inProgressSos = SosRequestEntity(
        id: 'sos_test_01',
        householdId: 'hh_100',
        latitude: 21.5430,
        longitude: 107.3990,
        priorityScore: 85,
        status: SosStatus.inProgress,
        assignedTeamId: 'team_01',
        createdAt: DateTime.now(),
      );

      // Hoàn thành cứu hộ
      final completedSos = inProgressSos.copyWith(
        status: SosStatus.completed,
      );

      expect(completedSos.status, equals(SosStatus.completed));
    });
  });
}
