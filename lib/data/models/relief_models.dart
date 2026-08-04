import 'package:freezed_annotation/freezed_annotation.dart';

part 'relief_models.freezed.dart';
part 'relief_models.g.dart';

enum SupplySource {
  @JsonValue('communeWarehouse') communeWarehouse,  // kho xã -> trừ tồn kho
  @JsonValue('teamStanding') teamStanding,          // biên chế đội -> không trừ
  @JsonValue('teamBrought') teamBrought,            // đội vãng lai tự mang -> không trừ
  @JsonValue('packageDirect') packageDirect,        // phát nguyên gói -> không trừ tồn kho chuẩn
}

enum PackageStatus {
  @JsonValue('received') received,
  @JsonValue('classified') classified,
  @JsonValue('distributed') distributed,
}

@freezed
class ReliefItem with _$ReliefItem {
  const factory ReliefItem({
    required String id,
    required String name,
    required double quantity,
    required double threshold,
    required String unit,
  }) = _ReliefItem;

  factory ReliefItem.fromJson(Map<String, dynamic> json) =>
      _$ReliefItemFromJson(json);
}

@freezed
class PackageLine with _$PackageLine {
  const factory PackageLine({
    required String rawName,
    required double quantity,
    required String unit,
    required String? mappedItemId,
  }) = _PackageLine;

  factory PackageLine.fromJson(Map<String, dynamic> json) =>
      _$PackageLineFromJson(json);
}

@freezed
class ReliefPackage with _$ReliefPackage {
  const factory ReliefPackage({
    required String code,
    required String donorName,
    required String donorPhone,
    required DateTime receivedAt,
    required String receivedBy,
    required PackageStatus status,
    required List<PackageLine> lines,
  }) = _ReliefPackage;

  factory ReliefPackage.fromJson(Map<String, dynamic> json) =>
      _$ReliefPackageFromJson(json);
}

@freezed
class ReliefReceipt with _$ReliefReceipt {
  const factory ReliefReceipt({
    required String id,
    required String householdId,
    required DateTime distributedAt,
    required String distributedBy,
    required SupplySource source,
    required Map<String, double> items, // Map itemId -> quantity
    required String? packageCode,       // Dùng khi phát nguyên gói (packageDirect)
    required String? note,
  }) = _ReliefReceipt;

  factory ReliefReceipt.fromJson(Map<String, dynamic> json) =>
      _$ReliefReceiptFromJson(json);
}

class ReliefInventoryException implements Exception {
  final String message;
  ReliefInventoryException(this.message);
  @override
  String toString() => 'ReliefInventoryException: $message';
}

/// Trừ tồn kho nếu phát từ kho xã. Trả về ReliefItem đã cập nhật, hoặc ném ngoại lệ nếu thiếu hàng (FR-10.8).
ReliefItem deductCommuneStock(ReliefItem item, double quantityToDeduct) {
  if (item.quantity < quantityToDeduct) {
    throw ReliefInventoryException(
      'Số lượng xuất vượt quá tồn kho hiện tại cho mặt hàng ${item.name} (Tồn: ${item.quantity}, Yêu cầu: $quantityToDeduct)'
    );
  }
  return item.copyWith(quantity: item.quantity - quantityToDeduct);
}

/// Kiểm tra xem tồn kho có dưới ngưỡng cảnh báo hay không
bool isBelowThreshold(ReliefItem item) {
  return item.quantity < item.threshold;
}
