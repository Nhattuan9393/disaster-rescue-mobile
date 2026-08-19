import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/i_rescue_team_repository.dart';
import '../../domain/rescue_team_model.dart';
import '../../domain/rescue_team_status.dart';
import '../../data/rescue_team_repository_impl.dart';
import '../../../auth/presentation/providers/auth_controller.dart';

final rescueTeamRepositoryProvider = Provider<IRescueTeamRepository>((ref) {
  return RescueTeamRepositoryImpl();
});

/// Theo dõi luồng danh sách toàn bộ đội cứu hộ realtime
final allRescueTeamsStreamProvider = StreamProvider<List<RescueTeamModel>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return const Stream.empty();
  final repo = ref.watch(rescueTeamRepositoryProvider);
  return repo.watchAllTeams();
});

/// Lọc danh sách các Đội cứu hộ đang rảnh (available) để gán việc
final availableRescueTeamsProvider = Provider<AsyncValue<List<RescueTeamModel>>>((ref) {
  final allTeamsAsync = ref.watch(allRescueTeamsStreamProvider);
  
  return allTeamsAsync.whenData((teams) {
    return teams.where((team) => team.status == RescueTeamStatus.available).toList();
  });
});

/// Theo dõi luồng thông tin đội cứu hộ hiện tại
final myRescueTeamStreamProvider = StreamProvider<RescueTeamModel?>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return const Stream.empty();
  
  final teamId = 'team_${user.uid}';
  return FirebaseFirestore.instance
      .collection('rescue_teams')
      .doc(teamId)
      .snapshots()
      .map((doc) => doc.exists ? RescueTeamModel.fromJson({...doc.data()!, 'id': doc.id}) : null);
});
