import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:disaster_rescue/core/theme/app_theme.dart';
import 'package:disaster_rescue/features/household/providers/sos_provider.dart';
import 'package:disaster_rescue/data/models/sos_models.dart';

class SosDetailScreen extends ConsumerStatefulWidget {
  const SosDetailScreen({super.key});

  @override
  ConsumerState<SosDetailScreen> createState() => _SosDetailScreenState();
}

class _SosDetailScreenState extends ConsumerState<SosDetailScreen> {
  // Form values
  bool _hasChildren = false;
  bool _hasElderly = false;
  bool _hasSeriouslyIll = false;
  bool _hasDisabled = false;
  bool _groundFloorFlooded = false;
  bool _needsMedicine = false;
  WaterLevel _waterLevel = WaterLevel.none;
  HouseType _houseType = HouseType.multiStory;
  int _peopleCount = 1;
  final _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load current state if exists
    final currentContext = ref.read(sosProvider).currentContext;
    _hasChildren = currentContext.hasChildren;
    _hasElderly = currentContext.hasElderly;
    _hasSeriouslyIll = currentContext.hasSeriouslyIll;
    _hasDisabled = currentContext.hasDisabled;
    _groundFloorFlooded = currentContext.groundFloorFlooded;
    _needsMedicine = currentContext.needsMedicine;
    _waterLevel = currentContext.waterLevel;
    _houseType = currentContext.houseType;
    _peopleCount = currentContext.peopleCount;
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  SosContext _buildContext() {
    return SosContext(
      hasChildren: _hasChildren,
      hasElderly: _hasElderly,
      hasSeriouslyIll: _hasSeriouslyIll,
      hasDisabled: _hasDisabled,
      groundFloorFlooded: _groundFloorFlooded,
      needsMedicine: _needsMedicine,
      waterLevel: _waterLevel,
      houseType: _houseType,
      peopleCount: _peopleCount,
    );
  }

  @override
  Widget build(BuildContext context) {
    final sosContext = _buildContext();
    final score = calculatePriority(sosContext);
    final priority = getPriorityLevel(score);

    Color scoreColor;
    String priorityText;
    switch (priority) {
      case PriorityLevel.red:
        scoreColor = AppColors.priorityRed;
        priorityText = 'NGUY CẤP';
        break;
      case PriorityLevel.orange:
        scoreColor = AppColors.priorityOrange;
        priorityText = 'NGUY HIỂM';
        break;
      case PriorityLevel.yellow:
        scoreColor = AppColors.priorityYellow;
        priorityText = 'CẦN HỖ TRỢ';
        break;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Bổ sung thông tin SOS'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            ref.read(sosProvider.notifier).resetSos();
            context.pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.base),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Banner Điểm SOS động
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: scoreColor.withValues(alpha: 0.1),
                borderRadius: AppRadius.card,
                border: Border.all(color: scoreColor.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  const Text(
                    'ĐỘ ƯU TIÊN CỨU HỘ HIỆN TẠI',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$score',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          color: scoreColor,
                        ),
                      ),
                      const Text(
                        ' / 100 điểm',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: scoreColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      priorityText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Form Fields
            _buildSectionTitle('1. Tình hình ngập lụt'),
            _buildWaterLevelSelector(),
            const SizedBox(height: AppSpacing.md),

            CheckboxListTile(
              title: const Text('Tầng trệt/tầng 1 đã bị ngập'),
              value: _groundFloorFlooded,
              onChanged: (val) => setState(() => _groundFloorFlooded = val ?? false),
              controlAffinity: ListTileControlAffinity.leading,
            ),
            const SizedBox(height: AppSpacing.md),

            _buildSectionTitle('2. Loại hình nhà ở'),
            _buildHouseTypeSelector(),
            const SizedBox(height: AppSpacing.md),

            _buildSectionTitle('3. Thành viên trong hộ đang kẹt'),
            CheckboxListTile(
              title: const Text('Có trẻ em'),
              value: _hasChildren,
              onChanged: (val) => setState(() => _hasChildren = val ?? false),
              controlAffinity: ListTileControlAffinity.leading,
            ),
            CheckboxListTile(
              title: const Text('Có người già'),
              value: _hasElderly,
              onChanged: (val) => setState(() => _hasElderly = val ?? false),
              controlAffinity: ListTileControlAffinity.leading,
            ),
            CheckboxListTile(
              title: const Text('Có người bệnh nặng'),
              value: _hasSeriouslyIll,
              onChanged: (val) => setState(() => _hasSeriouslyIll = val ?? false),
              controlAffinity: ListTileControlAffinity.leading,
            ),
            CheckboxListTile(
              title: const Text('Có người khuyết tật'),
              value: _hasDisabled,
              onChanged: (val) => setState(() => _hasDisabled = val ?? false),
              controlAffinity: ListTileControlAffinity.leading,
            ),
            CheckboxListTile(
              title: const Text('Cần thuốc men khẩn cấp'),
              value: _needsMedicine,
              onChanged: (val) => setState(() => _needsMedicine = val ?? false),
              controlAffinity: ListTileControlAffinity.leading,
            ),
            const SizedBox(height: AppSpacing.md),

            _buildSectionTitle('4. Số lượng người đang kẹt'),
            _buildPeopleStepper(),
            const SizedBox(height: AppSpacing.md),

            _buildSectionTitle('5. Ghi chú thêm'),
            TextField(
              controller: _noteController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'VD: Có người đang sốt cao, nước dâng nhanh...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            ElevatedButton(
              onPressed: () async {
                await ref.read(sosProvider.notifier).updateSosDetails(sosContext);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Đã cập nhật thông tin SOS chi tiết.'),
                      backgroundColor: AppColors.statusSafe,
                    ),
                  );
                  ref.read(sosProvider.notifier).resetSos();
                  context.pop();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
              ),
              child: const Text(
                'CẬP NHẬT THÔNG TIN SOS',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
          fontFamily: AppTypography.fontFamily,
        ),
      ),
    );
  }

  Widget _buildWaterLevelSelector() {
    return Wrap(
      spacing: AppSpacing.sm,
      children: [
        _buildWaterChip(WaterLevel.none, 'Chưa ngập'),
        _buildWaterChip(WaterLevel.knee, 'Ngập tới gối'),
        _buildWaterChip(WaterLevel.chest, 'Ngập tới ngực'),
        _buildWaterChip(WaterLevel.roof, 'Ngập tới mái'),
      ],
    );
  }

  Widget _buildWaterChip(WaterLevel level, String label) {
    final isSelected = _waterLevel == level;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => setState(() => _waterLevel = level),
      selectedColor: AppColors.primary.withValues(alpha: 0.15),
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primary : AppColors.textPrimary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildHouseTypeSelector() {
    return Row(
      children: [
        Expanded(
          child: RadioListTile<HouseType>(
            title: const Text('Nhà cấp 4'),
            value: HouseType.level4,
            groupValue: _houseType,
            onChanged: (val) => setState(() => _houseType = val!),
          ),
        ),
        Expanded(
          child: RadioListTile<HouseType>(
            title: const Text('Nhà nhiều tầng'),
            value: HouseType.multiStory,
            groupValue: _houseType,
            onChanged: (val) => setState(() => _houseType = val!),
          ),
        ),
      ],
    );
  }

  Widget _buildPeopleStepper() {
    return Row(
      children: [
        IconButton(
          onPressed: _peopleCount > 1 ? () => setState(() => _peopleCount--) : null,
          icon: const Icon(Icons.remove_circle_outline),
        ),
        Text(
          '$_peopleCount người',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        IconButton(
          onPressed: () => setState(() => _peopleCount++),
          icon: const Icon(Icons.add_circle_outline),
        ),
      ],
    );
  }
}
