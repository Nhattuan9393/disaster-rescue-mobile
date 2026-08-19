import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/presentation/providers/auth_controller.dart';
import '../../data/rescue_team_repository_impl.dart';
import '../../domain/rescue_team_status.dart';
import '../providers/rescue_team_provider.dart';

class RescueTeamStatusScreen extends ConsumerStatefulWidget {
  const RescueTeamStatusScreen({super.key});

  @override
  ConsumerState<RescueTeamStatusScreen> createState() =>
      _RescueTeamStatusScreenState();
}

class _RescueTeamStatusScreenState
    extends ConsumerState<RescueTeamStatusScreen> {
  RescueTeamStatus? _pending;
  String _breakReason = '';
  TimeOfDay _plannedReturn = const TimeOfDay(hour: 14, minute: 0);
  bool _submitting = false;

  static const _reasons = <String, String>{
    'rest': '🫖 Hồi sức',
    'meal': '🍚 Ăn cơm',
    'repair': '🔧 Sửa phương tiện',
    'other': '+ Khác',
  };

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final teamsAsync = ref.watch(allRescueTeamsStreamProvider);

    if (user?.teamId == null) {
      return const Scaffold(
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
                'Bạn không gắn với đội cứu hộ nào.\nVui lòng đăng nhập lại bằng tài khoản đội.',
                textAlign: TextAlign.center),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text(
          'Trạng thái đội của tôi',
          style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 16),
        ),
      ),
      body: teamsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Lỗi tải đội: $e')),
        data: (teams) {
          final myTeam = teams.firstWhere(
            (t) => t.id == user!.teamId,
            orElse: () => throw Exception('team not found'),
          );
          final current = myTeam.status;
          _pending ??= current;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _currentBanner(current, myTeam.assignedSosId),
                const SizedBox(height: 16),
                _sectionLabel('CHỌN TRẠNG THÁI MỚI'),
                const SizedBox(height: 8),
                _statusOption(
                  status: RescueTeamStatus.available,
                  title: 'Sẵn sàng',
                  subtitle: 'Nhận push SOS mới trong khu vực',
                  dotColor: Colors.green,
                  current: current,
                ),
                const SizedBox(height: 8),
                _statusOption(
                  status: RescueTeamStatus.onMission,
                  title: 'Đang nhiệm vụ',
                  subtitle: 'Hệ thống tự đặt khi bấm "Tôi đi"',
                  dotColor: const Color(0xFF1976D2),
                  current: current,
                ),
                const SizedBox(height: 8),
                _statusOption(
                  status: RescueTeamStatus.onBreak,
                  title: 'Tạm nghỉ',
                  subtitle: 'KHÔNG nhận SOS mới — phải nhập giờ quay lại',
                  dotColor: Colors.orange,
                  current: current,
                ),
                const SizedBox(height: 8),
                _statusOption(
                  status: RescueTeamStatus.endShift,
                  title: 'Kết thúc ca',
                  subtitle: 'Rút khỏi đợt thiên tai này',
                  dotColor: Colors.black,
                  current: current,
                ),
                if (_pending == RescueTeamStatus.onBreak) ...[
                  const SizedBox(height: 12),
                  _breakForm(),
                ],
                const SizedBox(height: 16),
                _offlineInfo(),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF57C00),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    onPressed: _submitting
                        ? null
                        : () => _apply(user!.teamId!, current),
                    child: _submitting
                        ? const CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white)
                        : const Text(
                            'CẬP NHẬT TRẠNG THÁI',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 14,
                                letterSpacing: 0.5),
                          ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _currentBanner(RescueTeamStatus current, String? assignedSosId) {
    Color bg;
    Color dot;
    switch (current) {
      case RescueTeamStatus.available:
        bg = Colors.green.shade700;
        dot = Colors.white;
        break;
      case RescueTeamStatus.onMission:
        bg = const Color(0xFF1976D2);
        dot = Colors.white;
        break;
      case RescueTeamStatus.onBreak:
        bg = Colors.orange.shade700;
        dot = Colors.white;
        break;
      case RescueTeamStatus.endShift:
        bg = Colors.black87;
        dot = Colors.white;
        break;
      case RescueTeamStatus.offline:
        bg = Colors.grey.shade700;
        dot = Colors.white;
        break;
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text('ĐANG LÀ',
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 11,
                  letterSpacing: 1)),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.circle, color: dot, size: 10),
              const SizedBox(width: 6),
              Text(current.label,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900)),
            ],
          ),
          if (assignedSosId != null) ...[
            const SizedBox(height: 4),
            Text('SOS #${_shortId(assignedSosId)} · nhận lúc ${_fmtHm(DateTime.now())}',
                style: const TextStyle(color: Colors.white, fontSize: 11)),
          ],
        ],
      ),
    );
  }

  Widget _statusOption({
    required RescueTeamStatus status,
    required String title,
    required String subtitle,
    required Color dotColor,
    required RescueTeamStatus current,
  }) {
    final selected = _pending == status;
    final isCurrent = current == status;
    final isDisabled = status == RescueTeamStatus.onMission;

    return GestureDetector(
      onTap: isDisabled
          ? null // Khóa không cho chọn thủ công
          : () => setState(() => _pending = status),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDisabled 
              ? Colors.grey.shade100
              : (selected ? const Color(0xFFE3F2FD) : Colors.white),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDisabled
                ? Colors.grey.shade300
                : (selected ? const Color(0xFF1976D2) : Colors.grey.shade300),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Opacity(
          opacity: isDisabled ? 0.6 : 1.0,
          child: Row(
            children: [
              Icon(Icons.circle, color: dotColor, size: 12),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(title,
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.bold)),
                        if (isDisabled) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                            decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(4)),
                            child: const Text('Tự động', style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold, color: Colors.black54)),
                          ),
                        ],
                      ],
                    ),
                    Text(subtitle,
                        style: const TextStyle(
                            fontSize: 11, color: Colors.black54)),
                  ],
                ),
              ),
              if (isCurrent)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1976D2),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: const Text('Hiện tại',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold)),
                )
              else
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: selected
                        ? const Color(0xFF1976D2)
                        : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: selected
                            ? const Color(0xFF1976D2)
                            : Colors.grey,
                        width: 1.5),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _breakForm() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade400),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('NẾU CHỌN "TẠM NGHỈ" — BẮT BUỘC ĐIỀN',
              style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade900)),
          const SizedBox(height: 8),
          const Text('Lý do',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _reasons.entries.map((e) {
              final sel = _breakReason == e.key;
              return GestureDetector(
                onTap: () => setState(() => _breakReason = e.key),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: sel ? Colors.orange.shade700 : Colors.white,
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(
                        color: sel
                            ? Colors.orange.shade700
                            : Colors.grey.shade300),
                  ),
                  child: Text(e.value,
                      style: TextStyle(
                          fontSize: 11,
                          color: sel ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.bold)),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 10),
          const Text('Dự kiến quay lại',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: () async {
              final t = await showTimePicker(
                context: context,
                initialTime: _plannedReturn,
              );
              if (t != null) setState(() => _plannedReturn = t);
            },
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '🕒 ${_plannedReturn.hour.toString().padLeft(2, "0")}:${_plannedReturn.minute.toString().padLeft(2, "0")} hôm nay',
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  const Icon(Icons.arrow_drop_down, color: Colors.grey),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Admin sẽ thấy: "Tạm nghỉ — quay lại ${_plannedReturn.hour.toString().padLeft(2, "0")}:${_plannedReturn.minute.toString().padLeft(2, "0")}" và điều SOS cho đội khác.',
            style: const TextStyle(
                fontSize: 10.5,
                color: Colors.black54,
                fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  Widget _offlineInfo() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('🚦', style: TextStyle(fontSize: 14)),
          const SizedBox(width: 6),
          const Expanded(
            child: Text(
              'Trạng thái "Mất kết nối" do hệ thống tự đặt.\nKhông có tín hiệu > 30 phút — admin nhận cảnh báo vì có thể đội gặp sự cố.',
              style: TextStyle(fontSize: 10.5, color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String s) => Text(
        s,
        style: const TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
            letterSpacing: 0.5),
      );

  Future<void> _apply(String teamId, RescueTeamStatus current) async {
    final pending = _pending;
    if (pending == null || pending == current) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chưa có thay đổi trạng thái')),
      );
      return;
    }
    if (pending == RescueTeamStatus.onBreak && _breakReason.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Vui lòng chọn lý do tạm nghỉ'),
            backgroundColor: Colors.orange),
      );
      return;
    }
    setState(() => _submitting = true);
    try {
      final repo = ref.read(rescueTeamRepositoryProvider);
      if (pending == RescueTeamStatus.onBreak) {
        final now = DateTime.now();
        final plannedAt = DateTime(
          now.year,
          now.month,
          now.day,
          _plannedReturn.hour,
          _plannedReturn.minute,
        );
        await (repo as RescueTeamRepositoryImpl).setBreakStatus(
          teamId,
          reason: _reasons[_breakReason] ?? _breakReason,
          plannedReturnAt: plannedAt,
        );
      } else {
        await repo.updateTeamStatus(teamId, pending);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('✅ Trạng thái mới: ${pending.label}'),
              backgroundColor: Colors.green),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  String _shortId(String id) =>
      id.length <= 4 ? id : id.substring(id.length - 4);
  String _fmtHm(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, "0")}:${dt.minute.toString().padLeft(2, "0")}';
  }
}
