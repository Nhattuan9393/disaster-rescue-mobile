import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disaster_rescue/data/models/household_model.dart';
import 'package:disaster_rescue/data/models/sos_models.dart';

class HouseholdRegistryState {
  final List<HouseholdModel> households;
  final List<Map<String, HouseholdModel>> duplicates; // Dữ liệu trùng đối chiếu: {'existing': X, 'imported': Y}
  final bool isLoading;
  final String? error;

  HouseholdRegistryState({
    this.households = const [],
    this.duplicates = const [],
    this.isLoading = false,
    this.error,
  });

  HouseholdRegistryState copyWith({
    List<HouseholdModel>? households,
    List<Map<String, HouseholdModel>>? duplicates,
    bool? isLoading,
    String? error,
  }) {
    return HouseholdRegistryState(
      households: households ?? this.households,
      duplicates: duplicates ?? this.duplicates,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class HouseholdRegistryNotifier extends StateNotifier<HouseholdRegistryState> {
  HouseholdRegistryNotifier() : super(HouseholdRegistryState(isLoading: true)) {
    _loadInitialHouseholds();
  }

  void _loadInitialHouseholds() {
    final mockHouseholds = [
      const HouseholdModel(
        id: 'h1',
        ownerName: 'Nguyễn Văn Ba',
        ownerPhone: '0901234567',
        address: 'Thôn Đồng Tâm',
        peopleCount: 4,
        houseType: HouseType.level4,
        hasChildren: true,
        hasElderly: true,
      ),
      const HouseholdModel(
        id: 'h2',
        ownerName: 'Trần Thị Mai',
        ownerPhone: '0987654321',
        address: 'Thôn Bản Vược',
        peopleCount: 3,
        houseType: HouseType.multiStory,
        hasChildren: false,
        hasElderly: false,
      ),
    ];
    state = HouseholdRegistryState(households: mockHouseholds, isLoading: false);
  }

  /// Nhập hộ dân thủ công (FR-05.4)
  bool addHousehold(HouseholdModel newHousehold) {
    // 1. Kiểm tra trùng SĐT
    final exists = state.households.any((h) => h.ownerPhone == newHousehold.ownerPhone);
    if (exists) {
      state = state.copyWith(error: 'Số điện thoại này đã tồn tại trong hệ thống.');
      return false;
    }

    state = state.copyWith(
      households: [...state.households, newHousehold],
      error: null,
    );
    return true;
  }

  /// Mô phỏng import file danh sách hộ dân từ Google Sheet/Zalo/Email (FR-05.5)
  void simulateImport(List<HouseholdModel> importedList) {
    final List<HouseholdModel> updatedHouseholds = List.from(state.households);
    final List<Map<String, HouseholdModel>> detectedDuplicates = [];

    for (final imported in importedList) {
      final existingIndex = updatedHouseholds.indexWhere((h) => h.ownerPhone == imported.ownerPhone);
      
      if (existingIndex != -1) {
        // Phát hiện trùng lặp
        detectedDuplicates.add({
          'existing': updatedHouseholds[existingIndex],
          'imported': imported,
        });
      } else {
        // Không trùng -> thêm thẳng
        updatedHouseholds.add(imported);
      }
    }

    state = state.copyWith(
      households: updatedHouseholds,
      duplicates: detectedDuplicates,
    );
  }

  /// Giải quyết trùng lặp đối chiếu (FR-05.5)
  void resolveDuplicate(String ownerPhone, String action) {
    final duplicateIndex = state.duplicates.indexWhere((d) => d['existing']!.ownerPhone == ownerPhone);
    if (duplicateIndex == -1) return;

    final duplicate = state.duplicates[duplicateIndex];
    final existing = duplicate['existing']!;
    final imported = duplicate['imported']!;

    final List<HouseholdModel> updatedHouseholds = List.from(state.households);
    final existingIndexInRegistry = updatedHouseholds.indexWhere((h) => h.ownerPhone == ownerPhone);

    if (action == 'overwrite') {
      // 1. Ghi đè: Thay thế dữ liệu hiện tại bằng dữ liệu import
      if (existingIndexInRegistry != -1) {
        updatedHouseholds[existingIndexInRegistry] = imported;
      }
    } else if (action == 'merge') {
      // 2. Hợp nhất: Trộn thông tin (lấy giá trị cực đại của số người, và true của checkbox yếu thế)
      final merged = HouseholdModel(
        id: existing.id,
        ownerName: imported.ownerName, // Cập nhật tên mới nhất
        ownerPhone: ownerPhone,
        address: imported.address,
        peopleCount: imported.peopleCount > existing.peopleCount ? imported.peopleCount : existing.peopleCount,
        houseType: imported.houseType,
        hasChildren: existing.hasChildren || imported.hasChildren,
        hasElderly: existing.hasElderly || imported.hasElderly,
        hasSeriouslyIll: existing.hasSeriouslyIll || imported.hasSeriouslyIll,
        hasDisabled: existing.hasDisabled || imported.hasDisabled,
      );
      if (existingIndexInRegistry != -1) {
        updatedHouseholds[existingIndexInRegistry] = merged;
      }
    }
    // 3. Skip (Bỏ qua): Giữ nguyên existing, không cần cập nhật updatedHouseholds

    // Xóa khỏi danh sách trùng lặp
    final updatedDuplicates = List<Map<String, HouseholdModel>>.from(state.duplicates)..removeAt(duplicateIndex);

    state = state.copyWith(
      households: updatedHouseholds,
      duplicates: updatedDuplicates,
    );
  }
}

final householdRegistryProvider =
    StateNotifierProvider<HouseholdRegistryNotifier, HouseholdRegistryState>((ref) {
  return HouseholdRegistryNotifier();
});
