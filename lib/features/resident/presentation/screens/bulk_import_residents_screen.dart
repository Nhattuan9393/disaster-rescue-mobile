import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BulkImportResidentsScreen extends StatefulWidget {
  const BulkImportResidentsScreen({super.key});

  @override
  State<BulkImportResidentsScreen> createState() => _BulkImportResidentsScreenState();
}

class _BulkImportResidentsScreenState extends State<BulkImportResidentsScreen> {
  bool _isUploading = false;
  bool _isImported = false;

  void _processImport() async {
    setState(() => _isUploading = true);
    await Future.delayed(const Duration(milliseconds: 600));
    setState(() {
      _isUploading = false;
      _isImported = true;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('🎉 Đã import thành công 480 hộ dân vào cơ sở dữ liệu Xã Bình Liêu!'),
          backgroundColor: Colors.green.shade800,
        ),
      );
    }
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
          'Import Dân Cư Hàng Loạt',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Thẻ Tải file mẫu CSV
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.file_download, color: Colors.blue.shade900, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tải file mẫu Excel / CSV chuẩn',
                          style: TextStyle(color: Colors.blue.shade900, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Định dạng bao gồm: Tên chủ hộ, SĐT, Thôn bản, Số nhân khẩu, Cấp nhà, Đối tượng ưu tiên.',
                          style: TextStyle(color: Colors.black87, fontSize: 10.5),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 2. Khung Tải lên tệp
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                children: [
                  const Icon(Icons.upload_file, color: Colors.blue, size: 48),
                  const SizedBox(height: 8),
                  Text(
                    'danh_sach_dan_cu_binh_lieu_480ho.csv',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue.shade900, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  const Text('Dung lượng: 48 KB · 480 hàng dữ liệu', style: TextStyle(color: Colors.grey, fontSize: 11)),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 3. Bảng Xem trước Dữ liệu (Data Preview)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'XEM TRƯỚC DỮ LIỆU IMPORT (480 HỘ)',
                  style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 11),
                ),
                Text(
                  _isImported ? '✅ Đã nạp vào DB' : '⏳ Sẵn sàng nạp',
                  style: TextStyle(
                    color: _isImported ? Colors.green.shade800 : Colors.orange.shade900,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: ListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildTableRow('Chủ hộ', 'Thôn', 'Khẩu', 'Nhà', 'Ưu tiên', isHeader: true),
                  const Divider(height: 1),
                  _buildTableRow('Nguyễn Văn A', 'Pắc Liềng', '5', 'Cấp 4', '👴 Người già'),
                  _buildTableRow('Trần Thị B', 'Nà Lầu', '3', 'Cấp 4', '👶 Trẻ em'),
                  _buildTableRow('Lý Văn C', 'Pắc Liềng', '7', 'Tầng', '♿ Khuyết tật'),
                  _buildTableRow('Hoàng Thị D', 'Khe Tiền', '2', 'Cấp 4', '🤰 Mang thai'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Nút Xác nhận Import
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isImported ? Colors.green.shade800 : Colors.blue.shade900,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _isUploading ? null : _processImport,
                child: _isUploading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        _isImported ? '✓ ĐÃ IMPORT 480 HỘ DÂN VÀO DB XÃ' : '📥 NHẬP 480 HỘ DÂN VÀO HỆ THỐNG XÃ',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13.5),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableRow(String c1, String c2, String c3, String c4, String c5, {bool isHeader = false}) {
    final style = TextStyle(
      fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
      fontSize: isHeader ? 11 : 11,
      color: isHeader ? Colors.grey.shade800 : Colors.black87,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      color: isHeader ? Colors.grey.shade100 : Colors.white,
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(c1, style: style)),
          Expanded(flex: 2, child: Text(c2, style: style)),
          Expanded(flex: 1, child: Text(c3, style: style)),
          Expanded(flex: 2, child: Text(c4, style: style)),
          Expanded(flex: 3, child: Text(c5, style: isHeader ? style : TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Colors.orange.shade900))),
        ],
      ),
    );
  }
}
