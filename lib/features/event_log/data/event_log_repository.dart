import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/event_log_model.dart';
import '../../../../core/utils/logger.dart';

final eventLogRepositoryProvider = Provider<EventLogRepository>((ref) {
  return EventLogRepository();
});

class EventLogRepository {
  final FirebaseFirestore _firestore;

  EventLogRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _logCollection =>
      _firestore.collection('event_logs');

  /// Ghi nhận log sự kiện
  Future<void> logEvent(EventLogModel log) async {
    try {
      AppLogger.i('Ghi nhận sự kiện cứu hộ [${log.action}]: ${log.message}');
      await _logCollection.doc(log.id).set(log.toJson());
    } catch (e, stack) {
      AppLogger.e('Không thể lưu Event Log', error: e, stackTrace: stack);
    }
  }

  /// Lấy danh sách sự kiện của một vụ SOS cụ thể
  Stream<List<EventLogModel>> watchLogsForSos(String sosId) {
    return _logCollection
        .where('sosId', isEqualTo: sosId)
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return EventLogModel.fromJson(data);
      }).toList();
    });
  }
}
