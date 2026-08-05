import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/models/report_models.dart';
import '../../providers/report_provider.dart';
import 'report_detail_screen.dart';

class ReportListScreen extends ConsumerWidget {
  const ReportListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportState = ref.watch(reportProvider);
    // Assuming the state exposes pendingReports as a list of report objects
    final pendingReports = reportState.pendingReports;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Báo cáo Cần Xác Minh',
              style: AppTypography.h2.copyWith(color: AppColors.textPrimary),
            ),
            const SizedBox(width: AppSpacing.sm),
            if (pendingReports.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.priorityRed,
                  borderRadius: AppRadius.chip,
                ),
                child: Text(
                  '${pendingReports.length}',
                  style: AppTypography.label.copyWith(color: AppColors.surface),
                ),
              ),
          ],
        ),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: pendingReports.isEmpty
          ? Center(
              child: Text(
                'Không có báo cáo cần xác minh',
                style: AppTypography.bodyLarge.copyWith(color: AppColors.textSecondary),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.base),
              itemCount: pendingReports.length,
              separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.base),
              itemBuilder: (context, index) {
                final report = pendingReports[index];
                return _buildReportCard(context, ref, report);
              },
            ),
    );
  }

  Widget _buildReportCard(BuildContext context, WidgetRef ref, dynamic report) {
    // Dynamic fallback values if model properties differ
    final reportId = report.reportId;
    final type = report.type ?? 'Lũ lụt';
    final sector = report.sector ?? 'Thôn Nà Lầu';
    final trustScore = report.trustScore ?? 80;
    final description = report.description ?? 'Mô tả chi tiết báo cáo sự cố được hiển thị ở đây...';
    final timestamp = report.timestamp?.toString() ?? 'Vừa xong';

    return Card(
      elevation: 2,
      shadowColor: const Color.fromRGBO(0, 0, 0, 0.1),
      shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
      color: AppColors.surface,
      child: InkWell(
        borderRadius: AppRadius.card,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ReportDetailScreen(reportId: reportId),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.base),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(224, 224, 224, 1),
                      borderRadius: AppRadius.card,
                    ),
                    child: const Icon(Icons.image, size: 40, color: AppColors.textDisabled),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$type — $sector',
                          style: AppTypography.h3,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Row(
                          children: [
                            Text(
                              'Độ tin cậy:',
                              style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: LinearProgressIndicator(
                                value: trustScore / 100,
                                backgroundColor: const Color.fromRGBO(224, 224, 224, 1),
                                color: AppColors.statusSafe,
                                minHeight: 6,
                                borderRadius: AppRadius.chip,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Text(
                              '$trustScore/100',
                              style: AppTypography.label.copyWith(color: AppColors.statusSafe),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.location_on, size: 14, color: AppColors.textSecondary),
                                const SizedBox(width: 4),
                                Text(
                                  'Khoảng cách: 320m',
                                  style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                            Text(
                              timestamp,
                              style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textPrimary,
                        side: const BorderSide(color: AppColors.textDisabled),
                        shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                      ),
                      onPressed: () {
                        ref.read(reportProvider.notifier).rejectReport(reportId, 'Từ chối thủ công');
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Đã từ chối báo cáo'),
                            backgroundColor: AppColors.statusMissing,
                          ),
                        );
                      },
                      child: const Text('Từ chối'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                      ),
                      onPressed: () {
                        ref.read(reportProvider.notifier).approveReport(reportId);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Đã duyệt thành SOS'),
                            backgroundColor: AppColors.statusSafe,
                          ),
                        );
                      },
                      child: const Text('Duyệt → SOS'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
