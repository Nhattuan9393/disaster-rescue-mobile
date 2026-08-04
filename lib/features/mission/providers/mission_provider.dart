import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/relief_models.dart';

// ─── SOS Request Model ──────────────────────────────────────────────
enum SosStatus { pending, verified, assigned, inProgress, completed, rejected, cancelled }

class SosRequest {
  final String id;
  final String householdId;
  final String householdName; // Ẩn khi chưa nhận
  final String phone;         // Ẩn khi chưa nhận
  final String address;       // Ẩn khi chưa nhận
  final String village;       // Khu vực chung (luôn hiển thị)
  final int memberCount;
  final int priorityScore;
  final String disasterType;
  final String waterLevel;
  final List<String> vulnerabilities; // Người già, trẻ em, cấp 4...
  final List<String> emergencyChips;
  final List<String> photos;
  final double lat;
  final double lng;
  final double? distanceKm;
  final SosStatus status;
  final String? assignedTeamId;
  final String? assignedTeamName;
  final DateTime createdAt;

  SosRequest({
    required this.id,
    required this.householdId,
    required this.householdName,
    required this.phone,
    required this.address,
    required this.village,
    required this.memberCount,
    required this.priorityScore,
    required this.disasterType,
    required this.waterLevel,
    this.vulnerabilities = const [],
    this.emergencyChips = const [],
    this.photos = const [],
    required this.lat,
    required this.lng,
    this.distanceKm,
    this.status = SosStatus.pending,
    this.assignedTeamId,
    this.assignedTeamName,
    required this.createdAt,
  });

  SosRequest copyWith({
    SosStatus? status,
    String? assignedTeamId,
    String? assignedTeamName,
    double? distanceKm,
  }) {
    return SosRequest(
      id: id,
      householdId: householdId,
      householdName: householdName,
      phone: phone,
      address: address,
      village: village,
      memberCount: memberCount,
      priorityScore: priorityScore,
      disasterType: disasterType,
      waterLevel: waterLevel,
      vulnerabilities: vulnerabilities,
      emergencyChips: emergencyChips,
      photos: photos,
      lat: lat,
      lng: lng,
      distanceKm: distanceKm ?? this.distanceKm,
      status: status ?? this.status,
      assignedTeamId: assignedTeamId ?? this.assignedTeamId,
      assignedTeamName: assignedTeamName ?? this.assignedTeamName,
      createdAt: createdAt,
    );
  }

  /// Hiển thị tên khi đã nhận nhiệm vụ, ẩn nếu chưa
  String maskedName(bool isAssigned) => isAssigned ? householdName : '••• (Nhận để xem)';
  String maskedPhone(bool isAssigned) => isAssigned ? phone : '••••••••••';
  String maskedAddress(bool isAssigned) => isAssigned ? address : '$village (vị trí ước tính)';

  String get priorityLabel {
    if (priorityScore >= 70) return 'KHẨN CẤP';
    if (priorityScore >= 40) return 'NGUY HIỂM';
    return 'CẦN HỖ TRỢ';
  }
}

// ─── Mission Completion Report ──────────────────────────────────────
enum HealthStatus { good, stable, needsMedical }

class MissionReport {
  final String sosId;
  final String householdId;
  final int rescuedCount;
  final HealthStatus healthStatus;
  final String? photoBefore;
  final String? photoAfter;
  final List<ReliefDistributionItem> distributedItems;
  final String? notes;
  final DateTime completedAt;

  MissionReport({
    required this.sosId,
    required this.householdId,
    required this.rescuedCount,
    required this.healthStatus,
    this.photoBefore,
    this.photoAfter,
    this.distributedItems = const [],
    this.notes,
    required this.completedAt,
  });
}

class ReliefDistributionItem {
  final String itemName;
  final int quantity;
  final String unit;
  final SupplySource source;

  ReliefDistributionItem({
    required this.itemName,
    required this.quantity,
    required this.unit,
    required this.source,
  });
}

// ─── Safety Verification Data ───────────────────────────────────────
enum PostRescueLocation { evacuationPoint, stayHome, medicalFacility }

class SafetyVerification {
  final String householdId;
  final int presentCount;
  final int totalCount;
  final PostRescueLocation location;
  final int injuredCount;
  final String? photoPath;
  final double? gpsLat;
  final double? gpsLng;
  final DateTime verifiedAt;

  SafetyVerification({
    required this.householdId,
    required this.presentCount,
    required this.totalCount,
    required this.location,
    this.injuredCount = 0,
    this.photoPath,
    this.gpsLat,
    this.gpsLng,
    required this.verifiedAt,
  });
}

// ─── Mission State ──────────────────────────────────────────────────
class MissionState {
  final List<SosRequest> sosList;
  final SosRequest? activeMission; // Nhiệm vụ đang thực hiện
  final bool isLoading;

  const MissionState({
    this.sosList = const [],
    this.activeMission,
    this.isLoading = false,
  });

  MissionState copyWith({
    List<SosRequest>? sosList,
    SosRequest? activeMission,
    bool? isLoading,
    bool clearActiveMission = false,
  }) {
    return MissionState(
      sosList: sosList ?? this.sosList,
      activeMission: clearActiveMission ? null : (activeMission ?? this.activeMission),
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// ─── Mission Provider (Riverpod StateNotifier) ──────────────────────
final missionProvider = StateNotifierProvider<MissionNotifier, MissionState>((ref) {
  return MissionNotifier();
});

class MissionNotifier extends StateNotifier<MissionState> {
  MissionNotifier() : super(MissionState(sosList: _generateMockSosList()));

  /// Nhận nhiệm vụ: chuyển SOS sang assigned, mở khóa thông tin hộ
  void acceptMission(String sosId, String teamId, String teamName) {
    final updated = state.sosList.map((sos) {
      if (sos.id == sosId) {
        return sos.copyWith(
          status: SosStatus.assigned,
          assignedTeamId: teamId,
          assignedTeamName: teamName,
        );
      }
      return sos;
    }).toList();

    final accepted = updated.firstWhere((s) => s.id == sosId);
    state = state.copyWith(sosList: updated, activeMission: accepted);
  }

  /// Hoàn thành nhiệm vụ: chuyển SOS sang completed, giải phóng đội
  void completeMission(MissionReport report) {
    final updated = state.sosList.map((sos) {
      if (sos.id == report.sosId) {
        return sos.copyWith(status: SosStatus.completed);
      }
      return sos;
    }).toList();

    state = state.copyWith(sosList: updated, clearActiveMission: true);
  }

  /// Xác nhận hộ an toàn tại hiện trường
  void verifySafety(SafetyVerification verification) {
    // Trong thực tế sẽ gọi API cập nhật SafetyStatus
    // Ở đây chỉ ghi nhận xác nhận thành công
  }

  // ─── Mock Data ──────────────────────────────────────────────────
  static List<SosRequest> _generateMockSosList() {
    return [
      SosRequest(
        id: 'SOS-0042',
        householdId: 'HH-001',
        householdName: 'Nguyễn Văn Hùng',
        phone: '0912345678',
        address: 'Nhà số 12, Thôn Pắc Liềng',
        village: 'Thôn Pắc Liềng',
        memberCount: 5,
        priorityScore: 75,
        disasterType: 'Lũ lụt',
        waterLevel: 'Ngang tầng 1',
        vulnerabilities: ['Người già', 'Trẻ em'],
        emergencyChips: ['Nước dâng nhanh', 'Cần ca nô'],
        photos: [],
        lat: 21.5247,
        lng: 107.4858,
        distanceKm: 1.2,
        status: SosStatus.verified,
        createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
      ),
      SosRequest(
        id: 'SOS-0043',
        householdId: 'HH-002',
        householdName: 'Trần Thị Mai',
        phone: '0987654321',
        address: 'Nhà cạnh suối, Thôn Đồng Văn',
        village: 'Thôn Đồng Văn',
        memberCount: 3,
        priorityScore: 55,
        disasterType: 'Sạt lở',
        waterLevel: 'Không ngập',
        vulnerabilities: ['Nhà cấp 4'],
        emergencyChips: ['Nguy cơ sạt lở'],
        photos: [],
        lat: 21.5310,
        lng: 107.4920,
        distanceKm: 2.8,
        status: SosStatus.verified,
        createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
      ),
      SosRequest(
        id: 'SOS-0044',
        householdId: 'HH-003',
        householdName: 'Lý Văn Sơn',
        phone: '0976543210',
        address: 'Nhà đầu bản, Thôn Cao Sơn',
        village: 'Thôn Cao Sơn',
        memberCount: 7,
        priorityScore: 85,
        disasterType: 'Lũ lụt',
        waterLevel: 'Ngang mái nhà',
        vulnerabilities: ['Người già', 'Trẻ em', 'Người khuyết tật'],
        emergencyChips: ['Nước dâng nhanh', 'Mắc kẹt tầng 2', 'Cần ca nô'],
        photos: [],
        lat: 21.5180,
        lng: 107.4780,
        distanceKm: 0.8,
        status: SosStatus.verified,
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      SosRequest(
        id: 'SOS-0045',
        householdId: 'HH-004',
        householdName: 'Hoàng Thị Lan',
        phone: '0965432109',
        address: 'Khu nhà ven sông, Thôn Pắc Liềng',
        village: 'Thôn Pắc Liềng',
        memberCount: 2,
        priorityScore: 30,
        disasterType: 'Lũ lụt',
        waterLevel: 'Sân nhà',
        vulnerabilities: [],
        emergencyChips: [],
        photos: [],
        lat: 21.5260,
        lng: 107.4870,
        distanceKm: 1.5,
        status: SosStatus.assigned,
        assignedTeamId: 'TEAM-DQ-01',
        assignedTeamName: 'Đội Dân quân',
        createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
      ),
    ];
  }
}
