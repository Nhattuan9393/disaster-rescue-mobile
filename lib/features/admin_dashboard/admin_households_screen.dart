import 'package:flutter/material.dart';
import 'package:disaster_rescue/core/theme/app_theme.dart';
import 'package:disaster_rescue/shared/widgets/household_card.dart';
import 'package:disaster_rescue/data/models/safety_status.dart';

/// Màn hình Đối chiếu danh sách hộ dân theo thôn (FR-07.3).
class AdminHouseholdsScreen extends StatefulWidget {
  const AdminHouseholdsScreen({super.key});

  @override
  State<AdminHouseholdsScreen> createState() => _AdminHouseholdsScreenState();
}

class _AdminHouseholdsScreenState extends State<AdminHouseholdsScreen> {
  String _selectedFilter = 'Tất cả';

  @override
  Widget build(BuildContext context) {
    // Mock danh sách hộ dân trong xã
    final households = [
      const HouseholdCard(
        name: 'Nguyễn Văn Tùng',
        village: 'Thôn Pắc Liềng',
        peopleCount: 4,
        status: SafetyState.sos,
        phone: '0912345678',
        isMasked: false,
      ),
      const HouseholdCard(
        name: 'Lò Thị Mai',
        village: 'Thôn Pắc Liềng',
        peopleCount: 3,
        status: SafetyState.missingContact,
        phone: '0987654321',
        isMasked: false,
      ),
      const HouseholdCard(
        name: 'Trần Văn Hùng',
        village: 'Thôn Khe Tiền',
        peopleCount: 5,
        status: SafetyState.safe,
        source: SafetySource.evacuationCheckin,
        phone: '0977889900',
        isMasked: false,
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.base),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Bộ lọc trạng thái an toàn
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['Tất cả', 'SOS', 'Mất liên lạc', 'An toàn'].map((filter) {
                  final isSelected = _selectedFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.sm),
                    child: ChoiceChip(
                      label: Text(
                        filter,
                        style: TextStyle(
                          color: isSelected ? AppColors.surface : AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontFamily: AppTypography.fontFamily,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: AppColors.primary,
                      onSelected: (val) {
                        if (val) {
                          setState(() {
                            _selectedFilter = filter;
                          });
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            const Text(
              'Danh sách đối chiếu hộ dân',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                fontFamily: AppTypography.fontFamily,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Expanded(
              child: ListView.separated(
                itemCount: households.length,
                separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                itemBuilder: (context, index) {
                  final card = households[index];
                  // Filter logic
                  if (_selectedFilter == 'SOS' && card.status != SafetyState.sos) {
                    return const SizedBox.shrink();
                  }
                  if (_selectedFilter == 'Mất liên lạc' && card.status != SafetyState.missingContact) {
                    return const SizedBox.shrink();
                  }
                  if (_selectedFilter == 'An toàn' && card.status != SafetyState.safe) {
                    return const SizedBox.shrink();
                  }
                  return card;
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
