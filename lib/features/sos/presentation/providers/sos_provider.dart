import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../domain/sos_model.dart';
import '../../domain/sos_status.dart';
import '../../data/sos_sync_service.dart';
import '../../../situation/presentation/providers/situation_provider.dart';

/// DR-023: Theo dõi luồng SOS realtime từ Firestore
final allSosRequestsStreamProvider = StreamProvider<List<SosRequestEntity>>((ref) {
  final repo = ref.watch(sosRepositoryProvider);
  return repo.watchSosRequests();
});

/// DR-024: Chuyển đổi List SOS thành List Marker để cắm lên Bản đồ OSM
final sosMarkersProvider = Provider<AsyncValue<List<Marker>>>((ref) {
  final sosRequestsAsync = ref.watch(allSosRequestsStreamProvider);
  final obstacles = ref.watch(obstaclesProvider);

  return sosRequestsAsync.whenData((requests) {
    final list = <Marker>[];

    // 1. Cắm mốc SOS
    for (final sos in requests) {
      Color markerColor;
      
      switch (sos.status) {
        case SosStatus.pending:
          markerColor = Colors.red; // Đang chờ cứu (Đỏ)
          break;
        case SosStatus.assigned:
          markerColor = Colors.orange; // Đang có đội di chuyển đến (Cam)
          break;
        case SosStatus.inProgress:
          markerColor = Colors.blue; // Đang xử lý (Xanh dương)
          break;
        case SosStatus.completed:
          markerColor = Colors.green; // Đã cứu xong (Xanh lá)
          break;
        case SosStatus.cancelled:
          markerColor = Colors.grey; // Đã hủy
          break;
        case SosStatus.escalated:
          markerColor = Colors.purple; // Leo thang lên Tỉnh (Tím)
          break;
      }

      list.add(
        Marker(
          point: LatLng(sos.latitude, sos.longitude),
          width: 40.0,
          height: 40.0,
          child: Icon(
            Icons.location_on,
            size: 40.0,
            color: markerColor,
          ),
        ),
      );
    }

    // 2. DR-043: Cắm mốc Chướng ngại vật giao thông (🚧 / ⚠️)
    for (final obs in obstacles) {
      list.add(
        Marker(
          point: LatLng(obs.latitude, obs.longitude),
          width: 36.0,
          height: 36.0,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.amber.shade800,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: const Center(
              child: Text('🚧', style: TextStyle(fontSize: 15)),
            ),
          ),
        ),
      );
    }

    return list;
  });
});

/// DR-030: Lắng nghe realtime tín hiệu SOS cuối cùng của Hộ dân cụ thể
final recentResidentSosProvider = Provider.family<AsyncValue<SosRequestEntity?>, String>((ref, householdId) {
  final allSosRequestsAsync = ref.watch(allSosRequestsStreamProvider);

  return allSosRequestsAsync.whenData((requests) {
    try {
      return requests.firstWhere((sos) => sos.householdId == householdId);
    } catch (_) {
      return null; // Không có yêu cầu SOS nào
    }
  });
});

