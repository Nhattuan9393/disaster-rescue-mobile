import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RescueTeamItem {
  final String id;
  final String name;
  final String category; // 'permanent', 'volunteer'
  final int membersCount;
  final int boatsCount;
  final String suppliesInfo;
  final String status; // 'ready', 'on_mission', 'resting', 'disconnected'
  final String statusNote;

  const RescueTeamItem({
    required this.id,
    required this.name,
    required this.category,
    required this.membersCount,
    required this.boatsCount,
    required this.suppliesInfo,
    required this.status,
    required this.statusNote,
  });
}

class RescueTeamsManagementScreen extends StatefulWidget {
  const RescueTeamsManagementScreen({super.key});

  @override
  State<RescueTeamsManagementScreen> createState() => _RescueTeamsManagementScreenState();
}

class _RescueTeamsManagementScreenState extends State<RescueTeamsManagementScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedStatusFilter = 'Tất cả';

  final List<RescueTeamItem> _teams = const [
    RescueTeamItem(
      id: 'team_01',
      name: 'Đội Dân quân Thôn Pắc Liềng',
      category: 'permanent',
      membersCount: 8,
      boatsCount: 2,
      suppliesInfo: '📦 Biên chế: 10 áo phao, 4 đèn pin',
      status: 'on_mission',
      statusNote: 'Đang ứng cứu SOS #DR-2025-0042',
    ),
    RescueTeamItem(
      id: 'team_02',
      name: 'Tổ Xung kích Nà Lầu',
      category: 'permanent',
      membersCount: 6,
      boatsCount: 1,
      suppliesInfo: '📦 Biên chế: 6 áo phao, 1 máy phát',
      status: 'resting',
      statusNote: 'Quay lại 14:00 — hồi sức',
    ),
    RescueTeamItem(
      id: 'team_03',
      name: 'Đội Cứu Hộ Công An Xã',
      category: 'permanent',
      membersCount: 10,
      boatsCount: 2,
      suppliesInfo: '📦 Biên chế: 15 áo phao, 2 máy đàm, 1 canô',
      status: 'ready',
      statusNote: 'Sẵn sàng xuất phát',
    ),
    RescueTeamItem(
      id: 'team_04',
      name: 'CLB Tình Nguyện Quảng Ninh',
      category: 'volunteer',
      membersCount: 12,
      boatsCount: 3,
      suppliesInfo: '📦 Tự trang bị: 12 áo phao, 3 xuồng máy',
      status: 'ready',
      statusNote: 'Đã điểm danh sẵn sàng',
    ),
    RescueTeamItem(
      id: 'team_05',
      name: 'Nhóm Thiện Nguyện Tiên Yên',
      category: 'volunteer',
      membersCount: 5,
      boatsCount: 1,
      suppliesInfo: '📦 Tự trang bị: Nhu yếu phẩm & bánh mì',
      status: 'on_mission',
      statusNote: 'Đang vận chuyển nhu yếu phẩm',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<RescueTeamItem> get _filteredTeams {
    final catIndex = _tabController.index;
    String targetCat = 'permanent';
    if (catIndex == 1) targetCat = 'volunteer';

    List<RescueTeamItem> list = _teams;
    if (catIndex == 0 || catIndex == 1) {
      list = list.where((t) => t.category == targetCat).toList();
    }

    if (_selectedStatusFilter == 'Sẵn sàng') {
      return list.where((t) => t.status == 'ready').toList();
    } else if (_selectedStatusFilter == 'Đang nhiệm vụ') {
      return list.where((t) => t.status == 'on_mission').toList();
    } else if (_selectedStatusFilter == 'Tạm nghỉ') {
      return list.where((t) => t.status == 'resting').toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredTeams;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Lực lượng Cứu hộ',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        actions: const [
          Center(
            child: Padding(
              padding: EdgeInsets.only(right: 16),
              child: Text(
                '12 đội',
                style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.blue.shade900,
          unselectedLabelColor: Colors.grey,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          indicatorColor: Colors.blue.shade900,
          onTap: (_) => setState(() {}),
          tabs: const [
            Tab(text: 'Thường trực'),
            Tab(text: 'Vãng lai'),
            Tab(text: 'Chờ duyệt (4)'),
            Tab(text: 'Kết thúc'),
          ],
        ),
      ),
      body: Column(
        children: [
          // 1. Thanh Lọc Chip Trạng thái
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildStatusChip('Tất cả'),
                  _buildStatusChip('Sẵn sàng'),
                  _buildStatusChip('Đang nhiệm vụ'),
                  _buildStatusChip('Tạm nghỉ'),
                ],
              ),
            ),
          ),
          const Divider(height: 1),

          // 2. Banner Thông tin Đội Thường trực
          if (_tabController.index == 0)
            Container(
              margin: const EdgeInsets.all(14),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Text(
                '🏛️ 5 đội thường trực — biên chế xã, đã kích hoạt. Không cần đăng ký lại mỗi đợt. Vật tư biên chế được tính vào tổng vật tư khả dụng của xã.',
                style: TextStyle(color: Colors.blue.shade900, fontSize: 11, height: 1.4, fontWeight: FontWeight.w600),
              ),
            ),

          // 3. Danh sách các thẻ Đội cứu hộ
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final team = filtered[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              team.name,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: Colors.black87),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              color: team.category == 'permanent' ? Colors.blue.shade100 : Colors.purple.shade100,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              team.category == 'permanent' ? 'THƯỜNG TRỰC' : 'TÌNH NGUYỆN',
                              style: TextStyle(
                                color: team.category == 'permanent' ? Colors.blue.shade900 : Colors.purple.shade900,
                                fontWeight: FontWeight.bold,
                                fontSize: 9.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      Text(
                        '👥 ${team.membersCount} người · 🛶 ${team.boatsCount} thuyền/xuồng',
                        style: TextStyle(color: Colors.grey.shade700, fontSize: 11),
                      ),
                      const SizedBox(height: 4),

                      Text(
                        team.suppliesInfo,
                        style: TextStyle(color: Colors.green.shade800, fontSize: 10.5, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 10),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildTeamStatusBadge(team.status),
                          Text(
                            team.statusNote,
                            style: const TextStyle(color: Colors.black54, fontSize: 10.5, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String label) {
    final isSelected = _selectedStatusFilter == label;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: ChoiceChip(
        selected: isSelected,
        label: Text(label),
        selectedColor: Colors.blue.shade100,
        labelStyle: TextStyle(
          color: isSelected ? Colors.blue.shade900 : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 11,
        ),
        onSelected: (val) {
          if (val) setState(() => _selectedStatusFilter = label);
        },
      ),
    );
  }

  Widget _buildTeamStatusBadge(String status) {
    Color bg;
    Color fg;
    String text;

    switch (status) {
      case 'on_mission':
        bg = Colors.blue.shade100;
        fg = Colors.blue.shade900;
        text = 'Đang nhiệm vụ';
        break;
      case 'resting':
        bg = Colors.orange.shade100;
        fg = Colors.orange.shade900;
        text = 'Tạm nghỉ';
        break;
      case 'ready':
      default:
        bg = Colors.green.shade100;
        fg = Colors.green.shade900;
        text = 'Sẵn sàng';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(text, style: TextStyle(color: fg, fontWeight: FontWeight.bold, fontSize: 10.5)),
    );
  }
}
