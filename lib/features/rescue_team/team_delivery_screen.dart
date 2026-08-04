import 'package:flutter/material.dart';
import 'package:disaster_rescue/core/theme/app_theme.dart';
import 'package:disaster_rescue/shared/widgets/quantity_stepper.dart';

/// Màn hình cấp phát hàng cứu trợ của đội cứu hộ (FR-10.7).
class TeamDeliveryScreen extends StatefulWidget {
  const TeamDeliveryScreen({super.key});

  @override
  State<TeamDeliveryScreen> createState() => _TeamDeliveryScreenState();
}

class _TeamDeliveryScreenState extends State<TeamDeliveryScreen> {
  String _selectedHousehold = 'Hộ ông Nguyễn Văn Tùng';
  String _selectedItem = 'Mì ăn liền';
  String _selectedSource = 'kho xã';
  num _qty = 2;

  void _handleDeliver() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Đã cấp phát thành công $_qty $_selectedItem cho $_selectedHousehold (Nguồn: $_selectedSource).',
        ),
      ),
    );
    setState(() {
      _qty = 2;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.base),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Ghi nhận phát hàng cứu trợ',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
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
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DropdownButtonFormField<String>(
                      value: _selectedHousehold,
                      decoration: const InputDecoration(
                        labelText: 'Hộ nhận cứu trợ',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        'Hộ ông Nguyễn Văn Tùng',
                        'Hộ bà Lò Thị Mai',
                        'Hộ ông Lò Văn Hinh',
                      ].map((h) {
                        return DropdownMenuItem(value: h, child: Text(h));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _selectedHousehold = val;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),
                    DropdownButtonFormField<String>(
                      value: _selectedItem,
                      decoration: const InputDecoration(
                        labelText: 'Loại vật phẩm',
                        border: OutlineInputBorder(),
                      ),
                      items: ['Mì ăn liền', 'Nước đóng chai', 'Áo phao', 'Gạo cứu đói'].map((i) {
                        return DropdownMenuItem(value: i, child: Text(i));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _selectedItem = val;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),
                    DropdownButtonFormField<String>(
                      value: _selectedSource,
                      decoration: const InputDecoration(
                        labelText: 'Nguồn hàng phát',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        'kho xã',
                        'biên chế đội',
                        'đội vãng lai tự mang',
                        'phát nguyên gói cứu trợ',
                      ].map((s) {
                        return DropdownMenuItem(value: s, child: Text('Cấp từ: $s'));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _selectedSource = val;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Số lượng cấp phát:',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                            fontFamily: AppTypography.fontFamily,
                          ),
                        ),
                        // Stepper dùng chung
                        QuantityStepper(
                          value: _qty,
                          min: 1,
                          max: 50,
                          unit: _selectedItem == 'Mì ăn liền' ? 'thùng' : 'đơn vị',
                          onChanged: (newVal) {
                            setState(() {
                              _qty = newVal;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    ElevatedButton.icon(
                      onPressed: _handleDeliver,
                      icon: const Icon(Icons.check_circle_outline_rounded),
                      label: const Text('Xác nhận phát hàng'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.statusSafe,
                        foregroundColor: AppColors.surface,
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
