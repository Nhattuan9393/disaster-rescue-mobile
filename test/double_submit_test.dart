import 'package:flutter_test/flutter_test.dart';
import 'package:disaster_rescue/data/models/relief_models.dart';
import 'package:disaster_rescue/data/services/submission_guard.dart';

void main() {
  group('Kiểm thử Chống gửi trùng lặp (Double-Submit Prevention)', () {
    
    group('SOS Double-Submit:', () {
      test('Cho phép gửi SOS mới khi không có SOS hoạt động (null, completed, rejected, cancelled)', () {
        expect(SubmissionGuard.canSubmitSos(null), isTrue);
        expect(SubmissionGuard.canSubmitSos('completed'), isTrue);
        expect(SubmissionGuard.canSubmitSos('rejected'), isTrue);
        expect(SubmissionGuard.canSubmitSos('cancelled'), isTrue);
      });

      test('Chặn gửi SOS mới khi có SOS đang xử lý (pending, verified, assigned, in_progress)', () {
        expect(SubmissionGuard.canSubmitSos('pending'), isFalse);
        expect(SubmissionGuard.canSubmitSos('verified'), isFalse);
        expect(SubmissionGuard.canSubmitSos('assigned'), isFalse);
        expect(SubmissionGuard.canSubmitSos('in_progress'), isFalse);
      });
    });

    group('Cứu trợ trùng lặp trong 24 giờ:', () {
      final now = DateTime.now();
      final history = [
        ReliefReceipt(
          id: 'rec_1',
          householdId: 'house_A',
          distributedAt: now.subtract(const Duration(hours: 6)), // 6 giờ trước
          distributedBy: 'team_leader_1',
          source: SupplySource.communeWarehouse,
          items: const {'instant_noodles': 2.0},
          packageCode: null,
          note: null,
        ),
        ReliefReceipt(
          id: 'rec_2',
          householdId: 'house_A',
          distributedAt: now.subtract(const Duration(hours: 30)), // 30 giờ trước
          distributedBy: 'team_leader_1',
          source: SupplySource.communeWarehouse,
          items: const {'water': 5.0},
          packageCode: null,
          note: null,
        ),
      ];

      test('TC-DBL-03: Cảnh báo/Phát hiện trùng lặp mặt hàng cứu trợ trong vòng 24 giờ', () {
        final hasDuplicate = SubmissionGuard.hasDuplicateDistribution(
          householdId: 'house_A',
          itemId: 'instant_noodles',
          newTime: now,
          history: history,
        );

        expect(hasDuplicate, isTrue); // Mì tôm nhận 6 giờ trước -> Trùng lặp
      });

      test('TC-DBL-04: Cho phép phát hàng nếu mặt hàng khác hoặc đã quá 24 giờ', () {
        // Hộ A nhận nước suối 30 giờ trước -> Không trùng lặp
        final duplicateWater = SubmissionGuard.hasDuplicateDistribution(
          householdId: 'house_A',
          itemId: 'water',
          newTime: now,
          history: history,
        );
        expect(duplicateWater, isFalse);

        // Hộ A chưa nhận thuốc men -> Không trùng lặp
        final duplicateMedicine = SubmissionGuard.hasDuplicateDistribution(
          householdId: 'house_A',
          itemId: 'medicine',
          newTime: now,
          history: history,
        );
        expect(duplicateMedicine, isFalse);
      });
    });
  });
}
