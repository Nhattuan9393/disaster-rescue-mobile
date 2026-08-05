import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disaster_rescue/features/household_registry/providers/household_registry_provider.dart';
import 'package:disaster_rescue/data/models/household_model.dart';
import 'package:disaster_rescue/data/models/sos_models.dart';

void main() {
  group('HouseholdRegistryNotifier Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('addHousehold successfully adds when SĐT is unique', () {
      final notifier = container.read(householdRegistryProvider.notifier);

      final newHousehold = const HouseholdModel(
        id: 'h3',
        ownerName: 'Vũ Văn Tám',
        ownerPhone: '0911111111',
        address: 'Thôn Đồng Tâm',
        peopleCount: 5,
        houseType: HouseType.level4,
      );

      final success = notifier.addHousehold(newHousehold);
      
      expect(success, isTrue);
      
      final state = container.read(householdRegistryProvider);
      expect(state.households.length, equals(3));
      expect(state.error, isNull);
    });

    test('addHousehold fails when SĐT already exists', () {
      final notifier = container.read(householdRegistryProvider.notifier);

      // Nguyễn Văn Ba có SĐT 0901234567 sẵn trong mock data
      final duplicateHousehold = const HouseholdModel(
        id: 'h3',
        ownerName: 'Trùng Số',
        ownerPhone: '0901234567',
        address: 'Thôn Bản Vược',
        peopleCount: 2,
        houseType: HouseType.multiStory,
      );

      final success = notifier.addHousehold(duplicateHousehold);
      
      expect(success, isFalse);
      
      final state = container.read(householdRegistryProvider);
      expect(state.households.length, equals(2)); // Vẫn giữ 2
      expect(state.error, equals('Số điện thoại này đã tồn tại trong hệ thống.'));
    });

    test('simulateImport detects duplicate and splits queue', () {
      final notifier = container.read(householdRegistryProvider.notifier);

      final importList = [
        const HouseholdModel(
          id: 'i1',
          ownerName: 'Nguyễn Văn Ba Mới',
          ownerPhone: '0901234567', // Trùng SĐT Nguyễn Văn Ba
          address: 'Thôn Đồng Tâm',
          peopleCount: 6, // Số nhân khẩu mới khác số cũ (4)
          houseType: HouseType.level4,
          hasChildren: true,
          hasElderly: true,
        ),
        const HouseholdModel(
          id: 'i2',
          ownerName: 'Lê Văn Chín',
          ownerPhone: '0922222222', // SĐT mới hoàn toàn
          address: 'Thôn Nam Ngàn',
          peopleCount: 2,
          houseType: HouseType.multiStory,
        ),
      ];

      notifier.simulateImport(importList);

      final state = container.read(householdRegistryProvider);
      // Lê Văn Chín không trùng nên được đưa thẳng vào danh sách
      expect(state.households.length, equals(3)); 
      
      // Nguyễn Văn Ba trùng nên đưa vào hàng đợi đối chiếu
      expect(state.duplicates.length, equals(1));
      expect(state.duplicates.first['existing']!.ownerName, equals('Nguyễn Văn Ba'));
      expect(state.duplicates.first['imported']!.ownerName, equals('Nguyễn Văn Ba Mới'));
    });

    test('resolveDuplicate skip resolution preserves existing data', () {
      final notifier = container.read(householdRegistryProvider.notifier);
      final importList = [
        const HouseholdModel(
          id: 'i1',
          ownerName: 'Nguyễn Văn Ba Mới',
          ownerPhone: '0901234567',
          address: 'Thôn Đồng Tâm Mới',
          peopleCount: 6,
          houseType: HouseType.level4,
        ),
      ];
      
      notifier.simulateImport(importList);
      notifier.resolveDuplicate('0901234567', 'skip');

      final state = container.read(householdRegistryProvider);
      expect(state.duplicates.isEmpty, isTrue);

      final ba = state.households.firstWhere((h) => h.ownerPhone == '0901234567');
      expect(ba.ownerName, equals('Nguyễn Văn Ba')); // Không đổi
      expect(ba.peopleCount, equals(4)); // Không đổi
    });

    test('resolveDuplicate overwrite resolution replaces existing data', () {
      final notifier = container.read(householdRegistryProvider.notifier);
      final importList = [
        const HouseholdModel(
          id: 'i1',
          ownerName: 'Nguyễn Văn Ba Mới',
          ownerPhone: '0901234567',
          address: 'Thôn Đồng Tâm Mới',
          peopleCount: 6,
          houseType: HouseType.level4,
        ),
      ];
      
      notifier.simulateImport(importList);
      notifier.resolveDuplicate('0901234567', 'overwrite');

      final state = container.read(householdRegistryProvider);
      expect(state.duplicates.isEmpty, isTrue);

      final ba = state.households.firstWhere((h) => h.ownerPhone == '0901234567');
      expect(ba.ownerName, equals('Nguyễn Văn Ba Mới')); // Đổi sang mới
      expect(ba.peopleCount, equals(6)); // Đổi sang mới
    });

    test('resolveDuplicate merge resolution combines maximum values', () {
      final notifier = container.read(householdRegistryProvider.notifier);
      
      // existing Nguyễn Văn Ba: peopleCount = 4, hasChildren = true, hasElderly = true, hasSeriouslyIll = false
      final importList = [
        const HouseholdModel(
          id: 'i1',
          ownerName: 'Nguyễn Văn Ba',
          ownerPhone: '0901234567',
          address: 'Thôn Đồng Tâm',
          peopleCount: 6, // nhiều hơn 4
          houseType: HouseType.level4,
          hasChildren: false,
          hasElderly: false,
          hasSeriouslyIll: true, // thêm trường yếu thế mới
        ),
      ];
      
      notifier.simulateImport(importList);
      notifier.resolveDuplicate('0901234567', 'merge');

      final state = container.read(householdRegistryProvider);
      expect(state.duplicates.isEmpty, isTrue);

      final ba = state.households.firstWhere((h) => h.ownerPhone == '0901234567');
      expect(ba.peopleCount, equals(6)); // lấy cực đại
      expect(ba.hasChildren, isTrue); // giữ nguyên true cũ
      expect(ba.hasElderly, isTrue); // giữ nguyên true cũ
      expect(ba.hasSeriouslyIll, isTrue); // trộn true mới
    });
  });
}
