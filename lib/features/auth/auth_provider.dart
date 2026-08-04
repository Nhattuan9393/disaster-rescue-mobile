import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disaster_rescue/data/models/user_role.dart';

/// Trạng thái Đăng nhập và Quyền hạn người dùng.
class AuthState {
  final bool isAuthenticated;
  final String? phoneNumber;
  final List<UserRole> availableRoles;
  final UserRole? activeRole;

  const AuthState({
    required this.isAuthenticated,
    this.phoneNumber,
    this.availableRoles = const [],
    this.activeRole,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    String? phoneNumber,
    List<UserRole>? availableRoles,
    UserRole? activeRole,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      availableRoles: availableRoles ?? this.availableRoles,
      activeRole: activeRole ?? this.activeRole,
    );
  }
}

/// Điều khiển trạng thái xác thực và vai trò hoạt động.
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState(isAuthenticated: false));

  /// Mô phỏng đăng nhập với SĐT và danh sách vai trò
  void login(String phone, List<UserRole> roles) {
    state = AuthState(
      isAuthenticated: true,
      phoneNumber: phone,
      availableRoles: roles,
      // Quy định nghiệp vụ FR-01.5: roles.length == 1 vào thẳng, >=2 chọn vai trò
      activeRole: roles.length == 1 ? roles.first : null,
    );
  }

  /// Chọn vai trò hoạt động (cho tài khoản có nhiều vai trò)
  void selectRole(UserRole role) {
    if (state.availableRoles.contains(role) || role == UserRole.public) {
      state = state.copyWith(activeRole: role);
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
