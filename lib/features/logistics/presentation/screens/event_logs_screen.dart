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

class EventLogsScreen extends StatelessWidget {
  const EventLogsScreen({super.key});

  final List<EventLogTimelineItem> _logs = const [
    EventLogTimelineItem(
      time: '10:15',
      icon: '📦',
      title: 'Xuất kho nhu yếu phẩm tiếp tế',
      description: 'Xuất 20 áo phao, 50 chăn, 100 chai nước cho điểm sơ tán Trường TH Bình Liêu',
      color: Colors.blue,
    ),
    EventLogTimelineItem(
      time: '10:05',
      icon: '⛑️',
      title: 'Cứu hộ thành công 5 người',
      description: 'Đội Dân quân Pắc Liềng đã tiếp cận và đưa 5 người hộ Nguyễn Văn A đến nơi an toàn',
      color: Colors.green,
    ),
    EventLogTimelineItem(
      time: '09:52',
      icon: '📣',
      title: 'Phát lệnh sơ tán diện rộng',
      description: 'Admin xã phát lệnh sơ tán khẩn cấp toàn vùng ngập Thôn Pắc Liềng & Nà Lầu kèm bản dịch Tiếng Tày',
      color: Colors.orange,
    ),
    EventLogTimelineItem(
      time: '09:45',
      icon: '🚀',
      title: 'Tiếp nhận nhiệm vụ SOS #DR-2025-0042',
      description: 'Đội Cứu Hộ Công An Xã bấm "Tôi đi" và xuất phát',
      color: Colors.purple,
    ),
    EventLogTimelineItem(
      time: '09:12',
      icon: '🆘',
      title: 'Tín hiệu SOS khẩn cấp mới',
      description: 'Hộ Trần Thị B gửi tín hiệu SOS (Ngập nhà 1.5m, 3 người, có trẻ em)',
      color: Colors.red,
    ),
  ];

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
          'Nhật ký Tác chiến Realtime',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _logs.length,
        itemBuilder: (context, index) {
          final item = _logs[index];
          final isLast = index == _logs.length - 1;

          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Timestamp
                SizedBox(
                  width: 45,
                  child: Text(
                    item.time,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey.shade700),
                  ),
                ),

                // Line & Node
                Column(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: item.color.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(color: item.color),
                      ),
                      child: Center(
                        child: Text(item.icon, style: const TextStyle(fontSize: 12)),
                      ),
                    ),
                    if (!isLast)
                      Expanded(
                        child: Container(
                          width: 2,
                          color: Colors.grey.shade300,
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 12),

                // Card details
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
                        Text(
                          item.title,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: item.color),
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
          );
        },
      ),
    );
  }
}
