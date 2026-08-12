import 'dart:convert';
import 'dart:io';
import 'dart:async';
import '../../../core/utils/logger.dart';
import '../../features/sos/domain/sos_model.dart';
import '../../features/rescue_team/domain/rescue_team_model.dart';

class ApiSyncService {
  static const String _baseUrl = 'https://kvdb.io/disaster_rescue_quangninh_v1';
  
  // Endpoint cụ thể cho SOS và Teams
  static const String _sosUrl = '$_baseUrl/sos';
  static const String _teamsUrl = '$_baseUrl/teams';

  static final List<SosRequestEntity> _localSosRequests = [];
  static final List<RescueTeamModel> _localTeams = [];

  static final _sosStreamController = StreamController<List<SosRequestEntity>>.broadcast();
  static final _teamsStreamController = StreamController<List<RescueTeamModel>>.broadcast();

  static Timer? _pollingTimer;

  static Stream<List<SosRequestEntity>> get sosStream => _sosStreamController.stream;
  static Stream<List<RescueTeamModel>> get teamsStream => _teamsStreamController.stream;

  static List<SosRequestEntity> get currentSosList => List.unmodifiable(_localSosRequests);
  static List<RescueTeamModel> get currentTeams => List.unmodifiable(_localTeams);

  static void startPolling() {
    _pollingTimer?.cancel();
    
    // Đọc lần đầu tiên
    _fetchSosFromCloud();
    _fetchTeamsFromCloud();

    // Định kỳ 3 giây fetch 1 lần để tạo real-time sync giả lập
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _fetchSosFromCloud();
      _fetchTeamsFromCloud();
    });
    
    AppLogger.i('ApiSyncService: Bắt đầu chạy ngầm đồng bộ hóa thời gian thực (3s/lần)...');
  }

  static void stopPolling() {
    _pollingTimer?.cancel();
  }

  // --- SOS SYNC ---
  static Future<void> _fetchSosFromCloud() async {
    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 3);
    try {
      final request = await client.getUrl(Uri.parse(_sosUrl));
      final response = await request.close();
      if (response.statusCode == 200) {
        final body = await response.transform(utf8.decoder).join();
        if (body.trim().isNotEmpty) {
          final List<dynamic> decoded = jsonDecode(body);
          final fetchedSos = decoded.map((item) => SosRequestEntity.fromJson(item)).toList();
          
          _localSosRequests.clear();
          _localSosRequests.addAll(fetchedSos);
          _sosStreamController.add(List.from(_localSosRequests));
        }
      }
    } catch (e) {
      AppLogger.w('ApiSyncService: Không thể tải SOS từ cloud (Chế độ offline tự động).');
    } finally {
      client.close();
    }
  }

  static Future<void> uploadSosToCloud() async {
    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 3);
    try {
      final request = await client.putUrl(Uri.parse(_sosUrl));
      request.headers.contentType = ContentType.json;
      
      final jsonPayload = jsonEncode(_localSosRequests.map((e) => e.toJson()).toList());
      request.write(jsonPayload);
      
      final response = await request.close();
      await response.drain();
      AppLogger.i('ApiSyncService: Đã tải ${_localSosRequests.length} SOS lên Cloud thành công.');
    } catch (e) {
      AppLogger.e('ApiSyncService: Không thể tải SOS lên cloud', error: e);
    } finally {
      client.close();
    }
  }

  static void addOrUpdateLocalSos(SosRequestEntity request) {
    final index = _localSosRequests.indexWhere((e) => e.id == request.id);
    if (index >= 0) {
      _localSosRequests[index] = request;
    } else {
      _localSosRequests.add(request);
    }
    _sosStreamController.add(List.from(_localSosRequests));
    uploadSosToCloud();
  }

  // --- TEAMS SYNC ---
  static Future<void> _fetchTeamsFromCloud() async {
    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 3);
    try {
      final request = await client.getUrl(Uri.parse(_teamsUrl));
      final response = await request.close();
      if (response.statusCode == 200) {
        final body = await response.transform(utf8.decoder).join();
        if (body.trim().isNotEmpty) {
          final List<dynamic> decoded = jsonDecode(body);
          final fetchedTeams = decoded.map((item) => RescueTeamModel.fromJson(item)).toList();
          
          _localTeams.clear();
          _localTeams.addAll(fetchedTeams);
          _teamsStreamController.add(List.from(_localTeams));
        }
      }
    } catch (e) {
      AppLogger.w('ApiSyncService: Không thể tải đội cứu hộ từ cloud (Chế độ offline tự động).');
    } finally {
      client.close();
    }
  }

  static Future<void> uploadTeamsToCloud() async {
    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 3);
    try {
      final request = await client.putUrl(Uri.parse(_teamsUrl));
      request.headers.contentType = ContentType.json;
      
      final jsonPayload = jsonEncode(_localTeams.map((e) => e.toJson()).toList());
      request.write(jsonPayload);
      
      final response = await request.close();
      await response.drain();
      AppLogger.i('ApiSyncService: Đã tải ${_localTeams.length} đội cứu hộ lên Cloud thành công.');
    } catch (e) {
      AppLogger.e('ApiSyncService: Không thể tải đội cứu hộ lên cloud', error: e);
    } finally {
      client.close();
    }
  }

  static void addOrUpdateLocalTeam(RescueTeamModel team) {
    final index = _localTeams.indexWhere((e) => e.id == team.id);
    if (index >= 0) {
      _localTeams[index] = team;
    } else {
      _localTeams.add(team);
    }
    _teamsStreamController.add(List.from(_localTeams));
    uploadTeamsToCloud();
  }
}
