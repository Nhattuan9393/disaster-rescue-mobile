import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:disaster_rescue/core/theme/app_theme.dart';
import 'package:disaster_rescue/features/household/providers/evacuation_request_provider.dart';
import 'package:disaster_rescue/features/household/widgets/assistance_type_chip.dart';

class EvacuationRequestScreen extends ConsumerStatefulWidget {
  const EvacuationRequestScreen({super.key});

  @override
  ConsumerState<EvacuationRequestScreen> createState() => _EvacuationRequestScreenState();
}

class _EvacuationRequestScreenState extends ConsumerState<EvacuationRequestScreen> {
  final TextEditingController _noteController = TextEditingController();

  final List<Map<String, dynamic>> _assistanceTypes = [
    {'id': 'vehicle', 'label': 'Xe chở người', 'icon': Icons.airport_shuttle_rounded},
    {'id': 'carry', 'label': 'Khiêng người/đồ', 'icon': Icons.back_hand_rounded},
    {'id': 'medical', 'label': 'Y tế cơ bản', 'icon': Icons.medical_services_rounded},
    {'id': 'food', 'label': 'Lương thực', 'icon': Icons.fastfood_rounded},
    {'id': 'house', 'label': 'Gia cố nhà', 'icon': Icons.home_repair_service_rounded},
    {'id': 'other', 'label': 'Khác', 'icon': Icons.more_horiz_rounded},
  ];

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _submit() async {
    final success = await ref.read(evacuationRequestProvider.notifier).submitRequest();
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã gửi yêu cầu hỗ trợ sơ tán thành công. Đang lưu ngoại tuyến nếu mất mạng.'),
          backgroundColor: AppColors.statusSafe,
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(evacuationRequestProvider);
    final notifier = ref.read(evacuationRequestProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Yêu cầu hỗ trợ sơ tán'),
      ),
      body: Column(
        children: [
          // Banner cảnh báo KHÔNG PHẢI SOS
          Container(
            color: AppColors.warningBanner,
            padding: const EdgeInsets.all(AppSpacing.base),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: AppColors.priorityOrange, size: 28),
                    SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        'Đây KHÔNG PHẢI là SOS khẩn cấp!',
                        style: TextStyle(
                          color: AppColors.priorityOrange,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          fontFamily: AppTypography.fontFamily,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                const Text(
                  'Nếu bạn hoặc gia đình đang gặp nguy hiểm tính mạng tức thì, vui lòng quay lại và dùng nút SOS.',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                OutlinedButton.icon(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.arrow_back_rounded, color: AppColors.primary),
                  label: const Text(
                    'Quay lại gửi SOS',
                    style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primary),
                  ),
                )
              ],
            ),
          ),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.base),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Loại hỗ trợ cần thiết
                  const Text(
                    '1. Bạn cần hỗ trợ gì?',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  const Text(
                    'Có thể chọn nhiều mục.',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: 0,
                    children: _assistanceTypes.map((type) {
                      final isSelected = state.selectedAssistanceTypes.contains(type['id']);
                      return AssistanceTypeChip(
                        label: type['label'],
                        icon: type['icon'],
                        isSelected: isSelected,
                        onSelected: (_) => notifier.toggleAssistanceType(type['id']),
                      );
                    }).toList(),
                  ),
                  if (state.errorMessage != null && state.selectedAssistanceTypes.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        state.errorMessage!,
                        style: const TextStyle(color: AppColors.primary, fontSize: 12),
                      ),
                    ),
                  
                  const SizedBox(height: AppSpacing.xl),
                  
                  // 2. Số lượng người cần hỗ trợ
                  const Text(
                    '2. Số lượng người cần sơ tán',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      IconButton(
                        onPressed: state.memberCount > 1 
                            ? () => notifier.updateMemberCount(state.memberCount - 1) 
                            : null,
                        icon: const Icon(Icons.remove_circle_outline),
                        color: AppColors.primary,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.textDisabled),
                          borderRadius: AppRadius.card,
                        ),
                        child: Text(
                          '${state.memberCount}',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        onPressed: () => notifier.updateMemberCount(state.memberCount + 1),
                        icon: const Icon(Icons.add_circle_outline),
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      const Text('Người', style: TextStyle(fontSize: 16)),
                    ],
                  ),
                  
                  const SizedBox(height: AppSpacing.xl),
                  
                  // 3. Thời gian mong muốn
                  const Text(
                    '3. Thời gian mong muốn',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'trong 1 giờ', label: Text('1 Giờ', style: TextStyle(fontSize: 13))),
                      ButtonSegment(value: 'trong 3 giờ', label: Text('3 Giờ', style: TextStyle(fontSize: 13))),
                      ButtonSegment(value: 'trước tối', label: Text('Trước Tối', style: TextStyle(fontSize: 13))),
                    ],
                    selected: {state.timeframe},
                    onSelectionChanged: (set) => notifier.updateTimeframe(set.first),
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.resolveWith((states) {
                        if (states.contains(WidgetState.selected)) {
                          return AppColors.primaryLight;
                        }
                        return null;
                      }),
                      foregroundColor: WidgetStateProperty.resolveWith((states) {
                        if (states.contains(WidgetState.selected)) {
                          return AppColors.surface;
                        }
                        return AppColors.textPrimary;
                      }),
                    ),
                  ),
                  
                  const SizedBox(height: AppSpacing.xl),
                  
                  // 4. Ghi chú & Cảnh báo thông minh
                  const Text(
                    '4. Ghi chú thêm (Không bắt buộc)',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextField(
                    controller: _noteController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Nhà có người già liệt giường, số lượng đồ đạc...',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: notifier.updateNote,
                  ),
                  
                  // Hiển thị cảnh báo thông minh nếu gõ từ khoá nguy cấp
                  if (state.isEmergencyWarning)
                    Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.sm),
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withAlpha(20),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.primary),
                        ),
                        child: const Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.error_outline, color: AppColors.primary, size: 20),
                            SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Text(
                                'Có vẻ bạn đang gặp tình huống rất nguy hiểm! Vui lòng dùng nút SOS để đội cứu hộ ưu tiên xử lý ngay lập tức.',
                                style: TextStyle(
                                  color: AppColors.primaryDark,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  
                  const SizedBox(height: AppSpacing.xxl),
                ],
              ),
            ),
          ),
          
          // Nút submit sticky ở đáy
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.base),
              child: ElevatedButton(
                onPressed: state.isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.surface,
                ),
                child: state.isSubmitting
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(color: AppColors.surface, strokeWidth: 2),
                      )
                    : const Text(
                        'GỬI YÊU CẦU SƠ TÁN',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
