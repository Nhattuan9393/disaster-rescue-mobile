# CLAUDE.md — DisasterRescue

Hướng dẫn cho agent (Claude Code / Antigravity / Gemini) khi làm việc trong repo này. Đọc file này trước mọi task.

---

## 1. Dự án

**DisasterRescue** — ứng dụng di động điều phối cứu hộ khẩn cấp thiên tai cấp xã tại Việt Nam.
Phạm vi demo: xã Bình Liêu, tỉnh Quảng Ninh (lũ lụt, sạt lở, cháy rừng, bão).

**Năm nguyên tắc thiết kế cốt lõi — không được vi phạm:**

1. **Offline-first** — mọi chức năng quan trọng phải chạy được khi mất mạng. SOS, xác nhận an toàn, check-in đều phải có hàng đợi local.
2. **SOS 1 chạm** — không bao giờ bắt người dùng điền form trước khi gửi SOS. Gửi trước, bổ sung sau.
3. **Số tuyệt đối** — hiển thị "45/200 người", KHÔNG hiển thị "22%".
4. **Phù hợp địa phương** — Tiếng Việt mặc định, Tiếng Tày cho thông báo quan trọng vùng Bình Liêu.
5. **Bảo mật thông tin hộ dân** — đội cứu hộ KHÔNG thấy tên/SĐT/địa chỉ chi tiết trước khi nhận nhiệm vụ.

---

## 2. QUYẾT ĐỊNH NGHIỆP VỤ ĐÃ CHỐT

> SRS đã nâng lên **v1.1** và hợp nhất toàn bộ 7 quyết định dưới đây.
> Mục này là **bản tóm tắt nhanh cho agent**; khi cần chi tiết đầy đủ, đọc
> `docs/DisasterRescue-SRS-Full.md`.

### 2.1 Bỏ luồng A của FR-03 — thay bằng AssistanceRequest

Luồng A "Tôi cần được cứu — form đầy đủ" đã bị loại bỏ vì trùng chức năng với nút SOS và đi ngược nguyên tắc "SOS 1 chạm".

Thay bằng **`AssistanceRequest`** — "Cần hỗ trợ sơ tán" (FR-17):

| | `SosRequest` | `AssistanceRequest` |
|---|---|---|
| Ngữ cảnh | Nguy hiểm TỨC THÌ | Còn thời gian |
| Đơn vị thời gian | Phút | Giờ |
| Ví dụ | Nước đã vào nhà, đất đang sạt | Cần xe chở cụ già đi sơ tán trước tối nay |
| Hàng đợi | Hàng đợi SOS (đỏ/cam/vàng) | Hàng đợi riêng, SLA 3 giờ |
| Leo thang tự động | Có (15/30/60 phút) | Không |

Trang chủ hộ dân phân **3 tầng theo mức khẩn cấp**:
- Tầng 1: nút SOS (180-250px)
- Tầng 2: `Cần hỗ trợ sơ tán` + `Tôi vẫn an toàn` (~88px)
- Tầng 3: `Báo giúp người khác` + `Báo tình hình khu vực` (~72px)

Màn "Báo tin cho xã" chỉ còn 2 luồng: B (báo giúp người khác → admin duyệt) và C (báo tình hình → không tạo SOS). Stepper 2 bước.

### 2.2 Trạng thái an toàn có NHIỀU NGUỒN XÁC NHẬN

Điện thoại hết pin / rơi nước trong lũ là chuyện bình thường. Không được để trạng thái an toàn phụ thuộc duy nhất vào thiết bị của hộ dân.

```dart
class SafetyStatus {
  final SafetyState status;      // safe | sos | missingContact | rescued | evacuated
  final SafetySource source;
  final String? verifiedBy;      // userId, null nếu tự báo
  final DateTime verifiedAt;
  final int confidence;          // 0-100
  final String? note;

  bool get requiresFieldCheck => status == SafetyState.missingContact;
}

enum SafetySource {
  rescueTeam,          // 100 — đội xác nhận tại hiện trường (ảnh + GPS)
  evacuationCheckin,   //  95 — check-in tại điểm sơ tán
  selfApp,             //  90 — hộ dân tự báo qua app
  adminManual,         //  70 — trưởng thôn xác nhận thủ công
  neighborReport,      //  40 — hàng xóm báo hộ (qua luồng B, cần duyệt)
}
```

**UI phải TÁCH hai trạng thái:**

| Chip | Màu | Ý nghĩa vận hành |
|---|---|---|
| `Mất liên lạc — thiết bị im lặng` | `#616161` | **Có thể mắc kẹt → PHẢI cử người kiểm tra** |
| `An toàn — đội xác nhận` ⛑️ | `#388E3C` | Không cần làm gì |
| `An toàn — check-in sơ tán` 🏫 | `#388E3C` | Không cần làm gì |
| `An toàn — tự báo` 📱 | `#388E3C` | Không cần làm gì |

Luôn hiển thị nguồn kèm trạng thái.

### 2.3 Đội cứu hộ có 2 loại và 5 trạng thái

| | Đội thường trực (`standing`) | Đội vãng lai (`adhoc`) |
|---|---|---|
| Ai tạo | Admin xã tạo trước mùa thiên tai | Tự đăng ký khi có thiên tai |
| Kích hoạt | 1 chạm, KHÔNG cần duyệt | Đăng ký → chờ duyệt |
| Vật tư | `standingEquipment` — biên chế | `broughtSupplies` — mang theo đợt này |
| Mã QR | Cố định (`DR-BL-DQ-PL01`) | Quét mã chốt |

```dart
enum TeamStatus {
  available,   // Sẵn sàng      — NHẬN push SOS mới
  onMission,   // Đang nhiệm vụ — hệ thống tự đặt khi bấm "Tôi đi"
  resting,     // Tạm nghỉ      — BẮT BUỘC lý do + giờ quay lại, KHÔNG đẩy SOS
  offline,     // Mất kết nối   — tự đặt sau 30 phút im lặng, cảnh báo admin
  ended,       // Kết thúc ca
}
```

**Ràng buộc:** logic gán đội PHẢI lọc `status == available`. Gán cho đội `resting` hoặc `offline` khiến SOS treo — không ai nhận nhưng đồng hồ leo thang vẫn chạy. Đây là cách mất SOS phổ biến nhất.

### 2.4 Kho cứu trợ — mô hình 2 tầng

**Tầng 1 `ReliefItem`**: danh mục chuẩn, có tồn kho, ngưỡng cảnh báo.

**Tầng 2 `ReliefPackage`**: lô hàng hỗn hợp từ đoàn từ thiện.

```dart
class ReliefPackage {
  final String code;          // GCT-2025-0007 — tự sinh, dán lên thùng
  final String donorName;
  final String donorPhone;
  final PackageStatus status; // received → classified → distributed
  final List<PackageLine> lines;

  bool get canDistributeAsWhole => status == PackageStatus.received;
}

class PackageLine {
  final String rawName;       // nhập thô
  final num quantity;
  final String unit;
  final String? mappedItemId; // null = chưa map, giữ theo mã gói
}
```

Luồng: tiếp nhận nhanh, sinh mã ngay, **KHÔNG chặn** → phát nguyên gói được khi khẩn → khi rảnh mới map từng dòng, dòng map được thì cộng tồn kho.

```dart
enum SupplySource {
  communeWarehouse,  // kho xã → TRỪ tồn kho
  teamStanding,      // biên chế đội → không trừ
  teamBrought,       // đội vãng lai tự mang → không trừ
  packageDirect,     // phát nguyên gói chưa phân loại
}
```

Cả bốn nguồn đều vào `ReliefReceipt`.

**Tổng vật tư khả dụng** = tồn kho + Σ(vật tư biên chế các đội) + Σ(vật tư đội vãng lai mang). Đây là con số quyết định có cần leo thang xin vật tư hay không.

### 2.5 Leo thang — bỏ trường mức khẩn cấp

Hành động leo thang tự nó đã là tuyên bố "xã hết khả năng". Nhãn tự đánh giá vô nghĩa vì xã nào cũng chọn mức cao nhất.

```dart
class EscalationEvidence {
  final int redSosUnassigned;
  final Duration longestWait;
  final int householdsMissing;
  final int teamsAvailable;
  final int teamsTotal;
  final int itemsBelowThreshold;
  final int evacuationSlotsFree;
  final DateTime computedAt;
  // Không có setter — admin không sửa được
}
```

Giữ lại: loại yêu cầu (nhân lực/vật tư/y tế/khác) + **số lượng cụ thể cần**.

### 2.6 Định tuyến vai trò sau đăng nhập

```
roles.length == 1 → vào THẲNG màn tương ứng (không hỏi)
roles.length >= 2 → hiện màn Chọn vai trò
```

Phải có nút **đổi vai trò** trong Hồ sơ (không cần đăng xuất). **Situation Board KHÔNG phải vai trò** — là trang công khai không cần đăng nhập.

### 2.7 Import hộ dân là công tác chuẩn bị

Làm trước mùa thiên tai. Trên mobile: **không kéo-thả**, dùng file picker + nhận file từ Zalo/Email + link Google Sheet. Có màn nhập thủ công từng hộ (FR-05.4) và màn xử lý trùng lặp so sánh 2 cột (FR-05.5).

---

## 3. Stack kỹ thuật

| Lớp | Công nghệ | Ghi chú |
|---|---|---|
| UI | Flutter (Material 3) | Android 8.0+ / iOS 13.0+ |
| State | Riverpod | |
| Local storage | Hive | SOS queue, GPS cache, offline data |
| Backend | Firebase Auth + Firestore + Storage + FCM | Không tự host server |
| Map | `flutter_map` + OpenStreetMap tiles | KHÔNG dùng Google Maps |
| Ngôn ngữ | `flutter_localizations` — vi_VN, tay_VN | |

OSM tiles pre-cache trước mùa thiên tai. SMS fallback khi chỉ có sóng 2G.

---

## 4. Cấu trúc thư mục

```
lib/
├── main.dart
├── app.dart                      # MaterialApp, router, theme
├── core/
│   ├── theme/                    # AppColors, AppTypography, AppSpacing, AppRadius
│   ├── router/                   # go_router config
│   ├── constants/
│   ├── utils/
│   └── extensions/
├── data/
│   ├── models/                   # domain models (freezed + json_serializable)
│   ├── repositories/             # interface + impl Firestore
│   ├── datasources/
│   │   ├── remote/               # Firestore, FCM, Storage
│   │   └── local/                # Hive boxes, SOS queue, GPS cache
│   └── services/                 # location, connectivity, sms_fallback, notification
├── features/
│   ├── auth/                     # login, register, role_select
│   ├── household/                # trang chủ hộ dân, hồ sơ, đăng ký
│   ├── sos/                      # SOS 1 chạm, assistance_request, báo tin
│   ├── safety/                   # xác nhận an toàn, safety_status
│   ├── notification/             # danh sách + chi tiết thông báo
│   ├── admin_dashboard/          # bản đồ, KPI, FAB menu
│   ├── household_registry/       # import, đối chiếu, chi tiết hộ, trùng lặp
│   ├── rescue_team/              # lực lượng, thường trực, chi tiết đội, QR
│   ├── mission/                  # nhiệm vụ đội, chi tiết SOS, hoàn thành
│   ├── report_review/            # duyệt báo cáo, xác minh
│   ├── evacuation/               # điểm sơ tán, check-in, phát lệnh
│   ├── relief/                   # kho, nhập/xuất/phát, gói cứu trợ, biên nhận
│   ├── escalation/               # leo thang, nhật ký
│   └── situation_board/          # công khai
└── shared/
    └── widgets/                  # SosButton, StatusChip, PriorityBadge, KpiCard,
                                  # HouseholdCard, StockCard, OfflineBanner,
                                  # LineEntryTable, QuantityStepper, AutoMetricsBlock
```

Mỗi feature: `presentation/` (screens, widgets) + `providers/` (Riverpod) + `domain/` (use cases nếu cần).

---

## 5. Design tokens

Đặt ở `lib/core/theme/`. **Không hardcode màu/spacing ở nơi khác.**

```dart
class AppColors {
  static const primary        = Color(0xFFD32F2F);  // Emergency red — nút SOS
  static const primaryLight   = Color(0xFFFF6659);
  static const primaryDark    = Color(0xFF9A0007);

  static const priorityRed    = Color(0xFFD32F2F);  // score >= 70
  static const priorityOrange = Color(0xFFF57C00);  // score 40-69
  static const priorityYellow = Color(0xFFF9A825);  // score < 40

  static const statusSafe      = Color(0xFF388E3C);
  static const statusRescuing  = Color(0xFF1976D2);
  static const statusMissing   = Color(0xFF616161);
  static const statusPending   = Color(0xFFF57C00);

  static const background    = Color(0xFFF5F5F5);
  static const surface       = Color(0xFFFFFFFF);
  static const infoBlue      = Color(0xFF1976D2);
  static const warningBanner = Color(0xFFFFF8E1);

  static const textPrimary   = Color(0xFF212121);
  static const textSecondary = Color(0xFF757575);
  static const textDisabled  = Color(0xFFBDBDBD);
}

class AppTypography {
  static const fontFamily = 'Inter';   // fallback: Roboto
  static const h1         = TextStyle(fontSize: 24, fontWeight: FontWeight.w700, height: 1.3);
  static const h2         = TextStyle(fontSize: 20, fontWeight: FontWeight.w600, height: 1.4);
  static const h3         = TextStyle(fontSize: 18, fontWeight: FontWeight.w600, height: 1.4);
  static const bodyLarge  = TextStyle(fontSize: 16, fontWeight: FontWeight.w400, height: 1.5);
  static const bodyMedium = TextStyle(fontSize: 14, fontWeight: FontWeight.w400, height: 1.5);
  static const caption    = TextStyle(fontSize: 12, fontWeight: FontWeight.w400, height: 1.4);
  static const label      = TextStyle(fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.5);
  static const button     = TextStyle(fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 0.5);
  static const sosButton  = TextStyle(fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: 1.0);
}

class AppSpacing {
  static const xs = 4.0;  static const sm = 8.0;  static const md = 12.0;
  static const base = 16.0; static const lg = 24.0; static const xl = 32.0; static const xxl = 48.0;
}

class AppRadius {
  static final card        = BorderRadius.circular(8);
  static final button      = BorderRadius.circular(8);
  static final chip        = BorderRadius.circular(50);
  static final sosButton   = BorderRadius.circular(16);
  static const bottomSheet = BorderRadius.vertical(top: Radius.circular(16));
}
```

---

## 6. Điểm ưu tiên SOS (FR-02.3)

```dart
int calculatePriority(SosContext c) {
  var s = 0;
  if (c.hasChildren)          s += 15;
  if (c.hasElderly)           s += 15;
  if (c.hasSeriouslyIll)      s += 20;
  if (c.hasDisabled)          s += 10;
  if (c.groundFloorFlooded)   s += 15;
  if (c.needsMedicine)        s += 10;
  if (c.waterLevel == WaterLevel.roof)  s += 20;
  if (c.waterLevel == WaterLevel.chest) s += 10;
  if (c.houseType == HouseType.level4)  s += 10;
  if (c.peopleCount > 5)      s += 5;
  return s;
}
// >= 70 → đỏ (khẩn cấp) | 40-69 → cam (nguy hiểm) | < 40 → vàng (cần hỗ trợ)
```

**SOS gửi không điền gì thêm vẫn tính được điểm hợp lý** vì hồ sơ hộ đã có sẵn `peopleCount`, `houseType`, `hasChildren`, `hasElderly` từ lúc đăng ký. **Không được chặn gửi SOS vì thiếu dữ liệu.**

---

## 7. Figma

**File key:** `xzPK3vAmMICpIGEkzylKUo`
**URL:** https://www.figma.com/design/xzPK3vAmMICpIGEkzylKUo

41 màn, 3 page, 123 kết nối prototype.

| Page | Section | Màn |
|---|---|---|
| A — Hộ dân | Design System | tokens + component library |
| A | NHÓM A | 01-09 + 06b (10 màn) |
| A | NHÓM A2 | 24 Chi tiết thông báo |
| B — Admin xã | NHÓM B | 10-18 (9 màn) |
| B | NHÓM B2 | 25-33, 37, 38, 41 (12 màn) |
| C — Đội cứu hộ | NHÓM C | 19-23 (5 màn) |
| C | NHÓM C2 | 34-36, 39, 40 (5 màn) |

Khi implement một màn, dùng Figma MCP `get_design_context` với `node-id` thay vì đoán.

---

## 8. Lệnh thường dùng

```bash
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs   # freezed/json
flutter analyze
flutter test
flutter run -d <device>
flutter build apk --release
```

Chạy `flutter analyze` sau mỗi thay đổi lớn. Không commit khi analyze còn lỗi.

---

## 9. Quy ước code

- **Đặt tên file:** `snake_case.dart`. Screen: `sos_one_tap_screen.dart`. Widget dùng lại: `status_chip.dart`. Provider: `sos_provider.dart`.
- **Model:** `freezed` + `json_serializable`. Mọi model có `fromJson`/`toJson`.
- **Không** dùng `setState` cho state dùng chung — dùng Riverpod.
- **Không** gọi Firestore trực tiếp từ widget — luôn qua repository.
- **Mọi thao tác ghi quan trọng** (SOS, xác nhận an toàn, check-in, phát hàng) phải có đường offline: ghi Hive trước, sync sau.
- **Chuỗi hiển thị** để trong `l10n/`, không hardcode tiếng Việt trong widget.
- Comment tiếng Việt được, tên biến/hàm tiếng Anh.

---

## 10. Tài liệu tham chiếu trong repo

| File | Nội dung |
|---|---|
| `docs/DisasterRescue-SRS-Full.md` | **SRS v1.1** — nguồn sự thật đầy đủ, đã hợp nhất 10 quyết định nghiệp vụ |
| `docs/DisasterRescue-Nghiepvu-v2.md` | Giải thích **vì sao** từng quyết định được đưa ra |
| `docs/BAN-GIAO-PHIEN-MOI.md` | Bàn giao ngữ cảnh khi mở phiên agent mới |

SRS v1.1 đã hợp nhất toàn bộ quyết định nghiệp vụ. Mục 2 của file này là bản tóm tắt nhanh cho agent; khi cần chi tiết đầy đủ, đọc SRS.

---

## 11. Nhắc cho agent

- Trước khi code một feature, đọc phần FR tương ứng trong SRS v1.1 **và** đối chiếu mục 2 ở trên.
- Khi implement màn hình, ưu tiên lấy spec từ Figma MCP thay vì đoán từ mô tả.
- Không tự ý thêm thư viện ngoài stack ở mục 3 mà không hỏi.
- Không đơn giản hoá logic offline để code chạy nhanh — offline là yêu cầu cốt lõi.
- Viết test cho: tính điểm ưu tiên, SOS queue offline, chuyển trạng thái an toàn, trừ tồn kho theo nguồn, chống double-submit.
- Chỉ Integration Owner (Tuấn) được sửa `app_router.dart` và `main_shell.dart`.
