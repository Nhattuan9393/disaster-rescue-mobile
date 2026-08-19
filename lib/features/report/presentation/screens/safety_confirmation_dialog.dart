import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../auth/presentation/providers/auth_controller.dart';

class SafetyConfirmationDialog extends ConsumerWidget {
  const SafetyConfirmationDialog({super.key});

  static void show(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // Bắt buộc trả lời theo RULE prototype s07
      builder: (context) => const SafetyConfirmationDialog(),
    );
  }

  void _confirmSafety(BuildContext context, WidgetRef ref, bool isSafe) async {
    final user = ref.read(currentUserProvider);
    final householdId = user?.householdId;
    if (householdId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bạn chưa liên kết với hộ dân nào.'),
          backgroundColor: Colors.orange,
        ),
      );
      Navigator.of(context).pop();
      return;
    }
    try {
      // Nguồn tự app (selfApp) = 90 điểm theo SRS
      await FirebaseFirestore.instance.collection('safety_confirmations').add({
        'householdId': householdId,
        'status': isSafe ? 'safe' : 'need_help',
        'source': 'selfApp',
        'confidence': 90,
        'createdBy': user!.uid,
        'timestamp': FieldValue.serverTimestamp(),
      });

      await FirebaseFirestore.instance
          .collection('households')
          .doc(householdId)
          .set({
        'safetyStatus': isSafe ? 'safe' : 'need_help',
        'safetySource': 'selfApp',
        'safetyConfidence': 90,
        'lastConfirmedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isSafe ? 'Đã ghi nhận bạn AN TOÀN!' : 'Đã ghi nhận yêu cầu trợ giúp!'),
            backgroundColor: isSafe ? Colors.green : Colors.red,
          ),
        );
        Navigator.of(context).pop(); // Đóng modal
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi kết nối: ${e.toString()}'), backgroundColor: Colors.red),
        );
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header cảnh báo điều kiện
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade100),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '⚙️ ĐIỀU KIỆN KÍCH HOẠT — CẢ 3 PHẢI ĐÚNG',
                    style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '1. Có thiên tai phủ khu vực hộ  2. Hộ chưa gửi SOS  3. Chưa xác nhận > 2 giờ',
                    style: TextStyle(fontSize: 8.5, color: Colors.black54),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Icon câu hỏi
            const Center(
              child: Text(
                '❓',
                style: TextStyle(fontSize: 36),
              ),
            ),
            const SizedBox(height: 8),

            const Center(
              child: Text(
                'Bạn có an toàn không?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ),
            const SizedBox(height: 4),
            const Center(
              child: Text(
                'Đây là lần hỏi thứ 2/3 — không phản hồi lần 3 sẽ báo admin',
                style: TextStyle(fontSize: 10.5, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),

            // Nút Tôi an toàn
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              onPressed: () => _confirmSafety(context, ref, true),
              child: const Text(
                '✓ TÔI AN TOÀN',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
            const SizedBox(height: 8),

            // Nút Tôi cần giúp
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              onPressed: () => _confirmSafety(context, ref, false),
              child: const Text(
                '🆘 TÔI CẦN GIÚP',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Không có nút đóng — bắt buộc trả lời',
              style: TextStyle(fontSize: 9, color: Colors.grey, fontStyle: FontStyle.italic),
              textAlign: TextAlign.center,
            ),
            const Divider(height: 24),

            // Bảng nguồn thay thế
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '🔁 NẾU ĐIỆN THOẠI MẤT / HẾT PIN — 4 NGUỒN THAY THẾ',
                    style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Colors.green.shade800),
                  ),
                  const SizedBox(height: 8),
                  _buildSourceRow('⛑️ Đội cứu hộ xác nhận tại hiện trường', '100%'),
                  _buildSourceRow('🏫 Check-in tại điểm sơ tán', '95%'),
                  _buildSourceRow('🏛️ Trưởng thôn xác nhận thủ công', '70%'),
                  _buildSourceRow('👥 Hàng xóm báo hộ (qua luồng B)', '40%'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceRow(String source, String confidence) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              source,
              style: const TextStyle(fontSize: 9, color: Colors.black87),
            ),
          ),
          Text(
            confidence,
            style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.green.shade700),
          ),
        ],
      ),
    );
  }
}
