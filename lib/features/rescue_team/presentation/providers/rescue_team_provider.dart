import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/i_rescue_team_repository.dart';
import '../../domain/rescue_team_model.dart';
import '../../domain/rescue_team_status.dart';
import '../../data/rescue_team_repository_impl.dart';

final rescueTeamRepositoryProvider = Provider<IRescueTeamRepository>((ref) {
  return RescueTeamRepositoryImpl();
});

/// Theo dõi luồng danh sách toàn bộ đội cứu hộ realtime
final allRescueTeamsStreamProvider = StreamProvider<List<RescueTeamModel>>((ref) {
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
