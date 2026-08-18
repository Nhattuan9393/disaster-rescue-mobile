import 'dart:convert';
import 'dart:io';
import 'dart:async';
import '../../../core/utils/logger.dart';
import '../../features/sos/domain/sos_model.dart';
import '../../features/rescue_team/domain/rescue_team_model.dart';
import '../../features/report/domain/assistance_request_model.dart';

import '../../features/sos/domain/sos_status.dart';
import '../../features/rescue_team/domain/rescue_team_status.dart';

class ApiSyncService {
  static const String _baseUrl = 'https://kvdb.io/disaster_rescue_quangninh_v1';
  
  // Endpoint cụ thể cho SOS, Teams và Reports
  static const String _sosUrl = '$_baseUrl/sos';
  static const String _teamsUrl = '$_baseUrl/teams';
  static const String _reportsUrl = '$_baseUrl/assistance_requests';

  static final List<SosRequestEntity> _localSosRequests = [
    SosRequestEntity(
      id: 'SOS-0042',
      householdId: 'Nguyễn Văn A',
      latitude: 21.5430,
      longitude: 107.3990,
      createdAt: DateTime.now(),
      status: SosStatus.assigned,
      priorityScore: 85,
      assignedTeamId: 'team_01',
    ),
    SosRequestEntity(
      id: 'SOS-0043',
      householdId: 'Trần Thị B',
      latitude: 21.5450,
      longitude: 107.4020,
      createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
      status: SosStatus.pending,
      priorityScore: 90,
    ),
  ];

  static final List<RescueTeamModel> _localTeams = [
    RescueTeamModel(
      id: 'team_01',
      name: 'Đội Dân quân Thôn Pắc Liềng',
      leaderName: 'Lý Văn Thắng',
      contactPhone: '0912.345.678',
      status: RescueTeamStatus.onMission,
      currentLatitude: 21.5430,
      currentLongitude: 107.3990,
      assignedSosId: 'SOS-0042',
    ),
    RescueTeamModel(
      id: 'team_02',
      name: 'Tổ Xung kích Nà Lầu',
      leaderName: 'Hoàng Văn Đại',
      contactPhone: '0987.654.321',
      status: RescueTeamStatus.offline,
      currentLatitude: 21.5450,
      currentLongitude: 107.4020,
    ),
    RescueTeamModel(
      id: 'team_03',
      name: 'Đội Cứu Hộ Công An Xã',
      leaderName: 'Chu Văn Bình',
      contactPhone: '0911.223.344',
      status: RescueTeamStatus.available,
      currentLatitude: 21.5410,
      currentLongitude: 107.3950,
    ),
    RescueTeamModel(
      id: 'team_04',
      name: 'Đội Y tế xã Bình Liêu',
      leaderName: 'BS. Vũ Thị Hoa',
      contactPhone: '0933.444.555',
      status: RescueTeamStatus.offline,
      currentLatitude: 21.5380,
      currentLongitude: 107.3900,
    ),
    RescueTeamModel(
      id: 'team_05',
      name: 'Hội Chữ thập đỏ Hạ Long',
      leaderName: 'Trần Văn Nam',
      contactPhone: '0966.777.888',
      status: RescueTeamStatus.available,
      currentLatitude: 21.5420,
      currentLongitude: 107.3960,
    ),
  ];

  static final List<AssistanceRequestModel> _localReports = [
    AssistanceRequestModel(
      id: 'REP-001',
      householdId: 'Nguyễn Văn A',
      reporterId: 'user_01',
      latitude: 21.5430,
      longitude: 107.3990,
      address: 'Thôn Pắc Liềng',
      description: 'Nước ngập sâu, cần áo phao và chăn ấm',
      neededSupports: const ['Áo phao', 'Chăn ấm'],
      priorityScore: 70,
      urgencyWindow: '1h',
      status: 'pending',
      confidenceScore: 85,
      timestamp: DateTime.now(),
    ),
  ];

  static final _sosStreamController = StreamController<List<SosRequestEntity>>.broadcast();
  static final _teamsStreamController = StreamController<List<RescueTeamModel>>.broadcast();
  static final _reportsStreamController = StreamController<List<AssistanceRequestModel>>.broadcast();

  static Timer? _pollingTimer;

  static Stream<List<SosRequestEntity>> get sosStream => _sosStreamController.stream;
  static Stream<List<RescueTeamModel>> get teamsStream => _teamsStreamController.stream;
  static Stream<List<AssistanceRequestModel>> get reportsStream => _reportsStreamController.stream;

  static List<SosRequestEntity> get currentSosList => List.unmodifiable(_localSosRequests);
  static List<RescueTeamModel> get currentTeams => List.unmodifiable(_localTeams);
  static List<AssistanceRequestModel> get currentReports => List.unmodifiable(_localReports);

  static void startPolling() {
    _pollingTimer?.cancel();
    
    // Phát ngay lập tức dữ liệu local/seed ban đầu để tránh loading vĩnh viễn
    _sosStreamController.add(List.from(_localSosRequests));
    _teamsStreamController.add(List.from(_localTeams));
    _reportsStreamController.add(List.from(_localReports));

    // Đọc lần đầu tiên
    _fetchSosFromCloud();
    _fetchTeamsFromCloud();
    _fetchReportsFromCloud();

    // Định kỳ 3 giây fetch 1 lần để tạo real-time sync giả lập
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _fetchSosFromCloud();
      _fetchTeamsFromCloud();
      _fetchReportsFromCloud();
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

  // --- ASSISTANCE REPORTS SYNC ---
  static Future<void> _fetchReportsFromCloud() async {
    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 3);
    try {
      final request = await client.getUrl(Uri.parse(_reportsUrl));
      final response = await request.close();
      if (response.statusCode == 200) {
        final body = await response.transform(utf8.decoder).join();
        if (body.trim().isNotEmpty) {
          final List<dynamic> decoded = jsonDecode(body);
          final fetched = decoded.map((item) => AssistanceRequestModel.fromJson(item)).toList();
          _localReports.clear();
          _localReports.addAll(fetched);
          _reportsStreamController.add(List.from(_localReports));
        }
      }
    } catch (e) {
      AppLogger.w('ApiSyncService: Không thể tải tin báo từ cloud (Chế độ offline tự động).');
    } finally {
      client.close();
    }
  }

  static Future<void> uploadReportsToCloud() async {
    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 3);
    try {
      final request = await client.putUrl(Uri.parse(_reportsUrl));
      request.headers.contentType = ContentType.json;
      final jsonPayload = jsonEncode(_localReports.map((e) => e.toJson()).toList());
      request.write(jsonPayload);
      final response = await request.close();
      await response.drain();
      AppLogger.i('ApiSyncService: Đã tải ${_localReports.length} tin báo lên Cloud thành công.');
    } catch (e) {
      AppLogger.e('ApiSyncService: Không thể tải tin báo lên cloud', error: e);
    } finally {
      client.close();
    }
  }

  static void addOrUpdateLocalReport(AssistanceRequestModel report) {
    final index = _localReports.indexWhere((e) => e.id == report.id);
    if (index >= 0) {
      _localReports[index] = report;
    } else {
      _localReports.add(report);
    }
    _reportsStreamController.add(List.from(_localReports));
    uploadReportsToCloud();
  }

  static void updateReportStatus(String reportId, String newStatus) {
    final index = _localReports.indexWhere((e) => e.id == reportId);
    if (index >= 0) {
      _localReports[index] = _localReports[index].copyWith(status: newStatus);
      _reportsStreamController.add(List.from(_localReports));
      uploadReportsToCloud();
    }
  }
}
