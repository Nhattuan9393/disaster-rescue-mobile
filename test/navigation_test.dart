import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disaster_rescue/core/router/app_router.dart';
import 'package:disaster_rescue/data/models/user_role.dart';
import 'package:disaster_rescue/features/auth/auth_provider.dart';
import 'package:disaster_rescue/features/auth/login_screen.dart';
import 'package:disaster_rescue/features/auth/role_selector_screen.dart';
import 'package:disaster_rescue/features/household/household_home_screen.dart';
import 'package:disaster_rescue/features/admin_dashboard/admin_map_screen.dart';

import 'dart:io';
import 'package:hive/hive.dart';
import 'package:disaster_rescue/data/models/offline_request.dart';

void main() {
  late Directory tempDir;
  late Box<OfflineRequest> box;

  setUpAll(() {
    try {
      Hive.registerAdapter(OfflineRequestAdapter());
    } catch (_) {}
  });

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('hive_nav_test');
    Hive.init(tempDir.path);
    box = await Hive.openBox<OfflineRequest>('offline_requests');
  });

  tearDown(() async {
    await box.clear();
    await box.close();
    try {
      await tempDir.delete(recursive: true);
    } catch (_) {}
  });

  group('GoRouter and Dynamic MainShell Navigation Tests', () {
    Widget createTestApp(ProviderContainer container) {
      return UncontrolledProviderScope(
        container: container,
        child: Consumer(
          builder: (context, ref, child) {
            final router = ref.watch(routerProvider);
            return MaterialApp.router(
              routerConfig: router,
            );
          },
        ),
      );
    }

    testWidgets('Initial route is LoginScreen', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      await tester.pumpWidget(createTestApp(container));
      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.text('ĐĂNG NHẬP'), findsOneWidget);
    });

    testWidgets('Public entry redirects to SituationBoardScreen', (tester) async {
      tester.view.physicalSize = const Size(800, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final container = ProviderContainer();
      addTearDown(container.dispose);
      await tester.pumpWidget(createTestApp(container));
      await tester.pumpAndSettle();

      // Tap on public entry button
      final publicBtn = find.text('Xem tình hình thiên tai');
      expect(publicBtn, findsOneWidget);
      await tester.tap(publicBtn);
      await tester.pumpAndSettle();

      expect(find.text('Bảng Tin Tình Hình Xã'), findsOneWidget);
    });

    testWidgets('Logging in as Household (1 role) redirects to HouseholdHomeScreen and shows household tabs', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      await tester.pumpWidget(createTestApp(container));
      await tester.pumpAndSettle();

      // Simulate logging in as Household
      container.read(authProvider.notifier).login('0987654321', [UserRole.household]);
      await tester.pumpAndSettle();

      // Should be on Household Home Screen (root)
      expect(find.byType(HouseholdHomeScreen), findsOneWidget);

      // Verify Household Tabs in bottom navigation bar
      expect(find.text('Trang chủ'), findsOneWidget);
      expect(find.text('Hỗ trợ'), findsOneWidget);
      expect(find.text('Hồ sơ'), findsOneWidget);
    });

    testWidgets('Logging in as Admin (1 role) redirects to AdminMapScreen and shows admin tabs', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      await tester.pumpWidget(createTestApp(container));
      await tester.pumpAndSettle();

      // Simulate logging in as Admin
      container.read(authProvider.notifier).login('0987654321', [UserRole.admin]);
      await tester.pumpAndSettle();

      // Should be on Admin Map Screen (root)
      expect(find.byType(AdminMapScreen), findsOneWidget);

      // Verify Admin Tabs
      expect(find.text('Bản đồ'), findsOneWidget);
      expect(find.text('Đối chiếu'), findsOneWidget);
      expect(find.text('Kho'), findsOneWidget);
      expect(find.text('Duyệt tin'), findsOneWidget);
    });

    testWidgets('Logging in with multiple roles redirects to RoleSelectorScreen', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      await tester.pumpWidget(createTestApp(container));
      await tester.pumpAndSettle();

      // Simulate logging in with both Household and Admin roles
      container.read(authProvider.notifier).login('0987654321', [UserRole.household, UserRole.admin]);
      await tester.pumpAndSettle();

      // Should be on Role Selector Screen
      expect(find.byType(RoleSelectorScreen), findsOneWidget);
      expect(find.text('Chọn vai trò hoạt động'), findsOneWidget);

      // Tap on Admin role to select it
      await tester.tap(find.text('Ban chỉ đạo xã'));
      await tester.pumpAndSettle();

      // Should now redirect to Admin screen
      expect(find.byType(AdminMapScreen), findsOneWidget);
    });
  });
}
