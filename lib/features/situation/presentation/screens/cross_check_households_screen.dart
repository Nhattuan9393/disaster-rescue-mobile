import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HouseholdCrossCheckItem {
  final String id;
  final String name;
  final String village;
  final int membersCount;
  final String houseType;
  final List<String> vulnerableGroups;
  final String status; // 'unreachable', 'sos_pending', 'rescuing', 'safe'
  final String durationText;
  final String timestampText;

  const HouseholdCrossCheckItem({
    required this.id,
    required this.name,
    required this.village,
    required this.membersCount,
    required this.houseType,
    required this.vulnerableGroups,
    required this.status,
    required this.durationText,
    required this.timestampText,
  });
}

class CrossCheckHouseholdsScreen extends StatefulWidget {
  const CrossCheckHouseholdsScreen({super.key});

  @override
  State<CrossCheckHouseholdsScreen> createState() => _CrossCheckHouseholdsScreenState();
}

class _CrossCheckHouseholdsScreenState extends State<CrossCheckHouseholdsScreen> {
  String _selectedFilter = 'Tất cả';

  final List<HouseholdCrossCheckItem> _households = const [
    HouseholdCrossCheckItem(
      id: 'hh_01',
      name: 'Nguyễn Văn A',
      village: 'Thôn Pắc Liềng',
      membersCount: 5,
      houseType: 'Cấp 4',
      vulnerableGroups: ['👴 Người già'],
      status: 'unreachable',
      durationText: 'Mất liên lạc — 4h',
      timestampText: '10:30 hôm qua',
    ),
    HouseholdCrossCheckItem(
      id: 'hh_02',
      name: 'Trần Thị B',
      village: 'Thôn Nà Lầu',
      membersCount: 3,
      houseType: 'Cấp 4',
      vulnerableGroups: ['👶 Trẻ em'],
      status: 'sos_pending',
      durationText: 'SOS — Chờ xử lý',
      timestampText: '09:12 hôm nay',
    ),
    HouseholdCrossCheckItem(
      id: 'hh_03',
      name: 'Lý Văn C',
      village: 'Thôn Pắc Liềng',
      membersCount: 7,
      houseType: 'Nhiều tầng',
      vulnerableGroups: ['♿ Khuyết tật'],
      status: 'rescuing',
      durationText: 'Đang cứu',
      timestampText: '09:45 hôm nay',
    ),
    HouseholdCrossCheckItem(
      id: 'hh_04',
      name: 'Hoàng Thị D',
      village: 'Thôn Khe Tiền',
      membersCount: 2,
      houseType: 'Cấp 4',
      vulnerableGroups: ['🤰 Mang thai'],
      status: 'safe',
      durationText: '⛑️ An toàn — đội xác nhận',
      timestampText: '09:50 hôm nay',
    ),
    HouseholdCrossCheckItem(
      id: 'hh_05',
      name: 'Nông Văn Sang',
      village: 'Thôn Pắc Liềng',
      membersCount: 4,
      houseType: 'Cấp 4',
      vulnerableGroups: ['👴 Người già'],
      status: 'unreachable',
      durationText: 'Mất liên lạc — 3h15p',
      timestampText: '06:15 hôm nay',
    ),
    HouseholdCrossCheckItem(
      id: 'hh_06',
      name: 'Vũ Thị Mơ',
      village: 'Thôn Nà Lầu',
      membersCount: 6,
      houseType: 'Cấp 4',
      vulnerableGroups: ['👶 Trẻ em'],
      status: 'unreachable',
      durationText: 'Mất liên lạc — 2h30p',
      timestampText: '07:00 hôm nay',
    ),
  ];

  List<HouseholdCrossCheckItem> get _filteredList {
    if (_selectedFilter == 'An toàn') {
      return _households.where((h) => h.status == 'safe').toList();
    } else if (_selectedFilter == 'SOS') {
      return _households.where((h) => h.status == 'sos_pending').toList();
    } else if (_selectedFilter == 'Mất liên lạc') {
      return _households.where((h) => h.status == 'unreachable').toList();
    } else if (_selectedFilter == 'Đang cứu') {
      return _households.where((h) => h.status == 'rescuing').toList();
    }
    return _households;
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredList;

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
          'Đối chiếu Hộ dân',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        actions: const [
          Center(
            child: Padding(
              padding: EdgeInsets.only(right: 16),
              child: Text(
                '480 hộ',
                style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. Thanh thống kê nhanh 3 thôn (Pắc Liềng, Nà Lầu, Khe Tiền)
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                _buildVillageStatCard('Thôn Pắc Liềng', '45 hộ', 'Mất LL: 8'),
                const SizedBox(width: 8),
                _buildVillageStatCard('Thôn Nà Lầu', '62 hộ', 'Mất LL: 5'),
                const SizedBox(width: 8),
                _buildVillageStatCard('Thôn Khe Tiền', '38 hộ', 'Mất LL: 2'),
              ],
            ),
          ),
          const Divider(height: 1),

          // 2. Thanh Chip lọc trạng thái
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('Tất cả'),
                  _buildFilterChip('Mất liên lạc'),
                  _buildFilterChip('SOS'),
                  _buildFilterChip('Đang cứu'),
                  _buildFilterChip('An toàn'),
                ],
              ),
            ),
          ),

          // 3. Thanh tiêu đề danh sách & Sắp xếp
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.grey.shade200,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      'Sắp xếp: Mất liên lạc giảm dần',
                      style: TextStyle(color: Colors.grey.shade800, fontWeight: FontWeight.w600, fontSize: 11),
                    ),
                    const Icon(Icons.arrow_drop_down, size: 16, color: Colors.grey),
                  ],
                ),
                Text(
                  '${filtered.length} kết quả',
                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                ),
              ],
            ),
          ),

          // 4. Danh sách các thẻ Hộ dân
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(14),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final item = filtered[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            item.name,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
                          ),
                          Text(
                            item.village,
                            style: const TextStyle(color: Colors.grey, fontSize: 11),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      Text(
                        '👨‍👩‍👧 ${item.membersCount} người   🏚️ ${item.houseType}   ${item.vulnerableGroups.join(" ")}',
                        style: TextStyle(color: Colors.grey.shade700, fontSize: 11),
                      ),
                      const SizedBox(height: 10),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildStatusBadge(item.status, item.durationText),
                          Text(
                            item.timestampText,
                            style: const TextStyle(color: Colors.grey, fontSize: 9.5),
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

  Widget _buildVillageStatCard(String villageName, String totalText, String missingText) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(villageName, style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Colors.black87)),
            Text(totalText, style: const TextStyle(fontSize: 9.5, color: Colors.grey)),
            Text(missingText, style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Colors.red)),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
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
          if (val) setState(() => _selectedFilter = label);
        },
      ),
    );
  }

  Widget _buildStatusBadge(String status, String text) {
    Color bg;
    Color fg;

    switch (status) {
      case 'unreachable':
        bg = Colors.grey.shade200;
        fg = Colors.grey.shade800;
        break;
      case 'sos_pending':
        bg = Colors.red.shade100;
        fg = Colors.red.shade900;
        break;
      case 'rescuing':
        bg = Colors.blue.shade100;
        fg = Colors.blue.shade900;
        break;
      case 'safe':
      default:
        bg = Colors.green.shade100;
        fg = Colors.green.shade900;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(color: fg, fontWeight: FontWeight.bold, fontSize: 10.5),
      ),
    );
  }
}
