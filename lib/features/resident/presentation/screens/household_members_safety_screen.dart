import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HouseholdMembersSafetyScreen extends StatefulWidget {
  const HouseholdMembersSafetyScreen({super.key});

  @override
  State<HouseholdMembersSafetyScreen> createState() => _HouseholdMembersSafetyScreenState();
}

class _HouseholdMembersSafetyScreenState extends State<HouseholdMembersSafetyScreen> {
  final Map<String, bool> _safetyMap = {
    'Nguyễn Văn A (78T)': true,
    'Trần Thị B (75T)': true,
    'Nguyễn Văn C (46T)': true,
    'Lê Thị D (43T)': true,
    'Nguyễn Văn E (5T)': true,
  };

  void _submit() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('✅ Đã cập nhật trạng thái an toàn cho 5 thành viên gia đình!'),
        backgroundColor: Colors.green.shade800,
      ),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final safeCount = _safetyMap.values.where((v) => v).length;

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
          'Điểm Danh An Toàn Gia Đình',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle_outline, color: Colors.green.shade800, size: 24),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Tích chọn những thành viên đã di chuyển đến vị trí an toàn hoặc điểm sơ tán.',
                      style: TextStyle(color: Colors.green.shade900, fontWeight: FontWeight.w600, fontSize: 11.5),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Text(
              'ĐÃ AN TOÀN: $safeCount / ${_safetyMap.length} THÀNH VIÊN',
              style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 11),
            ),
            const SizedBox(height: 8),

            Expanded(
              child: ListView(
                children: _safetyMap.keys.map((name) {
                  final isChecked = _safetyMap[name] ?? false;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: isChecked ? Colors.green.shade300 : Colors.grey.shade300),
                    ),
                    child: CheckboxListTile(
                      title: Text(
                        name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: isChecked ? Colors.green.shade900 : Colors.black87,
                        ),
                      ),
                      subtitle: Text(
                        isChecked ? '⛑️ Đã xác nhận an toàn' : '⚠️ Chưa xác nhận',
                        style: TextStyle(fontSize: 10.5, color: isChecked ? Colors.green.shade700 : Colors.grey),
                      ),
                      value: isChecked,
                      activeColor: Colors.green.shade700,
                      onChanged: (val) {
                        if (val != null) setState(() => _safetyMap[name] = val);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade800,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _submit,
                child: const Text(
                  '✓ GỬI XÁC NHẬN AN TOÀN CHO CẢ GIA ĐÌNH',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
