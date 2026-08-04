import 'package:flutter/material.dart';
import 'package:disaster_rescue/core/theme/app_theme.dart';

/// Màn hình Bản đồ khu vực và báo cáo Chướng ngại vật dành cho Đội cứu hộ (FR-09.8).
class TeamMapScreen extends StatefulWidget {
  const TeamMapScreen({super.key});

  @override
  State<TeamMapScreen> createState() => _TeamMapScreenState();
}

class _TeamMapScreenState extends State<TeamMapScreen> {
  final _obstacleController = TextEditingController();
  String _selectedType = 'Cây đổ';

  @override
  void dispose() {
    _obstacleController.dispose();
    super.dispose();
  }

  void _reportObstacle() {
    final desc = _obstacleController.text.trim();
    if (desc.isEmpty) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Đã gửi báo cáo chướng ngại vật: $_selectedType - $desc')),
    );
    _obstacleController.clear();
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
              'Bản đồ tuyến đường & chướng ngại vật',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                fontFamily: AppTypography.fontFamily,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppRadius.card,
                border: Border.all(color: AppColors.textDisabled.withOpacity(0.3)),
              ),
              alignment: Alignment.center,
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.map_rounded, size: 48, color: AppColors.textSecondary),
                  SizedBox(height: 8),
                  Text(
                    'Bản đồ chướng ngại tuyến di chuyển',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontFamily: AppTypography.fontFamily,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            const Text(
              'Báo cáo chướng ngại vật trên đường',
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
                      value: _selectedType,
                      decoration: const InputDecoration(
                        labelText: 'Loại chướng ngại',
                        border: OutlineInputBorder(),
                      ),
                      items: ['Cây đổ', 'Đường sập', 'Nước xiết', 'Cầu sập', 'Đất lở'].map((t) {
                        return DropdownMenuItem(value: t, child: Text(t));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _selectedType = val;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextFormField(
                      controller: _obstacleController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Chi tiết hiện trường (ví dụ: cản trở thuyền đi qua...)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    ElevatedButton.icon(
                      onPressed: _reportObstacle,
                      icon: const Icon(Icons.report_problem_rounded),
                      label: const Text('Gửi báo cáo chướng ngại'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.surface,
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
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
