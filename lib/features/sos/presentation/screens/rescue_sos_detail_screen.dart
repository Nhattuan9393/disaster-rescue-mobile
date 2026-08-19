import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/utils/logger.dart';
import '../../../../core/widgets/map_widget.dart';
import '../../../auth/presentation/providers/auth_controller.dart';
import '../../../household/data/household_repository.dart';
import '../../../rescue_team/presentation/providers/rescue_team_provider.dart';
import '../../data/sos_sync_service.dart';
import '../../domain/sos_model.dart';
import '../../domain/sos_status.dart';
import '../providers/sos_provider.dart';

/// Chi tiết SOS cho đội cứu hộ — khớp ảnh thiết kế "Chi tiết SOS #0042".
///
/// Logic hiển thị PII:
/// - Nếu SOS đã gán cho đội của user và status ∈ {assigned, inProgress} → mở
///   khoá PII (tên hộ, SĐT, địa chỉ chi tiết) qua `householdByIdStreamProvider`.
/// - Ngược lại chỉ hiển thị priority + chip tình huống + ảnh (không PII) —
///   thỏa RULE-007.
class RescueSosDetailScreen extends ConsumerStatefulWidget {
  final String sosId;
  const RescueSosDetailScreen({super.key, required this.sosId});

  @override
  ConsumerState<RescueSosDetailScreen> createState() =>
      _RescueSosDetailScreenState();
}

class _RescueSosDetailScreenState extends ConsumerState<RescueSosDetailScreen> {
  bool _acceptTried = false;

  /// Khi SOS được gán cho đội của tôi và đang ở trạng thái `assigned`,
  /// tự chuyển sang `inProgress` — user không cần bấm "Tôi đi" riêng.
  /// Chỉ chạy 1 lần / phiên.
  Future<void> _maybeAutoAccept(SosRequestEntity sos) async {
    if (_acceptTried) return;
    final user = ref.read(currentUserProvider);
    if (user?.teamId == null) return;
    if (sos.assignedTeamId != user!.teamId) return;
    if (sos.status != SosStatus.assigned) return;
    _acceptTried = true;
    try {
      final repo = ref.read(rescueTeamRepositoryProvider);
      await repo.acceptMission(user.teamId!, sos.id);
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('✅ Đã nhận nhiệm vụ. Bắt đầu tác chiến.'),
            backgroundColor: Colors.green.shade700,
          ),
        );
      }
    } catch (e, s) {
      AppLogger.w('Auto-accept SOS ${sos.id} thất bại', error: e, stackTrace: s);
      _acceptTried = false; // Cho phép retry ở lần rebuild kế tiếp
    }
  }

  @override
  Widget build(BuildContext context) {
    final sosAsync = ref.watch(allSosRequestsStreamProvider);

    // Trigger auto-accept khi SOS đã load — thực hiện ngoài build tree.
    sosAsync.whenData((list) {
      final sos = _findSos(list, widget.sosId);
      if (sos != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _maybeAutoAccept(sos));
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => context.pop(),
        ),
        title: Text(
          '← Chi tiết SOS #${_shortId(widget.sosId)}',
          style: const TextStyle(
              color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: sosAsync.when(
                data: (list) {
                  final sos = _findSos(list, widget.sosId);
                  if (sos == null) return const SizedBox.shrink();
                  return _PriorityBadgeSmall(level: sos.priorityLevel);
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ),
          )
        ],
      ),
      body: sosAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Lỗi tải SOS: $e')),
        data: (list) {
          final sos = _findSos(list, widget.sosId);
          if (sos == null) {
            return const Center(child: Text('Không tìm thấy SOS'));
          }
          return _Body(sos: sos);
        },
      ),
    );
  }

  static String _shortId(String id) {
    if (id.length <= 5) return id;
    // Số cuối cho đẹp: SOS-abc123 → 123
    return id.substring(id.length - 4);
  }

  SosRequestEntity? _findSos(List<SosRequestEntity> list, String id) {
    try {
      return list.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }
}

class _Body extends ConsumerWidget {
  final SosRequestEntity sos;
  const _Body({required this.sos});

  bool _isMyMission(WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    return user?.teamId != null && sos.assignedTeamId == user!.teamId;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMine = _isMyMission(ref);
    final householdAsync =
        ref.watch(householdByIdStreamProvider(sos.householdId));
    final canSeePII = isMine &&
        (sos.status == SosStatus.assigned ||
            sos.status == SosStatus.inProgress);

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _MiniMap(sos: sos),
                const SizedBox(height: 12),
                _PriorityHeader(sos: sos),
                const SizedBox(height: 12),
                _HouseholdCard(
                  sos: sos,
                  household: householdAsync.value,
                  canSeePII: canSeePII,
                ),
                const SizedBox(height: 12),
                if (isMine)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.lock_open, color: Colors.green.shade800, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Đã nhận nhiệm vụ — thông tin đầy đủ được mở khóa',
                            style: TextStyle(
                              color: Colors.green.shade900,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 12),
                _SituationCard(sos: sos),
                const SizedBox(height: 12),
                _PhotosCard(photos: sos.photos),
                const SizedBox(height: 12),
                _ObstacleAlert(sos: sos),
              ],
            ),
          ),
        ),
        _BottomActions(sos: sos, isMine: isMine, canSeePII: canSeePII,
            householdPhone: householdAsync.value?.contactPhone),
      ],
    );
  }
}

class _MiniMap extends StatelessWidget {
  final SosRequestEntity sos;
  const _MiniMap({required this.sos});

  @override
  Widget build(BuildContext context) {
    final center = LatLng(sos.latitude, sos.longitude);
    return Container(
      height: 160,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            CoreMapWidget(
              center: center,
              zoom: 15,
              markers: [
                Marker(
                  point: center,
                  width: 36,
                  height: 36,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFC62828),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Center(
                      child: Icon(Icons.home, color: Colors.white, size: 18),
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  '⏱ 500m · ~8 phút đi bộ',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PriorityBadgeSmall extends StatelessWidget {
  final SosPriorityLevel level;
  const _PriorityBadgeSmall({required this.level});

  @override
  Widget build(BuildContext context) {
    final color = _colorFor(level);
    final label = _labelFor(level);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 11,
            letterSpacing: 0.5),
      ),
    );
  }

  Color _colorFor(SosPriorityLevel l) {
    switch (l) {
      case SosPriorityLevel.red:
        return const Color(0xFFC62828);
      case SosPriorityLevel.orange:
        return const Color(0xFFF57C00);
      case SosPriorityLevel.yellow:
        return const Color(0xFFF9A825);
    }
  }

  String _labelFor(SosPriorityLevel l) {
    switch (l) {
      case SosPriorityLevel.red:
        return 'ĐỎ';
      case SosPriorityLevel.orange:
        return 'CAM';
      case SosPriorityLevel.yellow:
        return 'VÀNG';
    }
  }
}

class _PriorityHeader extends StatelessWidget {
  final SosRequestEntity sos;
  const _PriorityHeader({required this.sos});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _PriorityBadgeLarge(sos: sos),
        const Spacer(),
        Row(
          children: const [
            Text('🌊', style: TextStyle(fontSize: 16)),
            SizedBox(width: 4),
            Text('Lũ lụt',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
          ],
        ),
      ],
    );
  }
}

class _PriorityBadgeLarge extends StatelessWidget {
  final SosRequestEntity sos;
  const _PriorityBadgeLarge({required this.sos});

  @override
  Widget build(BuildContext context) {
    final level = sos.priorityLevel;
    final label = level == SosPriorityLevel.red
        ? 'ĐỎ'
        : level == SosPriorityLevel.orange
            ? 'CAM'
            : 'VÀNG';
    final color = level == SosPriorityLevel.red
        ? const Color(0xFFC62828)
        : level == SosPriorityLevel.orange
            ? const Color(0xFFF57C00)
            : const Color(0xFFF9A825);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '!! $label — ${sos.priorityScore} điểm',
        style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 13,
            letterSpacing: 0.5),
      ),
    );
  }
}

class _HouseholdCard extends StatelessWidget {
  final SosRequestEntity sos;
  final dynamic household; // HouseholdModel?
  final bool canSeePII;
  const _HouseholdCard({
    required this.sos,
    required this.household,
    required this.canSeePII,
  });

  @override
  Widget build(BuildContext context) {
    final headName = _headName();
    final phone = _phone();
    final address = _address();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFC62828), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$headName · $phone',
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.black87),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.location_on, color: Color(0xFFC62828), size: 14),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  address,
                  style:
                      const TextStyle(fontSize: 12, color: Colors.black87),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${sos.latitude.toStringAsFixed(4)}° N, ${sos.longitude.toStringAsFixed(4)}° E',
            style: const TextStyle(fontSize: 10.5, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  String _headName() {
    if (!canSeePII) return 'Hộ ***';
    return household?.headName ?? 'Hộ ${sos.householdId}';
  }

  String _phone() {
    if (!canSeePII) return '**** ***';
    return household?.contactPhone ?? '—';
  }

  String _address() {
    if (!canSeePII) return sos.sectorLabel ?? 'Khu vực chưa xác định';
    return household?.address ?? sos.sectorLabel ?? '—';
  }
}

class _SituationCard extends StatelessWidget {
  final SosRequestEntity sos;
  const _SituationCard({required this.sos});

  @override
  Widget build(BuildContext context) {
    final chips = <String>[
      if (sos.memberCount > 0) '${sos.memberCount} người',
      ...sos.situationChips,
    ];
    return _SectionCard(
      title: 'TÌNH HÌNH',
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        children: chips
            .map((c) => Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Text(
                    c,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.orange.shade900),
                  ),
                ))
            .toList(),
      ),
    );
  }
}

class _PhotosCard extends StatelessWidget {
  final List<String> photos;
  const _PhotosCard({required this.photos});

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'ẢNH HIỆN TRƯỜNG (${photos.length})',
      child: photos.isEmpty
          ? const Text(
              'Hộ chưa gửi ảnh hiện trường.',
              style: TextStyle(fontSize: 11, color: Colors.grey),
            )
          : Row(
              children: photos
                  .take(3)
                  .map((url) => Expanded(
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          height: 84,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                              image: NetworkImage(url),
                              fit: BoxFit.cover,
                              onError: (_, __) {},
                            ),
                          ),
                          child: url.isEmpty
                              ? const Icon(Icons.broken_image,
                                  color: Colors.grey)
                              : null,
                        ),
                      ))
                  .toList(),
            ),
    );
  }
}

class _ObstacleAlert extends StatelessWidget {
  final SosRequestEntity sos;
  const _ObstacleAlert({required this.sos});

  @override
  Widget build(BuildContext context) {
    // MVP: obstacles collection chưa được đọc realtime tại đây — hiện placeholder
    // khi có `note` bắt đầu bằng "Chướng ngại".
    final note = sos.note ?? '';
    if (!note.toLowerCase().contains('chướng')) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.amber.shade400),
      ),
      child: Row(
        children: [
          const Text('⚠️', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              note,
              style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: Colors.amber.shade900),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
                fontSize: 10.5,
                letterSpacing: 0.3),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

class _BottomActions extends ConsumerWidget {
  final SosRequestEntity sos;
  final bool isMine;
  final bool canSeePII;
  final String? householdPhone;
  const _BottomActions({
    required this.sos,
    required this.isMine,
    required this.canSeePII,
    required this.householdPhone,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE0E0E0), width: 0.5)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.phone, size: 16),
                  label: const Text('Gọi',
                      style: TextStyle(
                          fontSize: 12, fontWeight: FontWeight.bold)),
                  onPressed: !canSeePII
                      ? null
                      : () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    '📞 Đang gọi ${householdPhone ?? "hộ dân"}...')),
                          );
                        },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1976D2),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                  icon:
                      const Icon(Icons.navigation, size: 16, color: Colors.white),
                  label: const Text('Dẫn đường',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold)),
                  onPressed: () async {
                    final lat = sos.latitude;
                    final lng = sos.longitude;
                    final googleMapsUrl = Uri.parse('google.navigation:q=$lat,$lng');
                    final appleMapsUrl = Uri.parse('maps://?q=$lat,$lng');
                    final webMapsUrl = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');

                    try {
                      if (await canLaunchUrl(googleMapsUrl)) {
                        await launchUrl(googleMapsUrl);
                      } else if (await canLaunchUrl(appleMapsUrl)) {
                        await launchUrl(appleMapsUrl);
                      } else {
                        await launchUrl(webMapsUrl, mode: LaunchMode.externalApplication);
                      }
                    } catch (_) {
                      await launchUrl(webMapsUrl, mode: LaunchMode.externalApplication);
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF388E3C),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              icon: const Icon(Icons.check, color: Colors.white, size: 16),
              label: const Text(
                'BÁO CÁO HOÀN THÀNH',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                    letterSpacing: 0.5),
              ),
              onPressed: !isMine
                  ? null
                  : () =>
                      context.push('/rescue-completion?sosId=${sos.id}'),
            ),
          ),
        ],
      ),
    );
  }
}
