import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../utils/logger.dart';

/// Bọc `image_picker` thành 2 hàm cực gọn.
///
/// Không tự xin quyền — `image_picker` xử lý runtime permission trong native
/// (iOS đọc Info.plist, Android đọc AndroidManifest). Nếu user từ chối,
/// hàm trả `null`.
class CameraService {
  final ImagePicker _picker;

  CameraService({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  /// Mở camera thật để chụp 1 ảnh. Trả `XFile` hoặc `null` nếu user cancel.
  Future<XFile?> takePhoto({
    int imageQuality = 85,
    double? maxWidth = 1920,
  }) async {
    try {
      return await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: imageQuality,
        maxWidth: maxWidth,
        preferredCameraDevice: CameraDevice.rear,
      );
    } catch (e, s) {
      AppLogger.e('CameraService.takePhoto lỗi', error: e, stackTrace: s);
      return null;
    }
  }

  /// Mở thư viện ảnh (1 ảnh).
  Future<XFile?> pickFromGallery({
    int imageQuality = 85,
    double? maxWidth = 1920,
  }) async {
    try {
      return await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: imageQuality,
        maxWidth: maxWidth,
      );
    } catch (e, s) {
      AppLogger.e('CameraService.pickFromGallery lỗi', error: e, stackTrace: s);
      return null;
    }
  }

  /// Cho user chọn máy ảnh hay thư viện qua bottom sheet.
  Future<XFile?> pickWithChoice(BuildContext context) async {
    final choice = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFFD32F2F)),
              title: const Text('Chụp ảnh (Máy ảnh)',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.blue),
              title: const Text('Chọn từ thư viện',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (choice == null) return null;
    return choice == ImageSource.camera ? takePhoto() : pickFromGallery();
  }
}
