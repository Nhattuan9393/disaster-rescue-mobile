import 'package:freezed_annotation/freezed_annotation.dart';

part 'evacuation_models.freezed.dart';
part 'evacuation_models.g.dart';

enum EvacuationPointStatus {
  @JsonValue('open') open,
  @JsonValue('full') full,
  @JsonValue('damaged') damaged,
  @JsonValue('closed') closed,
}

@freezed
class EvacuationPoint with _$EvacuationPoint {
  const EvacuationPoint._();

  const factory EvacuationPoint({
    required String id,
    required String communeId,
    required String name,
    required String address,
    required int maxCapacity,
    required int currentOccupancy,
    required EvacuationPointStatus status,
    required List<String> supplies,
    required String? notes,
    required String managerName,
    required String managerPhone,
    required bool isPubliclyVisible,
  }) = _EvacuationPoint;

  factory EvacuationPoint.fromJson(Map<String, dynamic> json) =>
      _$EvacuationPointFromJson(json);

  int get availableCapacity => maxCapacity - currentOccupancy;
  bool get isFull => currentOccupancy >= maxCapacity;
}

enum EvacuationOrderStatus {
  @JsonValue('draft') draft,
  @JsonValue('issued') issued,
  @JsonValue('inProgress') inProgress,
  @JsonValue('completed') completed,
}

@freezed
class EvacuationOrder with _$EvacuationOrder {
  const EvacuationOrder._();

  const factory EvacuationOrder({
    required String id,
    required String communeId,
    required List<String> targetSectorIds,
    required String targetEvacuationPointId,
    required String messageVi,
    required String? messageTay,
    required int targetHouseholdCount,
    required int confirmedCount,
    required int unableCount,
    required EvacuationOrderStatus status,
    required String issuedBy,
    required DateTime issuedAt,
  }) = _EvacuationOrder;

  factory EvacuationOrder.fromJson(Map<String, dynamic> json) =>
      _$EvacuationOrderFromJson(json);

  String get confirmationProgress => '$confirmedCount/$targetHouseholdCount';
  double get progressRatio => targetHouseholdCount == 0 ? 0 : confirmedCount / targetHouseholdCount;
}

@freezed
class EvacuationCheckin with _$EvacuationCheckin {
  const factory EvacuationCheckin({
    required String id,
    required String householdId,
    required String householdHeadName,
    required String sectorName,
    required int presentCount,
    required int totalMembers,
    required DateTime checkInTime,
  }) = _EvacuationCheckin;

  factory EvacuationCheckin.fromJson(Map<String, dynamic> json) =>
      _$EvacuationCheckinFromJson(json);
}
