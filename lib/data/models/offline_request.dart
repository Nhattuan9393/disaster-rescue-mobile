import 'dart:convert';
import 'package:hive/hive.dart';

/// Lớp dữ liệu đại diện cho một lệnh ghi ngoại tuyến cần được xếp hàng và đồng bộ sau.
class OfflineRequest extends HiveObject {
  final String id;
  final String type; // 'sos', 'evacuation', 'safety_status', 'relief_delivery', 'obstacle_report'
  final Map<String, dynamic> payload;
  final DateTime timestamp;
  int retryCount;

  OfflineRequest({
    required this.id,
    required this.type,
    required this.payload,
    required this.timestamp,
    this.retryCount = 0,
  });
}

/// Bộ chuyển đổi nhị phân thủ công (Manual TypeAdapter) dành cho OfflineRequest.
/// Đảm bảo tính tương thích và hiệu năng mà không cần phụ thuộc vào build_runner cho Hive.
class OfflineRequestAdapter extends TypeAdapter<OfflineRequest> {
  @override
  final int typeId = 0;

  @override
  OfflineRequest read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OfflineRequest(
      id: fields[0] as String,
      type: fields[1] as String,
      payload: Map<String, dynamic>.from(jsonDecode(fields[2] as String)),
      timestamp: DateTime.parse(fields[3] as String),
      retryCount: fields[4] as int? ?? 0,
    );
  }

  @override
  void write(BinaryWriter writer, OfflineRequest obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(jsonEncode(obj.payload))
      ..writeByte(3)
      ..write(obj.timestamp.toIso8601String())
      ..writeByte(4)
      ..write(obj.retryCount);
  }
}
