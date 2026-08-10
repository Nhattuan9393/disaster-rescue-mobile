import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/obstacle_model.dart';
import '../../domain/weather_alert_model.dart';

final obstaclesProvider = Provider<List<ObstacleModel>>((ref) {
  return [
    ObstacleModel(
      id: 'obs_01',
      reporterId: 'user_01',
      latitude: 21.5455,
      longitude: 107.4010,
      title: '🚧 Sạt lở đá đèo Khe Tiền',
      obstacleType: 'landslide',
      description: 'Đá hộc sạt từ taluy dương lấp kín 100% đường giao thông. Xe máy/ô tô không qua được.',
      locationName: 'Đèo Khe Tiền, Thôn Khe Tiền',
      timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
    ),
    ObstacleModel(
      id: 'obs_02',
      reporterId: 'user_02',
      latitude: 21.5420,
      longitude: 107.3940,
      title: '🌊 Cầu bản Nà Lầu bị ngập sâu 1.2m',
      obstacleType: 'deep_flooding',
      description: 'Nước chảy siết ngang thân cầu. Cực kỳ nguy hiểm, đội cứu hộ chỉ di chuyển bằng xuồng máy.',
      locationName: 'Cầu Bản Nà Lầu',
      timestamp: DateTime.now().subtract(const Duration(minutes: 90)),
    ),
    ObstacleModel(
      id: 'obs_03',
      reporterId: 'user_03',
      latitude: 21.5390,
      longitude: 107.3910,
      title: '🌳 Cây xà cừ cổ thụ đổ chắn đường',
      obstacleType: 'tree_down',
      description: 'Gió giật mạnh làm đổ cây đè lên đường dây điện. Đã thông báo bên điện lực ngắt điện.',
      locationName: 'Trục đường chính xã Bình Liêu',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
    ),
  ];
});

final activeWeatherAlertProvider = Provider<WeatherAlertModel>((ref) {
  return WeatherAlertModel(
    id: 'alert_01',
    alertTitle: '🌊 CẢNH BÁO LŨ QUÉT & SẠT LỞ ĐẤT',
    alertLevel: 'CẤP 3 (KHẨN CẤP)',
    riverLevelMeters: 2.8,
    rainfallMm: 210,
    warningMessage: 'Mực nước sông Tiên Yên dâng nhanh +2.8m trên mức báo động 3. Dự báo mưa lớn tiếp diễn 150-220mm trong 6 giờ tới.',
    issuedAt: DateTime.now(),
  );
});
