import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

enum _ImportSource { fromDevice, fromZaloEmail, fromGoogleSheet }

class BulkImportResidentsScreen extends StatefulWidget {
  const BulkImportResidentsScreen({super.key});

  @override
  State<BulkImportResidentsScreen> createState() => _BulkImportResidentsScreenState();
}

class _BulkImportResidentsScreenState extends State<BulkImportResidentsScreen> {
  _ImportSource? _selectedSource;
  bool _hasPreview = false;
  bool _hasDuplicate = true; // mô phỏng 3 SĐT bị trùng
  bool _isImporting = false;
  bool _importDone = false;

  // State nhập thủ công
  final _manualNameCtrl = TextEditingController();
  final _manualPhoneCtrl = TextEditingController();
  final _manualAddressCtrl = TextEditingController();
  final _manualCountCtrl = TextEditingController(text: '4');

  @override
  void dispose() {
    _manualNameCtrl.dispose();
    _manualPhoneCtrl.dispose();
    _manualAddressCtrl.dispose();
    _manualCountCtrl.dispose();
    super.dispose();
  }

  void _selectSource(_ImportSource src) {
    if (src == _ImportSource.fromGoogleSheet) {
      _showGoogleSheetDialog();
    } else if (src == _ImportSource.fromDevice) {
      _showDeviceFileDialog();
    } else {
      _showZaloEmailDialog();
    }
  }

  // Mở Dialog Google Sheet
  void _showGoogleSheetDialog() {
    final linkCtrl = TextEditingController(text: 'https://docs.google.com/spreadsheets/d/1vG-Z9...');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.cloud_outlined, color: Colors.blue),
            SizedBox(width: 8),
            Text('Nhập link Google Sheet', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Dán link Google Sheet công khai chứa 12 cột danh sách hộ dân:', style: TextStyle(fontSize: 11.5)),
            const SizedBox(height: 10),
            TextField(
              controller: linkCtrl,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Link Google Sheet',
                contentPadding: EdgeInsets.all(10),
              ),
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade800),
            onPressed: () {
              Navigator.pop(ctx);
              _simulateLoadingPreview(_ImportSource.fromGoogleSheet);
            },
            child: const Text('Tải & Preview', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // Mở Dialog Chọn file từ máy
  void _showDeviceFileDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.folder_open, color: Colors.orange),
            SizedBox(width: 8),
            Text('Chọn tệp tin từ máy', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildFileSelectItem('ho_dan_binh_lieu_final.xlsx', '124 KB', () {
                Navigator.pop(ctx);
                _simulateLoadingPreview(_ImportSource.fromDevice);
              }),
              const SizedBox(height: 8),
              _buildFileSelectItem('danh_sach_cuu_tro_dong_ruong.csv', '45 KB', () {
                Navigator.pop(ctx);
                _simulateLoadingPreview(_ImportSource.fromDevice);
              }),
            ],
          ),
        ),
      ),
    );
  }

  // Mở Dialog File Zalo / Email
  void _showZaloEmailDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.chat_bubble_outline, color: Colors.green),
            SizedBox(width: 8),
            Text('Nhận tệp từ Zalo/Email', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildFileSelectItem('Zalo_Received_BinhLieu_Resident.xlsx', '98 KB', () {
                Navigator.pop(ctx);
                _simulateLoadingPreview(_ImportSource.fromZaloEmail);
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFileSelectItem(String fileName, String size, VoidCallback onTap) {
    return ListTile(
      tileColor: Colors.grey.shade100,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      leading: const Icon(Icons.table_chart, color: Colors.green),
      title: Text(fileName, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      subtitle: Text('Dung lượng: $size', style: const TextStyle(fontSize: 10)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 12),
      onTap: onTap,
    );
  }

  // Mô phỏng tải và hiển thị preview
  void _simulateLoadingPreview(_ImportSource src) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        content: Row(
          children: const [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Text('Đang phân tích cấu trúc tệp...', style: TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );

    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pop(); // Đóng loading dialog
    setState(() {
      _selectedSource = src;
      _hasPreview = true;
      _hasDuplicate = true;
      _importDone = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('📊 Đã tải thành công 120 hộ dân vào bảng Preview!'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  // Xử lý trùng số điện thoại
  void _handleDuplicateResolve() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            SizedBox(width: 8),
            Text('Xử lý SĐT trùng lặp', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          'Hệ thống phát hiện có 3 số điện thoại trùng lặp giữa file mới và cơ sở dữ liệu hiện tại của Xã Bình Liêu.\n\nChọn phương án xử lý:',
          style: TextStyle(fontSize: 12, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() => _hasDuplicate = false);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('✅ Đã giữ lại thông tin hiện có, bỏ qua bản ghi trùng.')),
              );
            },
            child: const Text('Bỏ qua bản ghi mới', style: TextStyle(fontSize: 11)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange.shade800),
            onPressed: () {
              Navigator.pop(ctx);
              setState(() => _hasDuplicate = false);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('✅ Đã ghi đè thông tin mới nhất lên cơ sở dữ liệu.')),
              );
            },
            child: const Text('Ghi đè bản mới', style: TextStyle(color: Colors.white, fontSize: 11)),
          ),
        ],
      ),
    );
  }

  // Mở Form Nhập thủ công
  void _showManualInputDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.edit, color: Colors.red),
            SizedBox(width: 8),
            Text('Nhập thủ công hộ dân', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _manualNameCtrl,
                decoration: const InputDecoration(labelText: 'Tên chủ hộ', contentPadding: EdgeInsets.all(8)),
                style: const TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _manualPhoneCtrl,
                decoration: const InputDecoration(labelText: 'Số điện thoại', contentPadding: EdgeInsets.all(8)),
                style: const TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _manualAddressCtrl,
                decoration: const InputDecoration(labelText: 'Địa chỉ (Thôn / Bản)', contentPadding: EdgeInsets.all(8)),
                style: const TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _manualCountCtrl,
                decoration: const InputDecoration(labelText: 'Số nhân khẩu', contentPadding: EdgeInsets.all(8)),
                keyboardType: TextInputType.number,
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade800),
            onPressed: () {
              if (_manualNameCtrl.text.isEmpty || _manualPhoneCtrl.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('⚠️ Vui lòng nhập đầy đủ tên và SĐT!'), backgroundColor: Colors.orange),
                );
                return;
              }
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('🎉 Đã thêm thành công hộ ${_manualNameCtrl.text} vào cơ sở dữ liệu!'),
                  backgroundColor: Colors.green,
                ),
              );
              // Reset form
              _manualNameCtrl.clear();
              _manualPhoneCtrl.clear();
              _manualAddressCtrl.clear();
            },
            child: const Text('Thêm hộ dân', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _doImport() async {
    setState(() => _isImporting = true);
    await Future.delayed(const Duration(milliseconds: 1000));
    setState(() {
      _isImporting = false;
      _importDone = true;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('🎉 Đã import thành công 120 hộ dân vào cơ sở dữ liệu Xã Bình Liêu!'),
          backgroundColor: Colors.green.shade800,
        ),
      );
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) context.pop();
      });
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
          'Import Danh sách Hộ dân',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Banner chuẩn bị
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Text('📅', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CÔNG TÁC CHUẨN BỊ — làm trước mùa thiên tai',
                          style: TextStyle(color: Colors.blue.shade900, fontWeight: FontWeight.bold, fontSize: 11),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Khuyến nghị dùng bản web để import số lượng lớn. Bản mobile dùng khi cần bổ sung gấp ngoài thực địa.',
                          style: TextStyle(color: Colors.blue.shade800, fontSize: 10, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 2. Chọn nguồn file
            const Text(
              'CHỌN NGUỒN FILE',
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 0.5),
            ),
            const SizedBox(height: 8),

            _buildSourceOption(
              icon: Icons.folder_open,
              iconColor: Colors.orange.shade700,
              title: 'Chọn file từ máy',
              subtitle: 'Từ bộ nhớ trong / thẻ nhớ — .xlsx, .csv',
              src: _ImportSource.fromDevice,
            ),
            const SizedBox(height: 8),
            _buildSourceOption(
              icon: Icons.chat_bubble_outline,
              iconColor: Colors.green.shade700,
              title: 'Nhận file từ Zalo / Email',
              subtitle: 'Mở file đính kèm đã tải về',
              src: _ImportSource.fromZaloEmail,
            ),
            const SizedBox(height: 8),
            _buildSourceOption(
              icon: Icons.cloud_outlined,
              iconColor: Colors.blue.shade700,
              title: 'Từ link Google Sheet',
              subtitle: 'Dán link chia sẻ công khai',
              src: _ImportSource.fromGoogleSheet,
            ),
            const SizedBox(height: 12),

            // 3. Nút phụ trợ
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue.shade800,
                      side: BorderSide(color: Colors.blue.shade300),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    icon: const Icon(Icons.picture_as_pdf, size: 16),
                    label: const Text('Gửi file mẫu về email', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('📧 Đã gửi file mẫu 12 cột về email đã đăng ký')),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey.shade700,
                      side: BorderSide(color: Colors.grey.shade400),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    icon: const Icon(Icons.table_chart_outlined, size: 16),
                    label: const Text('Xem cấu trúc 12 cột', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    onPressed: () {
                      _showColumnStructureDialog(context);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // 4. Nút nhập thủ công
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red.shade700,
                  side: BorderSide(color: Colors.red.shade300),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Icon(Icons.edit, size: 16),
                label: const Text('✏️ Nhập thủ công từng hộ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                onPressed: _showManualInputDialog,
              ),
            ),

            if (_hasPreview) ...[
              const SizedBox(height: 20),

              // 5. Preview header
              Row(
                children: [
                  Text(
                    'PREVIEW — ho_dan_binh_lieu.xlsx',
                    style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 0.3),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // 6. Stats cards
              Row(
                children: [
                  _buildStatCard('120', 'Tổng hộ', Colors.blue.shade800),
                  const SizedBox(width: 8),
                  _buildStatCard('450', 'Nhân khẩu', Colors.green.shade700),
                  const SizedBox(width: 8),
                  _buildStatCard('35', 'Người yếu thế', Colors.orange.shade700),
                ],
              ),
              const SizedBox(height: 10),

              // 7. Cảnh báo trùng
              if (_hasDuplicate)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.shade300),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.warning_amber_rounded, color: Colors.orange.shade800, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            '3 SĐT bị trùng',
                            style: TextStyle(color: Colors.orange.shade900, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: _handleDuplicateResolve,
                        child: Text(
                          'Xử lý →',
                          style: TextStyle(color: Colors.orange.shade900, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),

              // 8. Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey.shade700,
                        side: BorderSide(color: Colors.grey.shade400),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        setState(() {
                          _selectedSource = null;
                          _hasPreview = false;
                          _importDone = false;
                          _hasDuplicate = true;
                        });
                      },
                      child: const Text('Bỏ qua', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _importDone ? Colors.green.shade700 : Colors.red.shade800,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        elevation: 0,
                      ),
                      onPressed: _isImporting || _importDone ? null : _doImport,
                      child: _isImporting
                          ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Text(
                              _importDone ? '✓ Đã import 120 hộ thành công' : 'Xác nhận Import',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13),
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSourceOption({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required _ImportSource src,
  }) {
    final isSelected = _selectedSource == src;
    return GestureDetector(
      onTap: () => _selectSource(src),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.blue.shade400 : Colors.grey.shade300,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
                  Text(subtitle, style: TextStyle(color: Colors.grey.shade600, fontSize: 10.5)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 22)),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  void _showColumnStructureDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cấu trúc 12 cột chuẩn', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final col in [
                '1. Tên chủ hộ',
                '2. Số điện thoại',
                '3. Thôn / Bản',
                '4. Số nhân khẩu',
                '5. Cấp nhà',
                '6. Vĩ độ (lat)',
                '7. Kinh độ (lng)',
                '8. Người cao tuổi (Y/N)',
                '9. Trẻ em (Y/N)',
                '10. Khuyết tật (Y/N)',
                '11. Mang thai (Y/N)',
                '12. Ghi chú',
              ])
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Text(col, style: const TextStyle(fontSize: 12, color: Colors.black87)),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }
}
