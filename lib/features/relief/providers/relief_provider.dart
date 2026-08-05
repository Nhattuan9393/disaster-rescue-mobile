import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disaster_rescue/data/models/relief_models.dart';

class ReliefState {
  final List<ReliefItem> items;
  final List<ReliefPackage> packages;
  final List<ReliefReceipt> receipts;
  final bool isLoading;
  final String? error;

  ReliefState({
    this.items = const [],
    this.packages = const [],
    this.receipts = const [],
    this.isLoading = false,
    this.error,
  });

  ReliefState copyWith({
    List<ReliefItem>? items,
    List<ReliefPackage>? packages,
    List<ReliefReceipt>? receipts,
    bool? isLoading,
    String? error,
  }) {
    return ReliefState(
      items: items ?? this.items,
      packages: packages ?? this.packages,
      receipts: receipts ?? this.receipts,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class ReliefNotifier extends StateNotifier<ReliefState> {
  ReliefNotifier() : super(ReliefState(isLoading: true)) {
    _loadMockStock();
  }

  void _loadMockStock() {
    final mockItems = [
      const ReliefItem(id: 'i1', name: 'Gạo', quantity: 500, threshold: 200, unit: 'kg'),
      const ReliefItem(id: 'i2', name: 'Mì tôm', quantity: 150, threshold: 100, unit: 'thùng'),
      const ReliefItem(id: 'i3', name: 'Nước uống', quantity: 80, threshold: 100, unit: 'thùng'), // Dưới ngưỡng
      const ReliefItem(id: 'i4', name: 'Áo phao', quantity: 120, threshold: 50, unit: 'cái'),
    ];

    final mockPackages = [
      ReliefPackage(
        code: 'GCT-2025-0001',
        donorName: 'Đoàn Từ Thiện Tâm Đức',
        donorPhone: '0912345678',
        receivedAt: DateTime.now().subtract(const Duration(hours: 4)),
        receivedBy: 'Cán bộ Minh',
        status: PackageStatus.received,
        lines: const [
          PackageLine(rawName: 'Mì tôm Hảo Hảo', quantity: 30, unit: 'thùng', mappedItemId: null),
          PackageLine(rawName: 'Áo ấm trẻ em', quantity: 50, unit: 'cái', mappedItemId: null),
        ],
      ),
    ];

    state = ReliefState(items: mockItems, packages: mockPackages, receipts: const [], isLoading: false);
  }

  /// Nhập kho chuẩn (Tầng 1)
  void receiveItemStock(String itemId, double quantity) {
    if (quantity <= 0) return;
    final updated = state.items.map((item) {
      if (item.id == itemId) {
        return item.copyWith(quantity: item.quantity + quantity);
      }
      return item;
    }).toList();
    state = state.copyWith(items: updated);
  }

  /// Nhập gói cứu trợ hỗn hợp (Tầng 2 - QĐ 2.4)
  void receiveReliefPackage(String donorName, String donorPhone, List<PackageLine> lines) {
    final code = 'GCT-2025-000${state.packages.length + 2}';
    final newPackage = ReliefPackage(
      code: code,
      donorName: donorName,
      donorPhone: donorPhone,
      receivedAt: DateTime.now(),
      receivedBy: 'Admin Xã',
      status: PackageStatus.received,
      lines: lines,
    );
    state = state.copyWith(packages: [...state.packages, newPackage]);
  }

  /// Xuất kho cấp phát cho Đội cứu hộ (Tầng 1 - QĐ 2.4)
  bool dispatchStock(String itemId, double quantity) {
    if (quantity <= 0) return false;
    final itemIndex = state.items.indexWhere((item) => item.id == itemId);
    if (itemIndex == -1) {
      state = state.copyWith(error: 'Mặt hàng không tồn tại.');
      return false;
    }

    final item = state.items[itemIndex];
    try {
      final updatedItem = deductCommuneStock(item, quantity);
      final List<ReliefItem> updatedList = List.from(state.items);
      updatedList[itemIndex] = updatedItem;
      state = state.copyWith(items: updatedList, error: null);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Lập biên nhận phát hàng cứu trợ cho hộ dân (Screen 41 - QĐ 2.4)
  void createReceipt(ReliefReceipt receipt) {
    // Nếu nguồn phát từ kho xã, trừ tồn kho chuẩn
    if (receipt.source == SupplySource.communeWarehouse) {
      final List<ReliefItem> updatedItems = List.from(state.items);
      receipt.items.forEach((itemId, quantity) {
        final index = updatedItems.indexWhere((item) => item.id == itemId);
        if (index != -1) {
          try {
            updatedItems[index] = deductCommuneStock(updatedItems[index], quantity);
          } catch (_) {
            // Trong khẩn cấp nếu thiếu kho vẫn cho phát (hoặc ghi nhận âm nếu được phép)
            updatedItems[index] = updatedItems[index].copyWith(
              quantity: updatedItems[index].quantity - quantity,
            );
          }
        }
      });
      state = state.copyWith(
        items: updatedItems,
        receipts: [...state.receipts, receipt],
      );
    } else {
      // Các nguồn khác (đội tự mang, phát gói trực tiếp) chỉ ghi nhận biên nhận
      state = state.copyWith(
        receipts: [...state.receipts, receipt],
      );
    }
  }
}

final reliefProvider = StateNotifierProvider<ReliefNotifier, ReliefState>((ref) {
  return ReliefNotifier();
});
