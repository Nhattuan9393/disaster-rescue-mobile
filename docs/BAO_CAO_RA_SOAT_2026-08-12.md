# Báo cáo rà soát nghiệp vụ & công nghệ — DisasterRescue
**Ngày:** 2026-08-12 · **Phạm vi:** toàn bộ `lib/`, `test/`, `firestore.rules` đối chiếu SRS v1.1 và Backlog (docs/07) + kịch bản 3 máy (docs/11)

---

## 1. Quy trình test 3 máy thật KHÔNG cần cắm USB mỗi lần

**Nguyên tắc:** chỉ build đầy đủ 1 lần đầu. Sau đó mọi lần sửa code chỉ cần **hot reload (~1–2 giây) đồng thời trên cả 3 máy** qua Wi-Fi.

### Thiết lập 1 lần cho mỗi máy (Android 11+)
- **Cách A — không cần cáp:** Developer options → *Wireless debugging* → *Pair device with pairing code* → trên PC: `adb pair <IP>:<PORT_PAIR>` (nhập mã).
- **Cách B — cắm cáp đúng 1 lần:** `adb tcpip 5555` rồi rút cáp (giữ đến khi máy reboot).

### Mỗi phiên làm việc
```
adb connect <IP_may_A>:5555
adb connect <IP_may_B>:5555
adb connect <IP_may_C>:5555
flutter run -d all
```
- Sửa code → nhấn `r` → **hot reload cả 3 máy cùng lúc**. `R` = hot restart. Không build lại từ đầu.
- Đã tạo sẵn script: **`tools/run_3_devices.bat`** (sửa 3 IP trong file).
- Lưu ý: PC và 3 máy cùng mạng Wi-Fi; đặt DHCP reservation để IP không đổi.

### Khi cần phát bản ổn định cho người khác test
Dùng **Firebase App Distribution**: `flutter build apk` 1 lần → tester nhận link cài tự động. Phù hợp test theo phiên bản, không phải theo từng lần sửa code.

---

## 2. Kết quả rà soát nghiệp vụ (đối chiếu SRS + Gate Phase 1)

### ✅ Đạt
| Hạng mục | Ghi chú |
|---|---|
| Offline SOS queue (DR-019/020) | Hive queue, giữ UUID local, sync idempotent (`doc(request.id)` → retry không tạo trùng), khóa `_isSyncing` chống race |
| Debounce SOS (DR-022) | 30 giây, chặn spam đúng |
| Gán đội atomic (DR-027) | Firestore Transaction, kiểm tra SOS chưa gán + đội `available` → 2 admin không thể gán trùng |
| GPS cache (DR-021) | Fallback cache khi mất GPS |
| Priority Calculator (DR-017) | Đúng công thức SRS (bệnh +20, trẻ em +15, già +15, ngập mái +20, thương +20, >5 người +10, clamp 0–100) |
| Event log bất biến (DR-032) | Rules chặn update/delete |
| Dedup báo cáo +25 điểm | Có logic khoảng cách thật (latlong2) trong `verify_reports_screen` |
| Report/Assistance offline sync | Tương tự SOS, hoạt động đúng |

### ❌ Lỗ hổng nghiêm trọng — sẽ FAIL kịch bản 3 máy (docs/11)
1. **Đăng nhập là GIẢ LẬP.** `firebase_auth` có trong pubspec nhưng **không được gọi ở bất kỳ đâu**; login chỉ điều hướng theo vai trò, không tạo user, không ghi collection `users`. Hệ quả dây chuyền:
   - `firestore.rules` đọc `users/{uid}.role` → **toàn bộ rules không thể hoạt động** (hiện Firestore chắc chắn đang chạy test mode/open).
   - **Test 5 (Security) chắc chắn FAIL.**
2. **`firestore.rules` thiếu ≥5 collections đang dùng trong code:** `assistance_requests`, `situation_reports`, `safety_confirmations`, `evacuation_points`, `evacuation_orders`. Deploy rules thật → toàn bộ Phase 2 bị `permission-denied`.
3. **Rules hiện tại vi phạm chính Test 5:** role `rescueTeam` đọc được **mọi** `households` (PII) và mọi `sos_requests` kể cả khi chưa được gán. Rule `create` SOS không chặn client tự set `status`/`assignedTeamId`.
4. **FCM chưa có (DR-031):** không có `firebase_messaging`. "Đội C nhận notification" chỉ đúng khi app đang mở (realtime stream); app nền/tắt sẽ không nhận gì.
5. **SMS Fallback là mock UI:** payload hardcode `SOS#HH100#...`, không có plugin gửi SMS.
6. **Situation Board hardcode dữ liệu** (nhu cầu vật tư, liên hệ...) — chưa đọc Firestore, chưa đúng FR-11.

### ⚠️ Trung bình
- `updateSosStatus` không ghi event log → lifecycle log (DR-032) thiếu bước "Tôi đi"/hoàn thành.
- Logic dedup nằm ở UI layer thay vì domain; test dedup chỉ giả lập `copyWith` cộng điểm, chưa test khoảng cách/thời gian thật.
- Chưa có integration test / Firebase Emulator (DR-013, DR-034) — 4 file test hiện tại đều là unit test thuần model.
- Sandbox của tôi không cài được Flutter SDK → hãy chạy trên máy bạn: `flutter analyze && flutter test`.

---

## 3. Đáp ứng công nghệ so với SRS
| Yêu cầu SRS | Trạng thái |
|---|---|
| Flutter + Riverpod + go_router + freezed | ✅ |
| Firestore realtime | ✅ (dùng snapshots) |
| Hive offline-first | ✅ |
| flutter_map + OSM | ✅ |
| Firebase Auth | ❌ khai báo nhưng chưa tích hợp |
| FCM push notification | ❌ chưa có dependency |
| SMS fallback | ❌ mock |
| Security Rules đầy đủ | ❌ thiếu collections + sai mô hình PII |

---

## 4. Việc cần làm trước khi chạy Gate Phase 1 trên 3 máy thật (theo thứ tự)
1. Tích hợp Firebase Auth thật (tối thiểu: anonymous/email) + ghi doc `users/{uid}` chứa `role` khi đăng ký.
2. Bổ sung rules cho 5 collections thiếu; sửa rule households/sos theo mô hình "đội chỉ thấy SOS được gán".
3. Thêm `firebase_messaging` cho DR-031 (hoặc chấp nhận giới hạn "app phải mở" và ghi rõ trong biên bản test).
4. Ghi event log ở `updateSosStatus`.
5. Chạy `flutter analyze && flutter test` + test 5 kịch bản docs/11 bằng quy trình mục 1.
