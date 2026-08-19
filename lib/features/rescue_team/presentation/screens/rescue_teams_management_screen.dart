import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/rescue_team_provider.dart';
import '../../domain/rescue_team_model.dart';
import '../../domain/rescue_team_status.dart';

class RescueTeamsManagementScreen extends ConsumerStatefulWidget {
  const RescueTeamsManagementScreen({super.key});

  @override
  ConsumerState<RescueTeamsManagementScreen> createState() => _RescueTeamsManagementScreenState();
}

class _RescueTeamsManagementScreenState extends ConsumerState<RescueTeamsManagementScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedStatusFilter = 'Tất cả';

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

  @override
  Widget build(BuildContext context) {
    final allTeamsAsync = ref.watch(allRescueTeamsStreamProvider);

    return allTeamsAsync.when(
      data: (teams) {
        // Phân loại danh sách
        final permanentTeams = teams.where((t) => t.teamType == RescueTeamKind.permanent && t.isApproved).toList();
        final volunteerTeams = teams.where((t) => t.teamType == RescueTeamKind.volunteer && t.isApproved && t.status != RescueTeamStatus.endShift).toList();
        final pendingTeams = teams.where((t) => !t.isApproved).toList();
        final endedTeams = teams.where((t) => t.status == RescueTeamStatus.endShift && t.isApproved).toList();

        // Danh sách lọc của tab hiện tại
        List<RescueTeamModel> currentList = [];
        if (_tabController.index == 0) {
          currentList = permanentTeams;
        } else if (_tabController.index == 1) {
          currentList = volunteerTeams;
        } else if (_tabController.index == 2) {
          currentList = pendingTeams;
        } else {
          currentList = endedTeams;
        }

        // Áp dụng bộ lọc trạng thái chip (chỉ với Thường trực và Vãng lai)
        if (_tabController.index == 0 || _tabController.index == 1) {
          if (_selectedStatusFilter == 'Sẵn sàng') {
            currentList = currentList.where((t) => t.status == RescueTeamStatus.available).toList();
          } else if (_selectedStatusFilter == 'Đang nhiệm vụ') {
            currentList = currentList.where((t) => t.status == RescueTeamStatus.onMission).toList();
          } else if (_selectedStatusFilter == 'Tạm nghỉ') {
            currentList = currentList.where((t) => t.status == RescueTeamStatus.onBreak).toList();
          } else if (_selectedStatusFilter == 'Mất kết nối') {
            currentList = currentList.where((t) => t.status == RescueTeamStatus.offline).toList();
          }
        }

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
                    '${teams.length} đội',
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
                Tab(text: 'Chờ duyệt (${pendingTeams.length})'),
                const Tab(text: 'Kết thúc'),
              ],
            ),
          ),
          body: Column(
            children: [
              // 1. Thanh Lọc Chip Trạng thái tròn
              if (_tabController.index == 0 || _tabController.index == 1)
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildColorStatusChip('Sẵn sàng', Colors.green.shade700, 
                            (_tabController.index == 0 ? permanentTeams : volunteerTeams).where((t) => t.status == RescueTeamStatus.available).length),
                        _buildColorStatusChip('Đang nhiệm vụ', Colors.blue.shade700, 
                            (_tabController.index == 0 ? permanentTeams : volunteerTeams).where((t) => t.status == RescueTeamStatus.onMission).length),
                        _buildColorStatusChip('Tạm nghỉ', Colors.orange.shade700, 
                            (_tabController.index == 0 ? permanentTeams : volunteerTeams).where((t) => t.status == RescueTeamStatus.onBreak).length),
                        _buildColorStatusChip('Mất kết nối', Colors.grey.shade700, 
                            (_tabController.index == 0 ? permanentTeams : volunteerTeams).where((t) => t.status == RescueTeamStatus.offline).length),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '🏛️ Các đội thường trực biên chế xã đã được kích hoạt tác chiến. Vật tư cơ sở được điều phối trực tiếp bởi cán bộ chỉ huy.',
                        style: TextStyle(color: Colors.blue.shade900, fontSize: 10.5, height: 1.4, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),

              // 3. Danh sách các thẻ Đội cứu hộ
              Expanded(
                child: currentList.isEmpty
                    ? const Center(
                        child: Text(
                          'Không tìm thấy đội cứu hộ nào.',
                          style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        itemCount: currentList.length,
                        itemBuilder: (context, index) {
                          final team = currentList[index];
                          
                          String transportText = '🛶 ${team.boatCount} thuyền/xuồng';
                          if (team.id == 'team_04') {
                            transportText = '1 xe cứu thương';
                          } else if (team.id == 'team_05') {
                            transportText = '2 xe tải cứu trợ';
                          }

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: team.status == RescueTeamStatus.offline ? Colors.grey.shade400 : Colors.grey.shade300,
                                width: team.status == RescueTeamStatus.offline ? 1.5 : 1,
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
                                        color: team.teamType == RescueTeamKind.permanent ? Colors.blue.shade100 : Colors.orange.shade100,
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: Text(
                                        team.teamType == RescueTeamKind.permanent ? 'THƯỜNG TRỰC' : 'VÃNG LAI',
                                        style: TextStyle(
                                          color: team.teamType == RescueTeamKind.permanent ? Colors.blue.shade900 : Colors.orange.shade900,
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
                                      onPressed: () => _editTeam(team),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),

                                Text(
                                  '👥 ${team.memberCount} người · $transportText · SĐT: ${team.contactPhone}',
                                  style: TextStyle(color: Colors.grey.shade700, fontSize: 11),
                                ),
                                const SizedBox(height: 4),

                                Text(
                                  '📦 Lực lượng: Trưởng đội ${team.leaderName}',
                                  style: TextStyle(
                                    color: team.teamType == RescueTeamKind.permanent ? Colors.green.shade800 : Colors.orange.shade800, 
                                    fontSize: 10.5, 
                                    fontWeight: FontWeight.w600
                                  ),
                                ),
                                const SizedBox(height: 10),

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    _buildTeamStatusBadge(team.status),
                                    
                                    if (team.isApproved && team.status != RescueTeamStatus.endShift)
                                      Text(
                                        team.status == RescueTeamStatus.onMission 
                                            ? 'Đang hoạt động ứng cứu ➔' 
                                            : (team.status == RescueTeamStatus.offline ? 'Mất kết nối' : 'Sẵn sàng tác chiến'),
                                        style: TextStyle(
                                          color: team.status == RescueTeamStatus.onMission ? Colors.blue.shade800 : Colors.black54, 
                                          fontSize: 10.5, 
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                  ],
                                ),
                                if (!team.isApproved) ...[
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
                                        onPressed: () async {
                                          await ref.read(rescueTeamRepositoryProvider).rejectVolunteerTeam(team.id);
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
                                        onPressed: () async {
                                          await ref.read(rescueTeamRepositoryProvider).approveVolunteerTeam(team.id);
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('✅ Đã phê duyệt đơn đăng ký của ${team.name}!'), backgroundColor: Colors.green.shade700),
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
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, _) => Scaffold(body: Center(child: Text('Lỗi tải dữ liệu: $err'))),
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

  void _editTeam(RescueTeamModel team) {
    final nameCtrl = TextEditingController(text: team.name);
    final leaderCtrl = TextEditingController(text: team.leaderName);
    final phoneCtrl = TextEditingController(text: team.contactPhone);
    int members = team.memberCount;
    int boats = team.boatCount;
    String status = team.status.name;

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
              TextField(
                controller: leaderCtrl,
                decoration: InputDecoration(
                  labelText: 'Trưởng đội',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                style: const TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneCtrl,
                decoration: InputDecoration(
                  labelText: 'Số điện thoại',
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
                  {'key': 'available', 'label': 'Sẵn sàng'},
                  {'key': 'onMission', 'label': 'Đang nhiệm vụ'},
                  {'key': 'onBreak', 'label': 'Tạm nghỉ'},
                  {'key': 'endShift', 'label': 'Kết thúc ca'},
                  {'key': 'offline', 'label': 'Mất kết nối'},
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
                  onPressed: () async {
                    final updatedTeam = team.copyWith(
                      name: nameCtrl.text,
                      leaderName: leaderCtrl.text,
                      contactPhone: phoneCtrl.text,
                      memberCount: members,
                      boatCount: boats,
                      status: RescueTeamStatus.values.byName(status),
                    );
                    await ref.read(rescueTeamRepositoryProvider).saveRescueTeam(updatedTeam);
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

  Widget _buildTeamStatusBadge(RescueTeamStatus status) {
    Color bg;
    Color fg;
    String text;

    switch (status) {
      case RescueTeamStatus.onMission:
        bg = Colors.blue.shade100;
        fg = Colors.blue.shade900;
        text = 'Đang nhiệm vụ';
        break;
      case RescueTeamStatus.onBreak:
        bg = Colors.orange.shade100;
        fg = Colors.orange.shade900;
        text = 'Tạm nghỉ';
        break;
      case RescueTeamStatus.offline:
        bg = Colors.grey.shade300;
        fg = Colors.grey.shade800;
        text = 'Mất kết nối';
        break;
      case RescueTeamStatus.endShift:
        bg = Colors.grey.shade400;
        fg = Colors.grey.shade900;
        text = 'Đã rút quân';
        break;
      case RescueTeamStatus.available:
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
