import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import 'package:flutter_map/flutter_map.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/widgets/map_widget.dart';
import '../../../../core/widgets/app_drawer.dart';
import '../providers/sos_provider.dart';
import '../../domain/sos_model.dart';
import '../../domain/sos_status.dart';
import '../../data/sos_sync_service.dart';
import '../../../rescue_team/presentation/providers/rescue_team_provider.dart';
import '../../../rescue_team/domain/rescue_team_model.dart';
import '../../../rescue_team/domain/rescue_team_status.dart';
import '../../../situation/presentation/screens/cross_check_households_screen.dart';
import '../../../rescue_team/presentation/screens/rescue_teams_management_screen.dart';
import '../../../logistics/presentation/screens/warehouse_management_screen.dart';
import '../../../logistics/presentation/screens/event_logs_screen.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  int _currentTab = 0; // 0: Bản đồ, 1: Đối chiếu, 2: Lực lượng, 3: Kho, 4: Nhật ký
  SosRequestEntity? _selectedSos;
  String? _selectedTeamId;

  // Tọa độ trung tâm Bình Liêu, Quảng Ninh
  final LatLng _binhLieuCenter = const LatLng(21.5284, 107.3986);

  @override
  Widget build(BuildContext context) {
    final sosRequestsAsync = ref.watch(allSosRequestsStreamProvider);
    final markersAsync = ref.watch(sosMarkersProvider);
    final availableTeamsAsync = ref.watch(availableRescueTeamsProvider);
    final allTeamsAsync = ref.watch(allRescueTeamsStreamProvider);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        
        final shouldExit = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: const [
                Icon(Icons.exit_to_app, color: Colors.red),
                SizedBox(width: 8),
                Text('Thoát ứng dụng', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              ],
            ),
            content: const Text('Bạn có chắc chắn muốn thoát khỏi ứng dụng DisasterRescue?', style: TextStyle(fontSize: 12)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade800),
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Thoát', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );

        if (shouldExit == true) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF9F9FB),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.5,
          leading: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu, color: Colors.black87),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          title: const Text(
            'Admin Xã — Ban Chỉ Huy',
            style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        drawer: const AppDrawer(),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: 0, // Màn hình này luôn hiển thị Bản đồ nền
          selectedItemColor: const Color(0xFFD32F2F),
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
          unselectedLabelStyle: const TextStyle(fontSize: 11),
          onTap: (index) {
            if (index == 0) return;
            switch (index) {
              case 1:
                context.push('/cross-check');
                break;
              case 2:
                context.push('/rescue-teams');
                break;
              case 3:
                context.push('/warehouse');
                break;
              case 4:
                context.push('/event-logs');
                break;
            }
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Bản đồ'),
            BottomNavigationBarItem(icon: Icon(Icons.compare_arrows), label: 'Đối chiếu'),
            BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Lực lượng'),
            BottomNavigationBarItem(icon: Icon(Icons.inventory_2), label: 'Kho'),
            BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Leo thang & NK'),
          ],
        ),
        body: _buildMapTab(
          sosRequestsAsync,
          markersAsync,
          availableTeamsAsync,
        ),
      ),
    );
  }


  Widget _buildTabContent(
    AsyncValue<List<SosRequestEntity>> sosRequestsAsync,
    AsyncValue<List<Marker>> markersAsync,
    AsyncValue<List<RescueTeamModel>> availableTeamsAsync,
    AsyncValue<List<RescueTeamModel>> allTeamsAsync,
  ) {
    switch (_currentTab) {
      case 0:
        return _buildMapTab(sosRequestsAsync, markersAsync, availableTeamsAsync);
      case 1:
        return const CrossCheckHouseholdsScreen();
      case 2:
        return const RescueTeamsManagementScreen();
      case 3:
        return const WarehouseManagementScreen();
      case 4:
      default:
        return const EventLogsScreen();
    }
  }

  // TAB 1: BẢN ĐỒ TOÀN MÀN HÌNH + WIDGET NỔI + BOTTOM SHEET
  Widget _buildMapTab(
    AsyncValue<List<SosRequestEntity>> sosRequestsAsync,
    AsyncValue<List<Marker>> markersAsync,
    AsyncValue<List<RescueTeamModel>> availableTeamsAsync,
  ) {
    return Stack(
      children: [
        // A. Bản đồ nền toàn màn hình
        Positioned.fill(
          child: markersAsync.when(
            data: (markers) => CoreMapWidget(
              center: _binhLieuCenter,
              zoom: 13.0,
              markers: markers,
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(child: Text('Lỗi tải bản đồ: $err')),
          ),
        ),

        // B. Hàng chỉ số nổi ở phía trên (Top Overlay stats)
        Positioned(
          top: 12,
          left: 12,
          right: 12,
          child: sosRequestsAsync.when(
            data: (requests) {
              final pending = requests.where((r) => r.status == SosStatus.pending).length;
              final onMission = requests.where((r) => r.status == SosStatus.assigned || r.status == SosStatus.inProgress).length;
              final completed = requests.where((r) => r.status == SosStatus.completed).length;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => context.push('/cross-check'),
                        child: _buildStatCard('${pending + 2}', 'SOS chờ', const Color(0xFFC62828)),
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () => context.push('/cross-check'),
                        child: _buildStatCard('$onMission', 'Đang cứu', Colors.orange.shade800),
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () => context.push('/cross-check'),
                        child: _buildStatCard('${completed + 18}', 'Đã cứu', Colors.green.shade800),
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () => context.push('/cross-check'),
                        child: _buildStatCard('8', 'Mất LL', Colors.grey.shade700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: () => context.push('/situation-board'),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2)),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle_outline, color: Colors.green, size: 16),
                          SizedBox(width: 6),
                          Text(
                            '280/480 hộ an toàn — Bấm xem Bảng tình hình ➔',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ),

        // C. Các nút nổi ở góc phải (Right Overlay Actions)
        Positioned(
          right: 12,
          top: 120,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildFloatingAction('Tạo SOS thay', Icons.add_alert, const Color(0xFFC62828)),
              _buildFloatingAction('Duyệt báo cáo (4)', Icons.verified_user, Colors.green.shade700, onPressed: () => context.push('/verify-reports')),
              _buildFloatingAction('Phát lệnh sơ tán', Icons.campaign, Colors.orange.shade800, onPressed: () => context.push('/broadcast-evacuation')),
              _buildFloatingAction('Điểm sơ tán', Icons.night_shelter, Colors.teal.shade800, onPressed: () => context.push('/evacuation-points?role=admin')),
              _buildFloatingAction('Leo thang', Icons.notification_important, Colors.red.shade900, onPressed: () => context.push('/escalate-district')),
              _buildFloatingAction('Import dân cư', Icons.upload_file, Colors.blue.shade800, onPressed: () => context.push('/bulk-import')),
            ],
          ),
        ),

        // D. Khung danh sách SOS / Gán đội nổi dưới chân bản đồ (nếu chưa chọn SOS)
        if (_selectedSos == null)
          Positioned(
            bottom: 12,
            left: 12,
            right: 12,
            child: Container(
              height: 110,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 10, offset: const Offset(0, 2)),
                ],
              ),
              padding: const EdgeInsets.all(12),
              child: sosRequestsAsync.when(
                data: (requests) {
                  final active = requests.where((r) => r.status == SosStatus.pending || r.status == SosStatus.assigned).toList();
                  if (active.isEmpty) {
                    return const Center(
                      child: Text(
                        'Không có yêu cầu SOS chờ xử lý',
                        style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                      ),
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Danh sách SOS chờ xử lý:',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFFC62828)),
                      ),
                      const SizedBox(height: 6),
                      Expanded(
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: active.length,
                          itemBuilder: (context, index) {
                            final sos = active[index];
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedSos = sos;
                                  _selectedTeamId = null;
                                });
                                _showAssignBottomSheet(context, availableTeamsAsync);
                              },
                              onLongPress: () => context.push('/household-detail-admin'),
                              child: Container(
                                margin: const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFEBEE),
                                  border: Border.all(color: const Color(0xFFFFCDD2)),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Hộ: ${sos.householdId}',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFFC62828)),
                                    ),
                                    Text(
                                      'Điểm: ${sos.priorityScore}',
                                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 2),
                                    GestureDetector(
                                      onTap: () => context.push('/household-detail-admin'),
                                      child: const Text('👤 Xem hộ dân', style: TextStyle(fontSize: 10, color: Colors.blue, decoration: TextDecoration.underline)),
                                    ),
                                  ],
                                ),
                              ),
                            );

                          },
                        ),
                      )
                    ],
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Text('Lỗi: $err'),
              ),
            ),
          )
      ],
    );
  }

  Widget _buildStatCard(String val, String label, Color color) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 4, offset: const Offset(0, 2)),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Column(
          children: [
            Text(
              val,
              style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 18),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingAction(String label, IconData icon, Color color, {VoidCallback? onPressed}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: color,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: color.withOpacity(0.2)),
          ),
        ),
        icon: Icon(icon, size: 16),
        label: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.black87),
        ),
        onPressed: onPressed ?? () {},
      ),
    );
  }

  // BOTTOM SHEET PHÂN CÔNG ĐỘI CỨU HỘ
  void _showAssignBottomSheet(
    BuildContext context,
    AsyncValue<List<RescueTeamModel>> availableTeamsAsync,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            if (_selectedSos == null) return const SizedBox.shrink();

            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'ĐIỀU PHỐI CỨU NẠN: ${_selectedSos!.id.substring(0, 8)}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFFC62828)),
                  ),
                  const SizedBox(height: 12),
                  Text('Hộ dân ID: ${_selectedSos!.householdId}'),
                  Text('Điểm ưu tiên: ${_selectedSos!.priorityScore} / 100'),
                  const SizedBox(height: 16),
                  
                  // Dropdown chọn đội
                  availableTeamsAsync.when(
                    data: (teams) {
                      if (teams.isEmpty) {
                        return const Text(
                          'Không có đội cứu hộ nào rảnh (status: available) lúc này!',
                          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                        );
                      }

                      return DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Chọn Đội Cứu Hộ Rảnh',
                          border: OutlineInputBorder(),
                        ),
                        value: _selectedTeamId,
                        items: teams.map((team) {
                          return DropdownMenuItem<String>(
                            value: team.id,
                            child: Text('${team.name}'),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setModalState(() {
                            _selectedTeamId = val;
                          });
                        },
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (err, _) => Text('Lỗi: $err'),
                  ),
                  const SizedBox(height: 20),

                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD32F2F),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    icon: const Icon(Icons.assignment_ind),
                    label: const Text('GÁN ĐỘI CỨU HỘ'),
                    onPressed: _selectedTeamId == null
                        ? null
                        : () async {
                            try {
                              final repo = ref.read(sosRepositoryProvider);
                              await repo.assignRescueTeam(
                                _selectedSos!.id,
                                _selectedTeamId!,
                              );

                              if (context.mounted) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Đã gán đội cứu hộ thành công!'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }

                              setState(() {
                                _selectedSos = null;
                                _selectedTeamId = null;
                              });
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Lỗi: ${e.toString()}'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      setState(() {
        _selectedSos = null;
        _selectedTeamId = null;
      });
    });
  }

  // TAB 3: LỰC LƯỢNG CỨU HỘ TRỰC THUỘC (CỬA SỔ SỐ 13)
  Widget _buildRescueTeamsTab(AsyncValue<List<RescueTeamModel>> allTeamsAsync) {
    return allTeamsAsync.when(
      data: (teams) {
        if (teams.isEmpty) {
          return const Center(child: Text('Chưa có đội cứu hộ nào đăng ký trực thuộc'));
        }

        final permanent = teams.where((t) => t.id.startsWith('team_binh_lieu')).toList();
        final volunteer = teams.where((t) => !t.id.startsWith('team_binh_lieu')).toList();

        return DefaultTabController(
          length: 2,
          child: Column(
            children: [
              const TabBar(
                labelColor: Color(0xFFD32F2F),
                unselectedLabelColor: Colors.grey,
                indicatorColor: Color(0xFFD32F2F),
                tabs: [
                  Tab(text: 'LỰC LƯỢNG THƯỜNG TRỰC'),
                  Tab(text: 'ĐỘI VÃNG LAI / MTQ'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _buildTeamListView(permanent),
                    _buildTeamListView(volunteer),
                  ],
                ),
              )
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Lỗi: $err')),
    );
  }

  Widget _buildTeamListView(List<RescueTeamModel> teams) {
    if (teams.isEmpty) {
      return const Center(child: Text('Trống', style: TextStyle(color: Colors.grey)));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: teams.length,
      itemBuilder: (context, index) {
        final team = teams[index];
        Color statusColor;
        switch (team.status) {
          case RescueTeamStatus.available:
            statusColor = Colors.green;
            break;
          case RescueTeamStatus.onMission:
            statusColor = Colors.orange;
            break;
          case RescueTeamStatus.offline:
            statusColor = Colors.grey;
            break;
        }

        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: statusColor.withOpacity(0.1),
              child: Icon(Icons.local_shipping, color: statusColor),
            ),
            title: Text(team.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Đội trưởng: ${team.leaderName} | ĐT: ${team.contactPhone}'),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                team.status.name.toUpperCase(),
                style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 10),
              ),
            ),
          ),
        );
      },
    );
  }

  // TAB 5: NHẬT KÝ SỰ KIỆN CỨU HỘ REALTIME (DR-032)
  Widget _buildEventLogsTab() {
    final logsStream = FirebaseFirestore.instance
        .collection('event_logs')
        .orderBy('timestamp', descending: true)
        .snapshots();

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: logsStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Lỗi tải nhật ký: ${snapshot.error}'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return const Center(child: Text('Chưa có hoạt động cứu nạn nào được ghi nhận.'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data();
            final action = data['action'] as String?;
            final message = data['message'] as String? ?? '';
            final timestampStr = data['timestamp'] as String? ?? '';
            final time = DateTime.tryParse(timestampStr) ?? DateTime.now();

            IconData logIcon;
            Color logColor;

            switch (action) {
              case 'create':
                logIcon = Icons.warning_amber_rounded;
                logColor = Colors.red;
                break;
              case 'assign':
                logIcon = Icons.assignment_ind;
                logColor = Colors.orange;
                break;
              case 'accept':
                logIcon = Icons.directions_run;
                logColor = Colors.blue;
                break;
              case 'complete':
                logIcon = Icons.check_circle;
                logColor = Colors.green;
                break;
              default:
                logIcon = Icons.info_outline;
                logColor = Colors.grey;
            }

            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: logColor.withOpacity(0.1),
                  child: Icon(logIcon, color: logColor),
                ),
                title: Text(message, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                subtitle: Text('Thời gian: ${time.hour}:${time.minute}:${time.second} | SOS: ${data['sosId']?.toString().substring(0, 8)}'),
              ),
            );
          },
        );
      },
    );
  }
}
