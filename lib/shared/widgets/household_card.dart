import 'package:flutter/material.dart';
import 'package:disaster_rescue/core/theme/app_theme.dart';
import 'package:disaster_rescue/data/models/safety_status.dart';
import 'status_chip.dart';

/// Card thông tin hộ dân.
/// Hỗ trợ tham số [isMasked] để ẩn thông tin chi tiết (Tên/SĐT) trước khi đội cứu hộ nhận nhiệm vụ.
class HouseholdCard extends StatelessWidget {
  final String name;
  final String village;
  final int peopleCount;
  final SafetyState status;
  final SafetySource? source;
  final String? phone;
  final bool isMasked;
  final VoidCallback? onTap;

  const HouseholdCard({
    super.key,
    required this.name,
    required this.village,
    required this.peopleCount,
    required this.status,
    this.source,
    this.phone,
    this.isMasked = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Áp dụng quy tắc bảo mật thông tin hộ dân (CLAUDE.md mục 1.5)
    String displayName = name;
    if (isMasked) {
      final parts = name.trim().split(' ');
      if (parts.isNotEmpty) {
        displayName = 'Hộ gia đình ông/bà ${parts.last}';
      } else {
        displayName = 'Hộ dân cư đầu mối';
      }
    }

    String? displayPhone = phone;
    if (isMasked && phone != null && phone!.length >= 6) {
      displayPhone = '${phone!.substring(0, 3)}***${phone!.substring(phone!.length - 3)}';
    }

    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.card,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.base),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.h3.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    '$peopleCount người',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      fontFamily: AppTypography.fontFamily,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  const Icon(Icons.location_on_rounded, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    village,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      fontFamily: AppTypography.fontFamily,
                    ),
                  ),
                  if (displayPhone != null) ...[
                    const SizedBox(width: AppSpacing.base),
                    const Icon(Icons.phone_rounded, size: 16, color: AppColors.textSecondary),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      displayPhone,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        fontFamily: AppTypography.fontFamily,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              StatusChip(status: status, source: source),
            ],
          ),
        ),
      ),
    );
  }
}
