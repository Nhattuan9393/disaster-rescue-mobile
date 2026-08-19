import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/qr_scanner_screen.dart';
import '../providers/evacuation_provider.dart';
import '../../domain/evacuation_point_model.dart';

class EvacuationPointDetailScreen extends ConsumerStatefulWidget {
  final EvacuationPointModel point;
  const EvacuationPointDetailScreen({super.key, required this.point});
  @override
  ConsumerState<EvacuationPointDetailScreen> createState() => _EvacuationPointDetailScreenState();
}

class _EvacuationPointDetailScreenState extends ConsumerState<EvacuationPointDetailScreen> {
  late int _currentCount;
  late String _status;
  late TextEditingController _countController;

  final List<Map<String, dynamic>> _sampleHouseholds = [
    {'name': 'Nguyễn Văn A', 'village': 'Pắc Liềng', 'members': 5, 'checkedIn': false},
    {'name': 'Trần Thị B', 'village': 'Nà Lầu', 'members': 3, 'checkedIn': false},
    {'name': 'Lý Văn C', 'village': 'Pắc Liềng', 'members': 7, 'checkedIn': false},
    {'name': 'Hoàng Thị D', 'village': 'Khe Tiền', 'members': 2, 'checkedIn': true},
  ];

  @override
  void initState() {
    super.initState();
    _currentCount = widget.point.currentCount;
    _status = widget.point.status;
    _countController = TextEditingController(text: '$_currentCount');
  }

  @override
  void dispose() {
    _countController.dispose();
    super.dispose();
  }

  void _updateCount(int newCount) {
    if (newCount < 0) return;
    setState(() => _currentCount = newCount);
    _countController.text = '$newCount';
    _countController.selection = TextSelection.fromPosition(TextPosition(offset: _countController.text.length));
  }

  void _saveUpdates() async {
    final repo = ref.read(evacuationRepositoryProvider);
    final updatedPoint = widget.point.copyWith(
      currentCount: _currentCount,
      status: _status,
    );
    await repo.updateEvacuationPoint(updatedPoint);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Đã lưu cập nhật tình trạng điểm sơ tán!'), backgroundColor: Colors.green),
      );
      context.pop();
    }
  }

  Future<void> _showQrCheckinDialog() async {
    final code = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => const QrScannerScreen(
          title: 'Quét QR check-in',
          subtitle:
              'Đưa mã QR trên thẻ hộ / căn cước vào khung xanh để check-in vào điểm sơ tán.',
        ),
      ),
    );
    if (code == null || !mounted) return;

    // Parse "HH#<id>#<name>#<members>" — fallback: match theo name trong danh
    // sách mẫu để demo trải nghiệm end-to-end mà không cần dữ liệu hộ đầy đủ.
    final parts = code.split('#');
    String scannedName = parts.length >= 3 ? parts[2] : code;
    int scannedMembers = parts.length >= 4 ? int.tryParse(parts[3]) ?? 1 : 1;

    final match = _sampleHouseholds.firstWhere(
      (hh) => hh['name'].toString().toLowerCase() == scannedName.toLowerCase(),
      orElse: () => <String, dynamic>{},
    );
    if (match.isEmpty) {
      // QR không map vào hộ mẫu — thêm dòng mới.
      setState(() {
        _sampleHouseholds.add({
          'name': scannedName.length > 40 ? '${scannedName.substring(0, 38)}…' : scannedName,
          'village': '(qua QR)',
          'members': scannedMembers,
          'checkedIn': true,
        });
        _updateCount(_currentCount + scannedMembers);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Đã check-in mới qua QR: $scannedName ($scannedMembers người)'),
          backgroundColor: Colors.green.shade700,
        ),
      );
      return;
    }
    if (match['checkedIn'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hộ ${match['name']} đã check-in trước đó.'),
          backgroundColor: Colors.orange.shade700,
        ),
      );
      return;
    }
    setState(() {
      match['checkedIn'] = true;
      _updateCount(_currentCount + (match['members'] as int));
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ Đã check-in ${match['name']} (${match['members']} người)!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showSearchCheckinDialog() {
    final searchCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx2, setDialogState) {
          final query = searchCtrl.text.toLowerCase();
          final filtered = _sampleHouseholds.where((hh) =>
            hh['name'].toString().toLowerCase().contains(query) ||
            hh['village'].toString().toLowerCase().contains(query)
          ).toList();
          return AlertDialog(
            title: const Text('Tìm Hộ Dân theo Tên/SĐT', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: searchCtrl,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm...',
                      prefixIcon: const Icon(Icons.search, size: 18),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    ),
                    onChanged: (_) => setDialogState(() {}),
                  ),
                  const SizedBox(height: 8),
                  ...filtered.map((hh) => ListTile(
                    dense: true,
                    title: Text('${hh['name']} — ${hh['village']}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    subtitle: Text('${hh['members']} người', style: const TextStyle(fontSize: 10.5)),
                    trailing: hh['checkedIn']
                        ? Text('✓ Rồi', style: TextStyle(color: Colors.green.shade700, fontSize: 10, fontWeight: FontWeight.bold))
                        : TextButton(
                            onPressed: () {
                              setDialogState(() => hh['checkedIn'] = true);
                              setState(() => _updateCount(_currentCount + (hh['members'] as int)));
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('✅ Đã check-in ${hh['name']}'), backgroundColor: Colors.green),
                              );
                            },
                            child: const Text('Check-in'),
                          ),
                  )),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Đóng')),
            ],
          );
        },
      ),
    );
  }

  void _showSupplyRequestSheet() {
    String selectedSupply = 'Áo phao';
    int qty = 10;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx2, setSheetState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 16, right: 16, top: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('YÊU CẦU BỔ SUNG VẬT TƯ', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Colors.grey, letterSpacing: 0.5)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: ['Áo phao', 'Chăn ấm', 'Nước sạch', 'Lương khô', 'Thuốc men'].map((s) {
                  final isSel = selectedSupply == s;
                  return ChoiceChip(
                    label: Text(s),
                    selected: isSel,
                    selectedColor: Colors.blue.shade700,
                    labelStyle: TextStyle(color: isSel ? Colors.white : Colors.black87, fontWeight: isSel ? FontWeight.bold : FontWeight.normal, fontSize: 12),
                    onSelected: (v) { if (v) setSheetState(() => selectedSupply = s); },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () { if (qty > 1) setSheetState(() => qty--); },
                    child: Container(width: 40, height: 40, decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(8)), child: const Center(child: Text('−', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)))),
                  ),
                  const SizedBox(width: 20),
                  Text('$qty', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
                  const SizedBox(width: 20),
                  GestureDetector(
                    onTap: () => setSheetState(() => qty++),
                    child: Container(width: 40, height: 40, decoration: BoxDecoration(color: Colors.blue.shade700, borderRadius: BorderRadius.circular(8)), child: const Center(child: Text('+', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)))),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade800,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('📦 Đã gửi yêu cầu $qty $selectedSupply tới kho xã Bình Liêu'), backgroundColor: Colors.blue.shade800),
                    );
                  },
                  child: Text('GỬI YÊU CẦU $qty $selectedSupply', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13)),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => context.pop(),
        ),
        title: Text(
          widget.point.name,
          style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. SỐ NGƯỜI HIỆN TẠI (+/-) + Nhập tay
            const Text('SỐ NGƯỜI HIỆN TẠI', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 0.5)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => _updateCount(_currentCount - 1),
                    child: Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(10)),
                      child: const Center(child: Text('−', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87))),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            SizedBox(
                              width: 60,
                              child: TextField(
                                controller: _countController,
                                keyboardType: TextInputType.number,
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.green.shade700),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                ),
                                onChanged: (v) {
                                  final n = int.tryParse(v);
                                  if (n != null) setState(() => _currentCount = n);
                                },
                              ),
                            ),
                            Text(' / ${widget.point.capacity}',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.green.shade700)),
                          ],
                        ),
                        Text('còn ${widget.point.capacity - _currentCount} chỗ', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _updateCount(_currentCount + 1),
                    child: Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(color: Colors.green.shade700, borderRadius: BorderRadius.circular(10)),
                      child: const Center(child: Text('+', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white))),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // 2. TRẠNG THÁI ĐIỂM
            const Text('TRẠNG THÁI ĐIỂM SƠ TÁN', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 0.5)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                _buildStatusChip('open', 'Mở', Colors.green),
                _buildStatusChip('nearly_full', 'Sắp đầy', Colors.orange),
                _buildStatusChip('full', 'Đã đầy', Colors.red),
                _buildStatusChip('closed', 'Đóng — hỏng', Colors.grey),
              ],
            ),
            const SizedBox(height: 16),

            // 3. CHECK-IN HỘ DÂN
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.green.shade600, width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('✅ CHECK-IN HỘ DÂN — tự đặt trạng thái An toàn (95% Tin cậy)',
                      style: TextStyle(color: Colors.green.shade900, fontWeight: FontWeight.bold, fontSize: 11)),
                  const SizedBox(height: 4),
                  const Text('Giải bài toán "hết pin / mất điện thoại" — hộ được xác nhận an toàn dù app không hoạt động.',
                      style: TextStyle(color: Colors.black54, fontSize: 9.5, height: 1.4)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade700,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          icon: const Icon(Icons.qr_code_scanner, size: 16, color: Colors.white),
                          label: const Text('Quét QR app hộ', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                          onPressed: _showQrCheckinDialog,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.green.shade800,
                            side: BorderSide(color: Colors.green.shade600),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          icon: const Icon(Icons.search, size: 16),
                          label: const Text('Tìm theo tên/SĐT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          onPressed: _showSearchCheckinDialog,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _buildCheckinRow('✓ Nguyễn Văn A — Pắc Liềng', '5/5 người · check-in 09:52'),
                  const SizedBox(height: 4),
                  _buildCheckinRow('✓ Hoàng Thị D — Khe Tiền', '2/2 người · check-in 09:40'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 4. VẬT TƯ TẠI ĐIỂM
            const Text('VẬT TƯ TẠI ĐIỂM SƠ TÁN', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 0.5)),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                children: [
                  _buildSupplyItemRow('🛏️ Chăn', '30 cái', false),
                  const Divider(height: 1),
                  _buildSupplyItemRow('💧 Nước', '120 chai', false),
                  const Divider(height: 1),
                  _buildSupplyItemRow('🍞 Lương khô', '8 gói ⚠️ sắp hết', true),
                  const Divider(height: 1),
                  _buildSupplyItemRow('💊 Thuốc', '15 hộp', false),
                ],
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.blue.shade800,
                  side: BorderSide(color: Colors.blue.shade300),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.inventory_2, size: 18),
                label: const Text('📦 Yêu cầu bổ sung vật tư từ kho xã', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                onPressed: _showSupplyRequestSheet,
              ),
            ),
            const SizedBox(height: 16),

            // 5. LỰC LƯỢNG THƯỜNG TRỰC
            const Text('LỰC LƯỢNG THƯỜNG TRỰC TẠI ĐIỂM', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 0.5)),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                children: [
                  _buildGuardRow('👮', 'Tổ Dân quân Pắc Liềng', '4 người', 'Trực chiến'),
                  const Divider(height: 1),
                  _buildGuardRow('🏥', 'Y tế thôn', '1 người', 'Trực chiến'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 6. Người phụ trách
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  CircleAvatar(backgroundColor: Colors.grey.shade300, radius: 16, child: const Text('👤', style: TextStyle(fontSize: 14))),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Phụ trách: ${widget.point.inChargeName}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black87)),
                        Text('${widget.point.inChargePhone} — Đội cứu hộ gọi trước khi chở người đến', style: const TextStyle(color: Colors.grey, fontSize: 9.5)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Nút Lưu
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
                onPressed: _saveUpdates,
                child: const Text('LƯU CẬP NHẬT', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String statusKey, String label, MaterialColor color) {
    final isSelected = _status == statusKey;
    return ChoiceChip(
      selected: isSelected,
      label: Text(label),
      selectedColor: color.shade100,
      labelStyle: TextStyle(
        color: isSelected ? color.shade900 : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 11,
      ),
      onSelected: (val) { if (val) setState(() => _status = statusKey); },
    );
  }

  Widget _buildCheckinRow(String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black87)),
          Text(subtitle, style: const TextStyle(fontSize: 9.5, color: Colors.black54)),
        ],
      ),
    );
  }

  Widget _buildSupplyItemRow(String title, String count, bool isWarning) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.black87)),
          Text(count, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isWarning ? Colors.red.shade700 : Colors.black87)),
        ],
      ),
    );
  }

  Widget _buildGuardRow(String icon, String unitName, String strength, String shiftStatus) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(unitName, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)),
                Text('$strength · $shiftStatus', style: TextStyle(fontSize: 10.5, color: Colors.grey.shade600)),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.edit_outlined, color: Colors.grey.shade500, size: 18),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('✏️ Mở form chỉnh sửa ca trực')),
              );
            },
          ),
        ],
      ),
    );
  }
}
