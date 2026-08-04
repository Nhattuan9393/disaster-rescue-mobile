# Kế hoạch & Kịch bản Kiểm thử Nghiệp vụ Cốt lõi (QA Test Plan)
**Dự án:** DisasterRescue
**Người thực hiện:** Cường (QA/Risk Keeper)
**Ngày cập nhật:** 04/08/2026

Tài liệu này đặc tả các kịch bản kiểm thử (Acceptance Test Cases) cho 4 phân vùng logic nghiệp vụ quan trọng nhất của ứng dụng DisasterRescue theo phiên bản đặc tả SRS v1.1.

---

## 1. Tính Điểm Ưu Tiên SOS Tự Động (FR-02.3)

### Quy tắc tính điểm:
* **Nhân khẩu & Đối tượng yếu thế:** Trẻ em (+15) · Người già (+15) · Bệnh hiểm nghèo (+20) · Khuyết tật (+10) · Tổng thành viên > 5 người (+5).
* **Điều kiện hạ tầng:** Nhà cấp 4 (+10).
* **Tình huống khẩn cấp (nếu có bổ sung):** Ngập tầng 1 (+15) · Cần thuốc men gấp (+10) · Nước ngập ngang ngực (+10) · Nước ngập mức mái nhà (+20).
* **Phân loại mức độ nguy cấp:**
  * **Mức Đỏ (Khẩn cấp):** $\ge 70$ điểm.
  * **Mức Cam (Nguy hiểm):** $40 - 69$ điểm.
  * **Mức Vàng (Cần hỗ trợ):** $< 40$ điểm.

### Kịch bản kiểm thử (Test Cases):

| Mã TC | Tên kịch bản | Dữ liệu đầu vào | Kết quả mong đợi | Loại kiểm thử |
|---|---|---|---|---|
| **TC-PRI-01** | SOS Trắng (Chỉ lấy thông tin đăng ký của hộ) | Hộ dân A đăng ký: Nhà cấp 4, 3 người, có 1 người già (+15), 1 trẻ em (+15). Bấm SOS 1 chạm không bổ sung thông tin. | * Tổng điểm: $15 \text{ (già)} + 15 \text{ (trẻ)} + 10 \text{ (cấp 4)} = 40$ điểm.<br>* Xếp loại: **Mức Cam** (Nguy hiểm).<br>* Gửi SOS thành công. | Happy Path |
| **TC-PRI-02** | SOS Trắng (Hộ thường, không có yếu tố đặc biệt) | Hộ dân B: Nhà tầng, 3 thành viên, không có người yếu thế. Bấm SOS 1 chạm. | * Tổng điểm: $0$ điểm.<br>* Xếp loại: **Mức Vàng** (Cần hỗ trợ).<br>* SOS gửi thành công, không bị chặn vì thiếu dữ liệu. | Happy Path |
| **TC-PRI-03** | SOS bổ sung thông tin khẩn cấp tối đa (Đỏ) | Hộ dân C đăng ký: Nhà cấp 4 (+10), có người bệnh nặng (+20), 6 người (+5). Bổ sung khi gửi SOS: Nước ngập mức mái (+20), ngập tầng 1 (+15), cần thuốc men (+10). | * Tổng điểm: $10 + 20 + 5 + 20 + 15 + 10 = 80$ điểm.<br>* Xếp loại: **Mức Đỏ** (Khẩn cấp).<br>* Gửi SOS thành công với trạng thái đỏ trên Dashboard Admin. | Happy Path |
| **TC-PRI-04** | Kiểm tra điểm biên phân loại (Mức Cam tối thiểu) | Điểm tính toán đạt đúng 40 điểm. | Xếp loại **Mức Cam**. | Edge Case |
| **TC-PRI-05** | Kiểm tra điểm biên phân loại (Mức Cam tối đa) | Điểm tính toán đạt đúng 69 điểm. | Xếp loại **Mức Cam**. | Edge Case |
| **TC-PRI-06** | Kiểm tra điểm biên phân loại (Mức Đỏ tối thiểu) | Điểm tính toán đạt đúng 70 điểm. | Xếp loại **Mức Đỏ**. | Edge Case |

---

## 2. Xác Nhận An Toàn 5 Nguồn (FR-07.3 & FR-06.3)

### Quy tắc độ tin cậy (Confidence score):
1. `rescueTeam` (100) — Đội cứu hộ xác nhận trực tiếp tại hiện trường (bắt buộc kèm ảnh + GPS).
2. `evacuationCheckin` (95) — Check-in tại điểm sơ tán tập trung.
3. `selfApp` (90) — Hộ dân tự báo an toàn trên ứng dụng.
4. `adminManual` (70) — Trưởng thôn xác nhận thủ công (bắt buộc nhập lý do).
5. `neighborReport` (40) — Hàng xóm báo hộ qua luồng B (phải qua Admin duyệt).

### Kịch bản kiểm thử (Test Cases):

| Mã TC | Tên kịch bản | Các bước thực hiện | Kết quả mong đợi | Loại kiểm thử |
|---|---|---|---|---|
| **TC-SAF-01** | Trưởng thôn xác nhận đè lên trạng thái tự báo của Hộ dân | 1. Hộ tự báo an toàn qua app (`selfApp` - 90).<br>2. Trưởng thôn cập nhật thủ công trạng thái của hộ thành `missingContact` (`adminManual` - 70). | * Trạng thái của hộ dân giữ nguyên là **An toàn** (do độ tin cậy nguồn 90 > 70).<br>* Hệ thống hiển thị cảnh báo từ chối ghi đè lên log. | Conflict Resolution |
| **TC-SAF-02** | Đội cứu hộ ghi đè trạng thái của Trưởng thôn | 1. Trưởng thôn xác nhận hộ an toàn bằng tay (`adminManual` - 70).<br>2. Đội cứu hộ đến hiện trường phát hiện hộ gặp nạn và chuyển sang `sos` (`rescueTeam` - 100). | * Trạng thái hộ chuyển sang **SOS** (do độ tin cậy nguồn 100 > 70).<br>* Hệ thống phát tín hiệu SOS đỏ lên bản đồ admin xã. | Conflict Resolution |
| **TC-SAF-03** | Tự động chuyển "Mất liên lạc" khi im lặng | 1. Sự kiện thiên tai được kích hoạt.<br>2. Hộ dân nằm trong vùng ảnh hưởng.<br>3. Popup hỏi an toàn hiện lên định kỳ mỗi 2 giờ, hộ dân không trả lời quá 3 lần liên tiếp (hoặc 4 giờ im lặng). | * Trạng thái hộ tự động chuyển sang **Mất liên lạc — thiết bị im lặng** (`missingContact`).<br>* Thẻ hộ dân chuyển sang màu xám trên Dashboard của admin thôn/xã. | Offline/Timer |
| **TC-SAF-04** | Giải tỏa trạng thái mất liên lạc bằng Check-in điểm sơ tán | 1. Hộ đang ở trạng thái `missingContact` (Grey).<br>2. Quản lý điểm sơ tán thực hiện check-in cho hộ này tại điểm sơ tán (`evacuationCheckin` - 95). | * Trạng thái hộ chuyển thành **An toàn — check-in sơ tán** (Green).<br>* Nguồn cập nhật ghi rõ: "Điểm sơ tán [Tên điểm]".<br>* Hộ biến mất khỏi danh sách cần kiểm tra của admin. | Happy Path |
| **TC-SAF-05** | Tách biệt giao diện vận hành của Admin | Admin mở danh sách đối chiếu hộ dân. | * Bộ lọc hiển thị tách biệt rõ nhóm "Mất liên lạc" (màu xám) và nhóm "An toàn" (màu xanh).<br>* Không gộp chung hai nhóm này để tránh bỏ sót hộ cần cứu. | UI Verification |

---

## 3. Trừ Tồn Kho Cứu Trợ Theo Nguồn Phát (FR-10.8)

### Quy tắc trừ kho:
* Phát từ kho xã (`communeWarehouse`) $\rightarrow$ **TRỪ** trực tiếp tồn kho của xã.
* Đội thường trực phát vật tư biên chế (`teamStanding`) $\rightarrow$ **KHÔNG TRỪ** tồn kho xã lúc phát (vật tư đã được xuất cho đội từ trước).
* Đội vãng lai phát vật tư mang theo (`teamBrought`) $\rightarrow$ **KHÔNG TRỪ** tồn kho xã.
* Phát nguyên gói chưa phân loại (`packageDirect`) $\rightarrow$ **KHÔNG TRỪ** tồn kho chuẩn, giảm số lượng gói cứu trợ và ghi nhận theo mã gói `GCT-2025-xxxx`.
* Tất cả các nguồn phát đều phải được tạo và lưu trữ dưới dạng biên nhận `ReliefReceipt` trong sổ cứu trợ.

### Kịch bản kiểm thử (Test Cases):

| Mã TC | Tên kịch bản | Dữ liệu đầu vào | Kết quả mong đợi | Loại kiểm thử |
|---|---|---|---|---|
| **TC-INV-01** | Phát hàng từ Kho xã | Phát cho Hộ A: 2 thùng mì tôm từ nguồn `communeWarehouse`. Tồn kho mì tôm tại xã đang là 100 thùng. | * Hệ thống tạo `ReliefReceipt` thành công.<br>* Tồn kho mì tôm tại kho xã giảm còn 98 thùng.<br>* Sổ cứu trợ ghi nhận chi tiết giao dịch. | Happy Path |
| **TC-INV-02** | Phát hàng từ vật tư đội vãng lai tự mang | Phát cho Hộ B: 1 áo phao từ nguồn `teamBrought` (đội thiện nguyện Hạ Long mang theo). Tồn kho áo phao của xã đang là 50 chiếc. | * Hệ thống tạo `ReliefReceipt` thành công.<br>* Tồn kho áo phao tại kho xã **giữ nguyên 50 chiếc**.<br>* Sổ cứu trợ ghi nhận nguồn hàng: "Đội thiện nguyện tự mang". | Happy Path |
| **TC-INV-03** | Phát nguyên gói chưa phân loại | Phát cho Hộ C: 1 gói hàng mã `GCT-2025-0007` (nguồn `packageDirect`). | * Hệ thống tạo `ReliefReceipt` thành công, ghi nhận phát nguyên gói `GCT-2025-0007`.<br>* Không tác động tới tồn kho của các mặt hàng chuẩn thuộc `ReliefItem`. | Happy Path |
| **TC-INV-04** | Cảnh báo xuất vượt tồn kho | Admin thực hiện xuất kho cho đội cứu hộ số lượng 120 áo phao, trong khi tồn kho hiện tại chỉ còn 100. | * Hệ thống hiển thị thông báo lỗi/ngăn chặn: "Số lượng xuất vượt quá tồn kho hiện tại (100)".<br>* Giao dịch xuất kho bị chặn. | Boundary/Error |
| **TC-INV-05** | Cảnh báo tồn kho dưới ngưỡng | Cài đặt ngưỡng cảnh báo của nước uống là 50 chai. Tồn kho giảm từ 52 xuống 48 chai sau khi phát. | * Giao dịch thành công.<br>* Hệ thống gửi notification cho Admin xã và hiển thị icon cảnh báo màu đỏ cạnh mặt hàng nước uống trong quản lý kho. | Happy Path |

---

## 4. Chống Gửi Trùng Lặp (Double-Submit Prevention)

### Quy tắc chống trùng:
* **SOS 1 chạm:** Chặn gửi thêm SOS mới nếu hộ đang có yêu cầu SOS hoạt động ở trạng thái: `pending`, `verified`, `assigned`, hoặc `in_progress`.
* **Cứu trợ:** Cảnh báo và yêu cầu xác nhận nếu ghi nhận phát trùng loại hàng cứu trợ cho cùng một hộ trong vòng 24 giờ.

### Kịch bản kiểm thử (Test Cases):

| Mã TC | Tên kịch bản | Thao tác thực hiện | Kết quả mong đợi | Loại kiểm thử |
|---|---|---|---|---|
| **TC-DBL-01** | Bấm liên tục nút SOS 1 chạm (Mạng chậm/Lag) | 1. Giả lập mạng chậm (delay 5 giây).<br>2. Người dùng nhấn nút SOS 3 lần liên tiếp trong 2 giây. | * Chỉ có **1 yêu cầu SOS** được tạo và gửi đi.<br>* 2 lần bấm sau bị hệ thống chặn ở phía client và không gửi request lên server.<br>* Giao diện hiển thị trạng thái "Đang gửi..." ngay từ lần bấm đầu tiên và vô hiệu hóa (disable) nút bấm. | Concurrency / UX |
| **TC-DBL-02** | Gửi SOS khi đang có SOS chưa hoàn thành | 1. Hộ dân A đã gửi SOS thành công và đang ở trạng thái `assigned` (Đội đang đến).<br>2. Hộ dân A quay lại màn hình chính và cố tình gửi SOS lần nữa. | * Hệ thống không tạo yêu cầu SOS mới.<br>* App hiển thị màn hình chi tiết của SOS hiện tại kèm timeline trạng thái của đội cứu hộ thay vì hiện nút bấm SOS mới. | State Constraint |
| **TC-DBL-03** | Cảnh báo nhận trùng cứu trợ trong 24 giờ | 1. Hộ dân B đã được phát 2 thùng mì tôm vào lúc 08:00 sáng.<br>2. Vào lúc 14:00 cùng ngày, một đội cứu hộ khác cố gắng quét mã phát thêm mì tôm cho hộ B. | * Hệ thống hiển thị hộp thoại cảnh báo: "Hộ dân này đã nhận mì tôm cách đây 6 giờ. Bạn có chắc chắn muốn phát tiếp?"<br>* Cho phép đội cứu hộ bấm "Xác nhận phát tiếp" (nếu thực sự cần thiết) hoặc "Hủy". | Boundary / Warning |
| **TC-DBL-04** | Phát cứu trợ ngoài 24 giờ (Không cảnh báo) | 1. Hộ dân C được phát mì tôm vào lúc 08:00 ngày 04/08.<br>2. Lúc 09:00 ngày 05/08, đội cứu hộ thực hiện phát mì tôm tiếp. | * Hệ thống cho phép phát hàng bình thường mà không hiển thị cảnh báo trùng lặp. | Happy Path |
