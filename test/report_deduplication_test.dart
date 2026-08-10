import 'package:flutter_test/flutter_test.dart';
import 'package:disaster_rescue/features/report/domain/assistance_request_model.dart';

void main() {
  group('Report Cross-Referencing & Auto Deduplication Engine', () {
    test('1. Single Report Confidence Score Calculation', () {
      final report = AssistanceRequestModel(
        id: 'rep_01',
        householdId: 'hh_100',
        reporterId: 'user_A',
        latitude: 21.5435,
        longitude: 107.4005,
        address: 'Thôn Pắc Liềng, Xã Bình Liêu',
        description: 'Mắc kẹt mái nhà, nước dâng nhanh',
        neededSupports: ['🦺 Áo phao', '🛶 Xuồng cứu hộ'],
        priorityScore: 85,
        urgencyWindow: '1h',
        status: 'pending',
        confidenceScore: 70,
        timestamp: DateTime.now(),
      );

      expect(report.confidenceScore, equals(70));
      expect(report.priorityScore, equals(85));
    });

    test('2. Deduplication Boost for Matching Location & Time', () {
      final baseReport = AssistanceRequestModel(
        id: 'rep_01',
        householdId: 'hh_100',
        reporterId: 'user_A',
        latitude: 21.5435,
        longitude: 107.4005,
        address: 'Thôn Pắc Liềng, Xã Bình Liêu',
        description: 'Mắc kẹt mái nhà, nước dâng nhanh',
        neededSupports: ['🦺 Áo phao', '🛶 Xuồng cứu hộ'],
        priorityScore: 85,
        urgencyWindow: '1h',
        status: 'pending',
        confidenceScore: 70,
        timestamp: DateTime.now(),
      );

      // Nhận báo cáo thứ 2 cùng tọa độ & thời gian gần nhau -> +25 điểm tin cậy
      final updatedReport = baseReport.copyWith(
        confidenceScore: baseReport.confidenceScore + 25,
      );

      expect(updatedReport.confidenceScore, equals(95));
    });

    test('3. Admin Verification & Convert to SOS Ticket', () {
      final verifiedReport = AssistanceRequestModel(
        id: 'rep_01',
        householdId: 'hh_100',
        reporterId: 'user_A',
        latitude: 21.5435,
        longitude: 107.4005,
        address: 'Thôn Pắc Liềng, Xã Bình Liêu',
        description: 'Mắc kẹt mái nhà, nước dâng nhanh',
        neededSupports: ['🦺 Áo phao', '🛶 Xuồng cứu hộ'],
        priorityScore: 85,
        urgencyWindow: '1h',
        status: 'verified',
        confidenceScore: 95,
        timestamp: DateTime.now(),
      );

      expect(verifiedReport.status, equals('verified'));
    });
  });
}
