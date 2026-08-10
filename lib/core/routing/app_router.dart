import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/sos/presentation/screens/resident_sos_screen.dart';
import '../../features/sos/presentation/screens/admin_dashboard_screen.dart';
import '../../features/sos/presentation/screens/rescue_team_screen.dart';
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
import '../../features/logistics/presentation/screens/warehouse_management_screen.dart';
import '../../features/logistics/presentation/screens/dispatch_supplies_screen.dart';
import '../../features/logistics/presentation/screens/event_logs_screen.dart';

import '../../features/resident/presentation/screens/bulk_import_residents_screen.dart';
import '../../features/resident/presentation/screens/household_profile_screen.dart';
import '../../features/resident/presentation/screens/household_members_safety_screen.dart';
import '../../features/resident/presentation/screens/admin_households_list_screen.dart';

import '../../features/resident/presentation/screens/offline_sms_fallback_screen.dart';
import '../../features/sos/presentation/screens/escalate_to_district_screen.dart';
import '../../features/rescue_team/presentation/screens/volunteer_registration_screen.dart';

import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_household_screen.dart';
import '../../features/auth/presentation/screens/role_selection_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash', // Khởi động vào màn Loading Splash Screen s01
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
        builder: (context, state) => const RescueTeamScreen(),
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
        builder: (context, state) {
          final isImport = state.uri.queryParameters['mode'] == 'import';
          return DispatchSuppliesScreen(isImportMode: isImport);
        },
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
    ],
  );
});
