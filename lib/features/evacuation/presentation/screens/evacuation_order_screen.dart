import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/evacuation_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/models/evacuation_models.dart';

class EvacuationOrderScreen extends ConsumerStatefulWidget {
  const EvacuationOrderScreen({super.key});

  @override
  ConsumerState<EvacuationOrderScreen> createState() => _EvacuationOrderScreenState();
}

class _EvacuationOrderScreenState extends ConsumerState<EvacuationOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final List<String> _villages = const ['Thôn Pắc Liềng', 'Thôn Chè Cà', 'Thôn Nà Lầu'];
  final Set<String> _selectedVillages = {'Thôn Pắc Liềng'};
  
  String? _selectedPointId;
  
  final _viMessageController = TextEditingController(
    text: "Yêu cầu sơ tán khẩn cấp đến [Điểm]. Tuyến đường an toàn:...",
  );
  final _tayMessageController = TextEditingController();
  
  bool _sendTay = false;
  
  // Mock target households
  final int _targetHouseholds = 150;

  @override
  void dispose() {
    _viMessageController.dispose();
    _tayMessageController.dispose();
    super.dispose();
  }

  void _submitOrder() {
    if (_formKey.currentState!.validate()) {
      if (_selectedPointId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng chọn điểm sơ tán đích')),
        );
        return;
      }
      if (_selectedVillages.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng chọn ít nhất 1 khu vực sơ tán')),
        );
        return;
      }

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
          title: const Text('Thành công', style: AppTypography.h2),
          content: const Text(
            'Đã phát lệnh sơ tán thành công.',
            style: AppTypography.bodyLarge,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Đóng dialog
                Navigator.pop(context); // Đóng screen
              },
              child: const Text('Đóng', style: AppTypography.button),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final evacuationState = ref.watch(evacuationProvider);
    final availablePoints = evacuationState.points
        .where((p) => p.status != EvacuationPointStatus.closed && p.status != EvacuationPointStatus.damaged)
        .toList();

    EvacuationPoint? selectedPoint;
    if (_selectedPointId != null) {
      final idx = availablePoints.indexWhere((p) => p.id == _selectedPointId);
      if (idx != -1) {
        selectedPoint = availablePoints[idx];
      }
    }

    bool showWarning = false;
    if (selectedPoint != null && selectedPoint.availableCapacity < _targetHouseholds) {
      showWarning = true;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Phát Lệnh Sơ Tán'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.base),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSection1(),
              const SizedBox(height: AppSpacing.lg),
              _buildSection2(availablePoints, showWarning),
              const SizedBox(height: AppSpacing.lg),
              _buildSection3(),
              const SizedBox(height: AppSpacing.xl),
              _buildBottomAction(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection1() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.base),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Chọn khu vực sơ tán', style: AppTypography.h3),
            const SizedBox(height: AppSpacing.md),
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: AppRadius.card,
                border: Border.all(color: AppColors.textDisabled),
              ),
              alignment: Alignment.center,
              child: const Text(
                'Bản đồ khu vực (Mock)',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: _villages.map((village) {
                final isSelected = _selectedVillages.contains(village);
                return FilterChip(
                  label: Text(
                    village,
                    style: TextStyle(
                      color: isSelected ? AppColors.surface : AppColors.textPrimary,
                    ),
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedVillages.add(village);
                      } else {
                        _selectedVillages.remove(village);
                      }
                    });
                  },
                  selectedColor: AppColors.primary,
                  checkmarkColor: AppColors.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.chip,
                    side: const BorderSide(color: Colors.transparent),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection2(List<EvacuationPoint> points, bool showWarning) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.base),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Chọn điểm sơ tán đích', style: AppTypography.h3),
            const SizedBox(height: AppSpacing.md),
            DropdownButtonFormField<String>(
              value: _selectedPointId,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: AppRadius.card),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md, 
                  vertical: AppSpacing.sm,
                ),
              ),
              hint: const Text('Chọn điểm sơ tán', style: AppTypography.bodyLarge),
              items: points.map((p) {
                return DropdownMenuItem<String>(
                  value: p.id,
                  child: Text(
                    '${p.name} (Còn ${p.availableCapacity} chỗ)',
                    style: AppTypography.bodyLarge,
                  ),
                );
              }).toList(),
              onChanged: (val) {
                setState(() {
                  _selectedPointId = val;
                });
              },
              validator: (val) => val == null ? 'Bắt buộc chọn' : null,
            ),
            if (showWarning) ...[
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.warningBanner,
                  borderRadius: AppRadius.card,
                  border: Border.all(color: AppColors.priorityOrange),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded, 
                      color: AppColors.priorityOrange, 
                      size: 20,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        '⚠️ Điểm sơ tán không đủ sức chứa cho $_targetHouseholds hộ. Đề xuất chọn thêm điểm lân cận.',
                        style: AppTypography.bodyMedium.copyWith(color: AppColors.priorityOrange),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSection3() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.base),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Nội dung thông báo', style: AppTypography.h3),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _viMessageController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Tiếng Việt',
                labelStyle: const TextStyle(color: AppColors.textSecondary),
                border: OutlineInputBorder(borderRadius: AppRadius.card),
                alignLabelWithHint: true,
              ),
              style: AppTypography.bodyLarge,
              validator: (val) => val == null || val.isEmpty ? 'Không được để trống' : null,
            ),
            const SizedBox(height: AppSpacing.sm),
            SwitchListTile(
              title: const Text('Gửi thêm Tiếng Tày', style: AppTypography.bodyLarge),
              value: _sendTay,
              onChanged: (val) {
                setState(() {
                  _sendTay = val;
                });
              },
              contentPadding: EdgeInsets.zero,
              activeColor: AppColors.primary,
            ),
            if (_sendTay) ...[
              const SizedBox(height: AppSpacing.sm),
              TextFormField(
                controller: _tayMessageController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Tiếng Tày',
                  labelStyle: const TextStyle(color: AppColors.textSecondary),
                  border: OutlineInputBorder(borderRadius: AppRadius.card),
                  alignLabelWithHint: true,
                ),
                style: AppTypography.bodyLarge,
                validator: (val) {
                  if (_sendTay && (val == null || val.isEmpty)) {
                    return 'Không được để trống khi đã bật';
                  }
                  return null;
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBottomAction() {
    return Column(
      children: [
        Text(
          'Sẽ gửi đến $_targetHouseholds hộ dân',
          style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: _submitOrder,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.surface,
              shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
            ),
            child: const Text('Phát Lệnh Ngay', style: AppTypography.button),
          ),
        ),
      ],
    );
  }
}
