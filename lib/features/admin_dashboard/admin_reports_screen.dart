import 'package:flutter/material.dart';
import 'package:disaster_rescue/core/theme/app_theme.dart';

/// Màn hình Phê duyệt Báo cáo cứu trợ / Báo tin hộ dân (FR-03, FR-06).
class AdminReportsScreen extends StatelessWidget {
  const AdminReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock danh sách báo cáo chờ xác minh
    final reports = [
      {
        'id': 'BC-001',
        'reporter': 'Lê Văn Nam',
        'reporterPhone': '0981122334',
        'target': 'Hộ cụ Lò Văn Hinh (neo đơn)',
        'village': 'Thôn Khe Tiền',
        'description': 'Mái tôn tốc một nửa, cụ bị đau chân không tự sơ tán được, nước đang ngấp nghé sân.',
        'confidence': 85,
      },
      {
        'id': 'BC-002',
        'reporter': 'Hoàng Thị Hoa',
        'reporterPhone': '0945566778',
        'target': 'Khu vực Cầu Khe Tiền',
        'village': 'Thôn Khe Tiền',
        'description': 'Cầu bị sạt hai bên đầu cầu, ô tô không đi qua được, chỉ xe máy lách qua.',
        'confidence': 60,
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.base),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Danh sách tin báo chờ duyệt (Luồng B & C)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                fontFamily: AppTypography.fontFamily,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Expanded(
              child: ListView.separated(
                itemCount: reports.length,
                separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                itemBuilder: (context, index) {
                  final r = reports[index];
                  final confidence = r['confidence'] as int;

                  return Card(
                    shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.base),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Mã: ${r['id']}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: AppColors.primary,
                                  fontFamily: AppTypography.fontFamily,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: confidence >= 70
                                      ? AppColors.statusSafe.withOpacity(0.12)
                                      : AppColors.priorityOrange.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'Độ tin cậy: $confidence%',
                                  style: TextStyle(
                                    color: confidence >= 70 ? AppColors.statusSafe : AppColors.priorityOrange,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: AppTypography.fontFamily,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            'Người báo: ${r['reporter']} (${r['reporterPhone']})',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              fontFamily: AppTypography.fontFamily,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Đối tượng: ${r['target']} - ${r['village']}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                              fontFamily: AppTypography.fontFamily,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            '${r['description']}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textPrimary,
                              fontFamily: AppTypography.fontFamily,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              OutlinedButton(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Đã từ chối tin báo.')),
                                  );
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.textSecondary,
                                  side: BorderSide(color: AppColors.textSecondary.withOpacity(0.5)),
                                ),
                                child: const Text('Từ chối'),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              ElevatedButton(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Đã duyệt tin báo thành SOS khẩn cấp!')),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.statusSafe,
                                  foregroundColor: AppColors.surface,
                                ),
                                child: const Text('Duyệt & Tạo SOS'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
