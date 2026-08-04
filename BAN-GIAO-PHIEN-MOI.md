# DisasterRescue — Bàn giao phiên làm việc

> Dán nguyên file này vào phiên Claude mới (hoặc lưu làm bộ nhớ dự án).
> Cập nhật lần cuối: 04/08/2026.

---

## 1. DỰ ÁN LÀ GÌ

**DisasterRescue** — app di động điều phối cứu hộ khẩn cấp thiên tai cấp xã, demo xã Bình Liêu (Quảng Ninh). Bài tập lớn môn Phát triển ứng dụng di động, CSE.TLU.

**Stack:** Flutter · Riverpod · Hive · Firebase (Auth/Firestore/Storage/FCM) · flutter_map + OpenStreetMap. **Không** dùng Google Maps.

**Tuần này chạy mock-first hoàn toàn.** Firebase chỉ wiring nếu còn thời gian.

---

## 2. NHÓM VÀ PHÂN VAI

| | Vai | Email | GitHub | Module sở hữu |
|---|---|---|---|---|
| **Tuấn** (leader) | Integration Owner | nhattuan9393@gmail.com | (chưa điền) | GOV TOOL ARCH CORE OFF AUTH MAP ESC PUB REL |
| **Minh** | Product/UX Keeper | mingdeptrai2004@gmail.com | minhminh310504 | UX NOTI SOS ASSIST HH SUP |
| **Cường** | QA/Risk Keeper | cuongjaja9@gmail.com | CuongNguyen64KTPM1 | SAFE TEAM MISS EVAC RPT QA |

Minh và Cường là **người thật**, dùng chung máy và gói AI của Tuấn do hạn chế tài chính. Tài khoản Trello/GitHub là của chính họ, thao tác do họ tự làm.

**Màn hình phụ trách:**
- Tuấn: 01, 02, 03, 09, 10, 18, 23, 33 + toàn bộ hạ tầng và PR integration
- Minh: 04, 05, 06, 06b, 08, 24, 11, 12, 25, 26, 41, 17, 30, 31, 32
- Cường: 07, 13, 14, 15, 16, 19, 20, 21, 22, 27, 28, 29, 34, 35, 36, 37, 38, 39, 40

---

## 3. LIÊN KẾT

| Công cụ | Link / ID |
|---|---|
| Figma (41 màn + prototype) | `xzPK3vAmMICpIGEkzylKUo` — https://www.figma.com/design/xzPK3vAmMICpIGEkzylKUo |
| Trello board | https://trello.com/b/HY8fenJq/disasterrescue-dieu-phoi-cuu-ho-thien-tai |
| Trello workspace ARI | `ari:cloud:trello::workspace/69310d1b39b8a37575332efc` |
| Trello board ARI | `ari:cloud:trello::board/workspace/69310d1b39b8a37575332efc/6a716340e6a6ed0d46e194ab` |
| Drive gốc | https://drive.google.com/drive/folders/1ylVohgdBq-KfUvcNNYux30DjAo7APXYx |
| Drive `00_Admin` | `147GapsD_NDMKgn32GbGmlqOVEhxPehGQ` |
| Drive `Links` doc | `15yhLdgQTMZkIl9gouT6Ii-G1jWrLM12-8pUj3YHK_k8` |
| GitHub repo | **CHƯA TẠO** — dự kiến `disaster-rescue-mobile` |

> Lấy ARI của 9 list bằng `trelloReadList` action `list_by_board`, đừng hardcode.

**Thư mục tài liệu trên PC:** `G:\Tài liệu\TLU\37. PTƯDDĐ\DisasterRescue\`
- `DisasterRescue-SRS-Full.md` (v1.1, ~4200 dòng)
- `DisasterRescue-Kiro-Final.md` (bản tóm tắt, đã đồng bộ v1.1)

---

## 4. BẢY QUYẾT ĐỊNH NGHIỆP VỤ ĐÃ CHỐT

Đã hợp nhất vào SRS v1.1. Đọc lại trước khi code bất kỳ feature nào.

**4.1 Bỏ luồng A của FR-03.** "Tôi cần được cứu — form đầy đủ" trùng với nút SOS và đi ngược nguyên tắc SOS 1 chạm. Màn "Báo tin cho xã" còn 2 luồng: B (báo giúp người khác, cần admin duyệt) và C (báo tình hình, không tạo SOS).

**4.2 Thêm `AssistanceRequest` (FR-17).** "Cần hỗ trợ sơ tán" — tách hoàn toàn khỏi SOS. SOS tính bằng phút, cái này tính bằng giờ, SLA 3 giờ, hàng đợi riêng, không chạy đồng hồ leo thang. Trang chủ hộ dân phân 3 tầng: SOS (180-250px) → Cần hỗ trợ sơ tán + Tôi vẫn an toàn (88px) → Báo giúp người khác + Báo tình hình (72px).

**4.3 Trạng thái an toàn có 5 nguồn xác nhận (FR-07.3).** Điện thoại hết pin trong lũ là chuyện bình thường, không được để trạng thái an toàn phụ thuộc một nguồn.

```
rescueTeam        100  đội xác nhận tại hiện trường (ảnh + GPS)
evacuationCheckin  95  check-in tại điểm sơ tán
selfApp            90  hộ tự báo qua app
adminManual        70  trưởng thôn xác nhận tay, bắt buộc lý do
neighborReport     40  hàng xóm báo, qua luồng B, cần duyệt
```

UI **phải tách** `Mất liên lạc — thiết bị im lặng` (xám, *phải cử người kiểm tra*) khỏi `An toàn — <nguồn>` (xanh, *không cần làm gì*).

**4.4 Hai loại đội + 5 trạng thái (FR-09.6, FR-09.8).**
- `standing` — biên chế xã, khai báo trước mùa thiên tai, mã QR cố định, kích hoạt 1 chạm không cần duyệt, có `standingEquipment`
- `adhoc` — vãng lai, tự đăng ký, chờ duyệt, có `broughtSupplies`
- Trạng thái: `available` · `onMission` · `resting` (bắt buộc lý do + giờ quay lại) · `offline` (im lặng >30 phút) · `ended`
- **Ràng buộc:** gán đội phải lọc `status == available`. Gán cho đội nghỉ khiến SOS treo mà đồng hồ leo thang vẫn chạy.

**4.5 Kho hai tầng (FR-10.7).** Tầng 1 `ReliefItem` (danh mục chuẩn, có tồn kho). Tầng 2 `ReliefPackage` mã `GCT-2025-xxxx` cho lô hàng hỗn hợp — tiếp nhận trước, phân loại sau, không chặn luồng khẩn cấp. Bốn nguồn khi phát: `communeWarehouse` (trừ tồn) · `teamStanding` · `teamBrought` · `packageDirect` (ba cái sau không trừ nhưng đều vào sổ cứu trợ).

**4.6 Leo thang bỏ mức khẩn cấp (FR-13.1).** Thay bằng `EscalationEvidence` hệ thống tự sinh: SOS đỏ chưa gán, thời gian chờ lâu nhất, hộ mất liên lạc, đội khả dụng/tổng, mặt hàng dưới ngưỡng, chỗ sơ tán trống. Admin không sửa được. Giữ lại loại yêu cầu + **số lượng cụ thể cần**.

**4.7 Định tuyến vai trò (FR-01.5).** `roles.length == 1` → vào thẳng, không hỏi. `>= 2` → mới hiện màn chọn vai trò. Situation Board **không phải vai trò**, là trang công khai.

---

## 5. ĐÃ XONG

- ✅ 41 màn Figma, 3 page, 6 section, **123 kết nối prototype**, 3 luồng demo chạy được
- ✅ 3 sơ đồ luồng nghiệp vụ (định tuyến vai trò · vòng đời SOS · vòng đời trạng thái an toàn)
- ✅ SRS nâng lên **v1.1**, hợp nhất cả 7 quyết định vào Phần 1/5/6/7, có mục 0 Lịch sử thay đổi
- ✅ `CLAUDE.md`, `DisasterRescue-Nghiepvu-v2.md`, `HUONG-DAN-SETUP-CLAUDE-CODE.md`
- ✅ Trello board + 9 list + 7 thẻ (GOV-01, TOOL-01, TOOL-02, TOOL-04, CORE-01, ARCH-05, DOC-01)
- ✅ Drive 9 thư mục + `Links` doc
- ✅ Minh đã vào board Trello

## 6. CHƯA XONG

| Việc | Ai | Chặn cái gì |
|---|---|---|
| Tạo repo GitHub + mời 2 collaborator | Tuấn | **CORE-01 và mọi thẻ code** |
| 3 thư mục clone `dr-tuan`/`dr-minh`/`dr-cuong` với `git config --local` riêng | Tuấn | Dấu vết commit 3 người |
| Copy `CLAUDE.md` + `docs/` vào repo | Tuấn | Chất lượng output Claude Code |
| Cường tạo tài khoản Trello | Cường | Dấu vết thao tác của Cường |
| ~120 thẻ Trello còn lại | Claude | Sprint 2, 3 |
| Firebase project | Tuấn | DATA-* (tuần sau) |

**Thứ tự phụ thuộc tuần này:**
`TOOL-04 → CORE-01 → ARCH-05 → CORE-02/03/04 → OFF-01/02 → AUTH-* → feature`

---

## 7. CHIA VIỆC HAI MÁY

### 7.1 Máy PC — Tuấn và Minh

Thư mục làm việc: `~/dev/dr-tuan` và `~/dev/dr-minh`.

**Nhiệm vụ phiên này:**
1. Hoàn tất mục 6 (repo, clone, copy tài liệu)
2. Chạy `CORE-01` → `ARCH-05` → `CORE-02/03/04` → `OFF-01/02`
3. Minh làm các màn Hộ dân: 04, 05, 06, 06b, 08, 24
4. Sinh nốt thẻ Trello cho module của Tuấn và Minh

**Câu mở đầu gợi ý cho phiên mới:**
> Đọc file bàn giao này. Tôi là Tuấn, đang ở máy PC phụ trách phần của tôi và Minh. Việc đầu tiên: tạo repo GitHub và chạy CORE-01. Sinh tiếp thẻ Trello cho module CORE, OFF, AUTH, MAP, ESC, PUB (Tuấn) và NOTI, SOS, ASSIST, HH, SUP (Minh).

### 7.2 Máy laptop — Cường

Thư mục làm việc: `~/dev/dr-cuong`.

**Nhiệm vụ phiên đó:**
1. Cường tạo tài khoản Trello, accept lời mời board
2. Clone repo với `git config --local user.name "Cuong"` và `user.email "cuongjaja9@gmail.com"`
3. Chờ `CORE-01` merge rồi mới code được — trong lúc chờ, làm phần QA: viết test plan, chuẩn bị test case cho 4 chỗ logic quan trọng
4. Sau đó: màn Đội cứu hộ 19, 20, 21, 22, 34, 35, 36, 39, 40 và màn admin 13, 14, 15, 16, 27, 28, 29, 37, 38

**Câu mở đầu gợi ý cho phiên đó:**
> Đọc file bàn giao này. Tôi đang ở máy laptop, phụ trách phần của Cường (QA/Risk Keeper). Sinh thẻ Trello cho module SAFE, TEAM, MISS, EVAC, RPT, QA. Trong lúc chờ CORE-01 merge, viết test plan cho 4 chỗ logic: tính điểm ưu tiên SOS, chuyển trạng thái an toàn 5 nguồn, trừ tồn kho theo nguồn, chống double-submit.

### 7.3 Quy tắc bắt buộc giữa hai máy

- **Một thư mục clone chỉ một người dùng.** Hai người cùng sửa một thư mục là hỏng lịch sử commit — đó chính là thứ giảng viên nhìn.
- Chỉ **Tuấn** được sửa `app_router.dart` và `main_shell.dart`. Người khác cần route mới thì tạo thẻ `INT-ROUTE-*`, Tuấn mở PR integration riêng.
- Mọi PR vào `develop`, không ai push thẳng `main`/`develop`.
- Trello là nguồn sự thật về trạng thái. Chat không phải nơi lưu quyết định.

---

## 8. LƯU Ý KỸ THUẬT

- **Trello Free**: không có Custom Fields. Owner/Reviewer/Tester ghi ở **đầu phần mô tả thẻ** (đúng như file mẫu TowerHub hướng dẫn). File đính kèm tối đa 10MB — video test đẩy lên Drive rồi dán link.
- **Trello MCP không gán được member vào thẻ.** Dấu vết "3 người thao tác" đến từ việc họ tự kéo thẻ và comment dưới tài khoản mình, không phải từ avatar được gán.
- **Android Studio + plugin Claude Code**: phải đổi Boot Java Runtime sang bản có **JCEF**, nếu không plugin chỉ hiện bảng hướng dẫn. `Ctrl+Shift+A` → "Choose Boot Java Runtime for the IDE".
- **Figma MCP** hay rớt kết nối giữa phiên. Nếu `use_figma` báo lỗi auth thì authorize lại trong Settings → Connectors.
- Mỗi thẻ code tôi tạo đều có sẵn khối **"Prompt dán vào Claude Code"** — copy thẳng, không cần viết lại.

---

## 9. VIỆC TIẾP THEO NGAY

1. Tuấn tạo repo GitHub, gửi URL để cập nhật `Links` doc và các thẻ TOOL-04 / CORE-01 / ARCH-05
2. Cường tạo Trello, accept board
3. Chạy CORE-01
