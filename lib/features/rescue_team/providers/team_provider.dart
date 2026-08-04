import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/team_models.dart';

// Danh sách đội thường trực có sẵn để đối chiếu (Mock database)
final mockStandingTeams = <String, RescueTeam>{
  'DR-BL-DQ-PL01': RescueTeam(
    id: 'team_pl01',
    name: 'Dân quân thôn Pắc Liềng',
    phone: '0911222333',
    type: TeamType.standing,
    status: TeamStatus.available,
    members: const ['Nguyễn Văn Hải (Trưởng đội)', 'Lý Văn Nam', 'Chảo Sắn Mẩy', 'Lý Văn Sáng'],
    equipment: const {'Thuyền máy': 1.0, 'Áo phao': 12.0, 'Phao tròn': 4.0},
    supplies: const {},
    qrCode: 'DR-BL-DQ-PL01',
    restingReason: null,
    returnTime: null,
    lastActive: DateTime.now(),
  ),
  'DR-BL-DQ-NL02': RescueTeam(
    id: 'team_nl02',
    name: 'Dân quân thôn Nà Lầu',
    phone: '0911555666',
    type: TeamType.standing,
    status: TeamStatus.available,
    members: const ['Lý A Sáng (Trưởng đội)', 'Hoàng Văn Tuyên', 'Tô Văn Bảy'],
    equipment: const {'Thuyền chèo': 1.0, 'Áo phao': 8.0},
    supplies: const {},
    qrCode: 'DR-BL-DQ-NL02',
    restingReason: null,
    returnTime: null,
    lastActive: DateTime.now(),
  ),
};

class ActiveTeamState {
  final RescueTeam? currentTeam;
  final bool isPendingApproval; // Cho đội vãng lai đang chờ admin duyệt
  final String? errorMessage;

  ActiveTeamState({
    this.currentTeam,
    this.isPendingApproval = false,
    this.errorMessage,
  });

  ActiveTeamState copyWith({
    RescueTeam? currentTeam,
    bool? isPendingApproval,
    String? errorMessage,
  }) {
    return ActiveTeamState(
      currentTeam: currentTeam ?? this.currentTeam,
      isPendingApproval: isPendingApproval ?? this.isPendingApproval,
      errorMessage: errorMessage,
    );
  }
}

class ActiveTeamNotifier extends StateNotifier<ActiveTeamState> {
  ActiveTeamNotifier() : super(ActiveTeamState());

  /// Xử lý quét mã QR tại chốt.
  /// Trả về true nếu là đội thường trực (kích hoạt ngay), false nếu cần điền form đăng ký đội vãng lai.
  bool handleQrScan(String qrCode) {
    state = ActiveTeamState(); // Reset error
    
    if (mockStandingTeams.containsKey(qrCode)) {
      final team = mockStandingTeams[qrCode]!;
      // Đội thường trực: Kích hoạt ngay
      state = ActiveTeamState(
        currentTeam: team.copyWith(
          status: TeamStatus.available,
          lastActive: DateTime.now(),
        ),
      );
      return true; 
    } else {
      // Mã lạ hoặc mã chốt (ví dụ: DR-BL-CHOT-01) -> Cần đăng ký mới
      return false;
    }
  }

  /// Đăng ký đội vãng lai (MTQ) mới
  void registerAdhocTeam({
    required String name,
    required String phone,
    required List<String> members,
    required Map<String, double> supplies,
    required String qrCode,
  }) {
    final newTeam = RescueTeam(
      id: 'team_adhoc_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      phone: phone,
      type: TeamType.adhoc,
      status: TeamStatus.available, // Sẽ ở dạng available sau khi admin duyệt
      members: members,
      equipment: const {},
      supplies: supplies,
      qrCode: qrCode,
      restingReason: null,
      returnTime: null,
      lastActive: DateTime.now(),
    );

    // Chuyển sang trạng thái chờ duyệt
    state = ActiveTeamState(
      currentTeam: newTeam,
      isPendingApproval: true,
    );
  }

  /// Giả lập Admin phê duyệt đội vãng lai
  void approveAdhocTeam() {
    if (state.currentTeam != null && state.isPendingApproval) {
      state = ActiveTeamState(
        currentTeam: state.currentTeam!.copyWith(
          status: TeamStatus.available,
          lastActive: DateTime.now(),
        ),
        isPendingApproval: false,
      );
    }
  }

  /// Cập nhật trạng thái hoạt động của đội (available, resting, ended)
  void updateStatus(TeamStatus newStatus, {String? reason, DateTime? returnTime}) {
    if (state.currentTeam == null) return;

    state = state.copyWith(
      currentTeam: state.currentTeam!.copyWith(
        status: newStatus,
        restingReason: newStatus == TeamStatus.resting ? reason : null,
        returnTime: newStatus == TeamStatus.resting ? returnTime : null,
        lastActive: DateTime.now(),
      ),
    );
  }

  /// Rút đội / Đăng xuất
  void logout() {
    state = ActiveTeamState();
  }
}

final activeTeamProvider = StateNotifierProvider<ActiveTeamNotifier, ActiveTeamState>((ref) {
  return ActiveTeamNotifier();
});
