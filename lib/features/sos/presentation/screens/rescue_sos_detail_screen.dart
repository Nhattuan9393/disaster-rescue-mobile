import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RescueSosDetailScreen extends StatefulWidget {
  final String sosId;
  const RescueSosDetailScreen({super.key, required this.sosId});

  @override
  State<RescueSosDetailScreen> createState() => _RescueSosDetailScreenState();
}

class _RescueSosDetailScreenState extends State<RescueSosDetailScreen> {
  bool _isAssignedToUs = true; // Giả định đã nhận nhiệm vụ để người dùng test đầy đủ tính năng
  String _status = 'inProgress'; // 'assigned', 'inProgress', 'completed'

  @override
  Widget build(BuildContext context) {
    final isRedPriority = true; // ca khẩn cấp mẫu
    final showSecret = _isAssignedToUs && _status == 'inProgress';

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
          'Chi tiết SOS #${widget.sosId.substring(0, 5)}',
          style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16),
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
                  // Mức độ khẩn cấp
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isRedPriority ? const Color(0xFFC62828) : Colors.orange,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          isRedPriority ? 'ĐỎ — KHẤN CẤP' : 'CAM — NGUY HIỂM',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 0.5),
                        ),
                      ),
                      Row(
                        children: const [
                          Icon(Icons.tsunami, color: Colors.blue, size: 16),
                          SizedBox(width: 4),
                          Text('Ngập lụt sâu', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Hộp thông tin liên lạc bảo mật
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'THÔNG TIN LIÊN LẠC',
                          style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 10.5),
                        ),
                        const SizedBox(height: 8),
                        if (showSecret) ...[
                          _buildInfoRow('Chủ hộ:', 'Nguyễn Văn Tuấn'),
                          const SizedBox(height: 6),
                          _buildInfoRow('Số điện thoại:', '0987 654 321'),
                          const SizedBox(height: 6),
                          _buildInfoRow('Địa chỉ cụ thể:', 'Cạnh nhà văn hóa thôn Pắc Liềng'),
                        ] else ...[
                          _buildInfoRow('Chủ hộ:', 'Nguyễn Văn ***'),
                          const SizedBox(height: 6),
                          _buildInfoRow('Số điện thoại:', '0987 *** 321'),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.orange.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.lock, color: Colors.orange.shade800, size: 16),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Vui lòng bấm Nhận nhiệm vụ để mở khóa thông tin liên lạc cư dân.',
                                    style: TextStyle(color: Colors.orange.shade900, fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Mô tả chi tiết hộ dân
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'THÔNG TIN THÀNH VIÊN & THỰC ĐỊA',
                          style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 10.5),
                        ),
                        const SizedBox(height: 8),
                        _buildInfoRow('Số nhân khẩu:', '4 người (2 người già, 1 trẻ em)'),
                        const SizedBox(height: 6),
                        _buildInfoRow('Ghi chú của hộ:', 'Nước dâng ngập tầng 1, cả nhà đang trú trên tầng 2/nóc nhà, cần sơ tán gấp.'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Bản đồ mini mô phỏng chỉ đường (chỉ hiển thị khi đã nhận nhiệm vụ)
                  if (showSecret)
                    Container(
                      height: 180,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Stack(
                        children: [
                          const Center(
                            child: Icon(Icons.map_outlined, color: Colors.grey, size: 40),
                          ),
                          // Giả lập bản đồ vệ tinh nhỏ cắm mốc đỏ và xanh
                          Positioned(
                            top: 20,
                            left: 30,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: Colors.blue.shade900, borderRadius: BorderRadius.circular(4)),
                              child: const Text('Vị trí của tôi', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                            ),
                          ),
                          Positioned(
                            bottom: 40,
                            right: 50,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: Colors.red.shade900, borderRadius: BorderRadius.circular(4)),
                              child: const Text('Điểm SOS', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 12),

                  // Timeline tiến trình SOS
                  const Text(
                    'TIẾN TRÌNH XỬ LÝ SOS',
                    style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 10.5, letterSpacing: 0.3),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      children: [
                        _buildTimelineRow('15:00', 'Cư dân gửi yêu cầu SOS khẩn cấp', true),
                        _buildTimelineDivider(),
                        _buildTimelineRow('15:10', 'Ban chỉ huy xã phê duyệt tin báo', true),
                        _buildTimelineDivider(),
                        _buildTimelineRow('15:20', 'Đã phân công Đội Dân quân Pắc Liềng ứng cứu', _isAssignedToUs),
                        _buildTimelineDivider(),
                        _buildTimelineRow('15:30', 'Đội cứu hộ bắt đầu di chuyển tiếp cận', showSecret),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Nút hành động dưới chân
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFE0E0E0), width: 0.5)),
            ),
            child: !_isAssignedToUs
                ? SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade800,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        setState(() {
                          _isAssignedToUs = true;
                          _status = 'inProgress';
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('✅ Đã nhận nhiệm vụ! Thông tin liên hệ đã được mở khóa.'), backgroundColor: Colors.green),
                        );
                      },
                      child: const Text('NHẬN NHIỆM VỤ ➔', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13)),
                    ),
                  )
                : Row(
                    children: [
                      // Nút Gọi điện
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.blue.shade900,
                          side: BorderSide(color: Colors.blue.shade900),
                          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: const Icon(Icons.phone, size: 16),
                        label: const Text('Gọi điện', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('📞 Đang kết nối cuộc gọi khẩn cấp tới chủ hộ Nguyễn Văn Tuấn...')),
                          );
                        },
                      ),
                      const SizedBox(width: 8),

                      // Nút Tiếp tế
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.orange.shade900,
                            side: BorderSide(color: Colors.orange.shade600),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          icon: const Icon(Icons.backpack_outlined, size: 16),
                          label: const Text('Phát cứu trợ', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          onPressed: () => context.push('/rescue-delivery?sosId=${widget.sosId}'),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Nút Báo cáo hoàn thành / Xác nhận an toàn
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade700,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            elevation: 0,
                          ),
                          onPressed: () => context.push('/rescue-completion?sosId=${widget.sosId}'),
                          child: const Text('Báo cáo hoàn thành', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w600)),
        ),
        Expanded(
          child: Text(value, style: const TextStyle(color: Colors.black87, fontSize: 12, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildTimelineRow(String time, String title, bool isDone) {
    return Row(
      children: [
        Text(time, style: TextStyle(color: isDone ? Colors.green.shade800 : Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontWeight: isDone ? FontWeight.bold : FontWeight.normal,
              fontSize: 11.5,
              color: isDone ? Colors.black87 : Colors.grey,
            ),
          ),
        ),
        Icon(
          isDone ? Icons.check_circle : Icons.radio_button_unchecked,
          color: isDone ? Colors.green : Colors.grey,
          size: 15,
        ),
      ],
    );
  }

  Widget _buildTimelineDivider() {
    return Container(
      margin: const EdgeInsets.only(left: 30),
      alignment: Alignment.centerLeft,
      height: 12,
      child: Container(
        width: 1,
        color: Colors.grey.shade300,
      ),
    );
  }
}
