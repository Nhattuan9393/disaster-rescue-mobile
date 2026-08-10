import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AdminHouseholdListItem {
  final String id;
  final String name;
  final String phone;
  final String village;
  final int membersCount;
  final String houseType;
  final List<String> tags;

  const AdminHouseholdListItem({
    required this.id,
    required this.name,
    required this.phone,
    required this.village,
    required this.membersCount,
    required this.houseType,
    required this.tags,
  });
}

class AdminHouseholdsListScreen extends StatefulWidget {
  const AdminHouseholdsListScreen({super.key});

  @override
  State<AdminHouseholdsListScreen> createState() => _AdminHouseholdsListScreenState();
}

class _AdminHouseholdsListScreenState extends State<AdminHouseholdsListScreen> {
  String _searchQuery = '';
  String _selectedTag = 'Tất cả';

  final List<AdminHouseholdListItem> _allHouseholds = const [
    AdminHouseholdListItem(
      id: 'hh_01',
      name: 'Nguyễn Văn A',
      phone: '0912.345.678',
      village: 'Thôn Pắc Liềng',
      membersCount: 5,
      houseType: 'Cấp 4 — Trũng thấp',
      tags: ['👴 Người già', '👶 Trẻ em'],
    ),
    AdminHouseholdListItem(
      id: 'hh_02',
      name: 'Trần Thị B',
      phone: '0988.112.233',
      village: 'Thôn Nà Lầu',
      membersCount: 3,
      houseType: 'Cấp 4',
      tags: ['👶 Trẻ em'],
    ),
    AdminHouseholdListItem(
      id: 'hh_03',
      name: 'Lý Văn C',
      phone: '0977.445.566',
      village: 'Thôn Pắc Liềng',
      membersCount: 7,
      houseType: 'Nhiều tầng',
      tags: ['♿ Khuyết tật'],
    ),
    AdminHouseholdListItem(
      id: 'hh_04',
      name: 'Hoàng Thị D',
      phone: '0933.998.877',
      village: 'Thôn Khe Tiền',
      membersCount: 2,
      houseType: 'Cấp 4 — Trũng thấp',
      tags: ['🤰 Mang thai'],
    ),
  ];

  List<AdminHouseholdListItem> get _filteredHouseholds {
    return _allHouseholds.where((h) {
      final matchesSearch = h.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          h.village.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          h.phone.contains(_searchQuery);
      if (_selectedTag == 'Tất cả') return matchesSearch;
      return matchesSearch && h.tags.any((t) => t.contains(_selectedTag));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final list = _filteredHouseholds;

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
          'Danh sách 480 Hộ Dân Xã',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      body: Column(
        children: [
          // 1. Search Bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                hintText: '🔍 Tìm theo tên chủ hộ, SĐT, thôn bản...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                fillColor: Colors.grey.shade100,
                filled: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
          ),

          // 2. Filter Chips
          Container(
            color: Colors.white,
            padding: const EdgeInsets.only(left: 12, right: 12, bottom: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildTagChip('Tất cả'),
                  _buildTagChip('Người già'),
                  _buildTagChip('Mang thai'),
                  _buildTagChip('Trẻ em'),
                  _buildTagChip('Khuyết tật'),
                ],
              ),
            ),
          ),
          const Divider(height: 1),

          // 3. Danh sách các thẻ hộ dân
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: list.length,
              itemBuilder: (context, index) {
                final item = list[index];
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
                            style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      Text(
                        '📞 ${item.phone}   👨‍👩‍👧 ${item.membersCount} khẩu   🏚️ ${item.houseType}',
                        style: TextStyle(color: Colors.grey.shade700, fontSize: 11),
                      ),
                      const SizedBox(height: 8),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: item.tags.map((t) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 4),
                                child: Chip(
                                  label: Text(t, style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold)),
                                  backgroundColor: Colors.orange.shade50,
                                  visualDensity: VisualDensity.compact,
                                  padding: EdgeInsets.zero,
                                ),
                              );
                            }).toList(),
                          ),
                          TextButton(
                            onPressed: () => context.push('/household-profile'),
                            child: const Text('Xem hồ sơ ➔', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
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

  Widget _buildTagChip(String label) {
    final isSelected = _selectedTag == label;
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
          if (val) setState(() => _selectedTag = label);
        },
      ),
    );
  }
}
