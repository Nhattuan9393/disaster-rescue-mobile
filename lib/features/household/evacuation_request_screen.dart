import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:disaster_rescue/core/theme/app_theme.dart';

/// Màn hình gửi yêu cầu hỗ trợ sơ tán chủ động (AssistanceRequest).
class EvacuationRequestScreen extends StatefulWidget {
  const EvacuationRequestScreen({super.key});

  @override
  State<EvacuationRequestScreen> createState() => _EvacuationRequestScreenState();
}

class _EvacuationRequestScreenState extends State<EvacuationRequestScreen> {
  final _noteController = TextEditingController();
  bool _needsVehicle = false;
  bool _hasElderlyOrDisabled = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã gửi yêu cầu hỗ trợ sơ tán thành công. SLA 3 giờ.')),
    );
    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Yêu cầu hỗ trợ sơ tán'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.base),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Card(
              color: AppColors.warningBanner,
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.base),
                child: Row(
                  children: [
                    Icon(Icons.info_rounded, color: AppColors.priorityOrange),
                    SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        'Đây là luồng hỗ trợ sơ tán chủ động (SLA 3 giờ). Nếu đang gặp nguy hiểm tính mạng tức thì, hãy trở về trang chủ và bấm nút SOS 1 chạm để được ứng cứu ngay!',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          fontFamily: AppTypography.fontFamily,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            const Text(
              'THÔNG TIN CẦN TRỢ GIÚP',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                fontFamily: AppTypography.fontFamily,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Card(
              shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.base),
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text(
                        'Cần phương tiện vận chuyển',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, fontFamily: AppTypography.fontFamily),
                      ),
                      subtitle: const Text('Hộ dân không tự di chuyển được (nhà ngập sâu hoặc không có xe)'),
                      value: _needsVehicle,
                      activeColor: AppColors.primary,
                      onChanged: (val) {
                        setState(() {
                          _needsVehicle = val;
                        });
                      },
                    ),
                    const Divider(),
                    SwitchListTile(
                      title: const Text(
                        'Có người già, trẻ nhỏ hoặc người tàn tật',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, fontFamily: AppTypography.fontFamily),
                      ),
                      subtitle: const Text('Cần lực lượng hỗ trợ khiêng vác, bế hoặc hỗ trợ y tế đặc biệt'),
                      value: _hasElderlyOrDisabled,
                      activeColor: AppColors.primary,
                      onChanged: (val) {
                        setState(() {
                          _hasElderlyOrDisabled = val;
                        });
                      },
                    ),
                    const Divider(),
                    const SizedBox(height: AppSpacing.sm),
                    TextFormField(
                      controller: _noteController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'Ghi chú nhu cầu chi tiết (ví dụ: cần xe lăn, thuốc men mang theo...)',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton(
              onPressed: _handleSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              ),
              child: const Text(
                'Gửi yêu cầu hỗ trợ',
                style: TextStyle(
                  color: AppColors.surface,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  fontFamily: AppTypography.fontFamily,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
