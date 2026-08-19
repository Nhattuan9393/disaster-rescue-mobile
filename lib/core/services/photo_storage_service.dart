import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../utils/logger.dart';

/// Upload ảnh XFile local (từ image_picker) lên Firebase Storage rồi trả
/// download URL — dùng cho các payload cross-device (báo cáo, ảnh bàn giao,
/// ảnh hoàn thành cứu hộ). Nhờ URL, admin và đội khác truy cập được ảnh mà
/// không cần chia sẻ đường dẫn file local.
class PhotoStorageService {
  final FirebaseStorage _storage;
  static const _uuid = Uuid();

  PhotoStorageService({FirebaseStorage? storage})
      : _storage = storage ?? FirebaseStorage.instance;

  /// Upload 1 ảnh, trả `downloadUrl`.
  ///
  /// [folder] là subpath dưới root — VD `reports/situation`,
  /// `sos/{sosId}/handover`, `sos/{sosId}/completion`.
  Future<String> uploadOne(XFile file, {required String folder}) async {
    final id = _uuid.v4();
    final ext = _extFromName(file.name);
    final ref = _storage.ref('$folder/$id$ext');
    final metadata = SettableMetadata(contentType: _contentTypeFor(ext));
    await ref.putFile(File(file.path), metadata);
    final url = await ref.getDownloadURL();
    AppLogger.i('Upload ảnh $folder/$id$ext → $url');
    return url;
  }

  /// Upload nhiều ảnh. Ảnh nào fail được log riêng, còn lại vẫn trả URL.
  /// Trả list URL đúng thứ tự (fail → bỏ khỏi list, không chèn null).
  Future<List<String>> uploadMany(
    List<XFile> files, {
    required String folder,
  }) async {
    final urls = <String>[];
    for (final f in files) {
      try {
        urls.add(await uploadOne(f, folder: folder));
      } catch (e, s) {
        AppLogger.e('Upload ảnh ${f.name} thất bại — bỏ qua', error: e, stackTrace: s);
      }
    }
    return urls;
  }

  String _extFromName(String name) {
    final dot = name.lastIndexOf('.');
    if (dot < 0 || dot == name.length - 1) return '.jpg';
    final ext = name.substring(dot).toLowerCase();
    // Chỉ chấp nhận phần mở rộng ảnh phổ biến
    if (const {'.jpg', '.jpeg', '.png', '.heic', '.webp'}.contains(ext)) {
      return ext;
    }
    return '.jpg';
  }

  String _contentTypeFor(String ext) {
    switch (ext) {
      case '.png':
        return 'image/png';
      case '.heic':
        return 'image/heic';
      case '.webp':
        return 'image/webp';
      case '.jpg':
      case '.jpeg':
      default:
        return 'image/jpeg';
    }
  }
}

final photoStorageServiceProvider = Provider<PhotoStorageService>((ref) {
  return PhotoStorageService();
});
