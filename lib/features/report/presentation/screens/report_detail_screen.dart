import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../data/models/report_models.dart';
import '../../providers/report_provider.dart';

class ReportDetailScreen extends ConsumerWidget {
  final String reportId;

  const ReportDetailScreen({
    super.key,
    required this.reportId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportState = ref.watch(reportProvider);
    final report = reportState.reports.firstWhere(
      (r) => r.reportId == reportId,
      orElse: () => ThirdPartyReport(
        reportId: reportId,
        communeId: '',
        sectorId: 'Không xác định',
        reportedByUserId: 'Unknown',
        location: '',
        victimLocation: '',
        victimLocationAddress: '',
        description: 'Không tìm thấy báo cáo này',
        photoUrls: [],
        disasterType: 'Không xác định',
        trustScore: 0,
        status: ReportStatus.pendingVerification,
        verifiedBy: null,
        verifiedAt: null,
        rejectionReason: null,
        createdAt: DateTime.now(),
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('← Xác minh báo cáo'),
        centerTitle: true,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 1,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.md),
            child: Center(
              child: Text(
                '1/4',
                style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // TOP: Placeholder 2-point Map
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey.shade800,
                borderRadius: AppRadius.card,
              ),
              child: const Center(
                child: Text(
                  'Bản đồ 2 điểm: 📱 Người báo ↔ 🆘 Nạn nhân',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            
            _buildReportInfoCard(report),
            const SizedBox(height: AppSpacing.md),
            
            _buildTrustScoreCard(report),
            const SizedBox(height: AppSpacing.md),
            
            _buildReporterProfileCard(report),
            const SizedBox(height: AppSpacing.xl),
            
            _buildActionButtons(context, ref),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  Widget _buildReportInfoCard(ThirdPartyReport report) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.base),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Thông tin báo cáo',
              style: AppTypography.h3,
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: AppColors.primary, size: 20),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    '${report.disasterType} — ${report.sectorId}',
                    style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                const Icon(Icons.location_on, color: AppColors.textSecondary, size: 20),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Khu vực: ${report.victimLocationAddress}',
                  style: AppTypography.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              report.description,
              style: AppTypography.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.base),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: AppRadius.card,
                    ),
                    child: const Center(
                      child: Icon(Icons.image, color: Colors.grey, size: 40),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Container(
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: AppRadius.card,
                    ),
                    child: const Center(
                      child: Icon(Icons.image, color: Colors.grey, size: 40),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrustScoreCard(ThirdPartyReport report) {
    final double trustScore = report.trustScore > 0 ? report.trustScore.toDouble() : 80.0;
    
    Color scoreColor = AppColors.primary;
    if (trustScore > 70) {
      scoreColor = AppColors.statusSafe;
    } else if (trustScore > 40) {
      scoreColor = AppColors.priorityOrange;
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.base),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Độ tin cậy',
                  style: AppTypography.h3,
                ),
                Text(
                  '${trustScore.toInt()}/100',
                  style: AppTypography.h2.copyWith(color: scoreColor),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: trustScore / 100,
                backgroundColor: Colors.grey.shade300,
                color: scoreColor,
                minHeight: 8,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _buildTrustCriteria('Có ảnh hiện trường', '+20', AppColors.statusSafe),
            _buildTrustCriteria('GPS người báo < 500m', '+15', AppColors.statusSafe),
            _buildTrustCriteria('Cross-reference (nhiều người báo)', '+25', AppColors.statusSafe),
          ],
        ),
      ),
    );
  }

  Widget _buildTrustCriteria(String label, String score, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle, size: 16, color: color),
              const SizedBox(width: AppSpacing.sm),
              Text(label, style: AppTypography.bodyMedium),
            ],
          ),
          Text(
            score,
            style: AppTypography.bodyMedium.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReporterProfileCard(ThirdPartyReport report) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.base),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.infoBlue,
              child: Icon(Icons.person, color: Colors.white),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Người báo: ${report.reportedByUserId}',
                    style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Đã báo cáo 5 lần (Tỷ lệ chính xác 90%)',
                    style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Chức năng Hỏi thêm đang phát triển')),
                  );
                },
                child: const Text('💬 Hỏi thêm'),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                ),
                onPressed: () {
                  ref.read(reportProvider.notifier).rejectReport(reportId, 'Từ chối thủ công');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đã từ chối báo cáo')),
                  );
                  Navigator.pop(context);
                },
                child: const Text('✕ Từ chối'),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.surface,
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
          ),
          onPressed: () {
            ref.read(reportProvider.notifier).approveReport(reportId);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Đã duyệt báo cáo và tạo SOS')),
            );
            Navigator.pop(context);
          },
          child: const Text(
            '✓ DUYỆT → TẠO SOS',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
      ],
    );
  }
}
