import 'package:flutter/material.dart';
import 'package:disaster_rescue/core/theme/app_theme.dart';

/// Đại diện cho một dòng dữ liệu trong bảng nhập mặt hàng.
class LineEntryRow {
  final String name;
  final num quantity;
  final String unit;

  const LineEntryRow({
    required this.name,
    required this.quantity,
    required this.unit,
  });

  LineEntryRow copyWith({
    String? name,
    num? quantity,
    String? unit,
  }) {
    return LineEntryRow(
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
    );
  }
}

/// Bảng nhập dòng động cho các nghiệp vụ tiếp nhận/xuất kho vật tư và gói cứu trợ.
/// Thiết kế tối ưu hóa hiển thị trên màn hình di động.
class LineEntryTable extends StatelessWidget {
  final List<LineEntryRow> lines;
  final ValueChanged<List<LineEntryRow>> onChanged;

  const LineEntryTable({
    super.key,
    required this.lines,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Danh sách mặt hàng',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                fontFamily: AppTypography.fontFamily,
              ),
            ),
            TextButton.icon(
              onPressed: _addNewLine,
              icon: const Icon(Icons.add, size: 18),
              label: const Text(
                'Thêm dòng',
                style: TextStyle(fontFamily: AppTypography.fontFamily),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        if (lines.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.base),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.textDisabled.withOpacity(0.5), width: 1),
              borderRadius: AppRadius.card,
            ),
            child: const Text(
              'Chưa có mặt hàng nào. Bấm "Thêm dòng" để bắt đầu.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontFamily: AppTypography.fontFamily,
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: lines.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) {
              final line = lines[index];
              return _buildRow(context, index, line);
            },
          ),
      ],
    );
  }

  Widget _buildRow(BuildContext context, int index, LineEntryRow line) {
    return Row(
      children: [
        // Tên hàng
        Expanded(
          flex: 4,
          child: TextFormField(
            initialValue: line.name,
            style: const TextStyle(fontSize: 14, fontFamily: AppTypography.fontFamily),
            decoration: const InputDecoration(
              hintText: 'Tên hàng (ví dụ: Mì tôm)',
              contentPadding: EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.sm),
              border: OutlineInputBorder(),
              hintStyle: TextStyle(color: AppColors.textDisabled, fontSize: 13, fontFamily: AppTypography.fontFamily),
            ),
            onChanged: (val) => _updateLine(index, line.copyWith(name: val)),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        // Số lượng
        Expanded(
          flex: 2,
          child: TextFormField(
            initialValue: line.quantity == 0 ? '' : line.quantity.toString(),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(fontSize: 14, fontFamily: AppTypography.fontFamily, fontWeight: FontWeight.bold),
            decoration: const InputDecoration(
              hintText: 'S.Lượng',
              contentPadding: EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.sm),
              border: OutlineInputBorder(),
              hintStyle: TextStyle(color: AppColors.textDisabled, fontSize: 13, fontFamily: AppTypography.fontFamily),
            ),
            onChanged: (val) {
              final parsed = num.tryParse(val) ?? 0;
              _updateLine(index, line.copyWith(quantity: parsed));
            },
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        // Đơn vị
        Expanded(
          flex: 2,
          child: TextFormField(
            initialValue: line.unit,
            style: const TextStyle(fontSize: 14, fontFamily: AppTypography.fontFamily),
            decoration: const InputDecoration(
              hintText: 'Đơn vị',
              contentPadding: EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.sm),
              border: OutlineInputBorder(),
              hintStyle: TextStyle(color: AppColors.textDisabled, fontSize: 13, fontFamily: AppTypography.fontFamily),
            ),
            onChanged: (val) => _updateLine(index, line.copyWith(unit: val)),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        // Nút xoá dòng
        IconButton(
          onPressed: () => _deleteLine(index),
          icon: const Icon(Icons.delete_outline_rounded, color: AppColors.primary),
        ),
      ],
    );
  }

  void _addNewLine() {
    final updatedList = List<LineEntryRow>.from(lines)
      ..add(const LineEntryRow(name: '', quantity: 1, unit: 'thùng'));
    onChanged(updatedList);
  }

  void _updateLine(int index, LineEntryRow updatedLine) {
    final updatedList = List<LineEntryRow>.from(lines)..[index] = updatedLine;
    onChanged(updatedList);
  }

  void _deleteLine(int index) {
    final updatedList = List<LineEntryRow>.from(lines)..removeAt(index);
    onChanged(updatedList);
  }
}
