import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/sos/presentation/screens/resident_sos_screen.dart';
import '../../features/sos/presentation/screens/admin_dashboard_screen.dart';
import '../../features/sos/presentation/screens/rescue_team_screen.dart';
import '../../features/sos/presentation/screens/rescue_sos_detail_screen.dart';
import '../../features/sos/presentation/screens/rescue_delivery_receipt_screen.dart';
import '../../features/sos/presentation/screens/rescue_completion_report_screen.dart';
import '../../features/report/presentation/screens/report_screen.dart';

import '../../features/report/presentation/screens/assistance_request_screen.dart';
import '../../features/report/presentation/screens/verify_reports_screen.dart';
import '../../features/report/presentation/screens/report_detail_screen.dart';
import '../../features/report/domain/assistance_request_model.dart';
import '../../features/evacuation/presentation/screens/evacuation_points_screen.dart';
import '../../features/evacuation/presentation/screens/broadcast_evacuation_screen.dart';
import '../../features/evacuation/presentation/screens/evacuation_alert_detail_screen.dart';
import '../../features/evacuation/presentation/screens/evacuation_point_detail_screen.dart';
import '../../features/evacuation/domain/evacuation_point_model.dart';
import '../../features/evacuation/domain/evacuation_order_model.dart';

import '../../features/situation/presentation/screens/cross_check_households_screen.dart';
import '../../features/situation/presentation/screens/situation_board_screen.dart';

import '../../features/rescue_team/presentation/screens/rescue_teams_management_screen.dart';
import '../../features/rescue_team/presentation/screens/rescue_safety_confirmation_screen.dart';
import '../../features/rescue_team/presentation/screens/rescue_team_status_screen.dart';
import '../../features/logistics/presentation/screens/warehouse_management_screen.dart';
import '../../features/logistics/presentation/screens/dispatch_supplies_screen.dart';
import '../../features/logistics/presentation/screens/receive_donations_screen.dart';
import '../../features/logistics/presentation/screens/donation_package_detail_screen.dart';

import '../../features/logistics/presentation/screens/event_logs_screen.dart';

import '../../features/resident/presentation/screens/bulk_import_residents_screen.dart';
import '../../features/resident/presentation/screens/household_profile_screen.dart';
import '../../features/resident/presentation/screens/verify_profile_updates_screen.dart';
import '../../features/resident/presentation/screens/notifications_screen.dart';
import '../../features/resident/presentation/screens/disaster_news_screen.dart';
import '../../features/resident/presentation/screens/household_members_safety_screen.dart';
import '../../features/resident/presentation/screens/admin_households_list_screen.dart';

import '../../features/resident/presentation/screens/offline_sms_fallback_screen.dart';
import '../../features/sos/presentation/screens/escalate_to_district_screen.dart';
import '../../features/rescue_team/presentation/screens/volunteer_registration_screen.dart';
import '../../features/rescue_team/presentation/screens/permanent_forces_screen.dart';
import '../../features/rescue_team/presentation/screens/rescue_team_detail_admin_screen.dart';
import '../../features/resident/presentation/screens/household_detail_admin_screen.dart';
import '../../features/sos/presentation/screens/sms_inbox_admin_screen.dart';
import '../../features/config/presentation/screens/emergency_config_screen.dart';

import '../../features/auth/presentation/screens/splash_screen.dart';


import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_household_screen.dart';
import '../../features/auth/presentation/screens/role_selection_screen.dart';
import '../../features/auth/presentation/providers/auth_controller.dart';
import '../../features/auth/domain/user_model.dart';

/// Các route công khai — không yêu cầu đăng nhập.
const _publicRoutes = {
  '/splash',
  '/login',
  '/register-household',
  '/volunteer-register',
  '/situation-board',
  '/select-role',
};

String? _homeForRole(UserRole role) {
  switch (role) {
    case UserRole.admin:
      return '/admin';
    case UserRole.rescueTeam:
      return '/rescue';
    case UserRole.household:
      return '/resident';
    case UserRole.public:
      return '/situation-board';
  }
}

/// Route nào cấm role nào — nếu role vào nhầm khu vực khác, ép về home.
bool _roleAllowedForPath(UserRole role, String path) {
  if (path.startsWith('/admin') ||
      path.startsWith('/verify-reports') ||
      path.startsWith('/verify-profile-updates') ||
      path.startsWith('/cross-check') ||
      path.startsWith('/rescue-teams') ||
      path.startsWith('/warehouse') ||
      path.startsWith('/dispatch-supplies') ||
      path.startsWith('/receive-donations') ||
      path.startsWith('/donation-package-detail') ||
      path.startsWith('/event-logs') ||
      path.startsWith('/bulk-import') ||
      path.startsWith('/admin-households') ||
      path.startsWith('/escalate-district') ||
      path.startsWith('/permanent-forces') ||
      path.startsWith('/rescue-team-detail-admin') ||
      path.startsWith('/household-detail-admin') ||
      path.startsWith('/broadcast-evacuation') ||
      path.startsWith('/sms-inbox') ||
      path.startsWith('/emergency-config')) {
    return role == UserRole.admin;
  }
  if (path.startsWith('/rescue-sos-detail') ||
      path.startsWith('/rescue-delivery') ||
      path.startsWith('/rescue-completion') ||
      path.startsWith('/rescue-safety') ||
      path.startsWith('/rescue-team-status') ||
      path == '/rescue') {
    return role == UserRole.rescueTeam || role == UserRole.admin;
  }
  if (path.startsWith('/resident') ||
      path.startsWith('/report') ||
      path.startsWith('/assistance') ||
      path.startsWith('/household-profile') ||
      path.startsWith('/news') ||
      path.startsWith('/members-safety') ||
      path.startsWith('/offline-sms')) {
    return role == UserRole.household || role == UserRole.admin;
  }
  return true;
}

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: _AuthRefreshNotifier(ref),
    redirect: (context, state) {
      final auth = ref.read(authControllerProvider);
      final path = state.matchedLocation;

      // Đang khởi tạo — không redirect
      if (auth.isLoading && path == '/splash') return null;

      final user = auth.user;
      final isPublic = _publicRoutes.contains(path);

      if (user == null) {
        if (isPublic) return null;
        return '/login';
      }

      // Đã đăng nhập nhưng đang ở /login hoặc /splash → về home theo role
      if (path == '/login' || path == '/splash') {
        return _homeForRole(user.role);
      }
      // Chặn role vào sai khu vực
      if (!_roleAllowedForPath(user.role, path)) {
        return _homeForRole(user.role);
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/select-role',
        builder: (context, state) => const RoleSelectionScreen(),
      ),
      GoRoute(
        path: '/register-household',
        builder: (context, state) => const RegisterHouseholdScreen(),
      ),
      GoRoute(
        path: '/resident',
        builder: (context, state) => const ResidentSosScreen(),
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: '/rescue',
        builder: (context, state) {
          final type = state.uri.queryParameters['type'] ?? 'permanent';
          return RescueTeamScreen(teamType: type);
        },
      ),
      GoRoute(
        path: '/rescue-sos-detail',
        builder: (context, state) {
          final sosId = state.uri.queryParameters['sosId'] ?? '';
          return RescueSosDetailScreen(sosId: sosId);
        },
      ),
      GoRoute(
        path: '/rescue-delivery',
        builder: (context, state) {
          final sosId = state.uri.queryParameters['sosId'] ?? '';
          return RescueDeliveryReceiptScreen(sosId: sosId);
        },
      ),
      GoRoute(
        path: '/rescue-completion',
        builder: (context, state) {
          final sosId = state.uri.queryParameters['sosId'] ?? '';
          return RescueCompletionReportScreen(sosId: sosId);
        },
      ),
      GoRoute(
        path: '/rescue-safety',
        builder: (context, state) {
          final sosId = state.uri.queryParameters['sosId'] ?? '';
          return RescueSafetyConfirmationScreen(sosId: sosId);
        },
      ),
      GoRoute(
        path: '/rescue-team-status',
        builder: (context, state) => const RescueTeamStatusScreen(),
      ),

      GoRoute(
        path: '/report',
        builder: (context, state) {
          final type = state.uri.queryParameters['type'] ?? 'B';
          return ReportScreen(initialType: type);
        },
      ),
      GoRoute(
        path: '/assistance',
        builder: (context, state) => const AssistanceRequestScreen(),
      ),
      GoRoute(
        path: '/verify-reports',
        builder: (context, state) => const VerifyReportsScreen(),
      ),
      GoRoute(
        path: '/verify-profile-updates',
        builder: (context, state) => const VerifyProfileUpdatesScreen(),
      ),
      GoRoute(
        path: '/report-detail',
        builder: (context, state) {
          final report = state.extra as AssistanceRequestModel;
          return ReportDetailScreen(report: report);
        },
      ),
      GoRoute(
        path: '/evacuation-points',
        builder: (context, state) {
          final isAdmin = state.uri.queryParameters['role'] == 'admin';
          return EvacuationPointsScreen(isAdmin: isAdmin);
        },
      ),
      GoRoute(
        path: '/broadcast-evacuation',
        builder: (context, state) => const BroadcastEvacuationScreen(),
      ),
      GoRoute(
        path: '/evacuation-alert',
        builder: (context, state) {
          final order = state.extra as EvacuationOrderModel?;
          return EvacuationAlertDetailScreen(order: order);
        },
      ),
      GoRoute(
        path: '/evacuation-point-detail',
        builder: (context, state) {
          final point = state.extra as EvacuationPointModel;
          return EvacuationPointDetailScreen(point: point);
        },
      ),
      GoRoute(
        path: '/cross-check',
        builder: (context, state) => const CrossCheckHouseholdsScreen(),
      ),
      GoRoute(
        path: '/situation-board',
        builder: (context, state) => const SituationBoardScreen(),
      ),
      GoRoute(
        path: '/rescue-teams',
        builder: (context, state) => const RescueTeamsManagementScreen(),
      ),
      GoRoute(
        path: '/warehouse',
        builder: (context, state) => const WarehouseManagementScreen(),
      ),
      GoRoute(
        path: '/dispatch-supplies',
        builder: (context, state) => const DispatchSuppliesScreen(),
      ),
      GoRoute(
        path: '/receive-donations',
        builder: (context, state) => const ReceiveDonationsScreen(),
      ),
      GoRoute(
        path: '/donation-package-detail',
        builder: (context, state) => const DonationPackageDetailScreen(),
      ),

      GoRoute(
        path: '/event-logs',
        builder: (context, state) => const EventLogsScreen(),
      ),
      GoRoute(
        path: '/bulk-import',
        builder: (context, state) => const BulkImportResidentsScreen(),
      ),
      GoRoute(
        path: '/household-profile',
        builder: (context, state) => const HouseholdProfileScreen(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/news',
        builder: (context, state) => const DisasterNewsScreen(),
      ),
      GoRoute(
        path: '/members-safety',
        builder: (context, state) => const HouseholdMembersSafetyScreen(),
      ),
      GoRoute(
        path: '/admin-households',
        builder: (context, state) => const AdminHouseholdsListScreen(),
      ),
      GoRoute(
        path: '/offline-sms',
        builder: (context, state) => const OfflineSmsFallbackScreen(),
      ),
      GoRoute(
        path: '/escalate-district',
        builder: (context, state) => const EscalateToDistrictScreen(),
      ),
      GoRoute(
        path: '/volunteer-register',
        builder: (context, state) => const VolunteerRegistrationScreen(),
      ),
      GoRoute(
        path: '/permanent-forces',
        builder: (context, state) => const PermanentForcesScreen(),
      ),
      GoRoute(
        path: '/household-detail-admin',
        builder: (context, state) => const HouseholdDetailAdminScreen(),
      ),
      GoRoute(
        path: '/rescue-team-detail-admin',
        builder: (context, state) => const RescueTeamDetailAdminScreen(),
      ),
      GoRoute(
        path: '/sms-inbox',
        builder: (context, state) => const SmsInboxAdminScreen(),
      ),
      GoRoute(
        path: '/emergency-config',
        builder: (context, state) => const EmergencyConfigScreen(),
      ),
    ],
  );
});

/// Chạm vào GoRouter mỗi khi AuthState thay đổi → redirect chạy lại.
class _AuthRefreshNotifier extends ChangeNotifier {
  _AuthRefreshNotifier(Ref ref) {
    ref.listen<AuthState>(authControllerProvider, (_, __) => notifyListeners());
  }
}
