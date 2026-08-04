import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/report_models.dart';
import '../../../data/models/sos_models.dart';

class ReportState {
  final List<ThirdPartyReport> reports;

  const ReportState({
    this.reports = const [],
  });

  ReportState copyWith({
    List<ThirdPartyReport>? reports,
  }) {
    return ReportState(
      reports: reports ?? this.reports,
    );
  }

  List<ThirdPartyReport> get pendingReports =>
      reports.where((r) => r.status == ReportStatus.pendingVerification).toList();
}

class ReportNotifier extends StateNotifier<ReportState> {
  ReportNotifier() : super(ReportState(reports: _mockReports));

  void approveReport(String reportId) {
    final updated = state.reports.map((r) {
      if (r.reportId == reportId) {
        return r.copyWith(
          status: ReportStatus.approved,
          verifiedBy: 'admin_1',
          verifiedAt: DateTime.now(),
        );
      }
      return r;
    }).toList();
    state = state.copyWith(reports: updated);
    // In real app, this would also trigger SosRequest creation
  }

  void rejectReport(String reportId, String reason) {
    final updated = state.reports.map((r) {
      if (r.reportId == reportId) {
        return r.copyWith(
          status: ReportStatus.rejected,
          verifiedBy: 'admin_1',
          verifiedAt: DateTime.now(),
          rejectionReason: reason,
        );
      }
      return r;
    }).toList();
    state = state.copyWith(reports: updated);
  }

  void needMoreInfo(String reportId) {
    final updated = state.reports.map((r) {
      if (r.reportId == reportId) {
        return r.copyWith(
          status: ReportStatus.needMoreInfo,
        );
      }
      return r;
    }).toList();
    state = state.copyWith(reports: updated);
  }

  static final List<ThirdPartyReport> _mockReports = [
    ThirdPartyReport(
      reportId: 'rpt1',
      communeId: 'c1',
      sectorId: 'Thôn Nà Lầu',
      reportedByUserId: 'user1',
      location: '21.5, 107.4 (Cách 320m)',
      victimLocation: '21.503, 107.401',
      victimLocationAddress: 'Số 12, Thôn Nà Lầu',
      description: 'Hàng xóm đang bị ngập tầng 1, có người già bên trong.',
      photoUrls: [],
      disasterType: 'Lũ lụt',
      trustScore: 80,
      status: ReportStatus.pendingVerification,
      verifiedBy: null,
      verifiedAt: null,
      rejectionReason: null,
      createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
    ),
    ThirdPartyReport(
      reportId: 'rpt2',
      communeId: 'c1',
      sectorId: 'Thôn Đồng Văn',
      reportedByUserId: 'user2',
      location: '21.4, 107.5 (Cách 1.2km)',
      victimLocation: '21.41, 107.51',
      victimLocationAddress: 'Cuối Thôn Đồng Văn',
      description: 'Sạt lở đất chặn ngang đường, một số nhà bị cô lập.',
      photoUrls: [],
      disasterType: 'Sạt lở đất',
      trustScore: 45,
      status: ReportStatus.pendingVerification,
      verifiedBy: null,
      verifiedAt: null,
      rejectionReason: null,
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),
  ];
}

final reportProvider = StateNotifierProvider<ReportNotifier, ReportState>((ref) {
  return ReportNotifier();
});
