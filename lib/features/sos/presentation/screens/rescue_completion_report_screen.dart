import 'dart:io' show File;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/camera_service.dart';
import '../../../auth/presentation/providers/auth_controller.dart';
import '../../../household/data/household_repository.dart';
import '../../../rescue_team/presentation/providers/rescue_team_provider.dart';
import '../../data/sos_sync_service.dart';
import '../../domain/sos_model.dart';
import '../providers/sos_provider.dart';

enum RescueOutcome { success, partial, unreachable }

class RescueCompletionReportScreen extends ConsumerStatefulWidget {
  final String sosId;
  const RescueCompletionReportScreen({super.key, required this.sosId});

  @override
  ConsumerState<RescueCompletionReportScreen> createState() =>
      _RescueCompletionReportScreenState();
}

class _RescueCompletionReportScreenState
    extends ConsumerState<RescueCompletionReportScreen> {
  RescueOutcome _outcome = RescueOutcome.success;
  int _peopleSaved = 0;
  int _peopleInjured = 0;
  final Set<String> _statusChips = {'evacuated'};
  final TextEditingController _noteCtrl = TextEditingController();
  final List<String> _photos = []; // Path local hoặc URL sau upload
  final CameraService _cameraService = CameraService();
  bool _submitting = false;

  Future<void> _addCompletionPhoto() async {
    final f = await _cameraService.pickWithChoice(context);
    if (f == null || !mounted) return;
    setState(() => _photos.add(f.path));
  }

  static const _statusChoices = <String, String>{
    'evacuated': '✓ Đã đưa tới điểm sơ tán',
    'medical': '🚑 Cần y tế',
    'stayed': '🏠 Ở lại nhà',
    'medicine': '💊 Đã cấp thuốc',
  };

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit(SosRequestEntity sos) async {
    if (_photos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Bắt buộc chụp ít nhất 1 ảnh xác nhận.'),
            backgroundColor: Colors.orange),
      );
      return;
    }
    setState(() => _submitting = true);
    try {
      final user = ref.read(currentUserProvider);
      final teamId = user?.teamId;
      if (teamId == null) throw Exception('Bạn chưa gắn với đội cứu hộ');

      // Ghi báo cáo vào Firestore
      await FirebaseFirestore.instance.collection('sos_reports').add({
        'sosId': sos.id,
        'teamId': teamId,
        'outcome': _outcome.name,
        'peopleSaved': _peopleSaved,
        'peopleInjured': _peopleInjured,
        'statusChips': _statusChips.toList(),
        'note': _noteCtrl.text.trim(),
        'photos': _photos,
        'createdAt': FieldValue.serverTimestamp(),
        'createdBy': user!.uid,
      });

      // Cập nhật SOS + team → completed
      final repo = ref.read(rescueTeamRepositoryProvider);
      await repo.completeMission(teamId, sos.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('✅ Đã gửi báo cáo hoàn thành'),
              backgroundColor: Colors.green),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Lỗi gửi báo cáo: $e'),
              backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sosAsync = ref.watch(allSosRequestsStreamProvider);
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
          '← Báo cáo hoàn thành',
          style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 16),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: Text('#${_shortId(widget.sosId)}',
                  style: const TextStyle(
                      color: Color(0xFFC62828),
                      fontWeight: FontWeight.w900,
                      fontSize: 14)),
            ),
          )
        ],
      ),
      body: sosAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Lỗi: $e')),
        data: (list) {
          SosRequestEntity? sos;
          try {
            sos = list.firstWhere((s) => s.id == widget.sosId);
          } catch (_) {
            return const Center(child: Text('Không tìm thấy SOS'));
          }
          return _buildBody(sos);
        },
      ),
    );
  }

  Widget _buildBody(SosRequestEntity sos) {
    final householdAsync =
        ref.watch(householdByIdStreamProvider(sos.householdId));
    final headName = householdAsync.value?.headName ?? 'Hộ ${sos.householdId}';
    final receivedAt = _fmtHm(sos.createdAt);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card nhận nhiệm vụ
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.green.shade400),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.green.shade700,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.check,
                      color: Colors.white, size: 16),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SOS #${_shortId(sos.id)} — $headName',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Nhận lúc $receivedAt · Đến nơi ${_arrivalTime()}',
                        style: const TextStyle(
                            fontSize: 11, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          _sectionLabel('KẾT QUẢ CỨU HỘ'),
          const SizedBox(height: 8),
          _OutcomeSegmented(
            current: _outcome,
            onChanged: (v) => setState(() => _outcome = v),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _CounterField(
                  label: 'Số người đã cứu',
                  value: _peopleSaved,
                  onChanged: (v) => setState(() => _peopleSaved = v),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _CounterField(
                  label: 'Người bị thương',
                  value: _peopleInjured,
                  onChanged: (v) => setState(() => _peopleInjured = v),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          _sectionLabel('TÌNH TRẠNG NGƯỜI ĐƯỢC CỨU'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _statusChoices.entries.map((e) {
              final selected = _statusChips.contains(e.key);
              return _StatusChip(
                label: e.value,
                selected: selected,
                onTap: () {
                  setState(() {
                    if (selected) {
                      _statusChips.remove(e.key);
                    } else {
                      _statusChips.add(e.key);
                    }
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          _sectionLabel('GHI CHÚ HIỆN TRƯỜNG'),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: TextField(
              controller: _noteCtrl,
              maxLines: 4,
              style: const TextStyle(fontSize: 12.5),
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText:
                    'VD: Đã đưa 5 người tới Trường TH Bình Liêu. Cụ ông 78 tuổi bị trầy chân, đã băng bó, cần y tế kiểm tra. Nhà ngập ~1.2m.',
                hintStyle: TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(height: 16),

          _sectionLabel('ẢNH XÁC NHẬN (BẮT BUỘC 1 ẢNH)'),
          const SizedBox(height: 8),
          _PhotoPicker(
            photos: _photos,
            onAdd: _addCompletionPhoto,
            onRemove: (i) => setState(() => _photos.removeAt(i)),
          ),
          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF388E3C),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              icon: _submitting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.check, color: Colors.white),
              label: const Text(
                '✓ GỬI BÁO CÁO HOÀN THÀNH',
                style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    fontSize: 14,
                    letterSpacing: 0.5),
              ),
              onPressed: _submitting ? null : () => _submit(sos),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.amber.shade700, width: 1.5),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              icon: Icon(Icons.warning_amber_rounded,
                  color: Colors.amber.shade900, size: 18),
              label: Text(
                'Báo chướng ngại thay vì hoàn thành',
                style: TextStyle(
                    color: Colors.amber.shade900,
                    fontWeight: FontWeight.bold,
                    fontSize: 12.5),
              ),
              onPressed: () => _reportObstacle(sos),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _reportObstacle(SosRequestEntity sos) async {
    final ctrl = TextEditingController();
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Báo chướng ngại'),
        content: TextField(
          controller: ctrl,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'VD: Cây đổ chắn Km2, đi vòng lối ruộng',
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () async {
              await FirebaseFirestore.instance.collection('obstacles').add({
                'sosId': sos.id,
                'note': ctrl.text.trim(),
                'latitude': sos.latitude,
                'longitude': sos.longitude,
                'reportedBy': ref.read(currentUserProvider)?.uid,
                'createdAt': FieldValue.serverTimestamp(),
              });
              if (context.mounted) Navigator.pop(ctx);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('⚠️ Đã báo chướng ngại lên admin')),
                );
              }
            },
            child: const Text('Gửi'),
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

  String _shortId(String id) => id.length <= 4 ? id : id.substring(id.length - 4);

  String _arrivalTime() => _fmtHm(DateTime.now());
}

String _fmtHm(DateTime dt) {
  final h = dt.hour.toString().padLeft(2, '0');
  final m = dt.minute.toString().padLeft(2, '0');
  return '$h:$m';
}

class _OutcomeSegmented extends StatelessWidget {
  final RescueOutcome current;
  final ValueChanged<RescueOutcome> onChanged;
  const _OutcomeSegmented({required this.current, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: RescueOutcome.values.map((o) {
          final selected = o == current;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(o),
              child: Container(
                margin: const EdgeInsets.all(3),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: selected ? const Color(0xFF388E3C) : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    _label(o),
                    style: TextStyle(
                      color: selected ? Colors.white : Colors.black87,
                      fontWeight: selected ? FontWeight.w900 : FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _label(RescueOutcome o) {
    switch (o) {
      case RescueOutcome.success:
        return 'Thành công';
      case RescueOutcome.partial:
        return 'Một phần';
      case RescueOutcome.unreachable:
        return 'Không tiếp cận';
    }
  }
}

class _CounterField extends StatelessWidget {
  final String label;
  final int value;
  final ValueChanged<int> onChanged;
  const _CounterField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
              fontSize: 10.5, color: Colors.grey, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$value',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w900)),
              Row(
                children: [
                  _RoundBtn(
                    icon: Icons.remove,
                    onTap: value > 0 ? () => onChanged(value - 1) : null,
                  ),
                  const SizedBox(width: 6),
                  _RoundBtn(icon: Icons.add, onTap: () => onChanged(value + 1)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RoundBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _RoundBtn({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: onTap == null ? Colors.grey.shade200 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon,
            size: 16, color: onTap == null ? Colors.grey : Colors.black87),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _StatusChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF388E3C) : Colors.white,
          borderRadius: BorderRadius.circular(50),
          border: Border.all(
            color:
                selected ? const Color(0xFF388E3C) : Colors.grey.shade300,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
              color: selected ? Colors.white : Colors.black87,
              fontSize: 11.5,
              fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _PhotoPicker extends StatelessWidget {
  final List<String> photos;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;
  const _PhotoPicker({
    required this.photos,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (int i = 0; i < photos.length && i < 3; i++)
          Expanded(
            child: GestureDetector(
              onLongPress: () => onRemove(i),
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                height: 78,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(10),
                ),
                clipBehavior: Clip.antiAlias,
                child: photos[i].startsWith('/')
                    ? Image.file(
                        File(photos[i]),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Center(
                          child: Icon(Icons.broken_image, color: Color(0xFF388E3C)),
                        ),
                      )
                    : const Center(
                        child: Icon(Icons.image, color: Color(0xFF388E3C)),
                      ),
              ),
            ),
          ),
        if (photos.length < 3)
          Expanded(
            child: GestureDetector(
              onTap: onAdd,
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                height: 78,
                decoration: BoxDecoration(
                  color: const Color(0xFFEEEEEE),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: Colors.grey.shade400, style: BorderStyle.solid),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.camera_alt, size: 22, color: Colors.grey),
                    SizedBox(height: 2),
                    Text('+',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
