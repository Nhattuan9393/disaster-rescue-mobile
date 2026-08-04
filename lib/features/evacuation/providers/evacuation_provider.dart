import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/evacuation_models.dart';

class EvacuationState {
  final List<EvacuationPoint> points;
  final List<EvacuationOrder> orders;
  final List<EvacuationCheckin> checkins;
  final bool isLoading;

  const EvacuationState({
    this.points = const [],
    this.orders = const [],
    this.checkins = const [],
    this.isLoading = false,
  });

  EvacuationState copyWith({
    List<EvacuationPoint>? points,
    List<EvacuationOrder>? orders,
    List<EvacuationCheckin>? checkins,
    bool? isLoading,
  }) {
    return EvacuationState(
      points: points ?? this.points,
      orders: orders ?? this.orders,
      checkins: checkins ?? this.checkins,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class EvacuationNotifier extends StateNotifier<EvacuationState> {
  EvacuationNotifier() : super(EvacuationState(points: _mockPoints, orders: _mockOrders, checkins: _mockCheckins));

  void updatePoint(EvacuationPoint updatedPoint) {
    final updatedList = state.points.map((p) => p.id == updatedPoint.id ? updatedPoint : p).toList();
    state = state.copyWith(points: updatedList);
  }

  void issueOrder(EvacuationOrder order) {
    state = state.copyWith(orders: [...state.orders, order]);
  }

  void checkinHousehold({
    required String pointId,
    required String householdId,
    required String householdName,
    required String sectorName,
    required int presentCount,
    required int totalMembers,
  }) {
    final pointIndex = state.points.indexWhere((p) => p.id == pointId);
    if (pointIndex == -1) return;

    final point = state.points[pointIndex];
    final newOccupancy = point.currentOccupancy + presentCount;
    
    // Auto status full check
    final updatedPoint = point.copyWith(
      currentOccupancy: newOccupancy,
      status: newOccupancy >= point.maxCapacity ? EvacuationPointStatus.full : point.status,
    );

    final checkin = EvacuationCheckin(
      id: 'chk_${DateTime.now().millisecondsSinceEpoch}',
      householdId: householdId,
      householdHeadName: householdName,
      sectorName: sectorName,
      presentCount: presentCount,
      totalMembers: totalMembers,
      checkInTime: DateTime.now(),
    );

    updatePoint(updatedPoint);
    state = state.copyWith(checkins: [...state.checkins, checkin]);
  }

  List<EvacuationCheckin> getCheckinsForPoint(String pointId) {
    // For mock purposes, just return all checkins (or filter if we add pointId to checkin model later)
    return state.checkins;
  }

  static final List<EvacuationPoint> _mockPoints = [
    const EvacuationPoint(
      id: 'pt1',
      communeId: 'c1',
      name: 'Trường THCS Bình Liêu',
      address: 'Khu 2, Thị trấn Bình Liêu',
      maxCapacity: 200,
      currentOccupancy: 45,
      status: EvacuationPointStatus.open,
      supplies: ['Chăn màn', 'Nước suối', 'Mì tôm'],
      notes: null,
      managerName: 'Nguyễn Văn A',
      managerPhone: '0912345678',
      isPubliclyVisible: true,
    ),
    const EvacuationPoint(
      id: 'pt2',
      communeId: 'c1',
      name: 'Nhà Văn Hóa Thôn Pắc Liềng',
      address: 'Thôn Pắc Liềng',
      maxCapacity: 150,
      currentOccupancy: 150,
      status: EvacuationPointStatus.full,
      supplies: ['Gạo', 'Y tế'],
      notes: null,
      managerName: 'Lý A Sáng',
      managerPhone: '0987654321',
      isPubliclyVisible: true,
    ),
    const EvacuationPoint(
      id: 'pt3',
      communeId: 'c1',
      name: 'Trạm Y Tế Xã',
      address: 'Khu trung tâm',
      maxCapacity: 50,
      currentOccupancy: 10,
      status: EvacuationPointStatus.open,
      supplies: ['Giường bệnh', 'Thuốc men'],
      notes: null,
      managerName: 'Bác sĩ Hoa',
      managerPhone: '0909090909',
      isPubliclyVisible: true,
    ),
  ];

  static final List<EvacuationOrder> _mockOrders = [];
  
  static final List<EvacuationCheckin> _mockCheckins = [
    EvacuationCheckin(
      id: 'chk1',
      householdId: 'h1',
      householdHeadName: 'Chảo Sắn Mẩy',
      sectorName: 'Thôn Pắc Liềng',
      presentCount: 4,
      totalMembers: 4,
      checkInTime: DateTime.now().subtract(const Duration(minutes: 30)),
    ),
  ];
}

final evacuationProvider = StateNotifierProvider<EvacuationNotifier, EvacuationState>((ref) {
  return EvacuationNotifier();
});
