import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/utils/logger.dart';
import '../../notification/data/notification_inbox_service.dart';
import '../../notification/domain/app_notification.dart';
import '../domain/evacuation_order_model.dart';
import '../domain/evacuation_point_model.dart';
import '../domain/i_evacuation_repository.dart';

class EvacuationRepositoryImpl implements IEvacuationRepository {
  final FirebaseFirestore _firestore;
  final NotificationInboxRepository _inbox;

  EvacuationRepositoryImpl({
    FirebaseFirestore? firestore,
    NotificationInboxRepository? inbox,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _inbox = inbox ?? NotificationInboxRepository();

  CollectionReference<Map<String, dynamic>> get _pointsCollection =>
      _firestore.collection('evacuation_points');

  CollectionReference<Map<String, dynamic>> get _ordersCollection =>
      _firestore.collection('evacuation_orders');

  Future<void> _seedDefaultPointsIfEmpty() async {
    final snapshot = await _pointsCollection.limit(1).get();
    if (snapshot.docs.isEmpty) {
      AppLogger.i('Seed điểm sơ tán mặc định (chỉ chạy 1 lần trên project mới)');
      final defaults = const [
        EvacuationPointModel(
          id: 'evac_01',
          name: 'Trường TH Bình Liêu',
          latitude: 21.5430,
          longitude: 107.3990,
          capacity: 200,
          currentCount: 0,
          status: 'open',
          supplies: ['Chăn', 'Nước', 'Lương khô', 'Thuốc'],
          inChargeName: 'Cô Vũ Thị Lan',
          inChargePhone: '0203 456 789',
          checkedInHouseholdIds: [],
        ),
        EvacuationPointModel(
          id: 'evac_02',
          name: 'Nhà văn hóa Thôn Pắc Liềng',
          latitude: 21.5450,
          longitude: 107.4020,
          capacity: 120,
          currentCount: 0,
          status: 'open',
          supplies: ['Nước', 'Thuốc'],
          inChargeName: 'Bác Nông Văn Sang',
          inChargePhone: '0203 987 654',
          checkedInHouseholdIds: [],
        ),
      ];
      for (final p in defaults) {
        await _pointsCollection.doc(p.id).set(p.toJson());
      }
    }
  }

  @override
  Stream<List<EvacuationPointModel>> watchEvacuationPoints() {
    _seedDefaultPointsIfEmpty();
    return _pointsCollection.snapshots().map((snap) {
      return snap.docs.map((d) {
        final data = Map<String, dynamic>.from(d.data());
        data['id'] = d.id;
        return EvacuationPointModel.fromJson(data);
      }).toList();
    });
  }

  @override
  Stream<List<EvacuationOrderModel>> watchEvacuationOrders() {
    return _ordersCollection
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snap) {
      return snap.docs.map((d) {
        final data = Map<String, dynamic>.from(d.data());
        data['id'] = d.id;
        final ts = data['timestamp'];
        if (ts is Timestamp) data['timestamp'] = ts.toDate().toIso8601String();
        return EvacuationOrderModel.fromJson(data);
      }).toList();
    });
  }

  @override
  Future<void> createEvacuationPoint(EvacuationPointModel point) async {
    await _pointsCollection.doc(point.id).set(point.toJson());
  }

  @override
  Future<void> updateEvacuationPoint(EvacuationPointModel point) async {
    await _pointsCollection.doc(point.id).update(point.toJson());
  }

  @override
  Future<void> broadcastEvacuationOrder(EvacuationOrderModel order) async {
    final data = order.toJson();
    data['timestamp'] = FieldValue.serverTimestamp();
    await _ordersCollection.doc(order.id).set(data);

    await _firestore.collection('event_logs').add({
      'orderId': order.id,
      'action': 'broadcast_evacuation',
      'message':
          'PHÁT LỆNH SƠ TÁN KHẨN CẤP tới ${order.targetVillages.join(", ")}',
      'actorId': order.senderId,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Push notification cross-device: mọi hộ trong sector đích nhận toast
    final recipientTopics = <String>[];
    for (final sectorId in order.targetSectorIds) {
      recipientTopics.add('sector_$sectorId');
    }
    if (recipientTopics.isEmpty) {
      // Fallback theo tên thôn — sector default
      recipientTopics.add('sector_sector_pac_lieng');
    }
    await _inbox.push(
      kind: AppNotificationKind.evacuationOrder,
      title: '🚨 LỆNH SƠ TÁN KHẨN CẤP',
      body:
          '${order.contentVi.isNotEmpty ? order.contentVi : "Sơ tán tới ${order.targetPointName}"} — điểm: ${order.targetPointName}',
      recipientTopics: recipientTopics,
      actionRoute: '/evacuation-points',
      data: {'orderId': order.id, 'pointId': order.targetPointId},
      createdBy: order.senderId,
    );
  }

  @override
  Future<void> checkInHousehold(String pointId, String householdId) async {
    final docRef = _pointsCollection.doc(pointId);
    await _firestore.runTransaction((tx) async {
      final snap = await tx.get(docRef);
      if (!snap.exists) return;
      final point = EvacuationPointModel.fromJson(snap.data()!);
      final ids = List<String>.from(point.checkedInHouseholdIds);
      if (!ids.contains(householdId)) ids.add(householdId);
      tx.update(docRef, {
        'currentCount': point.currentCount + 1,
        'checkedInHouseholdIds': ids,
      });
    });

    // Cập nhật an toàn cho hộ — nguồn 95 điểm (evacuationCheckin) theo SRS
    await _firestore.collection('households').doc(householdId).set({
      'safetyStatus': 'safe',
      'evacuatedPointId': pointId,
      'lastConfirmedAt': FieldValue.serverTimestamp(),
      'safetySource': 'evacuation_checkin',
      'safetyConfidence': 95,
    }, SetOptions(merge: true));

    await _firestore.collection('safety_confirmations').add({
      'householdId': householdId,
      'status': 'safe',
      'source': 'evacuation_checkin',
      'confidence': 95,
      'evacuationPointId': pointId,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
