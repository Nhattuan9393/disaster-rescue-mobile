import 'package:freezed_annotation/freezed_annotation.dart';

part 'sos_models.freezed.dart';
part 'sos_models.g.dart';

enum WaterLevel {
  @JsonValue('none') none,
  @JsonValue('knee') knee,
  @JsonValue('chest') chest,
  @JsonValue('roof') roof,
}

enum HouseType {
  @JsonValue('level4') level4,
  @JsonValue('multiStory') multiStory,
}

enum PriorityLevel {
  @JsonValue('red') red,        // Nguy cấp (>= 70)
  @JsonValue('orange') orange,  // Nguy hiểm (40-69)
  @JsonValue('yellow') yellow,  // Cần hỗ trợ (< 40)
}

@freezed
class SosContext with _$SosContext {
  const factory SosContext({
    required bool hasChildren,
    required bool hasElderly,
    required bool hasSeriouslyIll,
    required bool hasDisabled,
    required bool groundFloorFlooded,
    required bool needsMedicine,
    required WaterLevel waterLevel,
    required HouseType houseType,
    required int peopleCount,
  }) = _SosContext;

  factory SosContext.fromJson(Map<String, dynamic> json) =>
      _$SosContextFromJson(json);
}

/// Tính điểm ưu tiên SOS dựa trên thông số đặc tả FR-02.3
int calculatePriority(SosContext c) {
  var s = 0;
  if (c.hasChildren) s += 15;
  if (c.hasElderly) s += 15;
  if (c.hasSeriouslyIll) s += 20;
  if (c.hasDisabled) s += 10;
  if (c.groundFloorFlooded) s += 15;
  if (c.needsMedicine) s += 10;
  
  if (c.waterLevel == WaterLevel.roof) {
    s += 20;
  } else if (c.waterLevel == WaterLevel.chest) {
    s += 10;
  }
  
  if (c.houseType == HouseType.level4) s += 10;
  if (c.peopleCount > 5) s += 5;
  return s;
}

/// Phân loại mức độ nguy cấp dựa trên điểm số
PriorityLevel getPriorityLevel(int score) {
  if (score >= 70) return PriorityLevel.red;
  if (score >= 40) return PriorityLevel.orange;
  return PriorityLevel.yellow;
}
