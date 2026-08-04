import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../../core/theme/app_theme.dart';
import 'qr_result_screen.dart';

class QrScannerScreen extends ConsumerStatefulWidget {
  const QrScannerScreen({super.key});

  @override
  ConsumerState<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends ConsumerState<QrScannerScreen> {
  final MobileScannerController controller = MobileScannerController();
  final TextEditingController _manualInputController = TextEditingController();
  bool _isScanning = true;

  @override
  void dispose() {
    controller.dispose();
    _manualInputController.dispose();
    super.dispose();
  }

  void _onCodeDetected(String code) {
    if (!_isScanning) return;
    setState(() {
      _isScanning = false;
    });
    controller.stop();

    // Chuyển sang màn hình kết quả quét phân nhánh (Màn hình 40)
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => QrResultScreen(qrCode: code),
      ),
    ).then((_) {
      // Khi quay lại màn hình này, tiếp tục quét
      setState(() {
        _isScanning = true;
      });
      controller.start();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'QUÉT MÃ QR TẠI CHỐT',
          style: AppTypography.h3.copyWith(color: Colors.white),
        ),
        actions: [
          IconButton(
            color: Colors.white,
            icon: const Icon(Icons.flash_on),
            iconSize: 28,
            onPressed: () => controller.toggleTorch(),
          ),
          IconButton(
            color: Colors.white,
            icon: const Icon(Icons.flip_camera_ios),
            iconSize: 28,
            onPressed: () => controller.switchCamera(),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 4,
            child: Stack(
              alignment: Alignment.center,
              children: [
                MobileScanner(
                  controller: controller,
                  onDetect: (capture) {
                    final List<Barcode> barcodes = capture.barcodes;
                    if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
                      _onCodeDetected(barcodes.first.rawValue!);
                    }
                  },
                ),
                // Lớp phủ khung quét (Overlay)
                Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColors.primary,
                      width: 3.0,
                    ),
                    borderRadius: AppRadius.card,
                  ),
                ),
                Positioned(
                  bottom: 30,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.base,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: AppRadius.chip,
                    ),
                    child: Text(
                      'Đặt mã QR vào trong khung quét',
                      style: AppTypography.caption.copyWith(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Phần nhập mã thủ công đề phòng khi camera bị mờ, ướt nước (FR-09.1)
          Container(
            padding: const EdgeInsets.all(AppSpacing.base),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadius.bottomSheet,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Không thể quét mã? Nhập thủ công',
                  style: AppTypography.label.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _manualInputController,
                        decoration: InputDecoration(
                          hintText: 'Nhập mã chốt hoặc mã đội...',
                          hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textDisabled),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.sm,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: AppRadius.button,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: AppRadius.button,
                            borderSide: const BorderSide(color: AppColors.primary),
                          ),
                        ),
                        style: AppTypography.bodyMedium,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.base,
                          vertical: AppSpacing.md,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadius.button,
                        ),
                      ),
                      onPressed: () {
                        final text = _manualInputController.text.trim();
                        if (text.isNotEmpty) {
                          _manualInputController.clear();
                          _onCodeDetected(text);
                        }
                      },
                      child: const Text('Gửi'),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                // Nút để tester dễ chuyển động demo nhanh
                TextButton(
                  onPressed: () {
                    _onCodeDetected('DR-BL-DQ-PL01');
                  },
                  child: const Text(
                    'Demo nhanh: Quét thử Đội Dân Quân (DR-BL-DQ-PL01)',
                    style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
