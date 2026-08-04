import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disaster_rescue/data/models/user_role.dart';

/// Trạng thái Đăng nhập và Quyền hạn người dùng.
class AuthState {
  final bool isAuthenticated;
  final String? phoneNumber;
  final String? displayName;
  final List<UserRole> availableRoles;
  final UserRole? activeRole;

  const AuthState({
    required this.isAuthenticated,
    this.phoneNumber,
    this.displayName,
    this.availableRoles = const [],
    this.activeRole,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    String? phoneNumber,
    String? displayName,
    List<UserRole>? availableRoles,
    UserRole? activeRole,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      displayName: displayName ?? this.displayName,
      availableRoles: availableRoles ?? this.availableRoles,
      activeRole: activeRole ?? this.activeRole,
    );
  }
}

/// Điều khiển trạng thái xác thực và vai trò hoạt động.
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState(isAuthenticated: false));

  /// Đăng nhập với SĐT, danh sách vai trò, và tên hiển thị.
  /// FR-01.5: roles.length == 1 → vào thẳng, >= 2 → chọn vai trò.
  void login(String phone, List<UserRole> roles, {String? displayName}) {
    state = AuthState(
      isAuthenticated: true,
      phoneNumber: phone,
      displayName: displayName,
      availableRoles: roles,
      activeRole: roles.length == 1 ? roles.first : null,
    );
  }

  /// Chọn vai trò hoạt động (cho tài khoản có nhiều vai trò)
  void selectRole(UserRole role) {
    if (state.availableRoles.contains(role) || role == UserRole.public) {
      state = state.copyWith(activeRole: role);
    }
  }

  /// Đổi vai trò — từ màn Hồ sơ, không cần đăng xuất (quyết định 2.6)
  void switchRole() {
    if (state.availableRoles.length >= 2) {
      state = state.copyWith(activeRole: null);
    }
  }

  /// Đăng nhập công khai (Situation Board) không cần tài khoản
  void enterAsPublic() {
    state = const AuthState(
      isAuthenticated: false,
      activeRole: UserRole.public,
    );
  }

  /// Đăng xuất
  void logout() {
    state = const AuthState(isAuthenticated: false);
  }
}

/// Provider toàn cục quản lý xác thực và vai trò.
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
