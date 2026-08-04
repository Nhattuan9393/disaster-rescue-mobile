import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/team_models.dart';

/// State quản lý danh sách TẤT CẢ đội cứu hộ (dành cho Admin xã).
/// Khác với ActiveTeamNotifier (chỉ quản lý đội hiện tại đang đăng nhập).
class AdminTeamState {
  final List<RescueTeam> allTeams;
  final bool isLoading;

  const AdminTeamState({
    this.allTeams = const [],
    this.isLoading = false,
  });

  /// Lọc theo loại đội
  List<RescueTeam> get standingTeams =>
      allTeams.where((t) => t.type == TeamType.standing).toList();

  List<RescueTeam> get adhocTeams =>
      allTeams.where((t) => t.type == TeamType.adhoc).toList();

  /// Lọc theo trạng thái
  List<RescueTeam> get availableTeams =>
      allTeams.where((t) => t.status == TeamStatus.available).toList();

  List<RescueTeam> get onMissionTeams =>
      allTeams.where((t) => t.status == TeamStatus.onMission).toList();

  List<RescueTeam> get restingTeams =>
      allTeams.where((t) => t.status == TeamStatus.resting).toList();

  List<RescueTeam> get offlineTeams =>
      allTeams.where((t) => t.status == TeamStatus.offline).toList();

  /// Thống kê tổng quan
  int get totalMembers =>
      allTeams.fold(0, (sum, t) => sum + t.members.length);

  AdminTeamState copyWith({
    List<RescueTeam>? allTeams,
    bool? isLoading,
  }) {
    return AdminTeamState(
      allTeams: allTeams ?? this.allTeams,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class AdminTeamNotifier extends StateNotifier<AdminTeamState> {
  AdminTeamNotifier() : super(AdminTeamState(allTeams: _generateMockTeams()));

  /// Thêm đội thường trực mới
  void addStandingTeam({
    required String name,
    required String phone,
    required List<String> members,
    required Map<String, double> equipment,
    required String village,
  }) {
    final qrCode = 'DR-BL-DQ-${village.toUpperCase().replaceAll(' ', '')}${state.standingTeams.length + 1}'.substring(0, 16);
    final newTeam = RescueTeam(
      id: 'team_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      phone: phone,
      type: TeamType.standing,
      status: TeamStatus.ended, // Chưa kích hoạt
      members: members,
      equipment: equipment,
      supplies: const {},
      qrCode: qrCode,
      restingReason: null,
      returnTime: null,
      lastActive: DateTime.now(),
    );
    state = state.copyWith(allTeams: [...state.allTeams, newTeam]);
  }

  /// Cập nhật thông tin đội thường trực
  void updateTeam(String teamId, {
    String? name,
    String? phone,
    List<String>? members,
    Map<String, double>? equipment,
  }) {
    final updated = state.allTeams.map((team) {
      if (team.id == teamId) {
        return team.copyWith(
          name: name ?? team.name,
          phone: phone ?? team.phone,
          members: members ?? team.members,
          equipment: equipment ?? team.equipment,
          lastActive: DateTime.now(),
        );
      }
      return team;
    }).toList();
    state = state.copyWith(allTeams: updated);
  }

  /// Kích hoạt toàn bộ lực lượng thường trực (chuẩn bị trước mùa lũ)
  void activateAllStandingTeams() {
    final updated = state.allTeams.map((team) {
      if (team.type == TeamType.standing && team.status == TeamStatus.ended) {
        return team.copyWith(
          status: TeamStatus.available,
          lastActive: DateTime.now(),
        );
      }
      return team;
    }).toList();
    state = state.copyWith(allTeams: updated);
  }

  /// Đăng ký đội vãng lai đã được admin duyệt
  void approveAdhocTeam(String teamId) {
    final updated = state.allTeams.map((team) {
      if (team.id == teamId) {
        return team.copyWith(
          status: TeamStatus.available,
          lastActive: DateTime.now(),
        );
      }
      return team;
    }).toList();
    state = state.copyWith(allTeams: updated);
  }

  /// Xoá đội (chỉ đội chưa kích hoạt)
  void removeTeam(String teamId) {
    state = state.copyWith(
      allTeams: state.allTeams.where((t) => t.id != teamId).toList(),
    );
  }

  // ─── Mock Data ──────────────────────────────────────────────────
  static List<RescueTeam> _generateMockTeams() {
    return [
      RescueTeam(
        id: 'team_pl01',
        name: 'Dân quân thôn Pắc Liềng',
        phone: '0911222333',
        type: TeamType.standing,
        status: TeamStatus.available,
        members: const ['Nguyễn Văn Hải (Đội trưởng)', 'Lý Văn Nam', 'Chảo Sắn Mẩy', 'Lý Văn Sáng'],
        equipment: const {'Thuyền máy': 1, 'Áo phao': 12, 'Phao tròn': 4},
        supplies: const {},
        qrCode: 'DR-BL-DQ-PL01',
        restingReason: null,
        returnTime: null,
        lastActive: DateTime.now().subtract(const Duration(minutes: 15)),
      ),
      RescueTeam(
        id: 'team_nl02',
        name: 'Dân quân thôn Nà Lầu',
        phone: '0911555666',
        type: TeamType.standing,
        status: TeamStatus.onMission,
        members: const ['Lý A Sáng (Đội trưởng)', 'Hoàng Văn Tuyên', 'Tô Văn Bảy'],
        equipment: const {'Thuyền chèo': 1, 'Áo phao': 8},
        supplies: const {},
        qrCode: 'DR-BL-DQ-NL02',
        restingReason: null,
        returnTime: null,
        lastActive: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
      RescueTeam(
        id: 'team_cs03',
        name: 'Dân quân thôn Cao Sơn',
        phone: '0933444555',
        type: TeamType.standing,
        status: TeamStatus.resting,
        members: const ['Hoàng Minh Quang (Đội trưởng)', 'Lý Văn Dũng'],
        equipment: const {'Áo phao': 6, 'Dây thừng': 2},
        supplies: const {},
        qrCode: 'DR-BL-DQ-CS03',
        restingReason: 'Đội viên kiệt sức sau cứu hộ 3 hộ liên tiếp',
        returnTime: DateTime.now().add(const Duration(hours: 2)),
        lastActive: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      RescueTeam(
        id: 'team_dv04',
        name: 'Dân quân thôn Đồng Văn',
        phone: '0944666777',
        type: TeamType.standing,
        status: TeamStatus.ended,
        members: const ['Tô Thị Hoa (Đội trưởng)', 'Nguyễn Văn Bình', 'Lý Minh Trung', 'Hoàng Văn Long'],
        equipment: const {'Ca nô': 1, 'Áo phao': 16, 'Phao tròn': 6},
        supplies: const {},
        qrCode: 'DR-BL-DQ-DV04',
        restingReason: null,
        returnTime: null,
        lastActive: DateTime.now().subtract(const Duration(days: 2)),
      ),
      // Đội vãng lai
      RescueTeam(
        id: 'team_adhoc_mtq01',
        name: 'Đội MTQ Quảng Ninh',
        phone: '0977888999',
        type: TeamType.adhoc,
        status: TeamStatus.available,
        members: const ['Trần Đức Anh (Trưởng đoàn)', 'Phạm Văn Cường', 'Lê Minh Hoàng', 'Nguyễn Thị Lan', 'Đỗ Văn Khoa'],
        equipment: const {},
        supplies: const {'Mì tôm (thùng)': 10, 'Nước uống (thùng)': 5, 'Chăn': 20},
        qrCode: 'DR-BL-CHOT-01-MTQ01',
        restingReason: null,
        returnTime: null,
        lastActive: DateTime.now().subtract(const Duration(minutes: 30)),
      ),
      RescueTeam(
        id: 'team_adhoc_mtq02',
        name: 'Nhóm Thiện nguyện Hà Nội',
        phone: '0988111222',
        type: TeamType.adhoc,
        status: TeamStatus.onMission,
        members: const ['Vũ Hoàng Nam (Trưởng nhóm)', 'Nguyễn Thị Hương', 'Bùi Văn Đạt'],
        equipment: const {},
        supplies: const {'Gạo (bao)': 5, 'Thuốc y tế (hộp)': 3},
        qrCode: 'DR-BL-CHOT-01-MTQ02',
        restingReason: null,
        returnTime: null,
        lastActive: DateTime.now().subtract(const Duration(minutes: 10)),
      ),
    ];
  }
}

final adminTeamProvider = StateNotifierProvider<AdminTeamNotifier, AdminTeamState>((ref) {
  return AdminTeamNotifier();
});
