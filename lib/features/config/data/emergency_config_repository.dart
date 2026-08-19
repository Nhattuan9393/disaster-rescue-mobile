import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/emergency_config.dart';

class EmergencyConfigRepository {
  final FirebaseFirestore _firestore;

  EmergencyConfigRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> get _doc =>
      _firestore.collection('config').doc('emergency');

  Stream<EmergencyConfig> watch() {
    return _doc.snapshots().map((snap) {
      if (!snap.exists || snap.data() == null) {
        return EmergencyConfig.fallback;
      }
      return EmergencyConfig.fromJson(snap.data()!);
    });
  }

  Future<EmergencyConfig> get() async {
    final snap = await _doc.get();
    if (!snap.exists || snap.data() == null) {
      return EmergencyConfig.fallback;
    }
    return EmergencyConfig.fromJson(snap.data()!);
  }

  Future<void> save(EmergencyConfig cfg) async {
    await _doc.set(cfg.toJson(), SetOptions(merge: true));
  }
}

final emergencyConfigRepositoryProvider =
    Provider<EmergencyConfigRepository>((ref) {
  return EmergencyConfigRepository();
});

final emergencyConfigStreamProvider =
    StreamProvider<EmergencyConfig>((ref) {
  return ref.watch(emergencyConfigRepositoryProvider).watch();
});

/// Snapshot đồng bộ tiện cho use-case cần đọc nhanh — trả `fallback` khi chưa
/// có gì hoặc còn loading.
final emergencyConfigProvider = Provider<EmergencyConfig>((ref) {
  return ref.watch(emergencyConfigStreamProvider).maybeWhen(
        data: (cfg) => cfg,
        orElse: () => EmergencyConfig.fallback,
      );
});
