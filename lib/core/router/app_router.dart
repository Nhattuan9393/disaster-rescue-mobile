import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:disaster_rescue/data/models/user_role.dart';
import 'package:disaster_rescue/features/auth/auth_provider.dart';
import 'package:disaster_rescue/features/auth/splash_screen.dart';
import 'package:disaster_rescue/features/auth/login_screen.dart';
import 'package:disaster_rescue/features/auth/register_household_screen.dart';
import 'package:disaster_rescue/features/auth/role_selector_screen.dart';
import 'package:disaster_rescue/features/auth/profile_screen.dart';
import 'package:disaster_rescue/features/situation_board/situation_board_screen.dart';
import 'package:disaster_rescue/features/household/household_home_screen.dart';
import 'package:disaster_rescue/features/household/evacuation_request_screen.dart';
import 'package:disaster_rescue/features/sos/report_to_commune_screen.dart';
import 'package:disaster_rescue/features/admin_dashboard/admin_map_screen.dart';
import 'package:disaster_rescue/features/admin_dashboard/admin_households_screen.dart';
import 'package:disaster_rescue/features/admin_dashboard/admin_warehouse_screen.dart';
import 'package:disaster_rescue/features/admin_dashboard/admin_reports_screen.dart';
import 'package:disaster_rescue/features/escalation/escalation_screen.dart';
import 'package:disaster_rescue/features/escalation/event_detail_screen.dart';
import 'package:disaster_rescue/features/rescue_team/team_missions_screen.dart';
import 'package:disaster_rescue/features/rescue_team/team_map_screen.dart';
import 'package:disaster_rescue/features/rescue_team/team_delivery_screen.dart';
import 'package:disaster_rescue/shared/widgets/main_shell.dart';

/// Provider cấu hình định tuyến của ứng dụng, tích hợp với bộ quản lý trạng thái Riverpod.
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final String matchedLocation = state.matchedLocation;
      final bool isAuthenticated = authState.isAuthenticated;
      final UserRole? activeRole = authState.activeRole;

      // Splash luôn cho qua
      if (matchedLocation == '/splash') return null;

      // Các route công khai — không cần auth
      const publicRoutes = ['/login', '/register-household', '/public-board'];
      if (publicRoutes.contains(matchedLocation)) {
        // Nếu đã login mà vào login → đưa về home
        if (isAuthenticated && matchedLocation == '/login') {
          return '/';
        }
        return null;
      }

      // 1. Chưa đăng nhập
      if (!isAuthenticated) {
        // Cho phép Situation Board công khai
        if (activeRole == UserRole.public) {
          return '/public-board';
        }
        return '/login';
      }

      // 2. Đã đăng nhập nhưng chưa chọn vai trò
      if (activeRole == null) {
        if (matchedLocation != '/role-selector') {
          return '/role-selector';
        }
        return null;
      }

      // 3. Đã chọn vai trò mà vẫn ở auth screens → đưa về home
      if (matchedLocation == '/login' || matchedLocation == '/role-selector') {
        return '/';
      }

      return null;
    },
    routes: [
      // ── Auth routes (ngoài shell) ──
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register-household',
        builder: (context, state) => const RegisterHouseholdScreen(),
      ),
      GoRoute(
        path: '/role-selector',
        builder: (context, state) => const RoleSelectorScreen(),
      ),
      GoRoute(
        path: '/public-board',
        builder: (context, state) => const SituationBoardScreen(),
      ),

      // ── Shell routes (có bottom nav) ──
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          // Home — điều hướng theo vai trò (FR-01.5)
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

          // ── Hộ dân routes ──
          GoRoute(
            path: '/evacuation-request',
            builder: (context, state) => const EvacuationRequestScreen(),
          ),
          GoRoute(
            path: '/report-to-commune',
            builder: (context, state) => const ReportToCommuneScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),

          // ── Admin xã routes ──
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
            path: '/escalation',
            builder: (context, state) => const EscalationScreen(),
          ),
          GoRoute(
            path: '/event-detail',
            builder: (context, state) => const EventDetailScreen(),
          ),

          // ── Đội cứu hộ routes ──
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
