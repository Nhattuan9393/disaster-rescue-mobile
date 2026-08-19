import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

/// Màn quét QR toàn màn hình. Trả về giá trị QR khi quét được (pop kết quả).
///
/// Chủ động xin quyền Camera trước khi khởi động MobileScanner — tránh
/// tình huống scanner render error placeholder khó dùng bên dưới viewfinder.
///
/// Sử dụng:
/// ```dart
/// final code = await Navigator.of(context).push<String>(
///   MaterialPageRoute(builder: (_) => const QrScannerScreen(title: 'Quét QR')),
/// );
/// ```
class QrScannerScreen extends StatefulWidget {
  final String title;
  final String? subtitle;

  const QrScannerScreen({
    super.key,
    this.title = 'Quét mã QR',
    this.subtitle,
  });

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

enum _PermState { checking, granted, denied, permanentlyDenied }

class _QrScannerScreenState extends State<QrScannerScreen>
    with WidgetsBindingObserver {
  MobileScannerController? _controller;
  bool _handled = false;
  bool _torchOn = false;
  _PermState _perm = _PermState.checking;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkAndRequestPermission();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // User quay về app từ System Settings — check lại quyền.
    if (state == AppLifecycleState.resumed &&
        (_perm == _PermState.denied || _perm == _PermState.permanentlyDenied)) {
      _checkAndRequestPermission(silent: true);
    }
  }

  Future<void> _checkAndRequestPermission({bool silent = false}) async {
    if (!silent) setState(() => _perm = _PermState.checking);

    var status = await Permission.camera.status;
    if (status.isGranted) {
      _startScanner();
      return;
    }

    if (status.isPermanentlyDenied) {
      if (mounted) setState(() => _perm = _PermState.permanentlyDenied);
      return;
    }

    // .denied hoặc .restricted → cố xin quyền
    status = await Permission.camera.request();
    if (!mounted) return;

    if (status.isGranted) {
      _startScanner();
    } else if (status.isPermanentlyDenied) {
      setState(() => _perm = _PermState.permanentlyDenied);
    } else {
      setState(() => _perm = _PermState.denied);
    }
  }

  void _startScanner() {
    _controller?.dispose();
    _controller = MobileScannerController(
      formats: const [BarcodeFormat.qrCode],
      detectionSpeed: DetectionSpeed.normal,
    );
    setState(() => _perm = _PermState.granted);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_handled) return;
    for (final b in capture.barcodes) {
      final v = b.rawValue;
      if (v != null && v.isNotEmpty) {
        _handled = true;
        Navigator.of(context).pop(v);
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        actions: _perm == _PermState.granted
            ? [
                IconButton(
                  icon: Icon(_torchOn ? Icons.flash_on : Icons.flash_off),
                  tooltip: 'Bật/tắt đèn',
                  onPressed: () async {
                    await _controller?.toggleTorch();
                    if (mounted) setState(() => _torchOn = !_torchOn);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.cameraswitch),
                  tooltip: 'Đổi camera',
                  onPressed: () => _controller?.switchCamera(),
                ),
              ]
            : null,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    switch (_perm) {
      case _PermState.checking:
        return const Center(
          child: CircularProgressIndicator(color: Colors.white),
        );
      case _PermState.denied:
        return _permissionCard(
          icon: Icons.videocam_off,
          title: 'Chưa cấp quyền Camera',
          message:
              'DisasterRescue cần quyền camera để quét mã QR. Bấm "Cấp quyền" để chọn Cho phép.',
          primaryLabel: 'CẤP QUYỀN',
          onPrimary: () => _checkAndRequestPermission(),
        );
      case _PermState.permanentlyDenied:
        return _permissionCard(
          icon: Icons.settings,
          title: 'Quyền camera đã bị chặn',
          message:
              'Bạn đã chọn "Không hỏi lại". Mở Cài đặt hệ thống và bật quyền Camera cho DisasterRescue để tiếp tục.',
          primaryLabel: 'MỞ CÀI ĐẶT',
          onPrimary: () => openAppSettings(),
        );
      case _PermState.granted:
        return _buildScannerBody();
    }
  }

  Widget _buildScannerBody() {
    if (_controller == null) {
      return const Center(child: CircularProgressIndicator(color: Colors.white));
    }
    return Stack(
      children: [
        MobileScanner(
          controller: _controller!,
          onDetect: _onDetect,
          errorBuilder: (ctx, err, child) => _scannerRuntimeError(err),
        ),
        // Viewfinder xanh
        Center(
          child: IgnorePointer(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.greenAccent, width: 3),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        if (widget.subtitle != null)
          Positioned(
            bottom: 40,
            left: 24,
            right: 24,
            child: IgnorePointer(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  widget.subtitle!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _scannerRuntimeError(MobileScannerException err) {
    // MobileScanner bung lỗi ngay cả khi permission đã granted (thường do
    // camera đang bị app khác chiếm, hoặc thiết bị không có camera).
    final code = err.errorCode.name;
    // Nếu là permission-denied thì quay về flow xin quyền (an toàn cho race).
    if (code.toLowerCase().contains('permission')) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _checkAndRequestPermission();
      });
      return const Center(child: CircularProgressIndicator(color: Colors.white));
    }
    return _permissionCard(
      icon: Icons.no_photography,
      title: 'Không mở được camera',
      message:
          'Mã lỗi: $code\nCó thể camera đang bị app khác chiếm, hoặc thiết bị không có camera sau.',
      primaryLabel: 'THỬ LẠI',
      onPrimary: _checkAndRequestPermission,
    );
  }

  Widget _permissionCard({
    required IconData icon,
    required String title,
    required String message,
    required String primaryLabel,
    required VoidCallback onPrimary,
  }) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.shade900,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: Colors.white70, size: 56),
                const SizedBox(height: 12),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 12, height: 1.4),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.check),
                    label: Text(primaryLabel,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13)),
                    onPressed: onPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white70,
                      side: BorderSide(color: Colors.grey.shade600),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Đóng',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
