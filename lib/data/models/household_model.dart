import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:disaster_rescue/data/models/sos_models.dart';

part 'household_model.freezed.dart';
part 'household_model.g.dart';

@freezed
class HouseholdModel with _$HouseholdModel {
  const factory HouseholdModel({
    required String id,
    required String ownerName,
    required String ownerPhone,
    required String address, // Tên thôn (ví dụ: Đồng Tâm, Bản Vược)
    required int peopleCount,
    required HouseType houseType,
    @Default(false) bool hasChildren,
    @Default(false) bool hasElderly,
    @Default(false) bool hasSeriouslyIll,
    @Default(false) bool hasDisabled,
  }) = _HouseholdModel;

  factory HouseholdModel.fromJson(Map<String, dynamic> json) => _$HouseholdModelFromJson(json);
}
