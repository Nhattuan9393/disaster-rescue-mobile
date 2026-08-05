import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:disaster_rescue/core/theme/app_theme.dart';
import 'package:disaster_rescue/features/household_registry/providers/household_registry_provider.dart';
import 'package:disaster_rescue/data/models/household_model.dart';
import 'package:disaster_rescue/data/models/sos_models.dart';

class ManualEntryScreen extends ConsumerStatefulWidget {
  const ManualEntryScreen({super.key});

  @override
  ConsumerState<ManualEntryScreen> createState() => _ManualEntryScreenState();
}

class _ManualEntryScreenState extends ConsumerState<ManualEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  String _address = 'Thôn Đồng Tâm';
  int _peopleCount = 4;
  HouseType _houseType = HouseType.level4;
  
  bool _hasChildren = false;
  bool _hasElderly = false;
  bool _hasSeriouslyIll = false;
  bool _hasDisabled = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;

    final newHousehold = HouseholdModel(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      ownerName: _nameController.text.trim(),
      ownerPhone: _phoneController.text.trim(),
      address: _address,
      peopleCount: _peopleCount,
      houseType: _houseType,
      hasChildren: _hasChildren,
      hasElderly: _hasElderly,
      hasSeriouslyIll: _hasSeriouslyIll,
      hasDisabled: _hasDisabled,
    );

    final success = ref.read(householdRegistryProvider.notifier).addHousehold(newHousehold);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã nhập hộ dân thành công!'),
          backgroundColor: AppColors.statusSafe,
        ),
      );
      context.pop();
    } else if (mounted) {
      final error = ref.read(householdRegistryProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Có lỗi xảy ra khi nhập hộ dân.'),
          backgroundColor: AppColors.primary,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Nhập hộ dân thủ công'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.base),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Thông tin chủ hộ',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  fontFamily: AppTypography.fontFamily,
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Họ và tên chủ hộ',
                  prefixIcon: Icon(Icons.person_rounded),
                  border: OutlineInputBorder(),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Vui lòng nhập họ tên chủ hộ.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),

              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Số điện thoại',
                  prefixIcon: Icon(Icons.phone_rounded),
                  border: OutlineInputBorder(),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Vui lòng nhập số điện thoại.';
                  }
                  if (!RegExp(r'^\d{10}$').hasMatch(val.trim())) {
                    return 'Số điện thoại phải gồm 10 chữ số.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.lg),

              const Text(
                'Địa chỉ & Nhà ở',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  fontFamily: AppTypography.fontFamily,
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              DropdownButtonFormField<String>(
                value: _address,
                decoration: const InputDecoration(
                  labelText: 'Thôn / Địa bàn',
                  prefixIcon: Icon(Icons.location_on_rounded),
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'Thôn Đồng Tâm', child: Text('Thôn Đồng Tâm')),
                  DropdownMenuItem(value: 'Thôn Bản Vược', child: Text('Thôn Bản Vược')),
                  DropdownMenuItem(value: 'Thôn Nam Ngàn', child: Text('Thôn Nam Ngàn')),
                ],
                onChanged: (val) => setState(() => _address = val!),
              ),
              const SizedBox(height: AppSpacing.md),

              Row(
                children: [
                  Expanded(
                    child: RadioListTile<HouseType>(
                      title: const Text('Nhà cấp 4'),
                      value: HouseType.level4,
                      groupValue: _houseType,
                      onChanged: (val) => setState(() => _houseType = val!),
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<HouseType>(
                      title: const Text('Nhà nhiều tầng'),
                      value: HouseType.multiStory,
                      groupValue: _houseType,
                      onChanged: (val) => setState(() => _houseType = val!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              const Text(
                'Nhân khẩu & Đối tượng yếu thế',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  fontFamily: AppTypography.fontFamily,
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Số nhân khẩu:', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      IconButton(
                        onPressed: _peopleCount > 1 ? () => setState(() => _peopleCount--) : null,
                        icon: const Icon(Icons.remove_circle_outline),
                      ),
                      Text(
                        '$_peopleCount người',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        onPressed: () => setState(() => _peopleCount++),
                        icon: const Icon(Icons.add_circle_outline),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),

              CheckboxListTile(
                title: const Text('Có trẻ em'),
                value: _hasChildren,
                onChanged: (val) => setState(() => _hasChildren = val ?? false),
                controlAffinity: ListTileControlAffinity.leading,
              ),
              CheckboxListTile(
                title: const Text('Có người già'),
                value: _hasElderly,
                onChanged: (val) => setState(() => _hasElderly = val ?? false),
                controlAffinity: ListTileControlAffinity.leading,
              ),
              CheckboxListTile(
                title: const Text('Có người bệnh nặng'),
                value: _hasSeriouslyIll,
                onChanged: (val) => setState(() => _hasSeriouslyIll = val ?? false),
                controlAffinity: ListTileControlAffinity.leading,
              ),
              CheckboxListTile(
                title: const Text('Có người khuyết tật'),
                value: _hasDisabled,
                onChanged: (val) => setState(() => _hasDisabled = val ?? false),
                controlAffinity: ListTileControlAffinity.leading,
              ),
              const SizedBox(height: AppSpacing.xl),

              ElevatedButton(
                onPressed: _handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.statusSafe,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
                ),
                child: const Text(
                  'NHẬP HỘ DÂN',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
