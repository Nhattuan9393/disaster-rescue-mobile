import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../providers/evacuation_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/models/evacuation_models.dart';
import '../../../../shared/widgets/quantity_stepper.dart';

class EvacuationDetailScreen extends ConsumerStatefulWidget {
  final String pointId;

  const EvacuationDetailScreen({
    super.key,
    required this.pointId,
  });

  @override
  ConsumerState<EvacuationDetailScreen> createState() => _EvacuationDetailScreenState();
}

class _EvacuationDetailScreenState extends ConsumerState<EvacuationDetailScreen> {
  int? _localOccupancy;
  dynamic _localStatus;

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final evacuationState = ref.watch(evacuationProvider);
    final point = evacuationState.points.firstWhere((p) => p.id == widget.pointId);
    
    // Initialize local state once
    _localOccupancy ??= point.currentOccupancy;
    final currentStatus = _localStatus ?? point.status;

    final checkIns = ref.watch(evacuationProvider.notifier).getCheckinsForPoint(widget.pointId);

    // Calculate capacity
    final totalCapacity = point.maxCapacity;
    final available = totalCapacity - _localOccupancy!;
    final progress = totalCapacity > 0 ? _localOccupancy! / totalCapacity : 0.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            Expanded(
              child: Text(
                point.name,
                style: AppTypography.h2.copyWith(color: AppColors.surface),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            _buildStatusChip(currentStatus),
          ],
        ),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: AppColors.surface),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.base),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildOccupancyCard(available, totalCapacity, progress),
            const SizedBox(height: AppSpacing.base),
            _buildStatusCard(currentStatus),
            const SizedBox(height: AppSpacing.base),
            _buildCheckInCard(checkIns, context),
            const SizedBox(height: AppSpacing.base),
            _buildSuppliesCard(point.supplies, context),
            const SizedBox(height: AppSpacing.base),
            _buildManagerCard(point),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.base),
          child: ElevatedButton(
            onPressed: () {
              _showSnackBar(context, 'Đã lưu cập nhật');
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.surface,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              shape: RoundedRectangleBorder(
                borderRadius: AppRadius.button,
              ),
              elevation: 0,
            ),
            child: const Text('LƯU CẬP NHẬT', style: AppTypography.label),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(dynamic status) {
    String label = 'Mở';
    Color color = AppColors.statusSafe;
    
    final statusStr = status.toString().toLowerCase();
    if (statusStr.contains('full') || statusStr.contains('đầy')) {
      label = 'Đã đầy';
      color = AppColors.priorityOrange;
    } else if (statusStr.contains('close') || statusStr.contains('đóng')) {
      label = 'Đóng - hỏng';
      color = AppColors.priorityRed;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.chip,
      ),
      child: Text(
        label,
        style: AppTypography.caption.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildOccupancyCard(int available, int totalCapacity, double progress) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.base),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Số người hiện tại', style: AppTypography.h3),
            const SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Còn $available chỗ',
                  style: AppTypography.bodyMedium.copyWith(
                    color: available > 0 ? AppColors.statusSafe : AppColors.priorityRed,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                QuantityStepper(
                  value: _localOccupancy!,
                  min: 0,
                  max: totalCapacity,
                  onChanged: (val) {
                    setState(() {
                      _localOccupancy = val.toInt();
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.base),
            ClipRRect(
              borderRadius: AppRadius.chip,
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 10,
                backgroundColor: AppColors.background,
                color: progress > 0.9 ? AppColors.priorityRed : AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '$_localOccupancy / $totalCapacity',
                style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(dynamic currentStatus) {
    final statusStr = currentStatus.toString().toLowerCase();
    String selected = 'open';
    if (statusStr.contains('full') || statusStr.contains('đầy')) selected = 'full';
    if (statusStr.contains('close') || statusStr.contains('đóng')) selected = 'closed';

    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.base),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Trạng thái điểm', style: AppTypography.h3),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              children: [
                _buildChoiceChip('Mở', 'open', selected),
                _buildChoiceChip('Đã đầy', 'full', selected),
                _buildChoiceChip('Đóng - hỏng', 'closed', selected),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChoiceChip(String label, String value, String selectedValue) {
    final isSelected = value == selectedValue;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _localStatus = value;
          });
        }
      },
      selectedColor: AppColors.primary,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.surface : AppColors.textPrimary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      backgroundColor: AppColors.background,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.chip,
        side: BorderSide(
          color: isSelected ? AppColors.primary : AppColors.textDisabled,
        ),
      ),
    );
  }

  Widget _buildCheckInCard(List<dynamic> checkIns, BuildContext context) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.card,
        side: const BorderSide(color: AppColors.statusSafe, width: 1.5),
      ),
      color: const Color.fromRGBO(232, 245, 233, 1.0),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.base),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.check_circle, color: AppColors.statusSafe),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'CHECK-IN HỘ DÂN',
                    style: AppTypography.h3.copyWith(color: AppColors.statusSafe),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            const Text(
              'Tự động cập nhật trạng thái An toàn cho hộ',
              style: AppTypography.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.base),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showSnackBar(context, 'Mở camera quét QR...'),
                    icon: const Icon(Icons.qr_code_scanner, size: 18),
                    label: const Text('Quét QR app hộ'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showSnackBar(context, 'Mở tìm kiếm...'),
                    icon: const Icon(Icons.search, size: 18),
                    label: const Text('Tìm theo tên/SĐT'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.surface,
                      shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.base),
            if (checkIns.isNotEmpty) ...[
              const Divider(color: AppColors.textDisabled),
              const SizedBox(height: AppSpacing.sm),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: checkIns.length,
                separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                itemBuilder: (context, index) {
                  final ci = checkIns[index];
                  return Row(
                    children: [
                      const Icon(Icons.person, color: AppColors.textSecondary, size: 20),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(ci.householdHeadName, style: AppTypography.label),
                            Text(ci.sectorName, style: AppTypography.caption),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${ci.checkedInCount}/${ci.totalMembers} người',
                            style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            DateFormat('HH:mm - dd/MM').format(ci.time),
                            style: AppTypography.caption,
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildSuppliesCard(List<dynamic> supplies, BuildContext context) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.base),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Vật tư tại điểm', style: AppTypography.h3),
            const SizedBox(height: AppSpacing.md),
            if (supplies.isEmpty)
              const Text('Chưa có thông tin vật tư', style: AppTypography.bodyMedium)
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: supplies.length,
                separatorBuilder: (_, __) => const Divider(color: AppColors.background),
                itemBuilder: (context, index) {
                  final s = supplies[index];
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(s.name, style: AppTypography.bodyMedium),
                      Text('${s.quantity} ${s.unit}', style: AppTypography.label),
                    ],
                  );
                },
              ),
            const SizedBox(height: AppSpacing.base),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _showSnackBar(context, 'Yêu cầu bổ sung vật tư...'),
                icon: const Icon(Icons.inventory_2_outlined, size: 18),
                label: const Text('Yêu cầu bổ sung vật tư'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManagerCard(dynamic point) {
    final managerName = point.managerName ?? 'Chưa cập nhật';
    final managerPhone = point.managerPhone ?? 'Chưa cập nhật';

    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.base),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Người phụ trách', style: AppTypography.h3),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: const BoxDecoration(
                    color: AppColors.background,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person, color: AppColors.primary),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(managerName, style: AppTypography.label),
                      const SizedBox(height: AppSpacing.xs),
                      Text(managerPhone, style: AppTypography.bodyMedium),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.phone, color: AppColors.infoBlue),
                  onPressed: () {},
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
