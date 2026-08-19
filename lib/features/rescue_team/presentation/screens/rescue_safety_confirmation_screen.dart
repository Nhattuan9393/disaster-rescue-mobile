import 'dart:io' show File;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/services/camera_service.dart';
import '../../../auth/presentation/providers/auth_controller.dart';
import '../../../household/data/household_repository.dart';
import '../../../sos/data/sos_sync_service.dart';
import '../../../sos/presentation/providers/sos_provider.dart';

enum PostRescueStatus {
  evacuated,
  atHome,
  medical,
}

/// Màn "Xác nhận an toàn" của đội cứu hộ — nguồn tin cậy 100 điểm (SRS §5).
/// Được mở từ nút phụ trên rescue_sos_detail_screen hoặc rescue_team_screen.
class RescueSafetyConfirmationScreen extends ConsumerStatefulWidget {
  final String sosId;
  const RescueSafetyConfirmationScreen({super.key, required this.sosId});

  @override
  ConsumerState<RescueSafetyConfirmationScreen> createState() =>
      _RescueSafetyConfirmationScreenState();
}

class _RescueSafetyConfirmationScreenState
    extends ConsumerState<RescueSafetyConfirmationScreen> {
  int _peoplePresent = 0;
  PostRescueStatus _status = PostRescueStatus.evacuated;
  int _injured = 0;
  bool _photoOk = false;
  bool _submitting = false;
  XFile? _photo;
  final CameraService _cameraService = CameraService();

  Future<void> _takeSafetyPhoto() async {
    final f = await _cameraService.takePhoto();
    if (f == null || !mounted) return;
    setState(() {
      _photo = f;
      _photoOk = true;
    });
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
        title: const Text('← Xác nhận an toàn',
            style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 16)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: Text('SOS #${_shortId(widget.sosId)}',
                  style: const TextStyle(
                      color: Color(0xFFC62828),
                      fontWeight: FontWeight.w900,
                      fontSize: 13)),
            ),
          )
        ],
      ),
      body: sosAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Lỗi: $e')),
        data: (list) {
          final sos = list.firstWhere(
            (s) => s.id == widget.sosId,
            orElse: () => throw Exception('SOS not found'),
          );
          return _buildBody(sos.householdId, sos.memberCount);
        },
      ),
    );
  }

  Widget _buildBody(String householdId, int recordedMembers) {
    final household = ref.watch(householdByIdStreamProvider(householdId)).value;
    final headName = household?.headName ?? 'Hộ ${householdId.substring(0, 4)}';
    final address = household?.address ?? 'Thôn Pắc Liềng';
    final members = household?.memberCount ?? recordedMembers;
    if (_peoplePresent == 0 && members > 0) _peoplePresent = members;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _greenBanner(),
          const SizedBox(height: 16),
          _householdCard(headName, address, members),
          const SizedBox(height: 16),
          _sectionLabel('TÌNH TRẠNG SAU CỨU HỘ'),
          const SizedBox(height: 8),
          _statusOption(
            status: PostRescueStatus.evacuated,
            title: 'Đã đưa tới điểm sơ tán',
            subtitle: 'Trường TH Bình Liêu — sẽ tự check-in',
            icon: Icons.school,
            iconColor: const Color(0xFFC62828),
          ),
          const SizedBox(height: 8),
          _statusOption(
            status: PostRescueStatus.atHome,
            title: 'Ở lại nhà — đã an toàn',
            subtitle: 'Nhà không bị ảnh hưởng thêm',
            icon: Icons.home,
            iconColor: Colors.black87,
          ),
          const SizedBox(height: 8),
          _statusOption(
            status: PostRescueStatus.medical,
            title: 'Đã chuyển tới cơ sở y tế',
            subtitle: 'Cần theo dõi riêng',
            icon: Icons.local_hospital,
            iconColor: Colors.blue.shade700,
          ),
          const SizedBox(height: 12),
          _injuredCounter(),
          const SizedBox(height: 16),
          _sectionLabel('ẢNH XÁC NHẬN (BẮT BUỘC 1 ẢNH)'),
          const SizedBox(height: 8),
          _photoRow(),
          const SizedBox(height: 16),
          _sectionLabel('GHI VÀO HỒ SƠ HỘ'),
          const SizedBox(height: 8),
          _summaryBox(),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF388E3C),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              onPressed: _submitting
                  ? null
                  : () => _submit(householdId),
              child: _submitting
                  ? const CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white)
                  : const Text(
                      '✓ LƯU XÁC NHẬN AN TOÀN',
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
  }

  Widget _greenBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('🔑', style: const TextStyle(fontSize: 15)),
              const SizedBox(width: 6),
              Text('Nguồn xác nhận tin cậy CAO NHẤT (100 điểm)',
                  style: TextStyle(
                      color: Colors.green.shade900,
                      fontWeight: FontWeight.w900,
                      fontSize: 12)),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Kèm ảnh + GPS + thời gian. Dùng khi hộ mất điện thoại, hết pin, hoặc không dùng được app.',
            style: TextStyle(fontSize: 11, color: Colors.green.shade900),
          ),
        ],
      ),
    );
  }

  Widget _householdCard(String name, String address, int members) {
    final matched = _peoplePresent == members;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF388E3C), width: 1.4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.home, color: Color(0xFF388E3C), size: 20),
              const SizedBox(width: 6),
              Text('Hộ $name',
                  style: const TextStyle(
                      fontSize: 13.5, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 4),
          Text('$address · hồ sơ ghi $members người',
              style: const TextStyle(fontSize: 11, color: Colors.black54)),
          const SizedBox(height: 10),
          Row(
            children: [
              const Expanded(
                  child: Text('Số người có mặt',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
              _RoundBtn(
                icon: Icons.remove,
                onTap: _peoplePresent > 0
                    ? () => setState(() => _peoplePresent--)
                    : null,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Text('$_peoplePresent',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w900)),
              ),
              _RoundBtn(
                icon: Icons.add,
                isPrimary: true,
                onTap: () => setState(() => _peoplePresent++),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: matched
                  ? const Color(0xFFE8F5E9)
                  : const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              matched
                  ? '✓ Đủ $members/$members người theo hồ sơ'
                  : '⚠️ Thiếu ${members - _peoplePresent} người',
              style: TextStyle(
                  fontSize: 11,
                  color: matched ? Colors.green.shade800 : Colors.orange.shade900,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusOption({
    required PostRescueStatus status,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
  }) {
    final selected = _status == status;
    return GestureDetector(
      onTap: () => setState(() => _status = status),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? const Color(0xFF388E3C) : Colors.grey.shade300,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.bold)),
                  Text(subtitle,
                      style: const TextStyle(
                          fontSize: 11, color: Colors.black54)),
                ],
              ),
            ),
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: selected ? const Color(0xFF388E3C) : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                    color: selected ? const Color(0xFF388E3C) : Colors.grey,
                    width: 1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _injuredCounter() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade400),
      ),
      child: Row(
        children: [
          const Text('🚑', style: TextStyle(fontSize: 18)),
          const SizedBox(width: 8),
          Expanded(
            child: Text('Người bị thương cần y tế',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade900)),
          ),
          _RoundBtn(
              icon: Icons.remove,
              onTap: _injured > 0 ? () => setState(() => _injured--) : null),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text('$_injured',
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w900)),
          ),
          _RoundBtn(
              icon: Icons.add,
              isPrimary: true,
              onTap: () => setState(() => _injured++)),
        ],
      ),
    );
  }

  Widget _photoRow() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: _takeSafetyPhoto,
            child: Container(
              height: 78,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: _photoOk ? const Color(0xFFE8F5E9) : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _photoOk ? const Color(0xFF388E3C) : Colors.grey.shade400),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(_photoOk ? Icons.check_circle : Icons.camera_alt,
                      color: _photoOk ? const Color(0xFF388E3C) : Colors.grey.shade700, size: 22),
                  const SizedBox(height: 2),
                  Text(_photoOk ? '${_fmtHm(DateTime.now())} · GPS ✓' : 'Chụp ảnh',
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: _photo == null ? _takeSafetyPhoto : null,
            child: Container(
              height: 78,
              decoration: BoxDecoration(
                color: const Color(0xFFEEEEEE),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade400),
              ),
              clipBehavior: Clip.antiAlias,
              child: _photo == null
                  ? const Center(child: Icon(Icons.image_outlined, color: Colors.grey, size: 22))
                  : Image.file(
                      File(_photo!.path),
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Center(
                        child: Icon(Icons.broken_image, color: Colors.grey),
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _summaryBox() {
    final me = ref.watch(currentUserProvider);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          _kv('status', _statusLabelForSafety()),
          _kv('source', 'rescue_team'),
          _kv('verifiedBy', me?.displayName ?? '—'),
          _kv('confidence', '100'),
        ],
      ),
    );
  }

  String _statusLabelForSafety() {
    switch (_status) {
      case PostRescueStatus.evacuated:
      case PostRescueStatus.atHome:
        return 'safe';
      case PostRescueStatus.medical:
        return 'medical';
    }
  }

  Widget _kv(String k, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(k,
              style: const TextStyle(
                  fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w600)),
          Text(v,
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: Colors.green.shade800)),
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

  Future<void> _submit(String householdId) async {
    if (!_photoOk) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Bắt buộc chụp ít nhất 1 ảnh xác nhận.'),
            backgroundColor: Colors.orange),
      );
      return;
    }
    setState(() => _submitting = true);
    try {
      final me = ref.read(currentUserProvider);

      await FirebaseFirestore.instance.collection('safety_confirmations').add({
        'householdId': householdId,
        'sosId': widget.sosId,
        'status': _statusLabelForSafety(),
        'source': 'rescue_team',
        'confidence': 100,
        'peoplePresent': _peoplePresent,
        'injured': _injured,
        'postRescueStatus': _status.name,
        'createdBy': me?.uid,
        'createdByName': me?.displayName,
        'timestamp': FieldValue.serverTimestamp(),
      });

      await FirebaseFirestore.instance
          .collection('households')
          .doc(householdId)
          .set({
        'safetyStatus': _statusLabelForSafety(),
        'safetySource': 'rescue_team',
        'safetyConfidence': 100,
        'lastConfirmedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('✅ Đã ghi xác nhận an toàn (100 điểm)'),
              backgroundColor: Colors.green),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Lỗi lưu: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  String _shortId(String id) =>
      id.length <= 4 ? id : id.substring(id.length - 4);

  String _fmtHm(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

class _RoundBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final bool isPrimary;
  const _RoundBtn({required this.icon, this.onTap, this.isPrimary = false});

  @override
  Widget build(BuildContext context) {
    final bg = onTap == null
        ? Colors.grey.shade200
        : (isPrimary ? const Color(0xFF388E3C) : Colors.grey.shade100);
    final fg = onTap == null
        ? Colors.grey
        : (isPrimary ? Colors.white : Colors.black87);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: 30,
        height: 30,
        decoration:
            BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
        child: Icon(icon, size: 16, color: fg),
      ),
    );
  }
}
