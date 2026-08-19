import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/sms_inbox_repository.dart';
import '../../../config/data/emergency_config_repository.dart';

class SmsInboxAdminScreen extends ConsumerWidget {
  const SmsInboxAdminScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inbox = ref.watch(smsInboxStreamProvider);
    final cfg = ref.watch(emergencyConfigProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Hộp thư SMS Tổng đài',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.black87),
            tooltip: 'Cấu hình khẩn cấp',
            onPressed: () => context.push('/emergency-config'),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: cfg.demoMode ? Colors.orange.shade50 : Colors.blue.shade50,
            child: Row(
              children: [
                Icon(
                  cfg.demoMode ? Icons.science_outlined : Icons.cell_tower,
                  color: cfg.demoMode ? Colors.orange.shade800 : Colors.blue.shade800,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cfg.demoMode
                            ? 'CHẾ ĐỘ DEMO — tin đến từ giả lập app cư dân'
                            : 'CHẾ ĐỘ THẬT — tin đến từ tổng đài SMS gateway',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: cfg.demoMode ? Colors.orange.shade900 : Colors.blue.shade900,
                        ),
                      ),
                      Text(
                        'Tổng đài: ${cfg.hotlinePhone} · ${cfg.hotlineLabel}',
                        style: const TextStyle(fontSize: 10, color: Colors.black87),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: inbox.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Lỗi tải hộp thư: $err')),
              data: (entries) {
                if (entries.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.inbox_outlined, size: 60, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        Text(
                          'Chưa có tin SMS nào đến tổng đài',
                          style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          cfg.demoMode
                              ? 'Bấm SOS bên hộ dân — tin sẽ xuất hiện ở đây.'
                              : 'Chờ tin từ SMS gateway.',
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 11.5),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: entries.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (ctx, i) => _SmsCard(entry: entries[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SmsCard extends ConsumerWidget {
  final SmsInboxEntry entry;
  const _SmsCard({required this.entry});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = entry.receivedAt;
    final timeStr =
        '${_two(t.hour)}:${_two(t.minute)}:${_two(t.second)} · ${_two(t.day)}/${_two(t.month)}';
    final priority = entry.priorityScore ?? 0;
    Color pColor;
    String pLabel;
    if (priority >= 70) {
      pColor = Colors.red.shade700;
      pLabel = 'ĐỎ $priority';
    } else if (priority >= 40) {
      pColor = Colors.orange.shade800;
      pLabel = 'CAM $priority';
    } else {
      pColor = Colors.amber.shade800;
      pLabel = 'VÀNG $priority';
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.sms, size: 16, color: Colors.blue),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Từ ${entry.fromNumber}',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: pColor, borderRadius: BorderRadius.circular(4)),
                child: Text(pLabel,
                    style: const TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(6),
            ),
            child: SelectableText(
              entry.payload,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 11.5,
                color: Colors.blue.shade900,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              if (entry.householdId != null)
                _chip(Icons.home_outlined, 'Hộ: ${_short(entry.householdId!)}'),
              if (entry.latitude != null && entry.longitude != null)
                _chip(Icons.place_outlined,
                    '${entry.latitude!.toStringAsFixed(4)}, ${entry.longitude!.toStringAsFixed(4)}'),
              if (entry.memberCount != null)
                _chip(Icons.groups_outlined, '${entry.memberCount} người'),
              _chip(
                entry.source == 'demo_relay' ? Icons.science_outlined : Icons.cell_tower,
                entry.source == 'demo_relay' ? 'demo relay' : 'sms gateway',
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(timeStr, style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
              if (entry.sosId != null)
                TextButton.icon(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: () => context.push('/household-detail-admin'),
                  icon: const Icon(Icons.open_in_new, size: 14),
                  label: const Text('Mở SOS', style: TextStyle(fontSize: 11)),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.grey.shade700),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 10, color: Colors.grey.shade800, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  String _short(String s) => s.length <= 10 ? s : '${s.substring(0, 8)}…';
  String _two(int n) => n.toString().padLeft(2, '0');
}
