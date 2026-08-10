import 'package:geolocator/geolocator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'hive_service.dart';
import '../utils/logger.dart';

class GpsLocation {
  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final bool isCached;

  GpsLocation({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    this.isCached = false,
  });
}

final gpsServiceProvider = Provider<GpsService>((ref) {
  return GpsService();
});

class GpsService {
  Future<GpsLocation?> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      AppLogger.w('Location services are disabled.');
      return _getCachedLocation();
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        AppLogger.w('Location permissions are denied');
        return _getCachedLocation();
      }
    }

    if (permission == LocationPermission.deniedForever) {
      AppLogger.w('Location permissions are permanently denied');
      return _getCachedLocation();
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );

      final loc = GpsLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        timestamp: position.timestamp,
      );

      // Lưu cache
      _saveToCache(loc);
      return loc;
    } catch (e, stack) {
      AppLogger.e('Lỗi lấy GPS', error: e, stackTrace: stack);
      return _getCachedLocation();
    }
  }

  void _saveToCache(GpsLocation loc) {
    final box = HiveService.getGpsCacheBox();
    box.put('lat', loc.latitude);
    box.put('lng', loc.longitude);
    box.put('timestamp', loc.timestamp.toIso8601String());
  }

  GpsLocation? _getCachedLocation() {
    final box = HiveService.getGpsCacheBox();
    final lat = box.get('lat') as double?;
    final lng = box.get('lng') as double?;
    final timestampStr = box.get('timestamp') as String?;

    if (lat != null && lng != null && timestampStr != null) {
      AppLogger.i('Sử dụng vị trí từ GPS Cache');
      return GpsLocation(
        latitude: lat,
        longitude: lng,
        timestamp: DateTime.parse(timestampStr),
        isCached: true,
      );
    }
    return null;
  }
}
