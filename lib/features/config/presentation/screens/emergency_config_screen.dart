import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/emergency_config_repository.dart';
import '../../domain/emergency_config.dart';

class EmergencyConfigScreen extends ConsumerStatefulWidget {
  const EmergencyConfigScreen({super.key});

  @override
  ConsumerState<EmergencyConfigScreen> createState() => _EmergencyConfigScreenState();
}

class _EmergencyConfigScreenState extends ConsumerState<EmergencyConfigScreen> {
  final _phoneCtrl = TextEditingController();
  final _labelCtrl = TextEditingController();
  bool _demoMode = true;
  bool _loaded = false;
  bool _saving = false;

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _labelCtrl.dispose();
    super.dispose();
  }

  void _hydrate(EmergencyConfig cfg) {
    if (_loaded) return;
    _loaded = true;
    _phoneCtrl.text = cfg.hotlinePhone;
    _labelCtrl.text = cfg.hotlineLabel;
    _demoMode = cfg.demoMode;
  }

  Future<void> _save() async {
    if (_phoneCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Số tổng đài không được để trống'), backgroundColor: Colors.red),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      await ref.read(emergencyConfigRepositoryProvider).save(
            EmergencyConfig(
              hotlinePhone: _phoneCtrl.text.trim(),
              hotlineLabel: _labelCtrl.text.trim().isEmpty
                  ? EmergencyConfig.fallback.hotlineLabel
                  : _labelCtrl.text.trim(),
              demoMode: _demoMode,
            ),
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Đã lưu cấu hình khẩn cấp'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cfgAsync = ref.watch(emergencyConfigStreamProvider);
    cfgAsync.whenData(_hydrate);

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
          'Cấu hình khẩn cấp',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      body: cfgAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Lỗi: $err')),
        data: (_) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.amber.shade300),
                ),
                child: Row(
                  children: [
                    Icon(Icons.admin_panel_settings, color: Colors.amber.shade900),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Ở bản demo, mọi admin đều có quyền super-admin sửa mục này. Production sẽ khoá về cấp huyện.',
                        style: TextStyle(fontSize: 11, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'TỔNG ĐÀI SMS SOS',
                style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 0.5),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Số điện thoại tổng đài',
                  hintText: 'VD 02033123456',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _labelCtrl,
                decoration: InputDecoration(
                  labelText: 'Nhãn tổng đài',
                  hintText: 'Ban Chỉ huy Cứu hộ Xã Bình Liêu',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                style: const TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 20),
              const Text(
                'CHẾ ĐỘ VẬN HÀNH',
                style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 0.5),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: SwitchListTile(
                  value: _demoMode,
                  onChanged: (v) => setState(() => _demoMode = v),
                  activeColor: Colors.orange.shade700,
                  title: const Text('Chế độ Demo relay',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  subtitle: const Text(
                    'Bấm SOS → app ghi thẳng vào hộp thư Firestore mô phỏng tổng đài. Không gửi SMS thật.',
                    style: TextStyle(fontSize: 11),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, size: 16, color: Colors.blue.shade800),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _demoMode
                            ? 'Đang demo: SOS test không tốn SMS phí, không cần SIM. Bảng "Hộp thư SMS" sẽ hiện tin realtime.'
                            : 'Chế độ thật: cần server SMS gateway parse SMS từ tổng đài → bơm vào Firestore sms_inbox. Chưa cắm.',
                        style: TextStyle(fontSize: 10.5, color: Colors.blue.shade900, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade700,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: _saving ? null : _save,
                  icon: _saving
                      ? const SizedBox(
                          width: 16, height: 16,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.save, color: Colors.white),
                  label: Text(
                    _saving ? 'Đang lưu…' : 'LƯU CẤU HÌNH',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: TextButton.icon(
                  onPressed: () => context.push('/sms-inbox'),
                  icon: const Icon(Icons.inbox, size: 16),
                  label: const Text('Xem hộp thư SMS tổng đài'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
