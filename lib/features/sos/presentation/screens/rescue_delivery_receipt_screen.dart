import 'dart:io' show File;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/services/camera_service.dart';
import '../../../auth/presentation/providers/auth_controller.dart';
import '../../../household/data/household_repository.dart';
import '../../data/sos_sync_service.dart';
import '../providers/sos_provider.dart';

/// Nguồn vật tư — đánh dấu có trừ tồn kho hay không.
enum SupplySource {
  wareHouse, // Kho xã — trừ tồn
  broughtByTeam, // Đội tự mang — không trừ tồn xã
}

class ReliefLine {
  final String id;
  final String name;
  final String emoji;
  final int stock;
  final SupplySource source;
  int qty;

  ReliefLine({
    required this.id,
    required this.name,
    required this.emoji,
    required this.stock,
    required this.source,
    this.qty = 0,
  });
}

class RescueDeliveryReceiptScreen extends ConsumerStatefulWidget {
  final String sosId;
  const RescueDeliveryReceiptScreen({super.key, required this.sosId});

  @override
  ConsumerState<RescueDeliveryReceiptScreen> createState() =>
      _RescueDeliveryReceiptScreenState();
}

class _RescueDeliveryReceiptScreenState
    extends ConsumerState<RescueDeliveryReceiptScreen> {
  // MVP: dữ liệu vật tư seed local — production sẽ đọc từ `relief_items` +
  // team's `broughtSupplies`.
  late final List<ReliefLine> _lines = [
    ReliefLine(
        id: 'life_vest',
        name: 'Áo phao',
        emoji: '🦺',
        stock: 20,
        source: SupplySource.wareHouse),
    ReliefLine(
        id: 'water',
        name: 'Nước suối',
        emoji: '💧',
        stock: 200,
        source: SupplySource.broughtByTeam),
    ReliefLine(
        id: 'noodle',
        name: 'Mì tôm',
        emoji: '🍜',
        stock: 50,
        source: SupplySource.broughtByTeam),
  ];

  bool _signed = false;
  bool _hasPhoto = false;
  XFile? _handoverPhoto;
  final CameraService _cameraService = CameraService();

  Future<void> _takeHandoverPhoto() async {
    final f = await _cameraService.takePhoto();
    if (f == null || !mounted) return;
    setState(() {
      _handoverPhoto = f;
      _hasPhoto = true;
    });
  }
  bool _duplicateHint = true; // MVP: chỗ này production sẽ query lịch sử
  bool _submitting = false;

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
        title: const Text('← Phát hàng cứu trợ',
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
            orElse: () => list.isNotEmpty ? list.first : throw Exception('empty'),
          );
          return _buildBody(sos.householdId);
        },
      ),
    );
  }

  Widget _buildBody(String householdId) {
    final householdAsync = ref.watch(householdByIdStreamProvider(householdId));
    final headName = householdAsync.value?.headName ?? 'Hộ ***';
    final memberCount = householdAsync.value?.memberCount ?? 0;
    final childrenCount = householdAsync.value?.childrenCount ?? 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card hộ nhận
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                const Icon(Icons.home, color: Color(0xFF388E3C), size: 22),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(headName,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 13.5)),
                      const SizedBox(height: 2),
                      Text(
                        '${householdAsync.value?.address ?? "Thôn Pắc Liềng"} · $memberCount người · $childrenCount trẻ em',
                        style: const TextStyle(
                            fontSize: 11, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text('Đổi ▾',
                      style: TextStyle(
                          fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          _sectionLabel('CHỌN HÀNG PHÁT — TỪ VẬT TƯ ĐỘI ĐANG MANG'),
          const SizedBox(height: 8),
          ..._lines.map(_buildLine),
          const SizedBox(height: 12),

          if (_duplicateHint) _buildDuplicateHint(),
          const SizedBox(height: 12),

          _buildReceiptPreview(headName, householdAsync.value?.contactPhone),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: Icon(
                    _signed ? Icons.check_circle : Icons.gesture,
                    size: 16,
                    color: _signed ? Colors.green : Colors.black87,
                  ),
                  label: const Text('Chữ ký hộ',
                      style: TextStyle(
                          fontSize: 12, fontWeight: FontWeight.bold)),
                  onPressed: () => setState(() => _signed = true),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: Icon(
                    _hasPhoto ? Icons.check_circle : Icons.camera_alt,
                    size: 16,
                    color: _hasPhoto ? Colors.green : Colors.black87,
                  ),
                  label: const Text('Ảnh bàn giao',
                      style: TextStyle(
                          fontSize: 12, fontWeight: FontWeight.bold)),
                  onPressed: _takeHandoverPhoto,
                ),
              ),
            ],
          ),
          if (_handoverPhoto != null) ...[
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.file(
                File(_handoverPhoto!.path),
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 120,
                  color: Colors.grey.shade200,
                  child: const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),

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
              onPressed: _submitting ? null : () => _submit(householdId, headName),
              child: _submitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Text(
                      'XÁC NHẬN PHÁT — TẠO BIÊN NHẬN',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                          letterSpacing: 0.5),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLine(ReliefLine line) {
    final isWarehouse = line.source == SupplySource.wareHouse;
    final srcLabel = isWarehouse ? 'Kho xã' : 'Đội tự mang';
    final srcColor = isWarehouse ? Colors.orange.shade700 : Colors.amber.shade800;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Text(line.emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${line.name} · còn ${line.stock}',
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.bold)),
                Text(srcLabel,
                    style: TextStyle(
                        fontSize: 11,
                        color: srcColor,
                        fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          _RoundBtn(
            icon: Icons.remove,
            onTap: line.qty > 0
                ? () => setState(() => line.qty--)
                : null,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text('${line.qty}',
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w900)),
          ),
          _RoundBtn(
            icon: Icons.add,
            isPrimary: true,
            onTap: line.qty < line.stock
                ? () => setState(() => line.qty++)
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildDuplicateHint() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.amber.shade400),
      ),
      child: Row(
        children: [
          const Text('⚠️', style: TextStyle(fontSize: 14)),
          const SizedBox(width: 6),
          const Expanded(
            child: Text(
              'Hộ này đã nhận nước suối lúc 08:15 hôm nay — xác nhận phát tiếp?',
              style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptPreview(String headName, String? phone) {
    final totalItems = _lines.where((l) => l.qty > 0).length;
    final totalUnits = _lines.fold<int>(0, (s, l) => s + l.qty);
    final warehouseCount =
        _lines.where((l) => l.qty > 0 && l.source == SupplySource.wareHouse).length;
    final broughtCount =
        _lines.where((l) => l.qty > 0 && l.source == SupplySource.broughtByTeam).length;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF388E3C), width: 1.4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'BIÊN NHẬN ${_generateReceiptCode()}',
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF388E3C)),
              ),
              Text(_now(),
                  style:
                      const TextStyle(fontSize: 11, color: Colors.black54)),
            ],
          ),
          const SizedBox(height: 8),
          _kv('Hộ nhận', '$headName · ${phone ?? "—"}'),
          _kv('Người phát', _me()),
          _kv('Tổng', '$totalItems mặt hàng · $totalUnits đơn vị'),
          const SizedBox(height: 6),
          Text(
            'Nguồn: $warehouseCount mặt hàng kho xã (trừ tồn) · $broughtCount mặt hàng đội tự mang (không trừ)',
            style: const TextStyle(
                fontSize: 10.5,
                color: Colors.black54,
                fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  Widget _kv(String k, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(width: 100, child: Text(k, style: const TextStyle(fontSize: 11, color: Colors.grey))),
          Expanded(
            child: Text(v,
                style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  String _me() {
    final u = ref.read(currentUserProvider);
    return u?.displayName ?? 'Đội cứu hộ';
  }

  String _now() {
    final n = DateTime.now();
    final dd = n.day.toString().padLeft(2, '0');
    final mm = n.month.toString().padLeft(2, '0');
    final h = n.hour.toString().padLeft(2, '0');
    final m = n.minute.toString().padLeft(2, '0');
    return '$dd/$mm $h:$m';
  }

  String _generateReceiptCode() {
    final y = DateTime.now().year;
    // MVP: sequence từ millis — production dùng transaction tăng counter thật
    final seq =
        (DateTime.now().millisecondsSinceEpoch % 10000).toString().padLeft(4, '0');
    return 'BN-$y-$seq';
  }

  String _shortId(String id) =>
      id.length <= 4 ? id : id.substring(id.length - 4);

  Widget _sectionLabel(String s) => Text(
        s,
        style: const TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
            letterSpacing: 0.5),
      );

  Future<void> _submit(String householdId, String headName) async {
    final selected = _lines.where((l) => l.qty > 0).toList();
    if (selected.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chưa chọn vật tư nào')),
      );
      return;
    }
    if (!_signed || !_hasPhoto) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Cần chữ ký hộ và ảnh bàn giao'),
            backgroundColor: Colors.orange),
      );
      return;
    }
    setState(() => _submitting = true);
    try {
      final code = _generateReceiptCode();
      final me = ref.read(currentUserProvider);

      await FirebaseFirestore.instance
          .collection('relief_receipts')
          .doc(code)
          .set({
        'code': code,
        'sosId': widget.sosId,
        'householdId': householdId,
        'headName': headName,
        'issuedBy': me?.uid,
        'issuedByName': me?.displayName,
        'teamId': me?.teamId,
        'items': selected
            .map((l) => {
                  'id': l.id,
                  'name': l.name,
                  'qty': l.qty,
                  'source': l.source == SupplySource.wareHouse
                      ? 'warehouse'
                      : 'brought',
                })
            .toList(),
        'signedByHousehold': _signed,
        'photoTaken': _hasPhoto,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Trừ tồn kho cho vật tư nguồn warehouse (MVP: đơn giản)
      for (final l in selected.where((x) => x.source == SupplySource.wareHouse)) {
        await FirebaseFirestore.instance
            .collection('relief_items')
            .doc(l.id)
            .set({
          'name': l.name,
          'currentStock': FieldValue.increment(-l.qty),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('✅ Đã tạo biên nhận $code'),
              backgroundColor: Colors.green),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Lỗi lưu biên nhận: $e'),
              backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
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
        width: 28,
        height: 28,
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
        child: Icon(icon, size: 16, color: fg),
      ),
    );
  }
}
