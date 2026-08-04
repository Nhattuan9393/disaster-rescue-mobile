import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:disaster_rescue/core/theme/app_theme.dart';
import 'package:disaster_rescue/data/models/user_role.dart';
import 'package:disaster_rescue/features/auth/auth_provider.dart';
import 'package:disaster_rescue/core/utils/connection_provider.dart';
import 'package:disaster_rescue/data/datasources/local/offline_queue_provider.dart';
import 'package:disaster_rescue/shared/widgets/offline_banner.dart';

/// Khung ứng dụng chính (App Shell) chứa Bottom Navigation Bar thay đổi động theo vai trò người dùng.
class MainShell extends ConsumerWidget {
  final Widget child;

  const MainShell({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final role = authState.activeRole;
    final location = GoRouterState.of(context).matchedLocation;

    final connectionStatus = ref.watch(connectionProvider);
    final queueState = ref.watch(offlineQueueProvider);
    final isOffline = connectionStatus == ConnectionStatus.offline;

    // 1. Định nghĩa các Tab tương ứng với từng vai trò
    final List<_ShellTabItem> tabs = [];

    if (role == UserRole.household) {
      tabs.addAll([
        const _ShellTabItem(
          icon: Icon(Icons.home_rounded),
          label: 'Trang chủ',
          path: '/',
        ),
        const _ShellTabItem(
          icon: Icon(Icons.airport_shuttle_rounded),
          label: 'Hỗ trợ',
          path: '/evacuation-request',
        ),
        const _ShellTabItem(
          icon: Icon(Icons.person_rounded),
          label: 'Hồ sơ',
          path: '/profile',
        ),
      ]);
    } else if (role == UserRole.admin) {
      tabs.addAll([
        const _ShellTabItem(
          icon: Icon(Icons.map_rounded),
          label: 'Bản đồ',
          path: '/',
        ),
        const _ShellTabItem(
          icon: Icon(Icons.people_rounded),
          label: 'Đối chiếu',
          path: '/admin-households',
        ),
        const _ShellTabItem(
          icon: Icon(Icons.warehouse_rounded),
          label: 'Kho',
          path: '/admin-warehouse',
        ),
        const _ShellTabItem(
          icon: Icon(Icons.rate_review_rounded),
          label: 'Duyệt tin',
          path: '/admin-reports',
        ),
      ]);
    } else if (role == UserRole.rescueTeam) {
      tabs.addAll([
        const _ShellTabItem(
          icon: Icon(Icons.health_and_safety_rounded),
          label: 'Nhiệm vụ',
          path: '/',
        ),
        const _ShellTabItem(
          icon: Icon(Icons.map_rounded),
          label: 'Chướng ngại',
          path: '/team-map',
        ),
        const _ShellTabItem(
          icon: Icon(Icons.local_shipping_rounded),
          label: 'Phát hàng',
          path: '/team-delivery',
        ),
      ]);
    }

    // 2. Tính toán tab hiện tại dựa trên URI path
    int selectedIndex = 0;
    for (int i = 0; i < tabs.length; i++) {
      if (tabs[i].path == location) {
        selectedIndex = i;
        break;
      }
    }

    final bool showBottomNavBar = tabs.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          if (isOffline)
            OfflineBanner(
              pendingSosCount: queueState.sosCount,
              pendingActionsCount: queueState.actionCount,
            ),
          Expanded(child: child),
        ],
      ),
      bottomNavigationBar: showBottomNavBar
          ? NavigationBar(
              selectedIndex: selectedIndex,
              onDestinationSelected: (index) {
                context.go(tabs[index].path);
              },
              destinations: tabs
                  .map((tab) => NavigationDestination(
                        icon: tab.icon,
                        label: tab.label,
                      ))
                  .toList(),
            )
          : null,
    );
  }
}

class _ShellTabItem {
  final Widget icon;
  final String label;
  final String path;

  const _ShellTabItem({
    required this.icon,
    required this.label,
    required this.path,
  });
}
