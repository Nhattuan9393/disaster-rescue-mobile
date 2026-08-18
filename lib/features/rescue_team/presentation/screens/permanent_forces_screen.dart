import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PermanentForcesScreen extends StatefulWidget {
  const PermanentForcesScreen({super.key});

  @override
  State<PermanentForcesScreen> createState() => _PermanentForcesScreenState();
}

class _PermanentForcesScreenState extends State<PermanentForcesScreen> {
  // Trạng thái kích hoạt của Đội dân quân Khe Tiền
  bool _kheTienActivated = false;

  void _activateKheTien() {
    setState(() {
      _kheTienActivated = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('⚡ Đã kích hoạt Đội Dân quân Khe Tiền thực thi nhiệm vụ!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _activateAll() {
    setState(() {
      _kheTienActivated = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('⚡ Đã kích hoạt toàn bộ 5 đội thường trực của Xã Bình Liêu!'),
        backgroundColor: Colors.green,
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
        title: const Text(
          'Lực lượng thường trực',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        actions: const [
          Center(
            child: Padding(
              padding: EdgeInsets.only(right: 16),
              child: Text(
                '5 đội',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Banner chuẩn bị thiên tai
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('📅', style: const TextStyle(fontSize: 16)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'CÔNG TÁC CHUẨN BỊ — làm trước mùa thiên tai',
                                style: TextStyle(color: Colors.blue.shade900, fontWeight: FontWeight.bold, fontSize: 11),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                'Đội biên chế xã khai báo sẵn 1 lần. Khi có thiên tai chỉ cần kích hoạt 1 chạm, không phải đăng ký và chờ duyệt.',
                                style: TextStyle(color: Colors.blue.shade800, fontSize: 10, height: 1.4),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // 2. Chỉ số Stats
                  Row(
                    children: [
                      _buildStatCard('5', 'Đội thường trực'),
                      const SizedBox(width: 8),
                      _buildStatCard('31', 'Tổng nhân lực'),
                      const SizedBox(width: 8),
                      _buildStatCard('8', 'Phương tiện'),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // 3. Tổng vật tư biên chế
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text('📦', style: const TextStyle(fontSize: 15)),
                            const SizedBox(width: 6),
                            Text(
                              'TỔNG VẬT TƯ BIÊN CHẾ CÁC ĐỘI',
                              style: TextStyle(color: Colors.green.shade900, fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 0.3),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        _buildSupplyRow('Áo phao', '32 cái'),
                        _buildSupplyRow('Đèn pin', '18 cái'),
                        _buildSupplyRow('Túi sơ cứu', '7 túi'),
                        _buildSupplyRow('Máy phát điện', '2 máy'),
                        const SizedBox(height: 8),
                        Text(
                          'Được cộng vào \'Tổng vật tư khả dụng\' ở màn Leo thang.',
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 9.5, fontStyle: FontStyle.italic),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 4. Tiêu đề danh sách
                  const Text(
                    'DANH SÁCH ĐỘI THƯỜNG TRỰC',
                    style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 8),

                  // 5. Các card Đội thường trực
                  _buildForceCard(
                    name: 'Đội Dân quân Pắc Liềng',
                    subtitle: 'Lý Văn Thắng · 8 người · Thôn Pắc Liềng',
                    isActivated: true,
                  ),
                  const SizedBox(height: 8),
                  _buildForceCard(
                    name: 'Tổ Xung kích Nà Lầu',
                    subtitle: 'Hoàng Văn Đại · 6 người · Thôn Nà Lầu',
                    isActivated: true,
                  ),
                  const SizedBox(height: 8),
                  _buildForceCard(
                    name: 'Đội Y tế xã Bình Liêu',
                    subtitle: 'BS. Vũ Thị Hoa · 4 người · Toàn xã',
                    isActivated: true,
                  ),
                  const SizedBox(height: 8),
                  _buildForceCard(
                    name: 'Đội Dân quân Khe Tiền',
                    subtitle: 'Chu Văn Bình · 5 người · Thôn Khe Tiền',
                    isActivated: _kheTienActivated,
                    onActivate: _activateKheTien,
                  ),
                ],
              ),
            ),
          ),

          // 6. Dưới cùng 2 nút hành động
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFE0E0E0), width: 0.5)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue.shade800,
                      side: BorderSide(color: Colors.blue.shade600),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('➕ Mở form thêm đội thường trực mới biên chế xã')),
                      );
                    },
                    child: const Text(
                      '+ Thêm đội',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                    onPressed: _activateAll,
                    child: const Text(
                      '⚡ Kích hoạt toàn bộ',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String val, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          children: [
            Text(val, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: Colors.blue)),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 10, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildSupplyRow(String label, String qty) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade700, fontSize: 11)),
          Text(qty, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildForceCard({
    required String name,
    required String subtitle,
    required bool isActivated,
    VoidCallback? onActivate,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 10),
                ),
              ],
            ),
          ),
          if (isActivated)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.green.shade700,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Đã kích hoạt',
                style: TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.bold),
              ),
            )
          else
            GestureDetector(
              onTap: onActivate,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Chưa kích hoạt',
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 10.5, fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
