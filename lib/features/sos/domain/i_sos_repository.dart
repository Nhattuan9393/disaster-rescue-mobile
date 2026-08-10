import '../domain/sos_model.dart';
import '../domain/sos_status.dart';

abstract class ISosRepository {
  /// Lấy dòng dữ liệu SOS realtime theo thời gian thực (cho Admin/Cứu hộ)
  Stream<List<SosRequestEntity>> watchSosRequests();

  /// Gửi yêu cầu cứu hộ khẩn cấp
  Future<void> sendSosRequest(SosRequestEntity request);

  /// Cập nhật trạng thái cứu hộ (VD: assigned, completed)
  Future<void> updateSosStatus(String id, SosStatus status);

  /// Gán đội cứu hộ cho SOS (Sử dụng Transaction/Atomic để tránh tranh chấp)
  Future<void> assignRescueTeam(String sosId, String teamId);

  /// Lấy toàn bộ hàng đợi SOS chưa đồng bộ ở local
  Future<List<SosRequestEntity>> getOfflineQueue();

  /// Xóa yêu cầu khỏi hàng đợi sau khi đã sync thành công
  Future<void> removeFromFileQueue(String id);
}
