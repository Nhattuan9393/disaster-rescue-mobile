import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../config/data/emergency_config_repository.dart';
import '../../../household/data/household_repository.dart';
import '../../../sos/data/sos_delivery_service.dart';
import '../../../sos/presentation/providers/sos_provider.dart';

class OfflineSmsFallbackScreen extends ConsumerWidget {
  const OfflineSmsFallbackScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final household = ref.watch(myHouseholdStreamProvider).value;
    final householdId = household?.id ?? 'HH000';
    final recentSosAsync = ref.watch(recentResidentSosProvider(householdId));
    final cfg = ref.watch(emergencyConfigProvider);
    final targetPhone = cfg.hotlinePhone;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.red.shade700,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          '📶 Cứu Hộ SMS Ngoại Tuyến',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      body: recentSosAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => _buildBody(
          context,
          _defaultPayload(householdId),
          latLng: 'Chưa xác định',
          priority: 'P0',
          members: '${household?.memberCount ?? 0}',
          address: household?.address ?? 'Chưa đăng ký',
          targetPhone: targetPhone,
          hotlineLabel: cfg.hotlineLabel,
        ),
        data: (sos) {
          final payload = sos != null
              ? SosDeliveryService.buildSmsPayload(sos)
              : _defaultPayload(householdId);
          return _buildBody(
            context,
            payload,
            latLng: sos != null
                ? '${sos.latitude.toStringAsFixed(4)}° N, ${sos.longitude.toStringAsFixed(4)}° E'
                : 'Toạ độ nhà đăng ký',
            priority: sos != null ? 'P${sos.priorityScore}' : 'P0',
            members: '${household?.memberCount ?? 0}',
            address: household?.address ?? 'Chưa đăng ký',
            targetPhone: targetPhone,
            hotlineLabel: cfg.hotlineLabel,
          );
        },
      ),
    );
  }

  String _defaultPayload(String householdId) {
    final shortHh = householdId.length > 8 ? householdId.substring(0, 8) : householdId;
    return 'SOS#$shortHh#21.5430,107.3990#P0#0';
  }

  Future<void> _sendSms(BuildContext context, String payload, String targetPhone) async {
    final messenger = ScaffoldMessenger.of(context);
    final uri = Uri(
      scheme: 'sms',
      path: targetPhone,
      queryParameters: {'body': payload},
    );
    bool ok;
    try {
      ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      ok = false;
    }
    if (!ok) {
      await Clipboard.setData(ClipboardData(text: payload));
      messenger.showSnackBar(
        SnackBar(
          content: Text('Không mở được ứng dụng SMS. Đã copy cú pháp — dán vào tin nhắn gửi $targetPhone'),
          backgroundColor: Colors.orange.shade800,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  Widget _buildBody(
    BuildContext context,
    String payload, {
    required String latLng,
    required String priority,
    required String members,
    required String address,
    required String targetPhone,
    required String hotlineLabel,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Thẻ Cảnh báo Mất mạng
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFEBEE),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.shade300),
            ),
            child: Row(
              children: [
                const Icon(Icons.signal_cellular_connected_no_internet_4_bar, color: Colors.red, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mất kết nối Internet 4G / Wifi',
                        style: TextStyle(color: Colors.red.shade900, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'SOS đã lưu vào hàng đợi và sẽ tự đồng bộ khi có mạng. Nếu cần khẩn cấp, gửi SMS bên dưới.',
                        style: TextStyle(color: Colors.black87, fontSize: 10.5),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 2. Chuỗi Cú pháp SMS mã hóa nén
          const Text(
            'CÚ PHÁP SMS NÉN MÃ HÓA (DƯỚI 140 KÝ TỰ)',
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 11),
          ),
          const SizedBox(height: 6),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SelectableText(
                  payload,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold,
                    fontSize: 13.5,
                    color: Colors.blue.shade900,
                  ),
                ),
                const Divider(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Tổng đài: $targetPhone · $hotlineLabel',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        await Clipboard.setData(ClipboardData(text: payload));
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('📋 Đã copy cú pháp SMS.')),
                          );
                        }
                      },
                      child: const Icon(Icons.content_copy, size: 16, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 3. Giải mã các trường dữ liệu
          const Text(
            'GIẢI MÃ NỘI DUNG GỬI',
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 11),
          ),
          const SizedBox(height: 6),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              children: [
                _buildDecodedRow('Mã hộ dân', address),
                _buildDecodedRow('Toạ độ GPS', latLng),
                _buildDecodedRow('Điểm ưu tiên', priority),
                _buildDecodedRow('Nhân khẩu', '$members người'),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 4. Trạng thái hàng đợi
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.cloud_off_outlined, color: Colors.blue.shade800, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'SOS đang giữ trong hàng đợi Hive local. Khi có mạng, hệ thống tự đẩy lên Ban chỉ huy — bạn không phải bấm lại.',
                    style: TextStyle(color: Colors.blue.shade900, fontSize: 10.5, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 5. Nút bấm gửi SMS
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => _sendSms(context, payload, targetPhone),
              icon: const Icon(Icons.sms, color: Colors.white),
              label: const Text(
                '📱 MỞ ỨNG DỤNG NHẮN TIN GỬI SMS NGAY',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDecodedRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.black87),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
