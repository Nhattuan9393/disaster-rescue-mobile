import 'dart:io' show File;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/services/camera_service.dart';

class ReceiveDonationsScreen extends StatefulWidget {
  const ReceiveDonationsScreen({super.key});

  @override
  State<ReceiveDonationsScreen> createState() => _ReceiveDonationsScreenState();
}

class _ReceiveDonationsScreenState extends State<ReceiveDonationsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _sponsorCtrl = TextEditingController(text: 'Nhóm thiện nguyện Hạ Long');
  final _phoneCtrl = TextEditingController(text: '0988 123 456');

  // Danh sách các mặt hàng trong gói
  final List<Map<String, dynamic>> _items = [
    {'name': 'Mì tôm', 'qty': '200', 'unit': 'thùng', 'map': '— chưa'},
    {'name': 'Nước suối', 'qty': '500', 'unit': 'chai', 'map': '💧 Nước'},
    {'name': 'Quần áo cũ', 'qty': '12', 'unit': 'bao', 'map': '— chưa'},
    {'name': 'Thuốc cảm', 'qty': '30', 'unit': 'hộp', 'map': '💊 Thuốc'},
  ];

  final CameraService _cameraService = CameraService();
  final List<XFile> _photos = [];

  Future<void> _pickFromGallery() async {
    final f = await _cameraService.pickFromGallery();
    if (f == null) return;
    if (!mounted) return;
    setState(() => _photos.add(f));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('🖼️ Đã thêm ${_labelFor(f)} vào gói.'), backgroundColor: Colors.green),
    );
  }

  Future<void> _takePhoto() async {
    final f = await _cameraService.takePhoto();
    if (f == null) return;
    if (!mounted) return;
    setState(() => _photos.add(f));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('📷 Đã chụp & đính kèm ${_labelFor(f)} vào gói GCT-2025-0007.'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _removePhoto(int index) {
    setState(() => _photos.removeAt(index));
  }

  String _labelFor(XFile f) {
    final base = f.name;
    return base.length > 22 ? '…${base.substring(base.length - 20)}' : base;
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: 1); // Chọn sẵn Gói hỗn hợp
  }

  @override
  void dispose() {
    _tabController.dispose();
    _sponsorCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _addItemRow() {
    setState(() {
      _items.add({'name': '', 'qty': '', 'unit': '', 'map': '— chưa'});
    });
  }

  void _submit() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Đã nhận gói GCT-2025-0007 thành công!'),
        backgroundColor: Colors.green,
      ),
    );
    // Chuyển sang màn hình Chi tiết gói cứu trợ đã nhận (Ảnh 5)
    context.pushReplacement('/donation-package-detail');
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
        title: const Text(
          'Nhập kho',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.blue.shade900,
          unselectedLabelColor: Colors.grey,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5),
          indicatorColor: Colors.blue.shade900,
          tabs: const [
            Tab(text: 'Hàng trong danh mục'),
            Tab(text: 'Gói hỗn hợp (mới)'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Hàng trong danh mục (Tĩnh)
          const Center(child: Text('Nhập kho hàng đơn lẻ chuẩn')),

          // Tab 2: Gói hỗn hợp (mới)
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Banner xanh lá
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: Row(
                          children: [
                            const Text('📝', style: TextStyle(fontSize: 18)),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Đoàn từ thiện chở lô hàng hỗn hợp? Nhập nhanh — hệ thống sinh mã gói ngay, phân loại sau. Không chặn luồng khẩn cấp.',
                                style: TextStyle(color: Colors.green.shade900, fontSize: 10.5, height: 1.4, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Hộp mã gói tự sinh
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'MÃ GÓI TỰ SINH',
                                  style: TextStyle(color: Colors.grey, fontSize: 9.5, fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'GCT-2025-0007',
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                              ],
                            ),
                            OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.white),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                              ),
                              icon: const Icon(Icons.print, size: 14),
                              label: const Text('In nhãn', style: TextStyle(fontSize: 10.5)),
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('🖨️ Đang kết nối máy in để in nhãn mã vạch GCT-2025-0007...')),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Textfields
                      TextField(
                        controller: _sponsorCtrl,
                        decoration: InputDecoration(
                          labelText: 'Đơn vị tài trợ *',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          contentPadding: const EdgeInsets.all(12),
                        ),
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _phoneCtrl,
                        decoration: InputDecoration(
                          labelText: 'SĐT liên hệ *',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          contentPadding: const EdgeInsets.all(12),
                        ),
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 14),

                      // Bảng danh sách mặt hàng
                      const Text(
                        'NỘI DUNG GÓI — LIỆT KÊ THÔ, MAP SAU',
                        style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 0.5),
                      ),
                      const SizedBox(height: 8),

                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Column(
                          children: [
                            // Header bảng
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                              color: Colors.grey.shade100,
                              child: Row(
                                children: const [
                                  Expanded(flex: 4, child: Text('Tên hàng', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10.5, color: Colors.grey))),
                                  Expanded(flex: 2, child: Text('SL', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10.5, color: Colors.grey))),
                                  Expanded(flex: 2, child: Text('Đơn vị', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10.5, color: Colors.grey))),
                                  Expanded(flex: 2, child: Text('Map', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10.5, color: Colors.grey))),
                                ],
                              ),
                            ),
                            const Divider(height: 1),
                            // Data rows
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _items.length,
                              separatorBuilder: (ctx, idx) => const Divider(height: 1),
                              itemBuilder: (ctx, idx) {
                                final item = _items[idx];
                                final isMapped = item['map'] != '— chưa';
                                return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 4,
                                        child: Text(
                                          item['name'],
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          item['qty'],
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          item['unit'],
                                          style: TextStyle(color: Colors.grey.shade600, fontSize: 11.5),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          item['map'],
                                          style: TextStyle(
                                            color: isMapped ? Colors.green.shade700 : Colors.grey,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11.5,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Nút thêm dòng
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.green.shade800,
                            side: BorderSide(color: Colors.green.shade300),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                          onPressed: _addItemRow,
                          child: const Text('+ Thêm dòng', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Khung ảnh xem trước
                      Container(
                        width: double.infinity,
                        height: 110,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
                        ),
                        child: _photos.isEmpty
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.image_outlined, size: 28, color: Colors.grey.shade400),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Chưa có ảnh — chọn hoặc chụp để đính kèm',
                                    style: TextStyle(color: Colors.grey.shade600, fontSize: 11, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              )
                            : ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: _photos.length,
                                separatorBuilder: (_, __) => const SizedBox(width: 8),
                                itemBuilder: (ctx, i) {
                                  final p = _photos[i];
                                  return Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.file(
                                          File(p.path),
                                          width: 90,
                                          height: 90,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => Container(
                                            width: 90, height: 90,
                                            color: Colors.grey.shade300,
                                            child: const Icon(Icons.broken_image, size: 28, color: Colors.grey),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        top: 2,
                                        right: 2,
                                        child: GestureDetector(
                                          onTap: () => _removePhoto(i),
                                          child: Container(
                                            padding: const EdgeInsets.all(3),
                                            decoration: const BoxDecoration(
                                              color: Colors.black54,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(Icons.close, color: Colors.white, size: 12),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                      ),
                      const SizedBox(height: 8),

                      // Hàng chụp ảnh
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: Colors.grey.shade400),
                                foregroundColor: Colors.black87,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              icon: const Icon(Icons.photo_library_outlined, size: 16),
                              label: Text(
                                _photos.isEmpty ? 'Chọn ảnh' : 'Chọn ảnh (${_photos.length})',
                                style: const TextStyle(fontSize: 11),
                              ),
                              onPressed: _pickFromGallery,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: Colors.grey.shade400),
                                foregroundColor: Colors.black87,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              icon: const Icon(Icons.camera_alt_outlined, size: 16),
                              label: const Text('Chụp ảnh', style: TextStyle(fontSize: 11)),
                              onPressed: _takePhoto,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      
                      Center(
                        child: Text(
                          '2/4 dòng map được — cộng thẳng tồn kho. 2 dòng còn lại giữ theo mã gói.',
                          style: TextStyle(color: Colors.grey.shade700, fontSize: 9.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Nút nhận gói dưới chân
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Color(0xFFE0E0E0), width: 0.5)),
                ),
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                    onPressed: _submit,
                    child: const Text(
                      'NHẬN GÓI — GCT-2025-0007',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

