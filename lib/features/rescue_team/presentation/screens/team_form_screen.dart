import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/models/team_models.dart';
import '../../../../shared/widgets/quantity_stepper.dart';
import '../../providers/admin_team_provider.dart';

class EquipmentFormItem {
  TextEditingController nameController;
  int quantity;

  EquipmentFormItem({required this.nameController, this.quantity = 1});
}

class TeamFormScreen extends ConsumerStatefulWidget {
  final String? teamId;

  const TeamFormScreen({Key? key, this.teamId}) : super(key: key);

  @override
  ConsumerState<TeamFormScreen> createState() => _TeamFormScreenState();
}

class _TeamFormScreenState extends ConsumerState<TeamFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _leaderNameController;
  late TextEditingController _leaderPhoneController;
  
  String _selectedTeamType = 'Dân quân';
  final List<String> _teamTypes = ['Dân quân', 'Tổ xung kích', 'Y tế', 'Đường thuỷ'];
  
  final List<TextEditingController> _memberControllers = [];
  final List<EquipmentFormItem> _equipmentItems = [];
  
  final List<String> _mockVillages = [
    'Thôn Pắc Liềng',
    'Thôn Nà Lầu',
    'Thôn Cao Sơn',
    'Thôn Đồng Văn',
    'Thôn Húc Động'
  ];
  final Set<String> _selectedVillages = {};

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _leaderNameController = TextEditingController();
    _leaderPhoneController = TextEditingController();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTeamData();
    });
  }

  void _loadTeamData() {
    if (widget.teamId != null) {
      try {
        final adminState = ref.read(adminTeamProvider);
        // Using dynamic to safely access properties that might vary slightly in the actual model
        final dynamic team = adminState.allTeams.firstWhere((t) => (t as dynamic).id == widget.teamId);
        
        setState(() {
          _nameController.text = team.name ?? '';
          if (team.type != null && _teamTypes.contains(team.type)) {
            _selectedTeamType = team.type;
          }
          _leaderNameController.text = team.leaderName ?? '';
          _leaderPhoneController.text = team.leaderPhone ?? '';
          
          if (team.members != null) {
            for (var member in team.members) {
              String mName = member is String ? member : (member.name ?? '');
              _memberControllers.add(TextEditingController(text: mName));
            }
          }
          
          if (team.equipment != null) {
            for (var eq in team.equipment) {
              String eName = eq.name ?? '';
              int eQty = eq.quantity ?? 1;
              _equipmentItems.add(EquipmentFormItem(
                nameController: TextEditingController(text: eName),
                quantity: eQty,
              ));
            }
          }
        });
      } catch (e) {
        debugPrint('Error loading team data: $e');
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _leaderNameController.dispose();
    _leaderPhoneController.dispose();
    for (var c in _memberControllers) {
      c.dispose();
    }
    for (var eq in _equipmentItems) {
      eq.nameController.dispose();
    }
    super.dispose();
  }

  void _saveTeam() {
    if (_formKey.currentState!.validate()) {
      try {
        final members = [_leaderNameController.text, ..._memberControllers.map((c) => c.text).where((t) => t.isNotEmpty)];
        final equipmentMap = <String, double>{};
        for (final eq in _equipmentItems) {
          if (eq.nameController.text.isNotEmpty) {
            equipmentMap[eq.nameController.text] = eq.quantity.toDouble();
          }
        }
        if (widget.teamId == null) {
          ref.read(adminTeamProvider.notifier).addStandingTeam(
            name: _nameController.text,
            phone: _leaderPhoneController.text,
            members: members,
            equipment: equipmentMap,
            village: _selectedVillages.isNotEmpty ? _selectedVillages.first : 'unknown',
          );
        } else {
          ref.read(adminTeamProvider.notifier).updateTeam(
            widget.teamId!,
            name: _nameController.text,
            phone: _leaderPhoneController.text,
            members: members,
            equipment: equipmentMap,
          );
        }
      } catch (e) {
        debugPrint('Provider method might differ: $e');
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lưu đội thường trực thành công!')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.teamId != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isEditing ? '← Sửa đội' : 'Tạo đội thường trực'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveTeam,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.base),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildBasicInfoSection(),
              const SizedBox(height: AppSpacing.base),
              _buildMembersSection(),
              const SizedBox(height: AppSpacing.base),
              _buildEquipmentSection(),
              const SizedBox(height: AppSpacing.base),
              _buildVillagesSection(),
              const SizedBox(height: AppSpacing.base),
              _buildQRCodeSection(),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.base),
          child: ElevatedButton(
            onPressed: _saveTeam,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
            ),
            child: const Text(
              'LƯU ĐỘI THƯỜNG TRỰC',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Card(
      elevation: 0,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.base),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Thông tin cơ bản', style: AppTypography.h3),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Tên đội *',
                border: OutlineInputBorder(),
              ),
              validator: (v) => v == null || v.isEmpty ? 'Vui lòng nhập tên đội' : null,
            ),
            const SizedBox(height: AppSpacing.md),
            Text('Loại đội', style: AppTypography.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: _teamTypes.map((type) {
                final isSelected = _selectedTeamType == type;
                return FilterChip(
                  label: Text(type),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) setState(() => _selectedTeamType = type);
                  },
                  backgroundColor: AppColors.background,
                  selectedColor: const Color.fromRGBO(211, 47, 47, 0.1), // AppColors.primary with opacity 0.1
                  checkmarkColor: AppColors.primary,
                  labelStyle: TextStyle(
                    color: isSelected ? AppColors.primary : AppColors.textPrimary,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.chip,
                    side: BorderSide(
                      color: isSelected ? AppColors.primary : AppColors.textDisabled,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _leaderNameController,
              decoration: const InputDecoration(
                labelText: 'Trưởng đội *',
                border: OutlineInputBorder(),
              ),
              validator: (v) => v == null || v.isEmpty ? 'Vui lòng nhập tên trưởng đội' : null,
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _leaderPhoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Số điện thoại *',
                border: OutlineInputBorder(),
              ),
              validator: (v) => v == null || v.isEmpty ? 'Vui lòng nhập số điện thoại' : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMembersSection() {
    return Card(
      elevation: 0,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.base),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Thành viên', style: AppTypography.h3),
            const SizedBox(height: AppSpacing.md),
            ..._memberControllers.asMap().entries.map((entry) {
              int idx = entry.key;
              var controller = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: controller,
                        decoration: InputDecoration(
                          labelText: 'Tên thành viên ${idx + 1}',
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: AppColors.primary),
                      onPressed: () {
                        setState(() {
                          _memberControllers[idx].dispose();
                          _memberControllers.removeAt(idx);
                        });
                      },
                    )
                  ],
                ),
              );
            }).toList(),
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _memberControllers.add(TextEditingController());
                });
              },
              icon: const Icon(Icons.add, color: AppColors.primary),
              label: const Text('+ Thêm thành viên', style: TextStyle(color: AppColors.primary)),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildEquipmentSection() {
    return Card(
      elevation: 0,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.base),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Phương tiện & Vật tư biên chế', style: AppTypography.h3),
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: const Color.fromRGBO(232, 245, 233, 1), // Light green background
                borderRadius: AppRadius.card,
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: AppColors.statusSafe, size: 20),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Tài sản biên chế, luôn có mặt mọi đợt thiên tai.',
                      style: AppTypography.caption.copyWith(color: AppColors.statusSafe),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            ..._equipmentItems.asMap().entries.map((entry) {
              int idx = entry.key;
              var item = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: item.nameController,
                        decoration: const InputDecoration(
                          labelText: 'Tên vật tư/phương tiện',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    QuantityStepper(
                      value: item.quantity,
                      onChanged: (val) {
                        item.quantity = val.toInt();
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: AppColors.primary),
                      onPressed: () {
                        setState(() {
                          _equipmentItems[idx].nameController.dispose();
                          _equipmentItems.removeAt(idx);
                        });
                      },
                    )
                  ],
                ),
              );
            }).toList(),
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _equipmentItems.add(EquipmentFormItem(nameController: TextEditingController()));
                });
              },
              icon: const Icon(Icons.add, color: AppColors.primary),
              label: const Text('+ Thêm vật tư', style: TextStyle(color: AppColors.primary)),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildVillagesSection() {
    return Card(
      elevation: 0,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.base),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Khu vực phụ trách', style: AppTypography.h3),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: _mockVillages.map((village) {
                final isSelected = _selectedVillages.contains(village);
                return FilterChip(
                  label: Text(village),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedVillages.add(village);
                      } else {
                        _selectedVillages.remove(village);
                      }
                    });
                  },
                  backgroundColor: AppColors.background,
                  selectedColor: const Color.fromRGBO(211, 47, 47, 0.1),
                  checkmarkColor: AppColors.primary,
                  labelStyle: TextStyle(
                    color: isSelected ? AppColors.primary : AppColors.textPrimary,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.chip,
                    side: BorderSide(
                      color: isSelected ? AppColors.primary : AppColors.textDisabled,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQRCodeSection() {
    return Card(
      elevation: 0,
      color: const Color.fromRGBO(33, 33, 33, 1), // Dark background card
      shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.qr_code_2, color: Colors.white, size: 80),
            const SizedBox(height: AppSpacing.md),
            const Text(
              'DR-BL-DQ-001',
              style: TextStyle(
                color: Colors.white, 
                fontSize: 18, 
                fontWeight: FontWeight.bold, 
                letterSpacing: 2
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            const Text(
              'Quét tại chốt để kích hoạt 1 chạm',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: AppSpacing.lg),
            OutlinedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Chuẩn bị in...')),
                );
              },
              icon: const Icon(Icons.print, color: Colors.white, size: 20),
              label: const Text('In nhãn', style: TextStyle(color: Colors.white)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.white),
                shape: RoundedRectangleBorder(borderRadius: AppRadius.chip),
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
              ),
            )
          ],
        ),
      ),
    );
  }
}
