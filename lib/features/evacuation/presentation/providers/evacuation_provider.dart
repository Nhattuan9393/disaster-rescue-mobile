import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/evacuation_point_model.dart';
import '../../domain/evacuation_order_model.dart';
import '../../domain/i_evacuation_repository.dart';
import '../../data/evacuation_repository_impl.dart';
import '../../../auth/presentation/providers/auth_controller.dart';

final evacuationRepositoryProvider = Provider<IEvacuationRepository>((ref) {
  return EvacuationRepositoryImpl();
});

final allEvacuationPointsProvider = StreamProvider<List<EvacuationPointModel>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return const Stream.empty();
  final repo = ref.watch(evacuationRepositoryProvider);
  return repo.watchEvacuationPoints();
});

final latestEvacuationOrderProvider = StreamProvider<EvacuationOrderModel?>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return const Stream.empty();
  final repo = ref.watch(evacuationRepositoryProvider);
  return repo.watchEvacuationOrders().map((list) => list.isNotEmpty ? list.first : null);
});
