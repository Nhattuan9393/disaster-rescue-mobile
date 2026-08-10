import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/evacuation_point_model.dart';
import '../domain/evacuation_order_model.dart';
import '../domain/i_evacuation_repository.dart';
import '../../../../core/utils/logger.dart';

class EvacuationRepositoryImpl implements IEvacuationRepository {
  final FirebaseFirestore _firestore;

  EvacuationRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _pointsCollection =>
      _firestore.collection('evacuation_points');

  CollectionReference<Map<String, dynamic>> get _ordersCollection =>
      _firestore.collection('evacuation_orders');

  // Khởi tạo các điểm sơ tán mẫu mặc định nếu Firestore rỗng
  Future<void> _seedDefaultPointsIfEmpty() async {
    final snapshot = await _pointsCollection.get();
    if (snapshot.docs.isEmpty) {
      AppLogger.i('Khởi tạo danh sách Điểm sơ tán mẫu lên Firestore...');
      final defaultPoints = [
        const EvacuationPointModel(
          id: 'evac_01',
          name: 'Trường TH Bình Liêu',
          latitude: 21.5430,
          longitude: 107.3990,
          capacity: 200,
          currentCount: 45,
          status: 'open',
          supplies: ['Chăn', 'Nước', 'Lương khô', 'Thuốc'],
          inChargeName: 'Cô Vũ Thị Lan',
          inChargePhone: '0203 456 789',
          checkedInHouseholdIds: ['household_my_family'],
        ),
        const EvacuationPointModel(
          id: 'evac_02',
          name: 'Nhà văn hóa Thôn Pắc Liềng',
          latitude: 21.5450,
          longitude: 107.4020,
          capacity: 120,
          currentCount: 118,
          status: 'nearly_full',
          supplies: ['Nước', 'Thuốc'],
          inChargeName: 'Bác Nông Văn Sang',
          inChargePhone: '0203 987 654',
          checkedInHouseholdIds: [],
        ),
        const EvacuationPointModel(
          id: 'evac_03',
          name: 'UBND xã Bình Liêu',
          latitude: 21.5410,
          longitude: 107.3950,
          capacity: 150,
          currentCount: 150,
          status: 'full',
          supplies: ['Chăn', 'Nước', 'Lương khô'],
          inChargeName: 'Trần Văn Bình',
          inChargePhone: '0203 123 456',
          checkedInHouseholdIds: [],
        ),
        const EvacuationPointModel(
          id: 'evac_04',
          name: 'Trạm Y tế Khe Tiền',
          latitude: 21.5380,
          longitude: 107.3900,
          capacity: 60,
          currentCount: 0,
          status: 'closed',
          supplies: [],
          inChargeName: 'Y sĩ Hoàng Thị Mơ',
          inChargePhone: '0203 333 999',
          checkedInHouseholdIds: [],
        ),
      ];

      for (final p in defaultPoints) {
        await _pointsCollection.doc(p.id).set(p.toJson());
      }
    }
  }

  @override
  Stream<List<EvacuationPointModel>> watchEvacuationPoints() {
    _seedDefaultPointsIfEmpty();
    return _pointsCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return EvacuationPointModel.fromJson(data);
      }).toList();
    });
  }

  @override
  Stream<List<EvacuationOrderModel>> watchEvacuationOrders() {
    return _ordersCollection
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return EvacuationOrderModel.fromJson(data);
      }).toList();
    });
  }

  @override
  Future<void> createEvacuationPoint(EvacuationPointModel point) async {
    try {
      await _pointsCollection.doc(point.id).set(point.toJson()).timeout(const Duration(milliseconds: 500));
    } catch (_) {}
  }

  @override
  Future<void> updateEvacuationPoint(EvacuationPointModel point) async {
    try {
      await _pointsCollection.doc(point.id).update(point.toJson()).timeout(const Duration(milliseconds: 500));
    } catch (_) {}
  }

  @override
  Future<void> broadcastEvacuationOrder(EvacuationOrderModel order) async {
    try {
      await _ordersCollection.doc(order.id).set(order.toJson()).timeout(const Duration(milliseconds: 500));
      
      // DR-032: Ghi log sự kiện phát lệnh sơ tán
      _firestore.collection('event_logs').add({
        'id': order.id,
        'sosId': order.id,
        'action': 'broadcast_evacuation',
        'message': 'PHÁT LỆNH SƠ TÁN KHẨN CẤP tới các thôn: ${order.targetVillages.join(", ")}.',
        'actorId': order.senderId,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      AppLogger.w('Đã lưu lệnh sơ tán vào local cache. Đóng màn hình ngay.');
    }
  }

  @override
  Future<void> checkInHousehold(String pointId, String householdId) async {
    try {
      final docRef = _pointsCollection.doc(pointId);
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);
        if (snapshot.exists) {
          final point = EvacuationPointModel.fromJson(snapshot.data()!);
          final updatedCheckedIn = List<String>.from(point.checkedInHouseholdIds);
          if (!updatedCheckedIn.contains(householdId)) {
            updatedCheckedIn.add(householdId);
          }
          transaction.update(docRef, {
            'currentCount': point.currentCount + 1,
            'checkedInHouseholdIds': updatedCheckedIn,
          });
        }
      }).timeout(const Duration(milliseconds: 500));

      // Cập nhật an toàn cho hộ
      _firestore.collection('households').doc(householdId).set({
        'safetyStatus': 'safe',
        'evacuatedPointId': pointId,
        'lastConfirmed': DateTime.now().toIso8601String(),
      }, SetOptions(merge: true));

      // Ghi nhận nguồn xác thực an toàn check-in
      _firestore.collection('safety_confirmations').add({
        'householdId': householdId,
        'status': 'safe',
        'source': 'evacuation_checkin',
        'confidence': 95, // Nguồn Check-in tại điểm sơ tán đạt 95% độ tin cậy
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (_) {}
  }
}
