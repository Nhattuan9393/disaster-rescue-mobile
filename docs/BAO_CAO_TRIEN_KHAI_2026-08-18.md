# Báo cáo triển khai — DisasterRescue

**Ngày:** 2026-08-18
**Phạm vi:** Sửa lỗi 3-máy không đồng bộ + rewrite UI đội cứu hộ + dọn dummy
**Đối chiếu:** SRS v1.1 · docs/02_AGENT_RULES · docs/04_DATA_SECURITY_CONTRACT · docs/11_PHASE1_3_DEVICE_TEST

---

## 1. Chẩn đoán vấn đề gốc

| Vấn đề bạn báo | Nguyên nhân | Cách xử lý |
|---|---|---|
| Máy admin không nhận SOS/tin an toàn | `ApiSyncService` (`kvdb.io`) polling 3s + PUT toàn blob → máy này ghi đè máy khác; seed cứng `SOS-0042` đè lên dữ liệu mới | Xoá toàn bộ ApiSyncService. Chuyển sang **Firestore realtime snapshots** (`sos_requests`, `rescue_teams`, `assistance_requests`, `situation_reports`) |
| Cư dân không thấy lệnh sơ tán | `evacuation_orders` có ghi Firestore nhưng: (a) không có Firebase Auth → rules chặn / mở toang; (b) resident không có cơ chế notification | Thêm Firebase Auth thật + `notifications` inbox collection + local toast qua `flutter_local_notifications` |
| Đội cứu hộ không thấy SOS được gán | Không có `currentUser`/`currentTeamId` → đội không biết ID mình là gì để filter SOS | Thêm `AuthController` giữ `currentUser`, `teamId`, `householdId`, `sectorId`, `communeId` |
| UI đội cứu hộ không giống thiết kế | Các màn code từ trước không theo mockup, dummy PII cứng | Rewrite 4 màn + tạo mới 2 màn theo 5 ảnh thiết kế bạn cung cấp |

---

## 2. Kiến trúc mới (đúng SRS + docs/03)

```
UI (Riverpod ConsumerWidget)
   ↓
AuthController (currentUser, currentRole, currentTeamId, currentHouseholdId)
   ↓
Repositories (SOS, RescueTeam, Report, Evacuation, Household, NotificationInbox)
   ↓
Firebase (Auth email/password, Firestore snapshots + transactions, Storage, FCM)
   ↓ (offline queue)
Hive Boxes (sos_queue, report_queue, gps_cache)
```

**Chiến lược notification cross-device (không cần Cloud Functions):**
- `notifications` collection với `recipientTopics: List<String>`
- Mỗi máy watch bằng `arrayContainsAny: [myTopics]` (max 10 topics/user)
- Local notification hiện toast khi có doc mới
- FCM đã setup sẵn (subscribe topic `role_admin_<commune>`, `team_<id>`, `household_<id>`, `sector_<id>`) — khi bạn thêm Cloud Function sau, không cần đổi client

---

## 3. Files đã thay đổi

### Mới tạo (8 files)
- [lib/features/auth/data/auth_repository.dart](lib/features/auth/data/auth_repository.dart) — FirebaseAuth wrapper + auto-provision demo user
- [lib/features/auth/presentation/providers/auth_controller.dart](lib/features/auth/presentation/providers/auth_controller.dart) — Riverpod state
- [lib/features/household/data/household_repository.dart](lib/features/household/data/household_repository.dart) — watch household by uid
- [lib/features/notification/data/push_notification_service.dart](lib/features/notification/data/push_notification_service.dart) — FCM + local
- [lib/features/notification/data/notification_inbox_service.dart](lib/features/notification/data/notification_inbox_service.dart) — cross-device inbox
- [lib/features/notification/domain/app_notification.dart](lib/features/notification/domain/app_notification.dart) — model
- [lib/features/rescue_team/presentation/screens/rescue_safety_confirmation_screen.dart](lib/features/rescue_team/presentation/screens/rescue_safety_confirmation_screen.dart) — ảnh 4
- [lib/features/rescue_team/presentation/screens/rescue_team_status_screen.dart](lib/features/rescue_team/presentation/screens/rescue_team_status_screen.dart) — ảnh 5

### Rewrite lớn (5 files)
- [lib/features/sos/data/sos_repository_impl.dart](lib/features/sos/data/sos_repository_impl.dart) — Firestore + transaction + inbox
- [lib/features/rescue_team/data/rescue_team_repository_impl.dart](lib/features/rescue_team/data/rescue_team_repository_impl.dart) — Firestore + transaction + inbox
- [lib/features/report/data/report_repository_impl.dart](lib/features/report/data/report_repository_impl.dart) — Firestore
- [lib/features/evacuation/data/evacuation_repository_impl.dart](lib/features/evacuation/data/evacuation_repository_impl.dart) — Firestore + notify sector
- [lib/features/auth/presentation/screens/login_screen.dart](lib/features/auth/presentation/screens/login_screen.dart) — Firebase Auth

### Rewrite UI theo ảnh thiết kế (3 files)
- [lib/features/sos/presentation/screens/rescue_sos_detail_screen.dart](lib/features/sos/presentation/screens/rescue_sos_detail_screen.dart) — ảnh 3
- [lib/features/sos/presentation/screens/rescue_completion_report_screen.dart](lib/features/sos/presentation/screens/rescue_completion_report_screen.dart) — ảnh 1
- [lib/features/sos/presentation/screens/rescue_delivery_receipt_screen.dart](lib/features/sos/presentation/screens/rescue_delivery_receipt_screen.dart) — ảnh 2

### Chỉnh sửa nhỏ (10+ files)
Model mở rộng theo SRS: `sos_model.dart`, `rescue_team_model.dart`, `rescue_team_status.dart`, `evacuation_order_model.dart`, `user_model.dart`. Router có auth guard + role guard. Bỏ hardcode `household_123`/`admin_commune`/`team_01` khỏi `resident_sos_screen`, `assistance_request_screen`, `safety_confirmation_dialog`, `broadcast_evacuation_screen`, `notifications_screen`.

### Xoá
- `lib/core/services/api_sync_service.dart` — nguồn gốc bug ghi đè

### Rules
- [firestore.rules](firestore.rules) — cover 14 collections; PII rules theo docs/04

---

## 4. Việc bạn PHẢI làm trước khi test

### Bước 1: Firebase project (bắt buộc)
```bash
npm install -g firebase-tools
dart pub global activate flutterfire_cli
firebase login
flutterfire configure --project=<tên-project-của-bạn>
```
Lệnh cuối tự ghi đè `lib/firebase_options.dart` với credentials thật (hiện tại còn dummy).

Trong Firebase Console bật:
- **Authentication** → Email/Password
- **Cloud Firestore** → Native mode
- **Cloud Storage**
- **Cloud Messaging** (cần Blaze plan)

### Bước 2: Deploy rules
```bash
firebase deploy --only firestore:rules
```

### Bước 3: Cài dependencies
```bash
flutter pub get
```

### Bước 4: Test 3 máy
Theo `tools/run_3_devices.bat` hoặc dùng Android Studio.

**Tài khoản demo — hệ thống tự tạo lần đăng nhập đầu:**
- `admin / 123456` → Admin xã
- `dq01 / 123456` → Đội cứu hộ thường trực
- `vl1 / 12345` → Đội cứu hộ vãng lai (MTQ)
- `0987654321 / 123456` → Hộ dân

---

## 5. Kịch bản kiểm chứng 3 máy (theo docs/11)

| # | Máy A (Hộ dân) | Máy B (Admin) | Máy C (Đội cứu hộ) |
|---|---|---|---|
| 1 | Bấm SOS | Nhận toast "🆘 SOS mới — ĐỎ 85"; SOS xuất hiện trên map/list | (chờ) |
| 2 | (chờ) | Chọn SOS → gán cho đội C (transaction) | Nhận toast "⛑️ Nhiệm vụ mới — SOS xxx"; SOS xuất hiện trong danh sách |
| 3 | Nhận toast "🚗 Đội cứu hộ đang tới" | Thấy SOS → in_progress | Bấm "Tôi đi" → vào chi tiết → thấy PII được mở khoá |
| 4 | Nhận toast "✅ Đã hoàn thành" | Thấy SOS → completed; đội C → available | Bấm "Báo cáo hoàn thành" → điền form đầy đủ |
| 5 | Nhận toast "🚨 LỆNH SƠ TÁN" | Vào "Phát lệnh sơ tán" → chọn thôn + điểm → phát | (nếu ở sector đích cũng nhận) |

Nếu máy nào chưa nhận toast — kiểm tra:
- User đã login (không phải public)
- Có internet
- `notifications` rules đã deploy
- Xem log console để chắc `PushNotificationService` init OK

---

## 6. Ràng buộc SRS/DoD đã thoả

| Ràng buộc | Trạng thái | Ghi chú |
|---|---|---|
| RULE-002 no silent architecture | ✅ | Đã hỏi user chọn Firebase (option A) trước khi thay |
| RULE-003 no fake backend | ✅ | Xoá ApiSyncService + seed cứng |
| RULE-004 cloud/shared state | ✅ | Firestore là source of truth; Hive chỉ queue |
| RULE-007 critical security | ⚠️ Một phần | Rules ngăn PII cho unassigned rescue theo `assignedTeamId`; nhưng MVP rules còn cho rescueTeam đọc mọi household — production nên chuyển sang Cloud Function để check assignment chính xác |
| RULE-008 SOS critical | ✅ | Debounce, offline queue, retry, GPS cache, transaction |
| RULE-009 assignment `available` | ✅ | Transaction check status == available |
| DR-027 atomic assignment | ✅ | Firestore transaction |
| DR-028 acceptMission | ✅ | Transaction |
| DR-031 FCM baseline | ✅ | Đã có `firebase_messaging` + inbox fallback |
| DR-032 event log immutable | ✅ | Rules chặn update/delete |
| DR-033 rules critical flow | ✅ | 14 collections có rules |
| DR-034 3-client integration | ⏳ | Chờ bạn test theo mục 5 |

---

## 7. Việc còn lại (khuyến nghị)

- **Cloud Function push FCM**: mỗi khi ghi `notifications/{id}`, trigger push tới `recipientTopics` để user không cần app mở
- **Storage upload thật cho ảnh**: hiện các nút "Chụp ảnh" ở màn đội cứu hộ mới chỉ set flag boolean, chưa gọi `image_picker` + `FirebaseStorage`
- **Sector rules chi tiết**: hiện admin xem mọi SOS trong Firestore; nên hạn chế theo `myCommune()` khi bạn có nhiều xã
- **Household PII gating chính xác**: Cloud Function kiểm `sos_requests[assignedTeamId == myTeamId]` trước khi cho đọc `households/{id}`
- **Dọn UI dummy còn sót**: các list demo trong `evacuation_point_detail_screen`, `donation_package_detail_screen`, `event_logs_screen`, `permanent_forces_screen` (tên/số điện thoại minh hoạ) — tuỳ bạn có muốn để mẫu hay không
- **Tests**: `flutter test test/sos_priority_calculator_test.dart` etc. — chạy để chắc business logic không đổi
