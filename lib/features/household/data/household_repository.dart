import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/presentation/providers/auth_controller.dart';
import '../domain/household_model.dart';

class HouseholdRepository {
  final FirebaseFirestore _firestore;
  HouseholdRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection('households');

  Future<HouseholdModel?> getById(String id) async {
    final snap = await _col.doc(id).get();
    if (!snap.exists) return null;
    final data = Map<String, dynamic>.from(snap.data()!);
    data['id'] = snap.id;
    return HouseholdModel.fromJson(_coerce(data));
  }

  Stream<HouseholdModel?> watchById(String id) {
    return _col.doc(id).snapshots().map((snap) {
      if (!snap.exists) return null;
      final data = Map<String, dynamic>.from(snap.data()!);
      data['id'] = snap.id;
      return HouseholdModel.fromJson(_coerce(data));
    });
  }

  Future<void> update(HouseholdModel h) async {
    final data = h.toJson();
    data['updatedAt'] = FieldValue.serverTimestamp();
    await _col.doc(h.id).set(data, SetOptions(merge: true));
  }

  Map<String, dynamic> _coerce(Map<String, dynamic> data) {
    // Loose-typing: các field số có thể là double/num tuỳ Firestore
    data['memberCount'] = (data['memberCount'] as num?)?.toInt() ?? 1;
    data['childrenCount'] = (data['childrenCount'] as num?)?.toInt() ?? 0;
    data['elderlyCount'] = (data['elderlyCount'] as num?)?.toInt() ?? 0;
    data['sickCount'] = (data['sickCount'] as num?)?.toInt() ?? 0;
    data['ownerUid'] = (data['ownerUid'] as String?) ?? '';
    data['address'] = (data['address'] as String?) ?? '';
    return data;
  }
}

final householdRepositoryProvider = Provider<HouseholdRepository>((ref) {
  return HouseholdRepository();
});

/// Stream hộ dân của user hiện tại — null nếu user không phải household hoặc
/// chưa có `householdId`.
final myHouseholdStreamProvider = StreamProvider<HouseholdModel?>((ref) {
  final user = ref.watch(currentUserProvider);
  final hid = user?.householdId;
  if (hid == null) return Stream.value(null);
  return ref.watch(householdRepositoryProvider).watchById(hid);
});

/// Stream hộ theo id bất kỳ — dùng cho đội cứu hộ mở khoá PII sau khi được gán.
final householdByIdStreamProvider =
    StreamProvider.family<HouseholdModel?, String>((ref, id) {
  return ref.watch(householdRepositoryProvider).watchById(id);
});

final pendingHouseholdsStreamProvider = StreamProvider<List<HouseholdModel>>((ref) {
  final firestore = FirebaseFirestore.instance;
  return firestore
      .collection('households')
      .where('isUpdatePending', isEqualTo: true)
      .snapshots()
      .map((snap) {
    return snap.docs.map((doc) {
      final data = Map<String, dynamic>.from(doc.data());
      data['id'] = doc.id;
      data['memberCount'] = (data['memberCount'] as num?)?.toInt() ?? 1;
      data['childrenCount'] = (data['childrenCount'] as num?)?.toInt() ?? 0;
      data['elderlyCount'] = (data['elderlyCount'] as num?)?.toInt() ?? 0;
      data['sickCount'] = (data['sickCount'] as num?)?.toInt() ?? 0;
      data['ownerUid'] = (data['ownerUid'] as String?) ?? '';
      data['address'] = (data['address'] as String?) ?? '';
      return HouseholdModel.fromJson(data);
    }).toList();
  });
});
