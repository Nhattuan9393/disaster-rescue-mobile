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

  List<RescueTeamItem> _teams = [
    // 6 đội thường trực
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
      name: 'Đội Y tế xã Bình Liêu',
      category: 'permanent',
      membersCount: 4,
      boatsCount: 0,
      suppliesInfo: '📦 Biên chế: Thiết bị y tế sơ cứu',
      status: 'disconnected',
      statusNote: 'Im lặng 42 phút',
    ),
    RescueTeamItem(
      id: 'team_04_b',
      name: 'Tổ cơ động Thôn Bản Phạt',
      category: 'permanent',
      membersCount: 5,
      boatsCount: 1,
      suppliesInfo: '📦 Biên chế: 5 áo phao',
      status: 'ready',
      statusNote: 'Trực tại nhà văn hóa',
    ),
    RescueTeamItem(
      id: 'team_04_c',
      name: 'Đội Dân quân Khe Tiền',
      category: 'permanent',
      membersCount: 7,
      boatsCount: 1,
      suppliesInfo: '📦 Biên chế: 8 áo phao',
      status: 'on_mission',
      statusNote: 'Tuần tra sạt lở',
    ),

    // 6 đội vãng lai/tình nguyện
    RescueTeamItem(
      id: 'team_05',
      name: 'Hội Chữ thập đỏ Hạ Long',
      category: 'volunteer',
      membersCount: 15,
      boatsCount: 0, // 2 xe tải
      suppliesInfo: '📦 Mang theo: 50 thùng mì, 200 chai nước',
      status: 'ready',
      statusNote: 'Đã duyệt 10:05',
    ),
    RescueTeamItem(
      id: 'team_06',
      name: 'Nhóm Thiện Nguyện Tiên Yên',
      category: 'volunteer',
      membersCount: 5,
      boatsCount: 1,
      suppliesInfo: '📦 Tự trang bị: Nhu yếu phẩm & bánh mì',
      status: 'on_mission',
      statusNote: 'Đang vận chuyển nhu yếu phẩm',
    ),
    RescueTeamItem(
      id: 'team_07',
      name: 'CLB Tình Nguyện Quảng Ninh',
      category: 'volunteer',
      membersCount: 12,
      boatsCount: 3,
      suppliesInfo: '📦 Tự trang bị: 12 áo phao, 3 xuồng máy',
      status: 'ready',
      statusNote: 'Đã điểm danh sẵn sàng',
    ),
    RescueTeamItem(
      id: 'team_08',
      name: 'Đoàn Thanh niên Than Quảng Ninh',
      category: 'volunteer',
      membersCount: 20,
      boatsCount: 2,
      suppliesInfo: '📦 Mang theo: Thiết bị cứu hộ chuyên dụng',
      status: 'on_mission',
      statusNote: 'Hỗ trợ dọn dẹp sạt lở',
    ),
    RescueTeamItem(
      id: 'team_09',
      name: 'Đội xuồng máy tự quản Hải Hà',
      category: 'volunteer',
      membersCount: 6,
      boatsCount: 3,
      suppliesInfo: '📦 Mang theo: 3 xuồng máy lớn',
      status: 'on_mission',
      statusNote: 'Đang sơ tán dân vùng ngập sâu',
    ),
    RescueTeamItem(
      id: 'team_10',
      name: 'Nhóm Thiện Nguyện Cẩm Phả',
      category: 'volunteer',
      membersCount: 8,
      boatsCount: 1,
      suppliesInfo: '📦 Mang theo: 100 suất cơm nóng',
      status: 'resting',
      statusNote: 'Đang chuẩn bị cơm trưa',
    ),
    // Đội chờ duyệt
    RescueTeamItem(
      id: 'team_11',
      name: 'Đội Phản Ứng Nhanh Uông Bí',
      category: 'volunteer',
      membersCount: 10,
      boatsCount: 2,
      suppliesInfo: '📦 Mang theo: 15 áo phao, 2 xuồng cao su',
      status: 'pending',
      statusNote: 'Đăng ký lúc 16:30',
    ),
    RescueTeamItem(
      id: 'team_12',
      name: 'Nhóm cứu hộ xuồng hơi Vân Đồn',
      category: 'volunteer',
      membersCount: 4,
      boatsCount: 1,
      suppliesInfo: '📦 Mang theo: 1 xuồng máy hơi',
      status: 'pending',
      statusNote: 'Đăng ký lúc 16:55',
    ),
    // Đội kết thúc
    RescueTeamItem(
      id: 'team_13',
      name: 'Đội Tình Nguyện Chi Lăng',
      category: 'volunteer',
      membersCount: 8,
      boatsCount: 0,
      suppliesInfo: '📦 Rút quân sau khi nước rút',
      status: 'ended',
      statusNote: 'Kết thúc lúc 09:00',
    ),
    RescueTeamItem(
      id: 'team_14',
      name: 'Đội Ca-nô Phù Cát',
      category: 'volunteer',
      membersCount: 6,
      boatsCount: 2,
      suppliesInfo: '📦 Trở về sau khi hoàn thành bàn giao vật tư',
      status: 'ended',
      statusNote: 'Kết thúc lúc 10:15',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<RescueTeamItem> get _filteredTeams {
    final catIndex = _tabController.index;
    if (catIndex == 2) {
      return _teams.where((t) => t.status == 'pending').toList();
    } else if (catIndex == 3) {
      return _teams.where((t) => t.status == 'ended').toList();
    }

    String targetCat = 'permanent';
    if (catIndex == 1) targetCat = 'volunteer';

    List<RescueTeamItem> list = _teams.where((t) => t.status != 'pending' && t.status != 'ended').toList();
    list = list.where((t) => t.category == targetCat).toList();

    if (_selectedStatusFilter == 'Sẵn sàng') {
      return list.where((t) => t.status == 'ready').toList();
    } else if (_selectedStatusFilter == 'Đang nhiệm vụ') {
      return list.where((t) => t.status == 'on_mission').toList();
    } else if (_selectedStatusFilter == 'Tạm nghỉ') {
      return list.where((t) => t.status == 'resting').toList();
    } else if (_selectedStatusFilter == 'Mất kết nối') {
      return list.where((t) => t.status == 'disconnected').toList();
    }
    return list;
  }


  int _getStatusCount(String status) {
    final catIndex = _tabController.index;
    String targetCat = 'permanent';
    if (catIndex == 1) targetCat = 'volunteer';
    
    List<RescueTeamItem> list = _teams.where((t) => t.status != 'pending' && t.status != 'ended').toList();
    if (catIndex == 0 || catIndex == 1) {
      list = list.where((t) => t.category == targetCat).toList();
    }
    return list.where((t) => t.status == status).toList().length;
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
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                '${_teams.length} đội',
                style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 13),
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
          tabs: [
            const Tab(text: 'Thường trực'),
            const Tab(text: 'Vãng lai'),
            Tab(text: 'Chờ duyệt (${_teams.where((t) => t.status == 'pending').length})'),
            const Tab(text: 'Kết thúc'),
          ],
        ),
      ),
      body: Column(
        children: [
          // 1. Thanh Lọc Chip Trạng thái tròn, màu sắc giống Ảnh 4 (chỉ hiện ở tab 0, 1)
          if (_tabController.index == 0 || _tabController.index == 1)
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildColorStatusChip('Sẵn sàng', Colors.green.shade700, _getStatusCount('ready')),
                    _buildColorStatusChip('Đang nhiệm vụ', Colors.blue.shade700, _getStatusCount('on_mission')),
                    _buildColorStatusChip('Tạm nghỉ', Colors.orange.shade700, _getStatusCount('resting')),
                    _buildColorStatusChip('Mất kết nối', Colors.grey.shade700, _getStatusCount('disconnected')),
                  ],
                ),
              ),
            ),

          const Divider(height: 1),

          // 2. Banner Thông tin Đội Thường trực + Link quản lý chuẩn bị
          if (_tabController.index == 0)
            GestureDetector(
              onTap: () => context.push('/permanent-forces'),
              child: Container(
                margin: const EdgeInsets.all(14),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '🏛️ 5 đội thường trực — biên chế xã, đã kích hoạt. Không cần đăng ký lại mỗi đợt. Vật tư biên chế được tính vào tổng vật tư khả dụng của xã.',
                      style: TextStyle(color: Colors.blue.shade900, fontSize: 10.5, height: 1.4, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.settings, size: 13, color: Colors.blue.shade900),
                        const SizedBox(width: 4),
                        Text(
                          'Quản lý danh sách & Kích hoạt lực lượng chuẩn bị thiên tai ➔',
                          style: TextStyle(color: Colors.blue.shade900, fontSize: 10, fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

          // 3. Danh sách các thẻ Đội cứu hộ
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final team = filtered[index];
                
                // Trực chiến xe cộ đặc biệt
                String transportText = '🛶 ${team.boatsCount} thuyền/xuồng';
                if (team.id == 'team_04') {
                  transportText = '1 xe cứu thương';
                } else if (team.id == 'team_05') {
                  transportText = '2 xe tải';
                }

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: team.status == 'disconnected' ? Colors.grey.shade400 : Colors.grey.shade300,
                      width: team.status == 'disconnected' ? 1.5 : 1,
                    ),
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
                              color: team.category == 'permanent' ? Colors.blue.shade100 : Colors.orange.shade100,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              team.category == 'permanent' ? 'THƯỜNG TRỰC' : 'VÃNG LAI',
                              style: TextStyle(
                                color: team.category == 'permanent' ? Colors.blue.shade900 : Colors.orange.shade900,
                                fontWeight: FontWeight.bold,
                                fontSize: 9.5,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          IconButton(
                            icon: Icon(Icons.edit_outlined, size: 18, color: Colors.grey.shade500),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () {
                              if (team.category == 'permanent') {
                                context.push('/rescue-team-detail-admin');
                              } else {
                                _editTeam(team);
                              }
                            },
                          ),

                        ],
                      ),
                      const SizedBox(height: 6),

                      Text(
                        '👥 ${team.membersCount} người · $transportText' + 
                        (team.id == 'team_05' ? ' · đã duyệt 10:05' : ''),
                        style: TextStyle(color: Colors.grey.shade700, fontSize: 11),
                      ),
                      const SizedBox(height: 4),

                      Text(
                        team.suppliesInfo,
                        style: TextStyle(
                          color: team.category == 'permanent' ? Colors.green.shade800 : Colors.orange.shade800, 
                          fontSize: 10.5, 
                          fontWeight: FontWeight.w600
                        ),
                      ),
                      const SizedBox(height: 10),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,

                        children: [
                          _buildTeamStatusBadge(team.status),
                          
                          // Nhãn Xem chi tiết hoặc note thời gian theo Ảnh 4 (chỉ hiện khi đang hoạt động)
                          if (team.status != 'pending' && team.status != 'ended')
                            GestureDetector(
                              onTap: () {
                                if (team.category == 'permanent') {
                                  context.push('/rescue-team-detail-admin');
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('🔍 Xem chi tiết hoạt động của ${team.name}')),
                                  );
                                }
                              },
                              child: Text(
                                team.status == 'on_mission' 
                                    ? 'Xem chi tiết ➔' 
                                    : (team.status == 'disconnected' ? 'Im lặng 42 phút' : team.statusNote),
                                style: TextStyle(
                                  color: team.status == 'on_mission' ? Colors.blue.shade800 : Colors.black54, 
                                  fontSize: 10.5, 
                                  fontWeight: FontWeight.bold,
                                  decoration: team.status == 'on_mission' ? TextDecoration.underline : TextDecoration.none,
                                ),
                              ),
                            ),
                        ],
                      ),
                      if (team.status == 'pending') ...[
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red.shade800,
                                side: BorderSide(color: Colors.red.shade300),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                              ),
                              onPressed: () {
                                setState(() {
                                  _teams.removeWhere((t) => t.id == team.id);
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('❌ Đã từ chối đơn đăng ký của ${team.name}'), backgroundColor: Colors.red.shade800),
                                );
                              },
                              child: const Text('Từ chối', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green.shade800,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                elevation: 0,
                              ),
                              onPressed: () {
                                setState(() {
                                  final idx = _teams.indexWhere((t) => t.id == team.id);
                                  if (idx >= 0) {
                                    _teams[idx] = RescueTeamItem(
                                      id: team.id,
                                      name: team.name,
                                      category: 'volunteer',
                                      membersCount: team.membersCount,
                                      boatsCount: team.boatsCount,
                                      suppliesInfo: team.suppliesInfo,
                                      status: 'ready',
                                      statusNote: 'Sẵn sàng',
                                    );
                                  }
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('✅ Đã phê duyệt đội: ${team.name}'), backgroundColor: Colors.green.shade700),
                                );
                              },
                              child: const Text('Phê duyệt', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ],
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

  Widget _buildColorStatusChip(String label, Color color, int count) {
    final isSelected = _selectedStatusFilter == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedStatusFilter = 'Tất cả';
          } else {
            _selectedStatusFilter = label;
          }
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: 1.2,
          ),
          boxShadow: isSelected ? [
            BoxShadow(color: color.withOpacity(0.3), blurRadius: 4, offset: const Offset(0, 2))
          ] : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white.withOpacity(0.2) : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey.shade700,
                  fontSize: 9.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  void _editTeam(RescueTeamItem team) {
    final nameCtrl = TextEditingController(text: team.name);
    int members = team.membersCount;
    int boats = team.boatsCount;
    String status = team.status;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx2, setSheetState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 16, right: 16, top: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('CHỈNH SỬA ĐỘI', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Colors.grey, letterSpacing: 0.5)),
              const SizedBox(height: 12),
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(
                  labelText: 'Tên đội',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                style: const TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Nhân sự', style: TextStyle(fontSize: 10.5, color: Colors.grey)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () { if (members > 1) setSheetState(() => members--); },
                              child: Container(width: 32, height: 32, decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(8)), child: const Center(child: Text('−', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)))),
                            ),
                            Expanded(child: Center(child: Text('$members', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)))),
                            GestureDetector(
                              onTap: () => setSheetState(() => members++),
                              child: Container(width: 32, height: 32, decoration: BoxDecoration(color: Colors.blue.shade700, borderRadius: BorderRadius.circular(8)), child: const Center(child: Text('+', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)))),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Thuyền/Xuồng', style: TextStyle(fontSize: 10.5, color: Colors.grey)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () { if (boats > 0) setSheetState(() => boats--); },
                              child: Container(width: 32, height: 32, decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(8)), child: const Center(child: Text('−', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)))),
                            ),
                            Expanded(child: Center(child: Text('$boats', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)))),
                            GestureDetector(
                              onTap: () => setSheetState(() => boats++),
                              child: Container(width: 32, height: 32, decoration: BoxDecoration(color: Colors.blue.shade700, borderRadius: BorderRadius.circular(8)), child: const Center(child: Text('+', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)))),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text('TRẠNG THÁI', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Colors.grey, letterSpacing: 0.5)),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                children: [
                  {'key': 'ready', 'label': 'Sẵn sàng'},
                  {'key': 'on_mission', 'label': 'Đang nhiệm vụ'},
                  {'key': 'resting', 'label': 'Tạm nghỉ'},
                  {'key': 'disconnected', 'label': 'Mất kết nối'},
                ].map((s) {
                  final isSel = status == s['key'];
                  return ChoiceChip(
                    label: Text(s['label']!),
                    selected: isSel,
                    selectedColor: Colors.blue.shade100,
                    labelStyle: TextStyle(color: isSel ? Colors.blue.shade900 : Colors.black87, fontWeight: isSel ? FontWeight.bold : FontWeight.normal, fontSize: 11),
                    onSelected: (v) { if (v) setSheetState(() => status = s['key']!); },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade800, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), elevation: 0),
                  onPressed: () {
                    setState(() {
                      final idx = _teams.indexWhere((t) => t.id == team.id);
                      if (idx >= 0) {
                        _teams[idx] = RescueTeamItem(
                          id: team.id,
                          name: nameCtrl.text,
                          category: team.category,
                          membersCount: members,
                          boatsCount: boats,
                          suppliesInfo: team.suppliesInfo,
                          status: status,
                          statusNote: team.statusNote,
                        );
                      }
                    });
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('✅ Đã cập nhật thông tin đội: ${nameCtrl.text}'), backgroundColor: Colors.green.shade700),
                    );
                  },
                  child: const Text('LƯU THAY ĐỔI', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13)),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
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
      case 'disconnected':
        bg = Colors.grey.shade300;
        fg = Colors.grey.shade800;
        text = 'Mất kết nối';
        break;
      case 'pending':
        bg = Colors.orange.shade100;
        fg = Colors.orange.shade900;
        text = 'Chờ duyệt';
        break;
      case 'ended':
        bg = Colors.grey.shade400;
        fg = Colors.grey.shade900;
        text = 'Đã rút quân';
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
