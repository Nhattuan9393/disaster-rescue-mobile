import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:disaster_rescue/data/models/user_role.dart';
import 'package:disaster_rescue/features/auth/auth_provider.dart';
import 'package:disaster_rescue/features/auth/login_screen.dart';
import 'package:disaster_rescue/features/auth/role_selector_screen.dart';
import 'package:disaster_rescue/features/situation_board/situation_board_screen.dart';
import 'package:disaster_rescue/features/household/household_home_screen.dart';
import 'package:disaster_rescue/features/household/evacuation_request_screen.dart';
import 'package:disaster_rescue/features/admin_dashboard/admin_map_screen.dart';
import 'package:disaster_rescue/features/admin_dashboard/admin_households_screen.dart';
import 'package:disaster_rescue/features/admin_dashboard/admin_warehouse_screen.dart';
import 'package:disaster_rescue/features/admin_dashboard/admin_reports_screen.dart';
import 'package:disaster_rescue/features/rescue_team/team_missions_screen.dart';
import 'package:disaster_rescue/features/rescue_team/team_map_screen.dart';
import 'package:disaster_rescue/features/rescue_team/team_delivery_screen.dart';
import 'package:disaster_rescue/shared/widgets/main_shell.dart';

/// Provider cấu hình định tuyến của ứng dụng, tích hợp với bộ quản lý trạng thái Riverpod.
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final String matchedLocation = state.matchedLocation;
      final bool isAuthenticated = authState.isAuthenticated;
      final UserRole? activeRole = authState.activeRole;

      // 1. Trường hợp người dùng chưa đăng nhập
      if (!isAuthenticated) {
        // Cho phép truy cập Situation Board công khai
        if (matchedLocation == '/public-board') {
          return null;
        }
        // Đăng nhập công khai không cần tài khoản
        if (activeRole == UserRole.public) {
          return '/public-board';
        }
        // Bắt buộc chuyển hướng về trang đăng nhập
        if (matchedLocation != '/login') {
          return '/login';
        }
        return null;
      }

      // 2. Trường hợp người dùng đã đăng nhập thành công
      // Nếu tài khoản có nhiều vai trò và chưa chọn vai trò làm việc
      if (activeRole == null) {
        if (matchedLocation != '/role-selector') {
          return '/role-selector';
        }
        return null;
      }

      // Nếu đã chọn vai trò mà vẫn đứng ở màn hình Auth, đưa về trang chủ vai trò đó
      if (matchedLocation == '/login' || matchedLocation == '/role-selector') {
        return '/';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/role-selector',
        builder: (context, state) => const RoleSelectorScreen(),
      ),
      GoRoute(
        path: '/public-board',
        builder: (context, state) => const SituationBoardScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) {
              final UserRole? activeRole = authState.activeRole;
              if (activeRole == UserRole.admin) {
                return const AdminMapScreen();
              } else if (activeRole == UserRole.rescueTeam) {
                return const TeamMissionsScreen();
              } else {
                return const HouseholdHomeScreen();
              }
            },
          ),
          GoRoute(
            path: '/evacuation-request',
            builder: (context, state) => const EvacuationRequestScreen(),
          ),
          GoRoute(
            path: '/admin-households',
            builder: (context, state) => const AdminHouseholdsScreen(),
          ),
          GoRoute(
            path: '/admin-warehouse',
            builder: (context, state) => const AdminWarehouseScreen(),
          ),
          GoRoute(
            path: '/admin-reports',
            builder: (context, state) => const AdminReportsScreen(),
          ),
          GoRoute(
            path: '/team-map',
            builder: (context, state) => const TeamMapScreen(),
          ),
          GoRoute(
            path: '/team-delivery',
            builder: (context, state) => const TeamDeliveryScreen(),
          ),
        ],
      ),
    ],
  );
});
