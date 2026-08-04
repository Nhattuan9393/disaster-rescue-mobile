import '../models/relief_models.dart';

class ActiveSosException implements Exception {
  final String message;
  ActiveSosException(this.message);
  @override
  String toString() => 'ActiveSosException: $message';
}

class SubmissionGuard {
  SubmissionGuard._();

  /// Kiểm tra xem hộ dân có thể gửi SOS mới hay không.
  /// Sẽ trả về false nếu hộ dân đang có một SOS ở trạng thái hoạt động (active)
  static bool canSubmitSos(String? currentSosStatus) {
    if (currentSosStatus == null) return true;
    
    final activeStatuses = {'pending', 'verified', 'assigned', 'in_progress'};
    if (activeStatuses.contains(currentSosStatus)) {
      return false;
    }
    return true;
  }

  /// Kiểm tra xem có giao dịch phát cứu trợ trùng lặp cho cùng một hộ, cùng một loại hàng trong vòng 24 giờ hay không.
  static bool hasDuplicateDistribution({
    required String householdId,
    required String itemId,
    required DateTime newTime,
    required List<ReliefReceipt> history,
  }) {
    for (final receipt in history) {
      if (receipt.householdId == householdId && receipt.items.containsKey(itemId)) {
        // Tính khoảng cách thời gian giữa thời điểm đã phát và thời điểm phát mới
        final difference = newTime.difference(receipt.distributedAt).abs();
        if (difference.inHours < 24) {
          return true;
        }
      }
    }
    return false;
  }
}
