import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disaster_rescue/core/theme/app_theme.dart';
import 'package:disaster_rescue/data/models/escalation_models.dart';

/// Mock evidence — hệ thống tự sinh
final _mockEvidence = EscalationEvidence(
  redSosUnassigned: 12,
  longestWait: const Duration(hours: 1, minutes: 47),
  householdsMissing: 8,
  teamsAvailable: 2,
  teamsTotal: 12,
  itemsBelowThreshold: 2,
  evacuationSlotsFree: 155,
  computedAt: DateTime.now(),
);

/// Mock nhật ký
final _mockEventLog = [
  EventLogEntry(
    id: 'E001',
    type: EventLogType.sos,
    title: 'SOS #0042 gán cho Đội Dân quân 1',
    timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
  ),
  EventLogEntry(
    id: 'E002',
    type: EventLogType.evacuation,
    title: 'Hộ Nguyễn Văn A xác nhận an toàn',
    detail: 'Nguồn: tự báo qua app',
    timestamp: DateTime.now().subtract(const Duration(minutes: 20)),
  ),
  EventLogEntry(
    id: 'E003',
    type: EventLogType.relief,
    title: 'Nhập kho: 50 áo phao (nguồn: nhà nước)',
    timestamp: DateTime.now().subtract(const Duration(minutes: 40)),
  ),
  EventLogEntry(
    id: 'E004',
    type: EventLogType.escalation,
    title: 'Leo thang lên huyện: yêu cầu 20 người + 3 xuồng',
    detail: 'Trạng thái: Đã tiếp nhận',
    timestamp: DateTime.now().subtract(const Duration(hours: 1)),
  ),
  EventLogEntry(
    id: 'E005',
    type: EventLogType.sos,
    title: 'SOS #0038 hoàn thành — hộ Lê Văn C đã được cứu',
    timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
  ),
  EventLogEntry(
    id: 'E006',
    type: EventLogType.evacuation,
    title: 'Phát lệnh sơ tán thôn Đồng Tâm',
    timestamp: DateTime.now().subtract(const Duration(hours: 2)),
  ),
];

/// Màn 18 — Leo thang & Nhật ký (FR-13).
/// Tab 1: Gửi yêu cầu leo thang + khối EscalationEvidence tự sinh.
/// Tab 2: Nhật ký sự kiện với filter.
class EscalationScreen extends ConsumerStatefulWidget {
  const EscalationScreen({super.key});

  @override
  ConsumerState<EscalationScreen> createState() => _EscalationScreenState();
}

class _EscalationScreenState extends ConsumerState<EscalationScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  EscalationRequestType _requestType = EscalationRequestType.manpower;
  final _descController = TextEditingController();
  final List<MapEntry<String, int>> _needs = [
    const MapEntry('Người', 20),
    const MapEntry('Xuồng máy', 3),
  ];
  final _needNameController = TextEditingController();
  int _needQty = 1;
  bool _isSubmitting = false;
  EventLogType? _logFilter;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _descController.dispose();
    _needNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Leo thang & Nhật ký'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Leo thang'),
            Tab(text: 'Nhật ký'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildEscalationTab(),
          _buildLogTab(),
        ],
      ),
    );
  }

  /// ── Tab Leo thang ──
  Widget _buildEscalationTab() {
    final e = _mockEvidence;
    final waitStr =
        '${e.longestWait.inHours}h ${e.longestWait.inMinutes % 60}ph';
    final timeStr =
        '${e.computedAt.hour.toString().padLeft(2, '0')}:${e.computedAt.minute.toString().padLeft(2, '0')}';

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.base),
      children: [
        // Info box
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: const Color(0xFFE3F2FD),
            borderRadius: AppRadius.card,
          ),
          child: const Text(
            'Leo thang tự nó đã là tuyên bố xã hết khả năng tự xử lý.\n'
            'Không còn chọn mức khẩn cấp — huyện xếp ưu tiên dựa trên số liệu bên dưới.',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.infoBlue,
              fontFamily: AppTypography.fontFamily,
              height: 1.5,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.base),

        // ── Khối CƠ SỞ LEO THANG ──
        Container(
          padding: const EdgeInsets.all(AppSpacing.base),
          decoration: BoxDecoration(
            color: const Color(0xFFFFEBEE),
            borderRadius: AppRadius.card,
            border: Border.all(color: AppColors.primary),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '📊 CƠ SỞ LEO THANG — tự động tính lúc $timeStr',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                  fontFamily: AppTypography.fontFamily,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              _evidenceRow('SOS mức đỏ chưa có đội nhận', '${e.redSosUnassigned}'),
              _evidenceRow('Thời gian chờ lâu nhất', waitStr),
              _evidenceRow('Hộ mất liên lạc > 4 giờ', '${e.householdsMissing}'),
              _evidenceRow('Đội khả dụng / tổng số',
                  '${e.teamsAvailable} / ${e.teamsTotal}'),
              _evidenceRow('Mặt hàng dưới ngưỡng', '${e.itemsBelowThreshold}'),
              _evidenceRow('Điểm sơ tán còn trống', '${e.evacuationSlotsFree} chỗ'),
              const SizedBox(height: AppSpacing.sm),
              const Row(
                children: [
                  Icon(Icons.lock_rounded, size: 14, color: AppColors.textSecondary),
                  SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Số liệu hệ thống sinh — admin không sửa được',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        fontStyle: FontStyle.italic,
                        fontFamily: AppTypography.fontFamily,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        // ── Section "Gửi yêu cầu hỗ trợ" ──
        const Text(
          'Gửi yêu cầu hỗ trợ',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            fontFamily: AppTypography.fontFamily,
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // Loại yêu cầu
        SegmentedButton<EscalationRequestType>(
          segments: EscalationRequestType.values
              .map((t) => ButtonSegment(value: t, label: Text(t.label)))
              .toList(),
          selected: {_requestType},
          onSelectionChanged: (v) =>
              setState(() => _requestType = v.first),
        ),
        const SizedBox(height: AppSpacing.md),

        // Số lượng cụ thể cần
        const Text(
          'SỐ LƯỢNG CỤ THỂ CẦN:',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            fontFamily: AppTypography.fontFamily,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        ..._needs.asMap().entries.map((entry) {
          final i = entry.key;
          final need = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    need.key,
                    style: const TextStyle(
                      fontSize: 14,
                      fontFamily: AppTypography.fontFamily,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline_rounded, size: 20),
                  onPressed: need.value > 1
                      ? () => setState(() {
                            _needs[i] = MapEntry(need.key, need.value - 1);
                          })
                      : null,
                ),
                SizedBox(
                  width: 40,
                  child: Text(
                    '${need.value}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: AppTypography.fontFamily,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline_rounded, size: 20),
                  onPressed: () => setState(() {
                    _needs[i] = MapEntry(need.key, need.value + 1);
                  }),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 18,
                      color: AppColors.textSecondary),
                  onPressed: () => setState(() => _needs.removeAt(i)),
                ),
              ],
            ),
          );
        }),

        // Thêm dòng mới
        OutlinedButton.icon(
          onPressed: () => _showAddNeedDialog(),
          icon: const Icon(Icons.add_rounded, size: 18),
          label: const Text('Thêm mặt hàng'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // Mô tả chi tiết
        TextFormField(
          controller: _descController,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Mô tả chi tiết',
            hintText: 'VD: Cần gấp 20 người hỗ trợ sơ tán thôn Đồng Tâm...',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // Ảnh hiện trường
        OutlinedButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Demo: Mở camera chụp ảnh hiện trường')),
            );
          },
          icon: const Icon(Icons.camera_alt_rounded),
          label: const Text('Ảnh hiện trường'),
        ),
        const SizedBox(height: AppSpacing.lg),

        // Nút gửi
        ElevatedButton.icon(
          onPressed: _isSubmitting ? null : _handleSubmitEscalation,
          icon: const Icon(Icons.campaign_rounded),
          label: _isSubmitting
              ? const SizedBox(
                  height: 20, width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text(
                  'GỬI YÊU CẦU LEO THANG LÊN HUYỆN',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    fontFamily: AppTypography.fontFamily,
                    letterSpacing: 0.3,
                  ),
                ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }

  Widget _evidenceRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontFamily: AppTypography.fontFamily,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              fontFamily: AppTypography.fontFamily,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddNeedDialog() {
    _needNameController.clear();
    _needQty = 1;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Thêm mặt hàng cần'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _needNameController,
                decoration: const InputDecoration(
                  labelText: 'Tên (VD: Áo phao)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: _needQty > 1
                        ? () => setDialogState(() => _needQty--)
                        : null,
                    icon: const Icon(Icons.remove_circle_outline_rounded),
                  ),
                  Text(
                    '$_needQty',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: () => setDialogState(() => _needQty++),
                    icon: const Icon(Icons.add_circle_outline_rounded),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Huỷ'),
            ),
            ElevatedButton(
              onPressed: () {
                final name = _needNameController.text.trim();
                if (name.isNotEmpty) {
                  setState(() => _needs.add(MapEntry(name, _needQty)));
                }
                Navigator.pop(ctx);
              },
              child: const Text('Thêm'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSubmitEscalation() async {
    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(milliseconds: 1000));
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã gửi yêu cầu leo thang lên huyện'),
        backgroundColor: AppColors.statusSafe,
      ),
    );
  }

  /// ── Tab Nhật ký ──
  Widget _buildLogTab() {
    final filtered = _logFilter == null
        ? _mockEventLog
        : _mockEventLog.where((e) => e.type == _logFilter).toList();

    return Column(
      children: [
        // Filter chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.base, vertical: AppSpacing.sm),
          child: Row(
            children: [
              _buildFilterChip('Tất cả', null),
              ...EventLogType.values.map((t) => _buildFilterChip(t.label, t)),
            ],
          ),
        ),

        // Timeline
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final entry = filtered[index];
              return _buildTimelineItem(entry, isLast: index == filtered.length - 1);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, EventLogType? type) {
    final isSelected = _logFilter == type;
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.sm),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => setState(() => _logFilter = type),
        selectedColor: AppColors.primary.withValues(alpha: 0.15),
        labelStyle: TextStyle(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          color: isSelected ? AppColors.primary : AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildTimelineItem(EventLogEntry entry, {required bool isLast}) {
    final timeStr =
        '${entry.timestamp.hour.toString().padLeft(2, '0')}:${entry.timestamp.minute.toString().padLeft(2, '0')}';

    Color dotColor;
    IconData icon;
    switch (entry.type) {
      case EventLogType.sos:
        dotColor = AppColors.primary;
        icon = Icons.sos_rounded;
      case EventLogType.evacuation:
        dotColor = AppColors.statusSafe;
        icon = Icons.directions_run_rounded;
      case EventLogType.relief:
        dotColor = AppColors.infoBlue;
        icon = Icons.inventory_2_rounded;
      case EventLogType.escalation:
        dotColor = AppColors.priorityOrange;
        icon = Icons.campaign_rounded;
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline line + dot
          SizedBox(
            width: 32,
            child: Column(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 14, color: Colors.white),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: AppColors.textDisabled.withValues(alpha: 0.4),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),

          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.base),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    timeStr,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                      fontFamily: AppTypography.fontFamily,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    entry.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      fontFamily: AppTypography.fontFamily,
                    ),
                  ),
                  if (entry.detail != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        entry.detail!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          fontFamily: AppTypography.fontFamily,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
