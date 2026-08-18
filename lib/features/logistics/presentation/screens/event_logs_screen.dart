import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class EventLogTimelineItem {
  final String time;
  final String icon;
  final String title;
  final String description;
  final Color color;
  const EventLogTimelineItem({
    required this.time,
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}

class EventLogsScreen extends StatefulWidget {
  const EventLogsScreen({super.key});
  @override
  State<EventLogsScreen> createState() => _EventLogsScreenState();
}

class _EventLogsScreenState extends State<EventLogsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Leo thang state
  String _requestType = 'Nhân lực';
  int _numPeople = 20;
  int _numBoats = 3;
  final _descController = TextEditingController(
    text: 'Đường vào thôn Pắc Liềng bị sạt lở, không tiếp cận bằng xe. Cần xuồng máy đi đường sông.',
  );

  final List<EventLogTimelineItem> _logs = const [
    EventLogTimelineItem(time: '10:15', icon: '📦', title: 'Xuất kho nhu yếu phẩm tiếp tế',
        description: 'Xuất 20 áo phao, 50 chăn, 100 chai nước cho điểm sơ tán Trường TH Bình Liêu', color: Colors.blue),
    EventLogTimelineItem(time: '10:05', icon: '⛑️', title: 'Cứu hộ thành công 5 người',
        description: 'Đội Dân quân Pắc Liềng đã tiếp cận và đưa 5 người hộ Nguyễn Văn A đến nơi an toàn', color: Colors.green),
    EventLogTimelineItem(time: '09:52', icon: '📣', title: 'Phát lệnh sơ tán diện rộng',
        description: 'Admin xã phát lệnh sơ tán khẩn cấp toàn vùng ngập Thôn Pắc Liềng & Nà Lầu kèm bản dịch Tiếng Tày', color: Colors.orange),
    EventLogTimelineItem(time: '09:45', icon: '🚀', title: 'Tiếp nhận nhiệm vụ SOS #DR-2025-0042',
        description: 'Đội Cứu Hộ Công An Xã bấm "Tôi đi" và xuất phát', color: Colors.purple),
    EventLogTimelineItem(time: '09:12', icon: '🆘', title: 'Tín hiệu SOS khẩn cấp mới',
        description: 'Hộ Trần Thị B gửi tín hiệu SOS (Ngập nhà 1.5m, 3 người, có trẻ em)', color: Colors.red),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _descController.dispose();
    super.dispose();
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
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'Leo thang & Nhật ký',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.red.shade800,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.red.shade800,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: const [
            Tab(text: 'Leo thang'),
            Tab(text: 'Nhật ký'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildEscalationTab(),
          _buildLogTab(),
        ],
      ),
    );
  }

  Widget _buildEscalationTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner
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
                Icon(Icons.info_outline, color: Colors.blue.shade800, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Leo thang tự nó đã là tuyên bố "xã hết khả năng" — Không còn chọn mức khẩn cấp. Huyện xếp ưu tiên dựa trên số liệu bên dưới.',
                    style: TextStyle(color: Colors.blue.shade900, fontSize: 10.5, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Bảng cơ sở leo thang
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.shade300, width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.bar_chart, color: Colors.red.shade800, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      'CƠ SỞ LEO THANG — tự động tính lúc 09:52',
                      style: TextStyle(color: Colors.red.shade900, fontWeight: FontWeight.bold, fontSize: 11),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _buildDataRow('SOS mức đỏ chưa có đội nhận', '12', Colors.red.shade700),
                _buildDataRow('Thời gian chờ lâu nhất', '1h 47ph', Colors.orange.shade800),
                _buildDataRow('Hộ mất liên lạc > 4 giờ', '8', Colors.red.shade700),
                _buildDataRow('Đội khả dụng / tổng số', '2 / 12', Colors.orange.shade800),
                _buildDataRow('Mặt hàng dưới ngưỡng', '2', Colors.orange.shade800),
                _buildDataRow('Điểm sơ tán còn trống', '155 chỗ', Colors.green.shade700),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '🔒 Số liệu hệ thống sinh — admin không sửa được',
                    style: TextStyle(color: Colors.red.shade900, fontSize: 9.5, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Loại yêu cầu
          const Text(
            'LOẠI YÊU CẦU',
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 0.5),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: ['Nhân lực', 'Vật tư', 'Y tế', 'Khác'].map((t) {
              final isSelected = _requestType == t;
              return ChoiceChip(
                label: Text(t),
                selected: isSelected,
                selectedColor: Colors.red.shade700,
                backgroundColor: Colors.white,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 12,
                ),
                onSelected: (v) { if (v) setState(() => _requestType = t); },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Số lượng cụ thể
          const Text(
            'SỐ LƯỢNG CỤ THỂ CẦN',
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 0.5),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _buildCounterBox('Người', _numPeople, (v) => setState(() => _numPeople = v))),
              const SizedBox(width: 12),
              Expanded(child: _buildCounterBox('Xuồng máy', _numBoats, (v) => setState(() => _numBoats = v))),
            ],
          ),
          const SizedBox(height: 16),

          // Mô tả chi tiết
          const Text(
            'MÔ TẢ CHI TIẾT',
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 0.5),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _descController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Mô tả tình huống chi tiết...',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
            style: const TextStyle(fontSize: 12),
          ),
          const SizedBox(height: 20),

          // Nút gửi
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade800,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              icon: const Icon(Icons.campaign, color: Colors.white, size: 18),
              label: const Text('GỬI YÊU CẦU LEO THANG LÊN HUYỆN',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13)),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('📢 Đã gửi yêu cầu leo thang: ${_requestType}, $_numPeople người, $_numBoats xuồng'),
                    backgroundColor: Colors.red.shade800,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataRow(String label, String value, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.black87)),
          Text(value, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: valueColor)),
        ],
      ),
    );
  }

  Widget _buildCounterBox(String label, int value, ValueChanged<int> onChanged) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 10.5, color: Colors.grey.shade600, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () { if (value > 0) onChanged(value - 1); },
                child: Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(8)),
                  child: const Center(child: Text('−', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                ),
              ),
              Text('$value', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
              GestureDetector(
                onTap: () => onChanged(value + 1),
                child: Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(color: Colors.red.shade700, borderRadius: BorderRadius.circular(8)),
                  child: const Center(child: Text('+', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white))),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLogTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _logs.length,
      itemBuilder: (context, index) {
        final item = _logs[index];
        final isLast = index == _logs.length - 1;
        return GestureDetector(
          onTap: () {
            // Navigate to log detail - passing index as log id
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => LogDetailScreen(logIndex: index, item: item),
              ),
            );
          },
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 45,
                  child: Text(
                    item.time,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey.shade700),
                  ),
                ),
                Column(
                  children: [
                    Container(
                      width: 28, height: 28,
                      decoration: BoxDecoration(
                        color: item.color.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(color: item.color),
                      ),
                      child: Center(child: Text(item.icon, style: const TextStyle(fontSize: 12))),
                    ),
                    if (!isLast)
                      Expanded(child: Container(width: 2, color: Colors.grey.shade300)),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                item.title,
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: item.color),
                              ),
                            ),
                            Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 16),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.description,
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade800, height: 1.3),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ======================== LOG DETAIL SCREEN ========================
class LogDetailScreen extends StatelessWidget {
  final int logIndex;
  final EventLogTimelineItem item;

  const LogDetailScreen({super.key, required this.logIndex, required this.item});

  @override
  Widget build(BuildContext context) {
    final logId = 'LOG-${80000 + logIndex * 1234}';
    final beforeStatus = logIndex == 3 ? 'status: verified\nassignedTeam: null' : 'status: pending\nassignedTeam: null';
    final afterStatus = logIndex == 3 ? 'status: assigned\nassignedTeam: Dân quân 1' : 'status: completed\nassignedTeam: Đội CA Xã';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Chi tiết sự kiện',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                logId,
                style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header event info
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: item.color.withValues(alpha: 0.4), width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          color: item.color.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Center(child: Text(item.icon, style: const TextStyle(fontSize: 18))),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          item.title,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: item.color),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _buildMetaRow('Người thực hiện', 'Trần Văn Nam — Admin xã'),
                  _buildMetaRow('Từ đâu', 'App mobile · 21.5412°N'),
                  _buildMetaRow('Thiết bị', 'Android 13 · v1.0.4'),
                  _buildMetaRow('Thời gian', '03/08/2026 ${item.time}:12'),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Diff trạng thái
            const Text('THAY ĐỔI GÌ', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 0.5)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('TRƯỚC', style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.bold, fontSize: 9)),
                        const SizedBox(height: 4),
                        Text(beforeStatus, style: TextStyle(color: Colors.red.shade900, fontSize: 10.5, fontFamily: 'monospace')),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(Icons.arrow_forward, color: Colors.grey.shade500, size: 20),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('SAU', style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.bold, fontSize: 9)),
                        const SizedBox(height: 4),
                        Text(afterStatus, style: TextStyle(color: Colors.green.shade900, fontSize: 10.5, fontFamily: 'monospace')),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Đối tượng liên quan
            const Text('ĐỐI TƯỢNG LIÊN QUAN', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 0.5)),
            const SizedBox(height: 8),
            _buildRelatedCard('🆘', 'SOS #DR-2025-0042', 'Hộ Nguyễn Văn A — Thôn Pắc Liềng', const Color(0xFFE53935)),
            const SizedBox(height: 6),
            _buildRelatedCard('🛶', 'Đội Dân quân Pắc Liềng', '8 người · 2 thuyền', Colors.green.shade700),
            const SizedBox(height: 14),

            // Chuỗi sự kiện
            const Text('CHUỖI SỰ KIỆN CỦA SOS #0042', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 0.5)),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTimelineEntry('14:12', 'SOS tạo — điểm ưu tiên 85 (ĐỎ)', false, Colors.red.shade700),
                  _buildTimelineEntry('14:20', 'Admin xác minh → verified', false, Colors.orange.shade700),
                  _buildTimelineEntry('14:35', 'Gán cho Đội Dân quân 1', true, Colors.blue.shade700),
                  _buildTimelineEntry('14:58', 'Đội báo đã đến hiện trường', false, Colors.green.shade700),
                  _buildTimelineEntry('15:22', 'Hoàn thành — cứu 5 người', false, Colors.green.shade900),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Nút xuất báo cáo
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.blue.shade800,
                  side: BorderSide(color: Colors.blue.shade300),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.file_download_outlined, size: 18),
                label: const Text('Xuất nhật ký sự kiện (PDF / Excel)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('📄 Đã xuất file báo cáo sự kiện thành công')),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetaRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: TextStyle(fontSize: 10.5, color: Colors.grey.shade600)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Colors.black87)),
          ),
        ],
      ),
    );
  }

  Widget _buildRelatedCard(String icon, String title, String subtitle, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
            child: Center(child: Text(icon, style: const TextStyle(fontSize: 14))),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black87)),
                Text(subtitle, style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 18),
        ],
      ),
    );
  }

  Widget _buildTimelineEntry(String time, String text, bool isCurrent, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Container(
            width: 8, height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text('$time — ', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 10.5,
                color: isCurrent ? Colors.blue.shade800 : Colors.black87,
                fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                backgroundColor: isCurrent ? Colors.blue.shade50 : Colors.transparent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
