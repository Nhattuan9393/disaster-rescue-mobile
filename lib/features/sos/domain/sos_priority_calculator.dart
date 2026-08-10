import '../../household/domain/household_model.dart';

class SosPriorityCalculator {
  /// Tính toán điểm ưu tiên (0 - 100) dựa trên:
  /// - Đặc điểm hộ dân (Trẻ em, người già, người bệnh)
  /// - Tình trạng môi trường (Mực nước lũ)
  static int calculate({
    required HouseholdModel household,
    required bool isWaterAtRoof, // Mực nước ngập mái nhà (+20đ)
    required bool isInjured,    // Có người bị thương nặng (+20đ)
  }) {
    int score = 0;

    // 1. Kiểm tra các yếu tố nhạy cảm trong hộ dân
    if (household.sickCount > 0) {
      score += 20; // Có người bệnh
    }
    if (household.childrenCount > 0) {
      score += 15; // Có trẻ em
    }
    if (household.elderlyCount > 0) {
      score += 15; // Có người già
    }

    // 2. Yếu tố khẩn cấp bên ngoài
    if (isWaterAtRoof) {
      score += 20;
    }
    if (isInjured) {
      score += 20;
    }

    // 3. Quy đổi số lượng thành viên (nếu đông người cứu hộ cần ưu tiên hơn)
    if (household.memberCount > 5) {
      score += 10;
    }

    // Đảm bảo điểm nằm trong khoảng 0 - 100
    return score.clamp(0, 100);
  }
}
