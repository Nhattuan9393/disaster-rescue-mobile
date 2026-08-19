import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/utils/logger.dart';
import '../domain/user_model.dart';

/// Auth + user profile access.
///
/// Chuẩn hoá username / SĐT → email dạng `<slug>@disaster.local` để dùng chung
/// FirebaseAuth Email/Password (không cần bật thêm provider). Mỗi user đăng
/// nhập thành công đều được đảm bảo có doc `users/{uid}` chứa role + phạm vi
/// địa lý — mọi màn hình phía sau đọc từ đây thay cho hardcode.
class AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthRepository({FirebaseAuth? auth, FirebaseFirestore? firestore})
      : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<User?> authStateChanges() => _auth.authStateChanges();
  User? get currentFirebaseUser => _auth.currentUser;

  Future<UserModel?> loadProfile(String uid) async {
    final snap = await _firestore.collection('users').doc(uid).get();
    if (!snap.exists) return null;
    final data = Map<String, dynamic>.from(snap.data()!);
    data['uid'] = uid;
    // Firestore Timestamp → DateTime để UserModel.fromJson nhận
    _normaliseTimestamps(data, const ['createdAt', 'updatedAt']);
    return UserModel.fromJson(data);
  }

  Future<UserModel> signIn({
    required String usernameOrPhone,
    required String password,
  }) async {
    final slug = normaliseUsername(usernameOrPhone);
    final email = '$slug@disaster.local';

    if (password.length < 6) {
      throw AuthException('Mật khẩu phải ≥ 6 ký tự (yêu cầu Firebase Auth).');
    }

    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final profile = await loadProfile(cred.user!.uid);
      if (profile == null) {
        // Hồ sơ bị mất — provision lại theo pattern demo
        return await provisionDemoProfile(cred.user!.uid, slug);
      }
      return profile;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'invalid-credential') {
        // Auto-provision tài khoản demo (admin, dq01, tt1, vl1, số SĐT…) —
        // giữ trải nghiệm test giống prototype cũ nhưng có Firebase Auth thật.
        final role = _inferRoleFromUsername(slug);
        if (role == null) {
          throw AuthException('Tài khoản không tồn tại. Vui lòng đăng ký.');
        }
        try {
          final cred = await _auth.createUserWithEmailAndPassword(
            email: email,
            password: password,
          );
          return await provisionDemoProfile(cred.user!.uid, slug);
        } on FirebaseAuthException catch (inner) {
          if (inner.code == 'email-already-in-use') {
            // Tài khoản có sẵn nhưng password nhập sai → phân biệt rõ, đừng
            // báo "user-not-found" nữa.
            throw AuthException(
              'Mật khẩu không đúng cho tài khoản "$slug". Bấm "Thử lại" hoặc đăng ký lại.',
            );
          }
          if (inner.code == 'weak-password') {
            throw AuthException(
              'Mật khẩu quá yếu — Firebase Auth yêu cầu tối thiểu 6 ký tự.',
            );
          }
          AppLogger.e('Lỗi auto-provision', error: inner);
          throw AuthException(inner.message ?? 'Không tạo được tài khoản demo.');
        }
      }
      if (e.code == 'wrong-password') {
        throw AuthException('Mật khẩu không đúng.');
      }
      if (e.code == 'too-many-requests') {
        throw AuthException(
          'Đăng nhập sai quá nhiều lần. Thử lại sau vài phút hoặc reset password.',
        );
      }
      AppLogger.e('Lỗi FirebaseAuth', error: e);
      throw AuthException(e.message ?? 'Đăng nhập thất bại.');
    }
  }

  /// Đăng ký hộ dân mới — tạo cả tài khoản Auth và doc `households/{id}`.
  Future<UserModel> registerHousehold({
    required String phoneOrUsername,
    required String password,
    required String displayName,
    required String address,
    required double latitude,
    required double longitude,
    required int memberCount,
    String communeId = 'commune_binh_lieu',
    String sectorId = 'sector_pac_lieng',
  }) async {
    final slug = normaliseUsername(phoneOrUsername);
    final email = '$slug@disaster.local';

    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final uid = cred.user!.uid;
    final householdId = 'household_$uid';

    final household = {
      'id': householdId,
      'headName': displayName,
      'phoneNumber': phoneOrUsername,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'memberCount': memberCount,
      'communeId': communeId,
      'sectorId': sectorId,
      'ownerUid': uid,
      'safetyStatus': 'unknown',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
    await _firestore.collection('households').doc(householdId).set(household);

    final user = UserModel(
      uid: uid,
      role: UserRole.household,
      displayName: displayName,
      phoneNumber: phoneOrUsername,
      email: email,
      householdId: householdId,
      communeId: communeId,
      sectorId: sectorId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await _writeUserDoc(user);
    return user;
  }

  /// Đăng ký đội cứu hộ vãng lai — tạo tài khoản + doc `rescue_teams/{teamId}`.
  Future<UserModel> registerVolunteerTeam({
    required String phoneOrUsername,
    required String password,
    required String leaderName,
    required String teamName,
    String communeId = 'commune_binh_lieu',
    String sectorId = 'sector_pac_lieng',
  }) async {
    final slug = normaliseUsername(phoneOrUsername);
    final email = '$slug@disaster.local';

    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final uid = cred.user!.uid;
    final teamId = 'team_$uid';

    await _firestore.collection('rescue_teams').doc(teamId).set({
      'id': teamId,
      'name': teamName,
      'leaderName': leaderName,
      'contactPhone': phoneOrUsername,
      'status': 'available',
      'teamType': 'volunteer',
      'ownerUid': uid,
      'currentLatitude': 21.542,
      'currentLongitude': 107.399,
      'communeId': communeId,
      'sectorId': sectorId,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    final user = UserModel(
      uid: uid,
      role: UserRole.rescueTeam,
      displayName: leaderName,
      phoneNumber: phoneOrUsername,
      email: email,
      teamId: teamId,
      teamType: RescueTeamType.volunteer,
      communeId: communeId,
      sectorId: sectorId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await _writeUserDoc(user);
    return user;
  }

  Future<void> signOut() => _auth.signOut();

  Future<void> updateFcmToken(String uid, String token) async {
    await _firestore.collection('users').doc(uid).update({
      'fcmToken': token,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _writeUserDoc(UserModel user) async {
    final data = user.toJson();
    data['createdAt'] = FieldValue.serverTimestamp();
    data['updatedAt'] = FieldValue.serverTimestamp();
    await _firestore.collection('users').doc(user.uid).set(data);
  }

  Future<UserModel> provisionDemoProfile(String uid, String slug) async {
    final role = _inferRoleFromUsername(slug) ?? UserRole.household;
    UserModel user;
    switch (role) {
      case UserRole.admin:
        user = UserModel(
          uid: uid,
          role: UserRole.admin,
          displayName: 'Admin Ban Chỉ Huy Xã',
          phoneNumber: slug,
          email: '$slug@disaster.local',
          communeId: 'commune_binh_lieu',
          sectorId: 'sector_pac_lieng',
        );
        break;
      case UserRole.rescueTeam:
        final teamType = _inferTeamTypeFromUsername(slug);
        final teamId = 'team_$uid';
        await _firestore.collection('rescue_teams').doc(teamId).set({
          'id': teamId,
          'name': teamType == RescueTeamType.volunteer
              ? 'Đội vãng lai $slug'
              : 'Đội thường trực $slug',
          'leaderName': slug.toUpperCase(),
          'contactPhone': slug,
          'status': 'available',
          'teamType': teamType.name,
          'ownerUid': uid,
          // Auto-approve khi provision demo — nếu không set, volunteer sẽ kẹt
          // ở màn "Chờ duyệt" trong lần đầu load (khi stream chưa emit doc).
          'isApproved': true,
          'currentLatitude': 21.542,
          'currentLongitude': 107.399,
          'communeId': 'commune_binh_lieu',
          'sectorId': 'sector_pac_lieng',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        user = UserModel(
          uid: uid,
          role: UserRole.rescueTeam,
          displayName: 'Đội cứu hộ $slug',
          phoneNumber: slug,
          email: '$slug@disaster.local',
          teamId: teamId,
          teamType: teamType,
          communeId: 'commune_binh_lieu',
          sectorId: 'sector_pac_lieng',
        );
        break;
      case UserRole.household:
      case UserRole.public:
        final householdId = 'household_$uid';
        await _firestore.collection('households').doc(householdId).set({
          'id': householdId,
          'headName': 'Hộ $slug',
          'phoneNumber': slug,
          'address': 'Thôn Pắc Liềng, xã Bình Liêu',
          'latitude': 21.542,
          'longitude': 107.399,
          'memberCount': 4,
          'communeId': 'commune_binh_lieu',
          'sectorId': 'sector_pac_lieng',
          'ownerUid': uid,
          'safetyStatus': 'unknown',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        user = UserModel(
          uid: uid,
          role: UserRole.household,
          displayName: 'Hộ dân $slug',
          phoneNumber: slug,
          email: '$slug@disaster.local',
          householdId: householdId,
          communeId: 'commune_binh_lieu',
          sectorId: 'sector_pac_lieng',
        );
        break;
    }
    await _writeUserDoc(user);
    return user;
  }

  UserRole? _inferRoleFromUsername(String slug) {
    if (slug == 'admin') return UserRole.admin;
    if (slug.startsWith('dq') ||
        slug.startsWith('tt') ||
        slug.startsWith('vl') ||
        slug.contains('cuuho') ||
        slug.contains('mtq')) {
      return UserRole.rescueTeam;
    }
    // Chuỗi số (SĐT) → hộ dân
    if (RegExp(r'^\d{9,11}$').hasMatch(slug)) return UserRole.household;
    if (slug.contains('nha') || slug.startsWith('truongthon')) {
      return UserRole.household;
    }
    return null;
  }

  RescueTeamType _inferTeamTypeFromUsername(String slug) {
    if (slug.startsWith('vl') || slug.contains('mtq')) {
      return RescueTeamType.volunteer;
    }
    return RescueTeamType.permanent;
  }

  /// Chuẩn hoá username: lowercase, bỏ khoảng trắng và ký tự đặc biệt.
  static String normaliseUsername(String input) {
    return input.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
  }

  static void _normaliseTimestamps(
      Map<String, dynamic> data, List<String> keys) {
    for (final k in keys) {
      final v = data[k];
      if (v is Timestamp) data[k] = v.toDate().toIso8601String();
    }
  }
}

class AuthException implements Exception {
  final String message;
  AuthException(this.message);
  @override
  String toString() => message;
}
