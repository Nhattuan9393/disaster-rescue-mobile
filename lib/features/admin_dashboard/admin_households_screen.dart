import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:disaster_rescue/core/theme/app_theme.dart';
import 'package:disaster_rescue/shared/widgets/household_card.dart';
import 'package:disaster_rescue/data/models/safety_status.dart';
import 'package:disaster_rescue/features/household_registry/providers/household_registry_provider.dart';

/// Màn hình Đối chiếu danh sách hộ dân theo thôn (FR-07.3).
class AdminHouseholdsScreen extends ConsumerStatefulWidget {
  const AdminHouseholdsScreen({super.key});

  @override
  ConsumerState<AdminHouseholdsScreen> createState() => _AdminHouseholdsScreenState();
}

class _AdminHouseholdsScreenState extends ConsumerState<AdminHouseholdsScreen> {
  String _selectedFilter = 'Tất cả';

  @override
  Widget build(BuildContext context) {
    final registryState = ref.watch(householdRegistryProvider);
    final duplicates = registryState.duplicates;

    // Map dữ liệu từ provider sang UI cards
    final households = registryState.households.map((h) {
      // Giả lập trạng thái an toàn dựa trên tên hoặc mock
      SafetyState safetyState = SafetyState.safe;
      if (h.ownerName.contains('Ba')) {
        safetyState = SafetyState.sos;
      } else if (h.ownerName.contains('Mai')) {
        safetyState = SafetyState.missingContact;
      }
      
      return HouseholdCard(
        name: h.ownerName,
        village: h.address,
        peopleCount: h.peopleCount,
        status: safetyState,
        phone: h.ownerPhone,
        isMasked: false,
      );
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.base),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Banner Cảnh báo trùng lặp dữ liệu import (Screen 26)
            if (duplicates.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.warningBanner,
                  borderRadius: AppRadius.card,
                  border: Border.all(color: AppColors.priorityOrange.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: AppColors.priorityOrange),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        'Phát hiện ${duplicates.length} hộ trùng lặp SĐT cần đối chiếu!',
                        style: const TextStyle(
                          color: AppColors.priorityOrange,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.push('/duplicate-resolution'),
                      child: const Text('ĐỐI CHIẾU', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ],

            // Bộ lọc và Nút thêm hộ tịch
            Row(
              children: [
                Expanded(
                  child: SingleChildScrollView(
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
                ),
                IconButton(
                  onPressed: () => context.push('/manual-entry'),
                  icon: const Icon(Icons.person_add_alt_1_rounded, color: AppColors.statusSafe),
                  tooltip: 'Nhập hộ dân thủ công',
                ),
              ],
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
