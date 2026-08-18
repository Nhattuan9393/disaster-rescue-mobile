import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RescueCompletionReportScreen extends StatefulWidget {
  final String sosId;
  const RescueCompletionReportScreen({super.key, required this.sosId});

  @override
  State<RescueCompletionReportScreen> createState() => _RescueCompletionReportScreenState();
}

class _RescueCompletionReportScreenState extends State<RescueCompletionReportScreen> {
  String _selectedDestination = 'Trường TH Bình Liêu (Đang có 185 người)';
  int _evacuatedCount = 4;
  final _noteCtrl = TextEditingController(text: 'Đã đưa hộ dân đến điểm sơ tán an toàn. Sức khỏe mọi người ổn định, cần bổ sung chăn ấm.');
  bool _confirmedSafe = true;

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  void _submitReport() {
    if (!_confirmedSafe) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ Vui lòng xác nhận hộ dân đã an toàn để đóng tin báo SOS!'), backgroundColor: Colors.red),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Đã gửi báo cáo tác chiến! SOS #88421 đã đóng (Hoàn thành).'),
        backgroundColor: Colors.green,
      ),
    );
    // Quay về màn hình Tác chiến cứu hộ
    context.pop(); // Pop form báo cáo
    context.pop(); // Pop chi tiết SOS để về dashboard
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
          'Báo cáo hoàn thành',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nhãn SOS
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Text(
                      '🚨 Báo cáo ứng cứu SOS #${widget.sosId.substring(0, 5)} — Hộ Nguyễn Văn Tuấn',
                      style: TextStyle(color: Colors.red.shade900, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ĐỊA ĐIỂM SƠ TÁN ĐÃ DI DỜI ĐẾN
                  const Text(
                    'ĐỊA ĐIỂM SƠ TÁN ĐÃ DI DỜI ĐẾN',
                    style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: _selectedDestination,
                    decoration: InputDecoration(
                      fillColor: Colors.white,
                      filled: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    style: const TextStyle(fontSize: 12.5, color: Colors.black87, fontWeight: FontWeight.bold),
                    items: const [
                      DropdownMenuItem(value: 'Trường TH Bình Liêu (Đang có 185 người)', child: Text('🏫 Trường TH Bình Liêu')),
                      DropdownMenuItem(value: 'Nhà văn hóa Pắc Liềng (Đang có 95 người)', child: Text('🏫 Nhà văn hóa Pắc Liềng')),
                      DropdownMenuItem(value: 'Trạm Y Tế Xã (Đang có 40 người)', child: Text('🏥 Trạm Y Tế Xã')),
                      DropdownMenuItem(value: 'Đã an toàn tại chỗ / tự túc', child: Text('🏠 Đã an toàn tại chỗ / tự túc')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedDestination = val);
                    },
                  ),
                  const SizedBox(height: 16),

                  // THỐNG KÊ NHÂN KHẨU DI DỜI THỰC TẾ
                  const Text(
                    'THỐNG KÊ NHÂN KHẨU DI DỜI THỰC TẾ',
                    style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Số người di dời thành công', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5)),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline, size: 20, color: Colors.grey),
                              onPressed: () {
                                if (_evacuatedCount > 0) setState(() => _evacuatedCount--);
                              },
                            ),
                            Container(
                              width: 30,
                              alignment: Alignment.center,
                              child: Text('$_evacuatedCount', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_circle, size: 20, color: Colors.red),
                              onPressed: () => setState(() => _evacuatedCount++),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // GHI CHÚ TÌNH TRẠNG CƯ DÂN
                  const Text(
                    'GHI CHÚ TÌNH TRẠNG & ĐỀ XUẤT',
                    style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _noteCtrl,
                    maxLines: 4,
                    decoration: InputDecoration(
                      fillColor: Colors.white,
                      filled: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
                      contentPadding: const EdgeInsets.all(12),
                    ),
                    style: const TextStyle(fontSize: 12.5),
                  ),
                  const SizedBox(height: 16),

                  // Checkbox xác nhận an toàn
                  Row(
                    children: [
                      Checkbox(
                        value: _confirmedSafe,
                        activeColor: Colors.red.shade800,
                        onChanged: (val) => setState(() => _confirmedSafe = val ?? true),
                      ),
                      const Expanded(
                        child: Text(
                          'Xác nhận hộ dân đã an toàn 100% tại điểm sơ tán.',
                          style: TextStyle(color: Colors.black87, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Nút gửi báo cáo
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
                  backgroundColor: Colors.red.shade800,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
                onPressed: _submitReport,
                child: const Text(
                  '📢 GỬI BÁO CÁO TÁC CHIẾN',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
