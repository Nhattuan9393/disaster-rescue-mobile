import 'package:flutter/material.dart';
import 'package:disaster_rescue/core/theme/app_theme.dart';

/// Màn 33 — Chi tiết nhật ký sự kiện (FR-12.2).
/// Hiển thị: icon + hành động, thời điểm, người thực hiện, TRƯỚC/SAU, chuỗi sự kiện.
class EventDetailScreen extends StatelessWidget {
  const EventDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data cho demo
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Chi tiết sự kiện'),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download_rounded),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Demo: Xuất nhật ký PDF/Excel')),
              );
            },
            tooltip: 'Xuất nhật ký',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.base),
        children: [
          // ── Header card ──
          Card(
            shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.base),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.sos_rounded,
                        color: AppColors.primary, size: 24),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Gán đội cứu hộ cho SOS',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            fontFamily: AppTypography.fontFamily,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'LOG-2025-0042 · 14:35:22',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            fontFamily: AppTypography.fontFamily,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // ── Người thực hiện ──
          Card(
            shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
            child: const Padding(
              padding: EdgeInsets.all(AppSpacing.base),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'NGƯỜI THỰC HIỆN',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                      fontFamily: AppTypography.fontFamily,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: AppSpacing.sm),
                  _InfoRow(label: 'Tên', value: 'Trần Thị Bình'),
                  _InfoRow(label: 'Vai trò', value: 'Admin xã'),
                  _InfoRow(label: 'Từ', value: 'App mobile · GPS 21.4617, 107.3689'),
                  _InfoRow(label: 'Thiết bị', value: 'Samsung A34 · v1.0.0'),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // ── THAY ĐỔI GÌ — TRƯỚC / SAU ──
          const Text(
            'THAY ĐỔI GÌ',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
              fontFamily: AppTypography.fontFamily,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              // TRƯỚC
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEBEE),
                    borderRadius: AppRadius.card,
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TRƯỚC',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                          fontFamily: AppTypography.fontFamily,
                        ),
                      ),
                      SizedBox(height: AppSpacing.xs),
                      Text('status: verified',
                          style: TextStyle(fontSize: 12, fontFamily: 'monospace')),
                      Text('assignedTeam: null',
                          style: TextStyle(fontSize: 12, fontFamily: 'monospace')),
                    ],
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                child: Icon(Icons.arrow_forward_rounded, color: AppColors.textSecondary),
              ),
              // SAU
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: AppRadius.card,
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SAU',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.statusSafe,
                          fontFamily: AppTypography.fontFamily,
                        ),
                      ),
                      SizedBox(height: AppSpacing.xs),
                      Text('status: assigned',
                          style: TextStyle(fontSize: 12, fontFamily: 'monospace')),
                      Text('assignedTeam: Dân quân 1',
                          style: TextStyle(fontSize: 12, fontFamily: 'monospace')),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // ── ĐỐI TƯỢNG LIÊN QUAN ──
          const Text(
            'ĐỐI TƯỢNG LIÊN QUAN',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
              fontFamily: AppTypography.fontFamily,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Card(
            shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.sos_rounded, color: AppColors.primary),
                  title: const Text('SOS #0042',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Hộ Nguyễn Văn An — Thôn Bình An'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {},
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.groups_rounded, color: AppColors.infoBlue),
                  title: const Text('Đội Dân quân 1',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Thường trực · 5 người'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // ── CHUỖI SỰ KIỆN ──
          const Text(
            'CHUỖI SỰ KIỆN',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
              fontFamily: AppTypography.fontFamily,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildEventChain(),

          const SizedBox(height: AppSpacing.lg),

          // Nút xuất
          OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Demo: Xuất nhật ký sự kiện (PDF / Excel)')),
              );
            },
            icon: const Icon(Icons.file_download_rounded),
            label: const Text('Xuất nhật ký sự kiện (PDF / Excel)'),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }

  Widget _buildEventChain() {
    final events = [
      ('14:00', 'SOS #0042 được gửi', false),
      ('14:05', 'Admin xác minh — mức ĐỎ (75 điểm)', false),
      ('14:35', 'Gán cho Đội Dân quân 1', true), // highlight
      ('—', 'Đang thực hiện...', false),
    ];

    return Card(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: events.asMap().entries.map((e) {
            final i = e.key;
            final (time, text, isHighlight) = e.value;
            return Padding(
              padding: EdgeInsets.only(
                  bottom: i < events.length - 1 ? AppSpacing.sm : 0),
              child: Row(
                children: [
                  SizedBox(
                    width: 48,
                    child: Text(
                      time,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                        fontFamily: AppTypography.fontFamily,
                      ),
                    ),
                  ),
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: isHighlight ? AppColors.primary : AppColors.textDisabled,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: isHighlight
                          ? const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm, vertical: 4)
                          : null,
                      decoration: isHighlight
                          ? BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            )
                          : null,
                      child: Text(
                        text,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight:
                              isHighlight ? FontWeight.w700 : FontWeight.normal,
                          color: isHighlight
                              ? AppColors.primary
                              : AppColors.textPrimary,
                          fontFamily: AppTypography.fontFamily,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 72,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontFamily: AppTypography.fontFamily,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                fontFamily: AppTypography.fontFamily,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
