import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:disaster_rescue/core/theme/app_theme.dart';

/// Loại báo tin — quyết định 2.1: chỉ còn 2 luồng (B và C).
enum _ReportType { helpOther, areaReport }

/// Loại sự cố khu vực (Luồng C)
enum _IncidentType {
  roadCollapse('Đường sập'),
  fallenTree('Cây đổ'),
  risingWater('Nước dâng'),
  fire('Lửa cháy'),
  bridgeDamage('Cầu hỏng');

  final String label;
  const _IncidentType(this.label);
}

/// Màn 06 (SRS) — Báo tin cho xã.
/// Stepper 2 bước: chọn loại → nhập chi tiết.
/// Luồng B: báo giúp người khác → admin duyệt → tạo SOS pending.
/// Luồng C: báo tình hình khu vực → không tạo SOS.
class ReportToCommuneScreen extends ConsumerStatefulWidget {
  const ReportToCommuneScreen({super.key});

  @override
  ConsumerState<ReportToCommuneScreen> createState() =>
      _ReportToCommuneScreenState();
}

class _ReportToCommuneScreenState
    extends ConsumerState<ReportToCommuneScreen> {
  int _currentStep = 0;
  _ReportType? _reportType;

  // Luồng B fields
  final _addressController = TextEditingController();
  final _descBController = TextEditingController();

  // Luồng C fields
  _IncidentType? _incidentType;
  final _descCController = TextEditingController();
  final _locationCController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void dispose() {
    _addressController.dispose();
    _descBController.dispose();
    _descCController.dispose();
    _locationCController.dispose();
    super.dispose();
  }

  void _goToStep2() {
    if (_reportType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn loại tin')),
      );
      return;
    }
    setState(() => _currentStep = 1);
  }

  Future<void> _handleSubmit() async {
    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(milliseconds: 1000));
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    final message = _reportType == _ReportType.helpOther
        ? 'Đã gửi báo tin giúp người khác — chờ admin xác minh'
        : 'Đã gửi báo tình hình khu vực — hiển thị trên bản đồ';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.statusSafe,
      ),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Báo tin cho xã'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            if (_currentStep > 0) {
              setState(() => _currentStep = 0);
            } else {
              context.pop();
            }
          },
        ),
      ),
      body: Column(
        children: [
          // Banner cảnh báo
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            color: const Color(0xFFE3F2FD),
            child: const Text(
              'Màn này dành cho việc của NGƯỜI KHÁC / NƠI KHÁC.\n'
              'Nhà bạn gặp nguy → dùng nút SOS. Cần xe sơ tán → dùng Cần hỗ trợ sơ tán.',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.infoBlue,
                fontFamily: AppTypography.fontFamily,
                height: 1.5,
              ),
            ),
          ),

          // Stepper indicator
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.base, vertical: AppSpacing.md),
            child: Row(
              children: [
                _buildStepDot(0, 'Chọn loại'),
                Expanded(
                  child: Container(
                    height: 2,
                    color: _currentStep >= 1
                        ? AppColors.primary
                        : AppColors.textDisabled,
                  ),
                ),
                _buildStepDot(1, 'Chi tiết'),
              ],
            ),
          ),

          // Content
          Expanded(
            child: _currentStep == 0 ? _buildStep1() : _buildStep2(),
          ),
        ],
      ),
    );
  }

  Widget _buildStepDot(int step, String label) {
    final isActive = _currentStep >= step;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 14,
          backgroundColor: isActive ? AppColors.primary : AppColors.textDisabled,
          child: Text(
            '${step + 1}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            color: isActive ? AppColors.primary : AppColors.textSecondary,
            fontFamily: AppTypography.fontFamily,
          ),
        ),
      ],
    );
  }

  /// Bước 1 — Chọn loại tin
  Widget _buildStep1() {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.base),
      children: [
        const Text(
          'Bạn muốn báo gì?',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            fontFamily: AppTypography.fontFamily,
          ),
        ),
        const SizedBox(height: AppSpacing.base),

        // Card Luồng B
        _buildTypeCard(
          type: _ReportType.helpOther,
          icon: Icons.people_rounded,
          borderColor: AppColors.priorityOrange,
          title: 'Báo giúp người khác',
          subtitle:
              'Hàng xóm, người thân đang gặp nạn → admin xác minh rồi tạo SOS',
        ),
        const SizedBox(height: AppSpacing.md),

        // Card Luồng C
        _buildTypeCard(
          type: _ReportType.areaReport,
          icon: Icons.camera_alt_rounded,
          borderColor: AppColors.infoBlue,
          title: 'Báo tình hình khu vực',
          subtitle: 'Đường sập, cây đổ, nước dâng, cầu hỏng → KHÔNG tạo SOS',
        ),

        const SizedBox(height: AppSpacing.lg),

        ElevatedButton(
          onPressed: _reportType != null ? _goToStep2 : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.priorityOrange,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
          ),
          child: const Text(
            'Tiếp theo',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: AppTypography.fontFamily,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTypeCard({
    required _ReportType type,
    required IconData icon,
    required Color borderColor,
    required String title,
    required String subtitle,
  }) {
    final isSelected = _reportType == type;
    return GestureDetector(
      onTap: () => setState(() => _reportType = type),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.base),
        decoration: BoxDecoration(
          color: isSelected ? borderColor.withValues(alpha: 0.08) : AppColors.surface,
          borderRadius: AppRadius.card,
          border: Border.all(
            color: isSelected ? borderColor : AppColors.textDisabled,
            width: isSelected ? 2.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: borderColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: borderColor, size: 28),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? borderColor : AppColors.textPrimary,
                      fontFamily: AppTypography.fontFamily,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontFamily: AppTypography.fontFamily,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle_rounded, color: borderColor, size: 24),
          ],
        ),
      ),
    );
  }

  /// Bước 2 — Chi tiết (thay đổi theo loại)
  Widget _buildStep2() {
    if (_reportType == _ReportType.helpOther) {
      return _buildFlowB();
    } else {
      return _buildFlowC();
    }
  }

  /// Luồng B — Báo giúp người khác
  Widget _buildFlowB() {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.base),
      children: [
        const Text(
          'Báo giúp người khác',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.priorityOrange,
            fontFamily: AppTypography.fontFamily,
          ),
        ),
        const SizedBox(height: AppSpacing.base),

        // Vị trí nạn nhân (mock map picker)
        Container(
          height: 140,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadius.card,
            border: Border.all(color: AppColors.textDisabled),
          ),
          child: const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.pin_drop_rounded, size: 36, color: AppColors.priorityOrange),
                SizedBox(height: 4),
                Text('Bấm để chọn vị trí nạn nhân',
                    style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        TextFormField(
          controller: _addressController,
          decoration: const InputDecoration(
            labelText: 'Địa chỉ / Mô tả vị trí',
            hintText: 'VD: Nhà ông Ba, cuối thôn Đồng Tâm',
            prefixIcon: Icon(Icons.location_on_rounded),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        TextFormField(
          controller: _descBController,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Mô tả tình trạng',
            hintText: 'VD: Nhà bị ngập, có cụ già không tự di chuyển được...',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // Badge mức tin cậy
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.priorityOrange.withValues(alpha: 0.08),
            borderRadius: AppRadius.card,
            border: Border.all(color: AppColors.priorityOrange.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Mức tin cậy: 35/100',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.priorityOrange,
                  fontFamily: AppTypography.fontFamily,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: 0.35,
                  backgroundColor: AppColors.textDisabled.withValues(alpha: 0.3),
                  color: AppColors.priorityOrange,
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              const Text(
                'Ảnh (+20) · GPS <500m (+15) · Báo trùng (+25)',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                  fontFamily: AppTypography.fontFamily,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // Nút chụp ảnh
        OutlinedButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Demo: Mở camera chụp ảnh')),
            );
          },
          icon: const Icon(Icons.camera_alt_rounded),
          label: const Text('Chụp ảnh hiện trường'),
        ),

        const SizedBox(height: AppSpacing.lg),
        _buildSubmitButton(),
      ],
    );
  }

  /// Luồng C — Báo tình hình khu vực
  Widget _buildFlowC() {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.base),
      children: [
        const Text(
          'Báo tình hình khu vực',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.infoBlue,
            fontFamily: AppTypography.fontFamily,
          ),
        ),
        const SizedBox(height: AppSpacing.base),

        // Chọn loại sự cố
        const Text(
          'Loại sự cố:',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: AppTypography.fontFamily,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: _IncidentType.values.map((type) {
            final isSelected = _incidentType == type;
            return ChoiceChip(
              label: Text(type.label),
              selected: isSelected,
              selectedColor: AppColors.infoBlue.withValues(alpha: 0.15),
              onSelected: (_) => setState(() => _incidentType = type),
              labelStyle: TextStyle(
                color: isSelected ? AppColors.infoBlue : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: AppSpacing.md),

        TextFormField(
          controller: _locationCController,
          decoration: const InputDecoration(
            labelText: 'Vị trí',
            hintText: 'VD: Cầu Bình Liêu, km3 đường vào thôn',
            prefixIcon: Icon(Icons.location_on_rounded),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        TextFormField(
          controller: _descCController,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Mô tả chi tiết',
            hintText: 'VD: Đoạn đường sạt lở khoảng 20m, xe không qua được...',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        OutlinedButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Demo: Mở camera chụp ảnh')),
            );
          },
          icon: const Icon(Icons.camera_alt_rounded),
          label: const Text('Chụp ảnh hiện trường'),
        ),

        const SizedBox(height: AppSpacing.lg),
        _buildSubmitButton(),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _isSubmitting ? null : _handleSubmit,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.priorityOrange,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
      ),
      child: _isSubmitting
          ? const SizedBox(
              height: 20, width: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
          : const Text(
              'GỬI BÁO TIN',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: AppTypography.fontFamily,
                letterSpacing: 0.5,
              ),
            ),
    );
  }
}
