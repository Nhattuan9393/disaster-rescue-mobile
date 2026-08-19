/// Trạng thái vận hành của đội cứu hộ — theo màn "Trạng thái đội của tôi"
/// (thiết kế ảnh 5) + SRS FR-09.8.
enum RescueTeamStatus {
  available, // Sẵn sàng — nhận push SOS mới trong khu vực
  onMission, // Đang nhiệm vụ — hệ thống tự đặt khi bấm "Tôi đi"
  onBreak,   // Tạm nghỉ — KHÔNG nhận SOS mới; phải nhập giờ quay lại
  endShift,  // Kết thúc ca — rút khỏi đợt thiên tai này
  offline,   // Mất kết nối > 30 phút — hệ thống tự đặt, admin cảnh báo
}

extension RescueTeamStatusLabel on RescueTeamStatus {
  String get label {
    switch (this) {
      case RescueTeamStatus.available:
        return 'Sẵn sàng';
      case RescueTeamStatus.onMission:
        return 'Đang nhiệm vụ';
      case RescueTeamStatus.onBreak:
        return 'Tạm nghỉ';
      case RescueTeamStatus.endShift:
        return 'Kết thúc ca';
      case RescueTeamStatus.offline:
        return 'Mất kết nối';
    }
  }
}
