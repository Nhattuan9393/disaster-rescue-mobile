import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/sos_model.dart';

/// Một dòng "tin SMS đã đến tổng đài" — chuẩn hoá bất kể vào bằng đường nào
/// (gateway thật hoặc demo relay).
class SmsInboxEntry {
  final String id;
  final String payload;
  final String fromNumber;
  final DateTime receivedAt;

  /// Đường vào: `demo_relay` (app tự ghi khi bật demoMode) hoặc `sms_gateway`
  /// (server thật parse SMS từ tổng đài rồi bơm lên Firestore).
  final String source;

  /// Các trường đã giải mã sẵn (server-side hoặc client-side) — tiện hiển
  /// thị bảng, không phải parse lại.
  final String? sosId;
  final String? householdId;
  final double? latitude;
  final double? longitude;
  final int? priorityScore;
  final int? memberCount;

  const SmsInboxEntry({
    required this.id,
    required this.payload,
    required this.fromNumber,
    required this.receivedAt,
    required this.source,
    this.sosId,
    this.householdId,
    this.latitude,
    this.longitude,
    this.priorityScore,
    this.memberCount,
  });

  Map<String, dynamic> toJson() => {
        'payload': payload,
        'fromNumber': fromNumber,
        'receivedAt': receivedAt.toIso8601String(),
        'source': source,
        if (sosId != null) 'sosId': sosId,
        if (householdId != null) 'householdId': householdId,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
        if (priorityScore != null) 'priorityScore': priorityScore,
        if (memberCount != null) 'memberCount': memberCount,
      };

  factory SmsInboxEntry.fromDoc(
      QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data();
    DateTime received;
    final rv = d['receivedAt'];
    if (rv is Timestamp) {
      received = rv.toDate();
    } else if (rv is String) {
      received = DateTime.tryParse(rv) ?? DateTime.now();
    } else {
      received = DateTime.now();
    }
    return SmsInboxEntry(
      id: doc.id,
      payload: d['payload'] as String? ?? '',
      fromNumber: d['fromNumber'] as String? ?? '',
      receivedAt: received,
      source: d['source'] as String? ?? 'demo_relay',
      sosId: d['sosId'] as String?,
      householdId: d['householdId'] as String?,
      latitude: (d['latitude'] as num?)?.toDouble(),
      longitude: (d['longitude'] as num?)?.toDouble(),
      priorityScore: (d['priorityScore'] as num?)?.toInt(),
      memberCount: (d['memberCount'] as num?)?.toInt(),
    );
  }
}

class SmsInboxRepository {
  final FirebaseFirestore _firestore;

  SmsInboxRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection('sms_inbox');

  Stream<List<SmsInboxEntry>> watchRecent({int limit = 50}) {
    return _col
        .orderBy('receivedAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => SmsInboxEntry.fromDoc(d)).toList());
  }

  /// Demo relay: giả lập tổng đài SMS gateway nhận payload từ user offline.
  /// Ghi thẳng vào Firestore để admin thấy realtime — dùng khi
  /// `EmergencyConfig.demoMode == true` và [`SosDeliveryService`] gọi.
  Future<void> pushDemoIncoming({
    required SosRequestEntity sos,
    required String fromNumber,
    required String payload,
  }) async {
    await _col.add({
      'payload': payload,
      'fromNumber': fromNumber,
      'receivedAt': FieldValue.serverTimestamp(),
      'source': 'demo_relay',
      'sosId': sos.id,
      'householdId': sos.householdId,
      'latitude': sos.latitude,
      'longitude': sos.longitude,
      'priorityScore': sos.priorityScore,
      'memberCount': sos.memberCount,
    });
  }

  Future<void> delete(String id) => _col.doc(id).delete();
}

final smsInboxRepositoryProvider = Provider<SmsInboxRepository>((ref) {
  return SmsInboxRepository();
});

final smsInboxStreamProvider =
    StreamProvider<List<SmsInboxEntry>>((ref) {
  return ref.watch(smsInboxRepositoryProvider).watchRecent();
});
