# DISASTERRESCUE — Đặc tả Dự án Hệ thống Điều phối Cứu hộ Khẩn cấp Thiên tai

> **Đồng bộ với SRS v1.1 — 04/08/2026.** Khi tài liệu này mâu thuẫn với
> `DisasterRescue-SRS-Full.md`, lấy SRS làm chuẩn.

## TÓM TẮT CÁC Ý CHÍNH ĐÃ THỐNG NHẤT

### Bối cảnh & Mục tiêu
- Ứng dụng mobile-first điều phối cứu hộ thiên tai tại Việt Nam
- Hỗ trợ 4 loại hình thiên tai: lũ lụt, sạt lở đất, cháy rừng, bão
- Demo tại Quảng Ninh: sạt lở (Bình Liêu, Tiên Yên, Ba Chẽ, Hải Hà), bão lũ (Hạ Long, Hòn Gai, Móng Cái)
- Nguyên tắc: offline-first, SOS 1 chạm không cần thao tác phức tạp, phù hợp mô hình chính quyền VN

### Mô hình chính quyền & Phân quyền
- Chính quyền VN tổ chức 2 cấp: tỉnh và cơ sở (xã)
- Demo scope: 1 xã với 4-8 thôn
- Admin được cấp sẵn tài khoản bởi cấp trên, không tự đăng ký
- Admin chính (chủ tịch xã/trưởng ban PCTT) thấy toàn xã
- Admin phụ (trưởng thôn) chỉ thấy thôn mình, do admin xã tạo

### 4 Nhóm người dùng
1. Hộ dân bị nạn — gửi SOS, báo cáo, xác nhận an toàn
2. Admin chính quyền xã — điều phối, bản đồ, kho cứu trợ, đối chiếu dân cư
3. Đội cứu hộ (dân quân + MTQ + tổ chức XH) — nhận nhiệm vụ, báo cáo hoàn thành
4. Công chúng — xem Situation Board (không cần đăng nhập)

### Nghiệp vụ cốt lõi đã thống nhất
1. SOS 1 chạm: bấm 1 nút gửi ngay, bổ sung thông tin sau (không bắt buộc) — thiết kế cho người hoảng loạn, tay ướt, trong mưa
2. Báo tin cho xã 2 luồng (v1.1): báo giúp người khác / báo tình hình khu vực. Hộ dân tự báo KHÔNG đi qua đây — dùng SOS 1 chạm (nguy hiểm tức thì) hoặc Yêu cầu hỗ trợ sơ tán (còn thời gian)
2b. Yêu cầu hỗ trợ sơ tán (v1.1): AssistanceRequest riêng, hàng đợi riêng, SLA tính bằng giờ — dành cho hộ cần xe chở người già, người khiêng đồ, thuốc men trước khi nguy cấp
3. Chống báo sai: xác thực danh tính + trạng thái "chờ xác minh" + mức tin cậy tự tính + admin duyệt
4. Người không có mạng: cảnh báo sớm + sơ tán chủ động + người khác báo thay + tìm kiếm sự im lặng
5. Offline: SOS queue local + SMS fallback sóng 2G + GPS cache vị trí cuối + bản đồ offline + sync khi có mạng
6. Import danh sách dân cư (v1.1): công tác chuẩn bị trước mùa thiên tai. Trên mobile bỏ kéo-thả, dùng file picker / nhận file từ Zalo-Email / link Google Sheet. Có màn nhập thủ công từng hộ và màn xử lý trùng SĐT (so sánh 2 cột, chọn giữ cũ / ghi đè / tạo hộ mới)
7. Đối chiếu hộ dân: overlay trạng thái (an toàn/SOS/mất liên lạc/đang cứu/đã cứu) lên danh sách, bảng tổng hợp theo thôn với progress bar số tuyệt đối (không dùng %)
8. Tìm kiếm sự im lặng: hộ trong vùng ảnh hưởng mà không có tín hiệu → tự đánh dấu "cần kiểm tra"
9. Xác nhận an toàn định kỳ: app hỏi, 1 nút bấm, không phản hồi 3 lần → cảnh báo admin
9b. Đa nguồn xác nhận an toàn (v1.1): trạng thái an toàn KHÔNG phụ thuộc duy nhất vào điện thoại hộ dân — điện thoại hết pin/rơi nước là bình thường trong lũ. Năm nguồn kèm độ tin cậy: đội cứu hộ tại hiện trường (100) · check-in điểm sơ tán (95) · hộ tự báo qua app (90) · trưởng thôn xác nhận tay (70) · hàng xóm báo hộ (40). Giao diện phải TÁCH "Mất liên lạc — thiết bị im lặng" (phải cử người kiểm tra) khỏi "An toàn — xác nhận gián tiếp" (không cần làm gì)
10. Kho cứu trợ đầy đủ: 1 kho/xã, nhập (đa nguồn) → xuất cho đội → phát cho hộ → tồn kho + cảnh báo sắp hết + đăng nhu cầu công khai
10b. Kho hai tầng (v1.1): Tầng 1 là danh mục chuẩn (ReliefItem, có tồn kho). Tầng 2 là Gói cứu trợ (ReliefPackage) cho lô hàng hỗn hợp từ đoàn từ thiện — sinh mã GCT-2025-xxxx ngay khi nhận, KHÔNG chặn luồng khẩn cấp; phân loại sau, dòng nào map được vào danh mục thì cộng tồn kho. Bốn nguồn hàng khi phát: kho xã (trừ tồn) · vật tư biên chế đội · đội vãng lai tự mang · phát nguyên gói — ba nguồn sau không trừ tồn kho xã nhưng đều vào sổ cứu trợ
10c. Tổng vật tư khả dụng (v1.1) = tồn kho xã + vật tư biên chế các đội thường trực + vật tư đội vãng lai đang mang. Đây là chỉ số quyết định có cần leo thang xin vật tư hay không
11. MTQ 2 luồng: tại hiện trường (QR scan + form siêu ngắn) và từ xa (đăng ký đầy đủ + dự kiến đến + check-in). Cả 2 cần admin duyệt
11b. Hai loại đội (v1.1): ĐỘI THƯỜNG TRỰC do xã khai báo trước mùa thiên tai (dân quân thôn, tổ xung kích, đội y tế), có mã QR cố định, kích hoạt 1 chạm KHÔNG cần duyệt, mang vật tư biên chế. ĐỘI VÃNG LAI tự đăng ký khi có thiên tai, chờ duyệt, mang vật tư riêng. Quét QR tại chốt phân nhánh tự động theo loại mã
11c. Năm trạng thái đội (v1.1): available (nhận SOS) · onMission · resting (bắt buộc nhập lý do + giờ quay lại, KHÔNG đẩy SOS) · offline (im lặng >30 phút, cảnh báo admin) · ended. Logic gán đội PHẢI lọc available — gán cho đội đang nghỉ khiến SOS treo mà đồng hồ leo thang vẫn chạy
12. MTQ quyền hạn chế: chỉ thấy vị trí + loại sự cố + số người + mức độ. Nhận nhiệm vụ mới thấy thông tin chi tiết hộ dân
13. MTQ phát hàng riêng: ghi nhận đơn giản (chọn hộ → loại hàng → số lượng), nguồn "MTQ tự mang"
14. Cảnh báo sớm: nhận dữ liệu thời tiết → push notification toàn vùng
15. Sơ tán chủ động: admin phát lệnh theo khu vực → hộ dân nhận + xác nhận → theo dõi tiến độ
16. Quản lý điểm sơ tán: danh sách, sức chứa, số người hiện tại, tình trạng, vật tư
17. Bản đồ trực quan bắt buộc cho admin: SOS markers (icon+màu theo loại thiên tai), vùng ảnh hưởng, đội cứu hộ, điểm sơ tán, ảnh hiện trường
18. Leo thang: admin xã gửi yêu cầu lên cấp trên khi quá tải. (v1.1) BỎ trường mức khẩn cấp — leo thang tự nó đã là tuyên bố xã hết khả năng, và nhãn tự đánh giá vô nghĩa vì xã nào cũng chọn mức cao nhất. Thay bằng khối số liệu hệ thống tự sinh (SOS đỏ chưa gán, thời gian chờ lâu nhất, hộ mất liên lạc, đội khả dụng/tổng, mặt hàng dưới ngưỡng, chỗ sơ tán trống) — huyện xếp ưu tiên bằng số liệu khách quan. Giữ lại: loại yêu cầu + SỐ LƯỢNG CỤ THỂ CẦN
19. Nhật ký sự kiện: log toàn bộ diễn biến theo thời gian
20. Situation Board công khai: bản đồ tổng quan + ảnh + thống kê + nhu cầu cứu trợ
21. Thông báo push theo vai trò, không gọi trong app (dùng điện thoại thường)
22. Hiển thị số tuyệt đối, không dùng % trên mọi thống kê và progress bar

---

## 1. YÊU CẦU CHỨC NĂNG CHI TIẾT

### 1.1 Quản lý tài khoản & Phân quyền

**Vai trò hệ thống:**

| Vai trò | Cách có tài khoản | Quyền hạn |
|---------|-------------------|-----------|
| Admin hệ thống (tỉnh) | Cài đặt ban đầu | Tạo tài khoản admin xã |
| Admin xã (chủ tịch/trưởng ban PCTT) | Được cấp sẵn | Toàn quyền trong xã: điều phối, duyệt MTQ, quản lý kho, tạo admin phụ, import dân cư |
| Admin phụ (trưởng thôn) | Do admin xã tạo | Chỉ thấy thôn mình, tạo SOS thay hộ dân, cập nhật tình hình thôn |
| Hộ dân | Tự đăng ký (SĐT + mật khẩu) | Gửi SOS, báo cáo, xác nhận an toàn, đăng ký hộ |
| Đội cứu hộ / MTQ | Tự đăng ký → chờ admin duyệt | Xem SOS trong khu vực được gán, nhận nhiệm vụ, báo cáo hoàn thành |
| Công chúng | Không cần đăng nhập | Chỉ xem Situation Board |

**Đăng nhập:** SĐT hoặc email + mật khẩu → chọn vai trò (chỉ hiện vai trò có quyền).

### 1.2 Loại hình thiên tai

4 loại hỗ trợ, mỗi loại có form thu thập riêng:

**Lũ lụt:** mực nước (đầu gối/ngực/mái nhà), xu hướng (lên/xuống/ổn định), phương tiện cứu hộ (thuyền)

**Sạt lở đất:** số nhà bị ảnh hưởng, số người nghi mất tích, địa hình, phương tiện (máy xúc, đội đào bới)

**Cháy rừng:** hướng lửa lan, tốc độ gió, khoảng cách khu dân cư, phương tiện (xe cứu hỏa)

**Bão:** loại thiệt hại (tốc mái/cây đổ/mất điện/ngập), tình trạng nhà

### 1.3 Cảnh báo sớm & Sơ tán chủ động

**Cảnh báo sớm:**
- Nguồn: API thời tiết hoặc admin nhập thủ công
- Khi có cảnh báo nguy hiểm → push notification toàn vùng ảnh hưởng
- Nội dung: loại thiên tai, vùng ảnh hưởng, mức độ, khuyến cáo hành động

**Sơ tán chủ động:**
- Admin chọn khu vực cần sơ tán → phát lệnh
- Hộ dân nhận: thông báo + điểm sơ tán gần nhất + tuyến đường
- Hộ dân xác nhận "Đã đến điểm sơ tán" (1 nút)
- Admin theo dõi: progress bar "Đã xác nhận sơ tán: 45/120" (số tuyệt đối, không %)

**Điểm sơ tán:**
- Thuộc tính: tên, tọa độ, sức chứa tối đa, số người hiện tại, tình trạng (còn chỗ/đầy/hư hỏng), vật tư có sẵn
- Hiển thị trên bản đồ cho tất cả vai trò

### 1.4 Đăng ký & Import hộ dân

**Import danh sách (admin):**
- Upload file Excel/CSV theo template
- Hoặc nhập thủ công từng hộ
- Preview trước khi xác nhận: bảng dữ liệu + tổng hợp (tổng hộ, nhân khẩu, người yếu thế theo loại)
- Cảnh báo trùng lặp (SĐT trùng)

**Tự đăng ký (hộ dân):**
- Form: họ tên, SĐT, số thành viên, loại nhà, người yếu thế, ghi chú, chọn vị trí trên bản đồ (GPS)

**Dữ liệu mỗi hộ:** tên chủ hộ, SĐT, tọa độ nhà, số thành viên, loại nhà (cấp 4/tầng), người yếu thế (người già/trẻ em/khuyết tật/mang thai), khu vực (thôn), ghi chú

### 1.5 SOS 1 chạm

**Nguyên tắc:** 1 nút, 0 form bắt buộc. Thiết kế cho người hoảng loạn, tay ướt, trong mưa.

**Luồng:**
1. Mở app → nút SOS 250px chiếm nửa màn hình
2. Bấm 1 lần → app tự lấy GPS → gửi SOS (vị trí + thời gian + tài khoản)
3. Trạng thái: "Đang gửi" → "Đã gửi" → "Đã tiếp nhận" → "Đội đang đến" → "Đã giải cứu"
4. Bổ sung thông tin (không bắt buộc): loại thiên tai, chips tình huống, số người, mực nước, ảnh

**Offline:**
- Mất data: SOS lưu queue local → hiển thị "Đã lưu, sẽ gửi khi có sóng" (vàng)
- Chỉ có 2G: gửi qua SMS → hiển thị "Đã gửi qua SMS" (xanh)
- GPS yếu: dùng tọa độ cache cuối → hiển thị "Vị trí gần đúng — cập nhật lúc HH:MM"

**Tính điểm ưu tiên tự động:**
- Có trẻ em: +15, có người già: +15, người ốm nặng: +20, khuyết tật: +10
- Ngập tầng 1: +15, cần thuốc: +10, nước mức mái nhà: +20, nước mức ngực: +10
- Nhà cấp 4: +10, >5 người: +5
- Score ≥70: đỏ, 40-69: cam, <40: vàng

### 1.6 Báo cáo chi tiết (3 luồng)

**Luồng A — Tôi cần được cứu:** = SOS chi tiết, có form phân loại đầy đủ

**Luồng B — Tôi báo cho người khác:**
- Vị trí người cần cứu: cho chọn ĐỒNG THỜI trên bản đồ VÀ nhập địa chỉ
- Thu thập GPS người báo (để tính khoảng cách → mức tin cậy)
- Trạng thái mặc định: "Chờ xác minh" (admin duyệt mới thành SOS)

**Luồng C — Báo cáo tình hình chung:**
- Thông tin tình hình: đường sập, nước dâng, lửa cháy, chướng ngại
- Hiển thị trên bản đồ admin, không tạo SOS

**Chống báo sai (luồng B, C):**
- Xác thực danh tính: phải đăng nhập
- Mức tin cậy tự tính: có ảnh (+), GPS gần hiện trường (+), nhiều người cùng báo (+), tài khoản xác thực (+), báo từ xa (-)
- Cross-reference: 2-3 người cùng báo bán kính 200m → nâng mức ưu tiên
- Admin duyệt trước khi điều phối

### 1.7 Tìm kiếm sự im lặng & Xác nhận an toàn

**Tìm kiếm sự im lặng:**
- Hộ trong vùng ảnh hưởng + không có tín hiệu gì sau ngưỡng thời gian → trạng thái "Mất liên lạc"
- Ưu tiên: nhà cấp 4 + có người yếu thế = trên cùng
- Admin thấy danh sách riêng → gửi đội kiểm tra

**Xác nhận an toàn:**
- App hỏi định kỳ "Bạn an toàn không?" khi thiên tai đang diễn ra
- 1 nút "Tôi an toàn" + 1 nút "Tôi cần giúp"
- Không phản hồi 3 lần → cảnh báo admin
- Hoạt động offline: lưu local → sync khi có mạng

### 1.8 Admin xã — Bản đồ & Điều phối

**Dashboard bản đồ (bắt buộc):**
- Bản đồ realtime: SOS markers (icon theo loại thiên tai, màu theo mức độ), báo cáo tình hình, vị trí đội cứu hộ, vùng ảnh hưởng, điểm sơ tán, ảnh hiện trường gắn tọa độ
- KPI cards: chờ xử lý (đỏ), đang cứu (cam), đã cứu (xanh), mất liên lạc (xám)
- Progress bar tổng: "280/480 đã an toàn" (số tuyệt đối)

**Đối chiếu hộ dân:**
- Bảng tổng hợp theo thôn: tổng hộ, đã an toàn, SOS, mất liên lạc (số tuyệt đối, không %)
- Sort theo số mất liên lạc giảm dần
- Filter: tất cả / an toàn / SOS / mất liên lạc / đang cứu / đã cứu
- Card hộ dân: tên, thôn, số người, người yếu thế, trạng thái, thời gian

**Duyệt báo cáo:** Danh sách báo cáo "Chờ xác minh", mức tin cậy, ảnh, nút Duyệt/Từ chối

**Điều phối:** Gán đội vào khu vực/nhiệm vụ, duyệt MTQ, cập nhật tình hình

**Leo thang:** Gửi yêu cầu lên cấp trên: loại (nhân lực/vật tư/y tế), mô tả, ảnh, mức khẩn cấp

**Leo thang tự động:** SOS đỏ chưa có đội: 15p → cảnh báo 1, 30p → cảnh báo 2, 60p → cảnh báo 3

### 1.9 Đội cứu hộ & MTQ

**Đăng ký MTQ tại hiện trường:**
- Quét QR tại chốt tiếp nhận → form siêu ngắn: tên, SĐT, số người, phương tiện
- Trạng thái: "Chờ duyệt" → admin duyệt (2-3 phút) → gán khu vực → hoạt động

**Đăng ký MTQ từ xa:**
- Form đầy đủ: tên, SĐT, số người, phương tiện, khả năng, hàng mang theo, khu vực muốn hỗ trợ, dự kiến thời gian đến
- Trạng thái: "Đã đăng ký — Đang di chuyển" → check-in khi đến (quét QR hoặc bấm nút) → admin gán khu vực

**Quyền xem:**
- Trước nhận nhiệm vụ: vị trí + loại sự cố + số người + mức khẩn cấp (KHÔNG thấy thông tin cá nhân)
- Sau nhận: tên chủ hộ, SĐT, địa chỉ chi tiết

**Luồng hoạt động:**
1. Xem danh sách SOS trong khu vực được gán
2. "Tôi đi" → lock SOS, đội khác thấy "Đội X đang đến"
3. Đến nơi → chụp ảnh → cứu hộ
4. Báo cáo hoàn thành: số người cứu, tình trạng sức khỏe, ảnh trước/sau, hàng đã phát
5. Báo chướng ngại: chụp ảnh + GPS + loại (cây đổ/đường sập/nước xiết/cầu sập/đất lở) → hiện trên bản đồ cho tất cả đội

### 1.10 Kho cứu trợ khẩn cấp

Scope: 1 kho chính/xã.

**Nhập kho:** loại hàng, số lượng, nguồn (nhà nước/MTQ/tổ chức XH/khác), ngày nhập → tồn kho tăng

**Xuất kho:** chọn đội → loại hàng + số lượng → xác nhận → tồn kho giảm. Đội thấy "Đang mang: X"

**Phát cho hộ dân:** đội chọn hộ từ SOS → loại hàng + số lượng → xác nhận. Ghi nhận: hộ X nhận Y từ đội Z

**MTQ phát hàng riêng:** chọn hộ → loại hàng + số lượng → nguồn "MTQ tự mang" → không ảnh hưởng tồn kho

**Cảnh báo:** tồn kho < ngưỡng, hộ nhận trùng lặp

**Đăng nhu cầu:** admin đăng lên Situation Board "Cần thêm X loại Y"

### 1.11 Situation Board (công khai)

- Không cần đăng nhập
- Bản đồ tổng quan vùng ảnh hưởng (không hiện tọa độ hộ dân)
- Thống kê: tổng SOS, đã cứu, đang chờ, đội hoạt động
- Ảnh hiện trường mới nhất
- Nhu cầu cứu trợ: cần gì, số lượng, điểm tiếp nhận

### 1.12 Nhật ký sự kiện

Log toàn bộ diễn biến theo thời gian: cảnh báo, lệnh sơ tán, SOS, đội nhận/đến/hoàn thành, hàng phát, cập nhật tình hình. Filter theo loại/thời gian.

### 1.13 Thông báo

Push notification theo vai trò. Không gọi trong app.

| Vai trò | Thông báo |
|---------|-----------|
| Hộ dân | Cảnh báo thời tiết, lệnh sơ tán, SOS đã tiếp nhận, đội đang đến, xác nhận an toàn |
| Admin xã | SOS mới, báo cáo mới cần duyệt, leo thang tự động, MTQ chờ duyệt, mất liên lạc, kho sắp hết |
| Đội cứu hộ | SOS mới trong khu vực, khu vực mới, chướng ngại trên tuyến |

---

## 2. YÊU CẦU PHI CHỨC NĂNG

### 2.1 Hiệu năng
- SOS 1 chạm: từ bấm đến gửi < 3 giây (khi có mạng)
- Bản đồ admin: load < 5 giây với 200+ markers
- Offline queue: xử lý 100+ SOS pending

### 2.2 Độ tin cậy
- SOS không được mất: queue local + retry + SMS fallback
- Uptime server: 99.9% trong mùa thiên tai (tháng 9-11)

### 2.3 Bảo mật
- Thông tin hộ dân (tên, SĐT, vị trí): chỉ hiện cho admin + đội cứu hộ đã nhận nhiệm vụ
- MTQ chưa nhận nhiệm vụ: không thấy thông tin cá nhân
- Situation Board: chỉ thống kê tổng hợp, không hiện tọa độ hộ dân
- Admin tài khoản cấp sẵn, không tự đăng ký

### 2.4 Offline-first
- SOS queue: lưu local, sync khi có mạng
- SMS fallback: khi còn sóng 2G
- GPS cache: lưu vị trí mỗi 5 phút, dùng vị trí cuối khi mất GPS
- Bản đồ offline: pre-cache tiles khu vực trước mùa thiên tai
- Đội cứu hộ offline: sync danh sách SOS trước khi xuất phát

### 2.5 Khả năng mở rộng
- Kiến trúc cho phép thêm loại thiên tai mới (hạn hán, động đất...)
- Mở rộng từ 1 xã lên liên xã/huyện/tỉnh
- Hướng phát triển: mesh networking BLE/Wi-Fi Direct, thiết bị beacon cộng đồng

---

## 3. TECH STACK

- **Mobile:** Flutter (Android + iOS)
- **Backend:** Firebase (Auth + Firestore + Storage + Cloud Messaging)
- **Map:** flutter_map + OpenStreetMap tiles (hỗ trợ offline)
- **State Management:** Riverpod
- **Architecture:** Feature-first, Repository Pattern
- **Offline Storage:** Hive (queue, cache)
- **Charts:** fl_chart
- **Camera:** image_picker
- **GPS:** geolocator
- **QR:** mobile_scanner
- **Notifications:** flutter_local_notifications + FCM
- **Connectivity:** connectivity_plus

---

## 4. DỮ LIỆU DEMO — QUẢNG NINH

### Tài khoản demo
- Hộ dân: `hodan@demo.vn` / `Demo@123`
- Admin xã: `admin@demo.vn` / `Demo@123` (cấp sẵn)
- Đội cứu hộ: `cuuho@demo.vn` / `Demo@123`
- Công khai: không cần đăng nhập

### Dữ liệu mẫu
- Xã demo: Đồng Tâm (Bình Liêu) — sạt lở, và 1 phường Hạ Long — bão lũ
- 4 thôn: Pắc Liềng, Nà Lầu, Bản Chuồng, Khe Tiền
- 12 hộ dân pre-register, mix nhà cấp 4/tầng, mix người yếu thế
- 15 SOS các trạng thái, mix 4 loại thiên tai, mix nguồn
- 6 đội cứu hộ (3 dân quân, 2 MTQ, 1 tổ chức XH)
- 3 điểm sơ tán (Trường TH Bình Liêu, Nhà VH thôn, Chùa Pắc Liềng)
- Kho: 4 loại hàng (áo phao, nước, lương khô, thuốc) với tồn kho mẫu

---

## 5. DANH SÁCH MÀN HÌNH (23 screens)

### Chung (3)
| # | Màn hình | Mô tả |
|---|----------|-------|
| 1 | Splash | Logo + loading + kiểm tra auth |
| 2 | Login | SĐT/email + mật khẩu. Không có đăng ký admin. Link xem Situation Board |
| 3 | Chọn vai trò | 4 card: Hộ dân, Admin Xã, Đội cứu hộ, Tình trạng. Chỉ hiện vai trò có quyền |

### Hộ dân (6)
| # | Màn hình | Mô tả |
|---|----------|-------|
| 4 | Trang chủ | Trạng thái SOS + bản đồ nhỏ (nhà, điểm sơ tán, đội) + thông tin khu vực. Banner offline nếu mất mạng |
| 5 | SOS 1 chạm | Nút SOS 250px, bấm 1 lần gửi ngay. Phần bổ sung (collapse). Trạng thái offline/SMS/GPS cache |
| 6 | Báo cáo chi tiết | 3 bước: loại báo cáo → loại thiên tai → form chi tiết + vị trí (bản đồ + địa chỉ) + ảnh. Mức tin cậy |
| 7 | Xác nhận an toàn | Modal: "Bạn an toàn không?" + 2 nút. Hiện lần hỏi thứ mấy |
| 8 | Thông báo | Timeline notification, filter theo loại |
| 9 | Đăng ký hộ dân | Form thông tin + map picker vị trí nhà |

### Admin xã (9)
| # | Màn hình | Mô tả |
|---|----------|-------|
| 10 | Dashboard bản đồ | Bản đồ realtime + KPI cards + progress tổng. FAB menu (tạo SOS thay, duyệt, sơ tán, leo thang, import) |
| 11 | Import dân cư | Upload Excel/CSV hoặc nhập thủ công. Preview + tổng hợp + cảnh báo trùng |
| 12 | Đối chiếu hộ dân | Bảng tổng hợp theo thôn (số tuyệt đối) + list hộ dân filter/sort theo trạng thái |
| 13 | Quản lý lực lượng | List đội + MTQ chờ duyệt + nút duyệt/từ chối/gán khu vực |
| 14 | Duyệt báo cáo | List báo cáo chờ xác minh + mức tin cậy + nút duyệt/từ chối |
| 15 | Điểm sơ tán | Map + list điểm (sức chứa, tình trạng, vật tư) |
| 16 | Phát lệnh sơ tán | Chọn khu vực → template tin nhắn → phát → theo dõi xác nhận |
| 17 | Kho cứu trợ | Tồn kho (progress bar số) + tabs nhập/xuất/đã phát + cảnh báo + đăng nhu cầu |
| 18 | Leo thang + Nhật ký | Form yêu cầu hỗ trợ + timeline log sự kiện |

### Đội cứu hộ (5)
| # | Màn hình | Mô tả |
|---|----------|-------|
| 19 | Đăng ký MTQ | 2 mode: QR scan (form ngắn) và từ xa (form đầy đủ + dự kiến đến). Chờ duyệt |
| 20 | Danh sách nhiệm vụ | Bản đồ khu vực + list SOS overlay. Quyền hạn chế (không thấy thông tin cá nhân). Nút "Tôi đi" |
| 21 | Chi tiết SOS | Sau nhận: thông tin đầy đủ hộ dân + SĐT + ảnh + bản đồ + "Dẫn đường" |
| 22 | Báo cáo hoàn thành | Số người cứu + tình trạng + ảnh trước/sau + hàng đã phát (kho xã / MTQ tự mang) |
| 23 | Báo chướng ngại | Camera + loại chướng ngại + GPS → đánh dấu bản đồ cho tất cả đội |

### Công khai (tích hợp)
| — | Situation Board | Trang công khai không cần login: bản đồ + thống kê + ảnh + nhu cầu cứu trợ |

---

## 6. LUỒNG NGHIỆP VỤ CHÍNH (Use Case Summary)

### UC01: Gửi SOS khẩn cấp
Actor: Hộ dân → Bấm SOS → App lấy GPS → Gửi server (hoặc queue offline/SMS) → Admin nhận notification → Hiện trên bản đồ

### UC02: Báo cáo cho người khác
Actor: Người có mạng → Chọn "Báo cho người khác" → Nhập vị trí + ảnh + mô tả → Tính mức tin cậy → Trạng thái "Chờ xác minh" → Admin duyệt → Chuyển SOS hoặc từ chối

### UC03: Điều phối cứu hộ
Actor: Admin xã → Xem bản đồ SOS → Gán đội cứu hộ → Đội nhận notification → "Tôi đi" → Lock SOS → Đến nơi → Báo cáo hoàn thành → SOS đóng

### UC04: Sơ tán chủ động
Actor: Admin xã → Nhận cảnh báo thời tiết → Chọn khu vực → Phát lệnh sơ tán → Hộ dân nhận → Xác nhận đã sơ tán → Admin theo dõi tiến độ

### UC05: Đăng ký MTQ tại hiện trường
Actor: MTQ → Quét QR chốt → Form ngắn → Gửi → Admin duyệt → Gán khu vực → MTQ thấy nhiệm vụ

### UC06: Đăng ký MTQ từ xa
Actor: MTQ → Đăng ký trên app → Form đầy đủ + dự kiến đến → Chờ duyệt → Đến nơi check-in → Admin gán khu vực

### UC07: Quản lý kho cứu trợ
Actor: Admin → Nhập kho (nguồn, loại, số lượng) → Xuất cho đội → Đội phát cho hộ dân → Ghi nhận → Cảnh báo sắp hết → Đăng nhu cầu công khai

### UC08: Tìm kiếm sự im lặng
Actor: Hệ thống → Đối chiếu danh sách hộ dân + vùng ảnh hưởng → Hộ không tín hiệu > ngưỡng → Đánh dấu "Mất liên lạc" → Admin thấy → Gửi đội kiểm tra

### UC09: Xác nhận an toàn
Actor: Hệ thống → Hiện popup "An toàn không?" → Hộ dân bấm "An toàn" (hoặc không) → 3 lần không phản hồi → Cảnh báo admin

### UC10: Leo thang
Actor: Admin xã → Quá tải → Gửi yêu cầu (loại, mô tả, ảnh, mức khẩn cấp) → Cấp trên nhận → Điều chuyển lực lượng

### UC11: Xem Situation Board
Actor: Công chúng → Mở app/web không cần login → Xem bản đồ + thống kê + ảnh + nhu cầu cứu trợ → Quyết định hỗ trợ

---

## 7. HƯỚNG DẪN CHO KIRO

Từ spec này, hãy generate:

1. **Tài liệu đặc tả phần mềm (SRS):** Theo chuẩn IEEE 830, bao gồm mục đích, phạm vi, yêu cầu chức năng (từ mục 1), yêu cầu phi chức năng (từ mục 2), ràng buộc.

2. **Thiết kế kiến trúc phần mềm:** Flutter + Firebase, feature-first architecture, repository pattern, offline-first với Hive queue, các layer (presentation → controller → domain → data), dependency injection với Riverpod.

3. **Acceptance Test scenarios:** Cho mỗi Use Case (UC01-UC11) trong mục 6, viết Given-When-Then scenarios bao gồm happy path, error path, offline path, và edge cases.

4. **Use Case diagrams & descriptions:** Từ mục 6, vẽ Use Case diagram (actors + use cases + relationships) và viết Use Case description chi tiết (precondition, main flow, alternative flow, postcondition, exception).

5. **Thiết kế cơ sở dữ liệu:** Firestore collections schema từ mục 4 + 1.x, bao gồm document structure, indexes, security rules, relationships, seed data.

6. **Thiết kế hướng đối tượng (OOP):** Class diagrams cho domain models (SosRequest, Household, RescueTeam, ReliefItem, Sector, EvacuationPoint, Notification, EventLog), inheritance, interfaces (Repository pattern), state machines (SOS status flow, incident status flow).

7. **Thiết kế giao diện (UI/UX):** Từ mục 5, wireframe descriptions cho 23 screens, navigation flow, component library (KPI card, status chip, priority badge, mission card, household card, stock card), design tokens (colors, typography, spacing từ design system đã define).
