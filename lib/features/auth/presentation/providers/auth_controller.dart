import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/logger.dart';
import '../../data/auth_repository.dart';
import '../../domain/user_model.dart';

class AuthState {
  final UserModel? user;
  final bool isLoading;
  final String? error;

  const AuthState({this.user, this.isLoading = false, this.error});

  AuthState copyWith({
    UserModel? user,
    bool clearUser = false,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(ref);
});

/// Convenience — user hiện tại (có thể null).
final currentUserProvider = Provider<UserModel?>((ref) {
  return ref.watch(authControllerProvider).user;
});

/// Vai trò hiện tại — dùng cho router guard.
final currentRoleProvider = Provider<UserRole?>((ref) {
  return ref.watch(currentUserProvider)?.role;
});

class AuthController extends StateNotifier<AuthState> {
  final Ref _ref;
  late final AuthRepository _repo;

  AuthController(this._ref) : super(const AuthState(isLoading: true)) {
    _repo = _ref.read(authRepositoryProvider);
    _bootstrap();
  }

  void _bootstrap() {
    // Lắng nghe FirebaseAuth state — khi restart app hoặc token hết hạn,
    // tự động load lại profile từ Firestore.
    _repo.authStateChanges().listen((fb.User? fbUser) async {
      if (fbUser == null) {
        state = const AuthState(user: null, isLoading: false);
        return;
      }
      try {
        var profile = await _repo.loadProfile(fbUser.uid);
        if (profile == null) {
          // Tự động khôi phục hồ sơ demo bị thiếu do lỗi quy tắc cũ
          final slug = fbUser.email!.split('@')[0];
          profile = await _repo.provisionDemoProfile(fbUser.uid, slug);
        }
        state = AuthState(user: profile, isLoading: false);
      } catch (e, s) {
        AppLogger.e('Không load được profile', error: e, stackTrace: s);
        state = AuthState(user: null, isLoading: false, error: e.toString());
      }
    });
  }

  Future<UserModel?> signIn(String usernameOrPhone, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final user = await _repo.signIn(
        usernameOrPhone: usernameOrPhone,
        password: password,
      );
      state = AuthState(user: user, isLoading: false);
      return user;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return null;
    }
  }

  Future<UserModel?> registerHousehold({
    required String phoneOrUsername,
    required String password,
    required String displayName,
    required String address,
    required double latitude,
    required double longitude,
    required int memberCount,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final user = await _repo.registerHousehold(
        phoneOrUsername: phoneOrUsername,
        password: password,
        displayName: displayName,
        address: address,
        latitude: latitude,
        longitude: longitude,
        memberCount: memberCount,
      );
      state = AuthState(user: user, isLoading: false);
      return user;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return null;
    }
  }

  Future<UserModel?> registerVolunteerTeam({
    required String phoneOrUsername,
    required String password,
    required String leaderName,
    required String teamName,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final user = await _repo.registerVolunteerTeam(
        phoneOrUsername: phoneOrUsername,
        password: password,
        leaderName: leaderName,
        teamName: teamName,
      );
      state = AuthState(user: user, isLoading: false);
      return user;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return null;
    }
  }

  Future<void> signOut() async {
    await _repo.signOut();
    state = const AuthState(user: null);
  }
}
