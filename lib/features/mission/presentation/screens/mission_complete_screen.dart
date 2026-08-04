import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/quantity_stepper.dart';
import '../../../../data/models/relief_models.dart';
import '../../providers/mission_provider.dart';

class MissionCompleteScreen extends ConsumerStatefulWidget {
  final String sosId;
  final String householdId;
  final int suggestedCount;

  const MissionCompleteScreen({
    super.key,
    required this.sosId,
    required this.householdId,
    required this.suggestedCount,
  });

  @override
  ConsumerState<MissionCompleteScreen> createState() => _MissionCompleteScreenState();
}

class _DistributionRow {
  final TextEditingController nameController = TextEditingController();
  int quantity = 1;
  SupplySource source = SupplySource.communeWarehouse;
}

class _MissionCompleteScreenState extends ConsumerState<MissionCompleteScreen> {
  late int _rescuedCount;
  HealthStatus _healthStatus = HealthStatus.stable;
  
  final List<_DistributionRow> _distributedItems = [];
  final TextEditingController _notesController = TextEditingController();

  String? _photoBeforePath;
  String? _photoAfterPath;

  @override
  void initState() {
    super.initState();
    _rescuedCount = widget.suggestedCount;
  }

  @override
  void dispose() {
    for (var item in _distributedItems) {
      item.nameController.dispose();
    }
    _notesController.dispose();
    super.dispose();
  }

  void _submitReport() {
    final distItems = _distributedItems.map((e) => ReliefDistributionItem(
      itemName: e.nameController.text.trim().isEmpty ? 'Hàng cứu trợ' : e.nameController.text.trim(),
      quantity: e.quantity,
      unit: 'Gói',
      source: e.source,
    )).toList();

    final report = MissionReport(
      sosId: widget.sosId,
      householdId: widget.householdId,
      rescuedCount: _rescuedCount,
      healthStatus: _healthStatus,
      photoBefore: _photoBeforePath,
      photoAfter: _photoAfterPath,
      distributedItems: distItems,
      notes: _notesController.text.trim(),
      completedAt: DateTime.now(),
    );

    ref.read(missionProvider.notifier).completeMission(report);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Báo cáo hoàn thành thành công!')),
    );
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void _openCamera(bool isBefore) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Mở camera...')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Báo cáo Hoàn thành'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.base),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildRescueResultSection(),
            const SizedBox(height: AppSpacing.lg),
            _buildPhotoSection(),
            const SizedBox(height: AppSpacing.lg),
            _buildDistributedItemsSection(),
            const SizedBox(height: AppSpacing.lg),
            _buildNotesSection(),
            const SizedBox(height: AppSpacing.xl),
            ElevatedButton(
              onPressed: _submitReport,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.statusSafe,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.base),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: AppTypography.fontFamily,
                ),
              ),
              child: const Text('GỬI BÁO CÁO HOÀN THÀNH'),
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildRescueResultSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.base),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Kết quả cứu hộ',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: AppTypography.fontFamily,
              ),
            ),
            const SizedBox(height: AppSpacing.base),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Số người đã cứu được', style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textPrimary,
                  fontFamily: AppTypography.fontFamily,
                )),
                QuantityStepper(
                  value: _rescuedCount,
                  min: 0,
                  onChanged: (val) {
                    setState(() {
                      _rescuedCount = val.toInt();
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            const Text('Tình trạng sức khỏe', style: TextStyle(
              fontSize: 16,
              color: AppColors.textPrimary,
              fontFamily: AppTypography.fontFamily,
            )),
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<HealthStatus>(
                segments: const [
                  ButtonSegment(
                    value: HealthStatus.good,
                    label: Text('Tốt'),
                  ),
                  ButtonSegment(
                    value: HealthStatus.stable,
                    label: Text('Ổn'),
                  ),
                  ButtonSegment(
                    value: HealthStatus.needsMedical,
                    label: Text('Cần y tế'),
                  ),
                ],
                selected: {_healthStatus},
                onSelectionChanged: (Set<HealthStatus> newSelection) {
                  setState(() {
                    _healthStatus = newSelection.first;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.base),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ảnh bằng chứng',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: AppTypography.fontFamily,
              ),
            ),
            const SizedBox(height: AppSpacing.base),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildPhotoBox(
                  label: 'Ảnh trước',
                  onTap: () => _openCamera(true),
                ),
                _buildPhotoBox(
                  label: 'Ảnh sau',
                  onTap: () => _openCamera(false),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoBox({required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 150,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.background,
              border: Border.all(color: AppColors.textDisabled),
              borderRadius: AppRadius.card,
            ),
            child: const Center(
              child: Icon(
                Icons.camera_alt,
                size: 40,
                color: AppColors.textDisabled,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(label, style: const TextStyle(
            fontSize: 14,
            color: AppColors.textPrimary,
            fontFamily: AppTypography.fontFamily,
          )),
        ],
      ),
    );
  }

  Widget _buildDistributedItemsSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        title: const Text(
          'Hàng đã phát (tuỳ chọn)',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: AppTypography.fontFamily,
            color: AppColors.textPrimary,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base, vertical: AppSpacing.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ..._distributedItems.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  return _buildDistributionRow(index, item);
                }).toList(),
                const SizedBox(height: AppSpacing.sm),
                OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      _distributedItems.add(_DistributionRow());
                    });
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Thêm loại hàng'),
                ),
                const SizedBox(height: AppSpacing.base),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDistributionRow(int index, _DistributionRow row) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: AppRadius.card,
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: row.nameController,
                    decoration: const InputDecoration(
                      labelText: 'Tên hàng',
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: AppColors.primary),
                  onPressed: () {
                    setState(() {
                      _distributedItems.removeAt(index);
                    });
                  },
                )
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                QuantityStepper(
                  value: row.quantity,
                  min: 1,
                  onChanged: (val) {
                    setState(() {
                      row.quantity = val.toInt();
                    });
                  },
                ),
                ToggleButtons(
                  isSelected: [
                    row.source == SupplySource.communeWarehouse,
                    row.source == SupplySource.teamBrought,
                  ],
                  onPressed: (selectedIndex) {
                    setState(() {
                      row.source = selectedIndex == 0
                          ? SupplySource.communeWarehouse
                          : SupplySource.teamBrought;
                    });
                  },
                  borderRadius: AppRadius.card,
                  constraints: const BoxConstraints(minHeight: 36),
                  children: const [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                      child: Text('Kho xã'),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                      child: Text('Đội mang'),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.base),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ghi chú',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: AppTypography.fontFamily,
              ),
            ),
            const SizedBox(height: AppSpacing.base),
            TextField(
              controller: _notesController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Nhập ghi chú bổ sung...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
