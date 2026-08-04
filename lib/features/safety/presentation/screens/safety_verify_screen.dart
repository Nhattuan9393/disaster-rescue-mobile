import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/quantity_stepper.dart';
import '../../../mission/providers/mission_provider.dart';

class SafetyVerifyScreen extends ConsumerStatefulWidget {
  final String householdId;
  final String householdName;
  final int totalMembers;

  const SafetyVerifyScreen({
    Key? key,
    required this.householdId,
    required this.householdName,
    required this.totalMembers,
  }) : super(key: key);

  @override
  ConsumerState<SafetyVerifyScreen> createState() => _SafetyVerifyScreenState();
}

class _SafetyVerifyScreenState extends ConsumerState<SafetyVerifyScreen> {
  late int _presentCount;
  PostRescueLocation? _selectedLocation;
  int _injuredCount = 0;

  @override
  void initState() {
    super.initState();
    _presentCount = widget.totalMembers;
  }

  void _submit() {
    if (_selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn tình trạng sau cứu hộ')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã xác nhận hộ an toàn thành công!')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Xác nhận an toàn'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.base),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildInfoBox(),
            const SizedBox(height: AppSpacing.base),
            _buildHouseholdInfoCard(),
            const SizedBox(height: AppSpacing.base),
            _buildLocationSection(),
            if (_selectedLocation == PostRescueLocation.medicalFacility || _injuredCount > 0) ...[
              const SizedBox(height: AppSpacing.base),
              _buildMedicalSection(),
            ],
            const SizedBox(height: AppSpacing.base),
            _buildPhotoSection(),
            const SizedBox(height: AppSpacing.base),
            _buildPreviewCard(),
            const SizedBox(height: AppSpacing.xl),
            ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.statusSafe,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.base),
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.card,
                ),
              ),
              child: Text(
                '✓ XÁC NHẬN HỘ NÀY AN TOÀN',
                style: AppTypography.h3.copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBox() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.statusSafe.withValues(alpha: 0.1),
        borderRadius: AppRadius.card,
        border: Border.all(color: AppColors.statusSafe.withValues(alpha: 0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.verified_user, color: AppColors.statusSafe),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              'Nguồn xác nhận tin cậy CAO NHẤT (100 điểm). Kèm ảnh + GPS + thời gian. Dùng khi hộ mất điện thoại, hết pin, hoặc không dùng được app.',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.statusSafe),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHouseholdInfoCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.householdName, style: AppTypography.h3),
            const SizedBox(height: AppSpacing.xs),
            Text('Số người theo hồ sơ: ${widget.totalMembers}', style: AppTypography.bodyMedium),
            const Divider(height: AppSpacing.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Số người có mặt:', style: AppTypography.label),
                QuantityStepper(
                  value: _presentCount,
                  min: 0,
                  max: widget.totalMembers * 2,
                  onChanged: (val) {
                    setState(() {
                      _presentCount = val.toInt();
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            if (_presentCount == widget.totalMembers)
              Text(
                '✓ Đủ ${widget.totalMembers}/${widget.totalMembers} người theo hồ sơ',
                style: AppTypography.bodyMedium.copyWith(color: AppColors.statusSafe, fontWeight: FontWeight.bold),
              )
            else
              Text(
                '⚠ Chỉ có $_presentCount/${widget.totalMembers} người — cần ghi chú lý do',
                style: AppTypography.bodyMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Tình trạng sau cứu hộ', style: AppTypography.h3),
        const SizedBox(height: AppSpacing.md),
        _buildLocationCard(
          location: PostRescueLocation.evacuationPoint,
          icon: '🏫',
          title: 'Đã đưa tới điểm sơ tán',
          subtitle: 'Tự động check-in tại điểm sơ tán',
        ),
        const SizedBox(height: AppSpacing.sm),
        _buildLocationCard(
          location: PostRescueLocation.stayHome,
          icon: '🏠',
          title: 'Ở lại nhà — đã an toàn',
          subtitle: 'Nhà không bị ảnh hưởng thêm',
        ),
        const SizedBox(height: AppSpacing.sm),
        _buildLocationCard(
          location: PostRescueLocation.medicalFacility,
          icon: '🚑',
          title: 'Đã chuyển tới cơ sở y tế',
          subtitle: 'Nạn nhân thương tích cần theo dõi',
        ),
      ],
    );
  }

  Widget _buildLocationCard({
    required PostRescueLocation location,
    required String icon,
    required String title,
    required String subtitle,
  }) {
    final isSelected = _selectedLocation == location;
    return InkWell(
      onTap: () => setState(() => _selectedLocation = location),
      borderRadius: AppRadius.card,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.infoBlue.withValues(alpha: 0.1) : AppColors.surface,
          borderRadius: AppRadius.card,
          border: Border.all(
            color: isSelected ? AppColors.infoBlue : AppColors.textDisabled.withValues(alpha: 0.5),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.h3.copyWith(
                      color: isSelected ? AppColors.infoBlue : AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            Radio<PostRescueLocation>(
              value: location,
              groupValue: _selectedLocation,
              onChanged: (val) => setState(() => _selectedLocation = val),
              activeColor: AppColors.infoBlue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicalSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Số người bị thương cần y tế:',
                style: AppTypography.label,
              ),
            ),
            QuantityStepper(
              value: _injuredCount,
              min: 0,
              max: _presentCount,
              onChanged: (val) {
                setState(() {
                  _injuredCount = val.toInt();
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Ảnh xác nhận (bắt buộc)', style: AppTypography.h3),
        const SizedBox(height: AppSpacing.sm),
        InkWell(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Mở camera...')),
            );
          },
          borderRadius: AppRadius.card,
          child: Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: AppRadius.card,
              border: Border.all(
                color: AppColors.textDisabled,
                style: BorderStyle.solid, 
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.camera_alt, size: 48, color: AppColors.textSecondary),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Chạm để chụp ảnh xác nhận',
                  style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Tự động đính kèm GPS + Thời gian',
          style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildPreviewCard() {
    return Card(
      elevation: 0,
      color: AppColors.infoBlue.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.card,
        side: BorderSide(color: AppColors.infoBlue.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ghi vào hồ sơ hộ', style: AppTypography.h3),
            const SizedBox(height: AppSpacing.md),
            _buildPreviewRow('Trạng thái:', _buildChip('safe', AppColors.statusSafe)),
            const SizedBox(height: AppSpacing.xs),
            _buildPreviewRow('Nguồn:', _buildChip('rescue_team', AppColors.infoBlue)),
            const SizedBox(height: AppSpacing.xs),
            _buildPreviewRow('Xác nhận bởi:', Text('Đội của tôi', style: AppTypography.bodyMedium)),
            const SizedBox(height: AppSpacing.xs),
            _buildPreviewRow('Độ tin cậy:', Text('100', style: AppTypography.bodyMedium.copyWith(color: AppColors.statusSafe, fontWeight: FontWeight.bold))),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewRow(String label, Widget value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary)),
        value,
      ],
    );
  }

  Widget _buildChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: AppRadius.chip,
      ),
      child: Text(
        label,
        style: AppTypography.caption.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }
}
