# DisasterRescue — Rà soát nghiệp vụ v2

> Tài liệu giải thích **vì sao** các quyết định nghiệp vụ được đưa ra, đối chiếu với SRS v1.0.
> Phần "làm gì" đã hợp nhất vào SRS v1.1 và tóm tắt ở `CLAUDE.md` mục 2.
> Tài liệu này là phần **lập luận** — cần khi bảo vệ đồ án và khi gặp tình huống SRS chưa nói rõ.
>
> Trạng thái: đã chốt, đã dựng 41 màn Figma, đã hợp nhất vào SRS v1.1.

---

## 1. Đăng nhập & định tuyến vai trò

**SRS FR-01.5 đã quy định đúng:** *"Nếu chỉ 1 role → tự động chuyển màn hình."* Vấn đề nằm ở bản mockup v1 vẽ đủ 4 card nên trông như ai đăng nhập cũng phải chọn.

```
Đăng nhập thành công
   ↓ đọc user.roles[] từ Firestore
   ├── roles.length == 1 → vào THẲNG màn tương ứng
   │     ["household"]     → Trang chủ hộ dân
   │     ["commune_admin"] → Dashboard bản đồ
   │     ["rescue_team"]   → Danh sách nhiệm vụ
   └── roles.length >= 2 → màn Chọn vai trò
```

**Vì sao vẫn giữ màn chọn vai trò:** ở cấp xã, một người kiêm nhiều vai rất phổ biến — trưởng thôn (admin phụ) đồng thời là chủ hộ và là dân quân trong đội cứu hộ. Người đó cần chuyển qua lại giữa "gửi SOS cho nhà mình" và "điều phối thôn mình".

**Bổ sung:** nút đổi vai trò nhanh trong Hồ sơ, không cần đăng xuất.

---

## 2. Situation Board không phải một vai trò

Đặt Situation Board cạnh "Hộ dân / Admin xã / Đội cứu hộ" là sai về mặt khái niệm: ba cái kia là **quyền**, cái này là **một trang công khai không cần đăng nhập** (FR-11.1).

| Điểm vào | Trạng thái |
|---|---|
| Nút "Xem tình hình thiên tai" ở màn Đăng nhập | ✅ đã có — điểm vào chính |
| Link chia sẻ / QR dán tại UBND xã | đối tượng thật: người thân ở xa, báo chí, nhà hảo tâm |
| Mục trong Hồ sơ sau khi đăng nhập | tiện, không bắt buộc |

→ Đã bỏ card "Situation Board" khỏi màn Chọn vai trò.

---

## 3. SOS vs Báo tin vs Yêu cầu hỗ trợ

### 3.1 Vấn đề

SRS v1.0 FR-03 định nghĩa 3 luồng báo cáo:

| Luồng | Nội dung | Kết quả | Đánh giá |
|---|---|---|---|
| A | "Tôi cần được cứu" — form đầy đủ | Tạo SOS ngay | ⚠️ trùng nút SOS |
| B | "Tôi báo cho người khác" | Report chờ xác minh | ✅ khác biệt rõ |
| C | "Báo tình hình chung" | Không tạo SOS | ✅ khác biệt rõ |

Luồng A phân biệt với SOS bằng **độ dài form** — tiêu chí sai, và chính nó gây bối rối cho người dùng. Bắt người đang ngập nước điền form đầy đủ *trước khi* gửi là đi ngược nguyên tắc "SOS 1 chạm" (SRS mục 2.1): mọi gián đoạn (hết pin, nước dâng, hoảng loạn) đều khiến SOS không bao giờ được gửi.

### 3.2 Nhưng bỏ hẳn luồng A cũng sai

Hai vấn đề xuất hiện khi thử loại bỏ:

**Rào cản tâm lý.** Nút SOS đỏ 250px "BẤM ĐỂ GỬI NGAY" phát tín hiệu nguy cấp tối đa. Một hộ có cụ 85 tuổi liệt giường, nước dự báo lên tối nay, cần xe chở đi sơ tán — họ sẽ ngần ngại: *"nhà mình chưa ngập, bấm SOS có bị coi là báo động giả không?"*. Tâm lý ngại làm phiền chính quyền ở nông thôn rất thật. Bỏ kênh này thì hoặc họ không báo gì (xã không biết), hoặc bấm SOS (làm loãng hàng đợi đỏ).

**Khác biệt về đơn vị thời gian.** SOS tính bằng **phút**. Trường hợp trên tính bằng **giờ**. Hai loại cần hàng đợi riêng, SLA riêng, thậm chí đội xử lý riêng.

### 3.3 Giải pháp — định vị lại luồng A

Luồng A không thừa, nó chỉ bị mô tả bằng sai tiêu chí. Đổi thành **"Cần hỗ trợ sơ tán"**, tạo đối tượng riêng `AssistanceRequest` (FR-17).

Ba hành động khác nhau ở **chủ ngữ**, không ở độ dài form:

```
🆘 SOS               = "NHÀ TÔI đang nguy hiểm"        → cứu tôi ngay
🙋 Cần hỗ trợ sơ tán = "Tôi cần giúp để tự sơ tán"     → xã lên kế hoạch
📣 Báo tin           = "TÔI THẤY chỗ khác có chuyện"   → cứu người khác
✓  Tôi an toàn       = "Nhà tôi ổn, đừng lo cho tôi"   → xã bớt việc kiểm tra
```

### 3.4 Trang chủ — phân tầng theo mức khẩn cấp

```
┌─────────────────────────────────┐
│   🆘  S O S                     │  180px — TỨC THÌ (phút)
│   BẤM ĐỂ GỬI NGAY               │
└─────────────────────────────────┘
┌───────────────┐ ┌───────────────┐
│ 🙋 Cần hỗ trợ │ │ ✓ Tôi vẫn     │  88px — CÒN THỜI GIAN (giờ)
│    sơ tán     │ │   an toàn     │
└───────────────┘ └───────────────┘
┌───────────────┐ ┌───────────────┐
│ 👥 Báo giúp   │ │ 📷 Báo tình   │  72px — VỀ NGƯỜI/NƠI KHÁC
│  người khác   │ │  hình khu vực │
└───────────────┘ └───────────────┘
```

Ba tầng đọc được ngay bằng mắt. Hai nút tầng 3 có thể ẩn khi không có thiên tai đang diễn ra.

**Lưu ý về điểm ưu tiên:** SOS trắng thông tin vẫn tính được điểm hợp lý vì hồ sơ hộ đã có sẵn số người, loại nhà, người yếu thế từ lúc đăng ký (FR-01.2). Form chỉ bổ sung tình huống hiện tại như mực nước. Lo ngại "SOS thiếu dữ liệu" không nghiêm trọng như tưởng — và không bao giờ được lấy đó làm lý do chặn gửi SOS.

---

## 4. Xác nhận an toàn & vấn đề mất điện thoại

### 4.1 Điều kiện kích hoạt (FR-07.1) — cả 3 phải đúng

1. Có sự kiện thiên tai đang `active` phủ khu vực của hộ
2. Hộ **chưa** gửi SOS
3. Hộ **chưa** xác nhận an toàn trong **> 2 giờ**

```
Hỏi lần 1 ──1h không trả lời──> Hỏi lần 2 ──1h──> Hỏi lần 3
                                                     │ không trả lời
                                                     ↓
                                  Cảnh báo admin: "Hộ X im lặng 3 lần"
                                                     ↓
                           Sau 4h im lặng (FR-06.1) → missing_contact
                                                     ↓
                                    Admin bấm "Gửi đội kiểm tra"
```

### 4.2 Lỗ hổng nghiêm trọng

Trạng thái an toàn **chỉ có một nguồn: chiếc điện thoại của hộ dân**. Trong lũ lụt, điện thoại chết pin / rơi nước / mất sóng là chuyện *bình thường*, không phải ngoại lệ.

Hậu quả:
- Hộ **đã được cứu, đang ngồi ở điểm sơ tán** → hệ thống vẫn báo `missing_contact` → xã cử đội thứ hai đi kiểm tra → **lãng phí nguồn lực đang khan hiếm**
- Đội cứu hộ đã đến nơi nhưng không có cách ghi nhận → số liệu "280/480 hộ an toàn" trên Situation Board sai

### 4.3 Giải pháp — 5 nguồn xác nhận

| # | Nguồn | Ai ghi nhận | Tin cậy | Màn hình |
|---|---|---|---|---|
| 1 | Đội cứu hộ xác nhận tại hiện trường | Đội | **100** (ảnh + GPS + giờ) | 36 |
| 2 | Check-in tại điểm sơ tán | Quản lý điểm | 95 | 29 |
| 3 | Hộ dân tự báo qua app | Hộ dân | 90 | 07 |
| 4 | Trưởng thôn xác nhận thủ công | Admin phụ | 70 | 41 |
| 5 | Hàng xóm báo hộ | Hộ dân khác | 40 (cần duyệt) | 06 luồng B |

### 4.4 Phải tách hai trạng thái đang bị gộp

| Chip | Ý nghĩa với admin |
|---|---|
| `Mất liên lạc — thiết bị im lặng` (xám) | **Có thể mắc kẹt → PHẢI cử người kiểm tra** |
| `An toàn — đội xác nhận` ⛑️ (xanh) | Không cần làm gì |
| `An toàn — check-in sơ tán` 🏫 (xanh) | Không cần làm gì |

Đây là khác biệt sống còn. Gộp chung khiến admin không biết ưu tiên vào đâu.

---

## 5. Chi tiết thông báo

Nội dung và nút hành động đổi theo loại:

| Loại | Nội dung | Hành động |
|---|---|---|
| Cảnh báo thời tiết | Bản đồ vùng ảnh hưởng, mức độ, khuyến cáo, nguồn tin | Xem điểm sơ tán gần nhất |
| Lệnh sơ tán | Điểm đích + đường đi, danh sách cần mang, bản Tiếng Tày | Tôi đã đến / Không thể sơ tán |
| SOS của tôi | Timeline trạng thái, tên đội đang đến, ETA | Gọi đội / Huỷ SOS |
| Phát cứu trợ | Biên nhận điện tử: hàng, số lượng, người phát, mã gói | Xem sổ cứu trợ của tôi |

---

## 6. Import hộ dân

SRS mục 2.5 ghi rõ: *"Danh sách hộ dân **đã được chuẩn bị trước** mùa thiên tai"* → đây là **công tác chuẩn bị, không phải thao tác khẩn cấp**.

| Vấn đề | Xử lý |
|---|---|
| Kéo-thả không hợp mobile | 3 nguồn: chọn file từ máy / nhận từ Zalo-Email / link Google Sheet |
| Template download vô nghĩa trên mobile | "📧 Gửi file mẫu về email" + "👁 Xem cấu trúc 12 cột" |
| Nhập thủ công chưa có UI | Màn 25 (FR-05.4) |
| Xem hộ trùng chưa có UI | Màn 26 (FR-05.5) — so sánh 2 cột |

**Màn xử lý trùng lặp:**

```
┌──────────────────────────────────────────────┐
│  SĐT trùng: 0987654321          Cặp 1/3      │
├─────────────────────┬────────────────────────┤
│  ĐANG CÓ TRONG HỆ   │  TRONG FILE IMPORT     │
│  Nguyễn Văn A       │  Chu Văn E         ⚠️  │
│  Thôn Pắc Liềng     │  Thôn Nà Lầu       ⚠️  │
│  5 người            │  4 người           ⚠️  │
├─────────────────────┴────────────────────────┤
│ [Giữ cũ] [Ghi đè] [Tạo hộ mới — sửa SĐT]     │
└──────────────────────────────────────────────┘
```

**Khuyến nghị kiến trúc:** nên có bản web admin cho các nghiệp vụ chuẩn bị (import dân cư, cấu hình ngưỡng, quản lý danh mục hàng). App mobile giữ bản rút gọn dùng khi cần gấp ngoài thực địa.

---

## 7. Đội cứu hộ: chi tiết, trạng thái, và đội thường trực

### 7.1 Lỗ hổng: hệ thống coi mọi đội đều là "người lạ đến đăng ký"

SRS v1.0 FR-09 chỉ có hai đường vào — quét QR tại chốt, hoặc đăng ký từ xa — **cả hai đều là tự đăng ký trong lúc thiên tai đang xảy ra**, đều phải chờ admin duyệt.

Nhưng đội dân quân thôn Pắc Liềng **đã tồn tại từ trước**: có biên chế, có trưởng đội, có 2 chiếc thuyền cất trong kho thôn, có khu vực phụ trách cố định. Bắt họ đăng ký lại mỗi đợt lũ và chờ duyệt 2-3 phút là vô lý — đó chính là 2-3 phút vàng.

Đây là cùng một logic với danh sách hộ dân: **chuẩn bị trước mùa thiên tai, không phải làm lúc khẩn cấp**.

### 7.2 Tách hai loại đội

| | Đội thường trực | Đội vãng lai (MTQ) |
|---|---|---|
| Ai tạo | Tổ công tác xã, trước mùa thiên tai | Tự đăng ký khi thiên tai xảy ra |
| Khi có thiên tai | **Kích hoạt 1 chạm**, không cần duyệt | Đăng ký → chờ admin duyệt |
| Vật tư | `standingEquipment` — biên chế, luôn có | `broughtSupplies` — mang theo đợt này |
| Mã QR | Cố định, in nhãn (`DR-BL-DQ-PL01`) | Quét mã chốt |
| Ví dụ | Dân quân thôn, Tổ xung kích, Đội y tế xã | Hội Chữ thập đỏ Hạ Long, đoàn thiện nguyện |

**Hệ quả về số liệu:** tổng vật tư khả dụng của xã ở v1.0 chỉ tính tồn kho. Đúng ra phải là `tồn kho + vật tư biên chế các đội + vật tư đội vãng lai mang`. Đây là con số quyết định có cần leo thang xin vật tư — tính thiếu thì xã có thể xin thêm áo phao trong khi 3 đội đang giữ sẵn 60 cái.

### 7.3 Năm trạng thái đội

| Trạng thái | Ý nghĩa | Ai đặt | Hệ thống xử lý |
|---|---|---|---|
| `available` Sẵn sàng | Đã check-in, chờ nhiệm vụ | Đội tự bật | Nhận push SOS mới |
| `on_mission` Đang nhiệm vụ | Đã bấm "Tôi đi" | Hệ thống | Không nhận SOS mới |
| `resting` Tạm nghỉ | Đội tự báo, có giờ quay lại | Đội tự bật | **Không đẩy SOS**, admin thấy giờ quay lại |
| `offline` Mất kết nối | Im lặng > 30 phút | Hệ thống | Cảnh báo admin — có thể đội gặp sự cố |
| `ended` Kết thúc ca | Rút khỏi đợt | Đội / Admin | Loại khỏi danh sách khả dụng |

**Vì sao quan trọng:** nếu đội nghỉ mà hệ thống vẫn đẩy SOS cho họ, SOS đó bị treo — không ai nhận, đồng hồ leo thang vẫn chạy nhưng thực tế không ai biết. Đây là cách **mất SOS** phổ biến nhất.

### 7.4 Màn chi tiết đội

Thông tin liên hệ · thành viên · phương tiện · **vật tư đang mang phân theo nguồn** · khu vực gán · GPS realtime · lịch sử nhiệm vụ · thống kê (số hộ đã cứu, thời gian phản ứng TB).

Hành động: Gán khu vực · Gán SOS cụ thể · Gọi trưởng đội · Xuất vật tư cho đội · Kết thúc ca.

---

## 8. Xác minh báo cáo

Màn danh sách chỉ có "Từ chối / Duyệt" — không đủ cơ sở để quyết định. Màn chi tiết cần:

- **Ảnh full-screen**, timestamp + toạ độ EXIF
- **Bản đồ 2 điểm:** vị trí báo có nạn nhân ↔ vị trí người báo lúc gửi (khoảng cách là yếu tố tin cậy quan trọng nhất)
- **Bảng chi tiết điểm tin cậy** thay vì chỉ tổng số:

  | Yếu tố | Điểm | Trạng thái |
  |---|---|---|
  | Có ảnh hiện trường | +20 | ✅ 2 ảnh |
  | GPS người báo < 500m | +15 | ✅ 320m |
  | Nhiều người báo cùng nơi | +25 | ✅ 3 báo cáo |
  | Tài khoản đã xác thực | +10 | ✅ |
  | Báo từ xa > 5km | −15 | — |
  | **Tổng** | **80/100** | |

- **Danh sách báo cáo trùng khu vực** (cross-reference FR-03.4)
- **Hồ sơ người báo:** đã báo bao nhiêu lần, tỉ lệ được duyệt
- **Ba hành động** (thay vì hai): Duyệt → tạo SOS · Yêu cầu bổ sung thông tin · Từ chối (bắt buộc chọn lý do)

---

## 9. Điểm sơ tán & check-in

**Cập nhật tình trạng** gồm: stepper số người · trạng thái (Mở/Sắp đầy/Đầy/Đóng-hỏng) · vật tư tại điểm + nút yêu cầu bổ sung · người phụ trách + SĐT (để đội gọi trước khi chở người đến) · ảnh + ghi chú.

**Check-in hộ dân tại điểm sơ tán** — quét QR trên app hộ dân **hoặc** tìm theo tên/SĐT → chọn hộ → xác nhận số người có mặt → tự động đặt `safe / evacuation_checkin`.

Đây là lời giải cho vấn đề mục 4, đồng thời làm con số "45/200" ở điểm sơ tán khớp với "280/480 hộ an toàn" trên dashboard — ở v1.0 hai con số này độc lập, không có gì đảm bảo nhất quán.

---

## 10. Kho cứu trợ & gói cứu trợ ngoài danh mục

### 10.1 Ba màn còn thiếu ở v1.0

| Màn | Nội dung chính |
|---|---|
| Nhập kho | Chọn hàng từ danh mục hoặc tạo Gói mới · số lượng · **nguồn** · đơn vị tài trợ · ảnh biên bản |
| Xuất cho đội | Chọn đội · nhiều mặt hàng · cảnh báo vượt tồn/dưới ngưỡng · ký nhận · sinh phiếu xuất có mã |
| Phát cho hộ | Chọn hộ · hàng đang mang · **cảnh báo trùng** (cùng hộ, cùng loại trong 24h) · chữ ký/ảnh · biên nhận điện tử |

### 10.2 Mô hình gói cứu trợ 2 tầng

Vấn đề thực tế: một đoàn từ thiện chở đến 1 xe tải gồm mì tôm, quần áo cũ, thuốc, bánh kẹo — **không ai có thời gian phân loại từng món trong lúc lũ đang lên**.

**Tầng 1 — `ReliefItem`**: danh mục chuẩn, có tồn kho và ngưỡng cảnh báo.

**Tầng 2 — `ReliefPackage`**:

```
ReliefPackage
├─ code:       GCT-2025-0007          ← tự sinh, dán lên thùng
├─ donor:      "Nhóm thiện nguyện Hạ Long" + SĐT
├─ status:     received → classified → distributed
└─ lines: [
     { name: "Mì tôm",     qty: 200, unit: "thùng", mappedTo: null       },
     { name: "Nước suối",  qty: 500, unit: "chai",  mappedTo: "water"    },
     { name: "Quần áo cũ", qty: 12,  unit: "bao",   mappedTo: null       },
     { name: "Thuốc cảm",  qty: 30,  unit: "hộp",   mappedTo: "medicine" },
   ]
```

```
Đoàn từ thiện đến
      ↓
[Nhập nhanh] ảnh + tên đơn vị + liệt kê thô → sinh mã ngay, KHÔNG chặn
      ↓
      ├──[Khẩn] Phát nguyên gói → biên nhận ghi "1 gói GCT-2025-0007"
      └──[Rảnh] Map từng dòng vào danh mục chuẩn
              ↓ dòng map được  → cộng tồn kho
                dòng không map → giữ dạng "hàng khác" theo mã gói
```

**Ba lợi ích:** không chặn luồng khẩn cấp · truy vết đầy đủ (yêu cầu minh bạch của công tác cứu trợ) · sổ cứu trợ chính xác.

### 10.3 Bốn nguồn hàng khi phát cho hộ

| Nguồn | Trừ tồn kho xã? | Vào sổ cứu trợ? |
|---|---|---|
| Kho xã | ✅ có | ✅ |
| Vật tư biên chế đội thường trực | ❌ không | ✅ |
| Vật tư đội vãng lai tự mang | ❌ không | ✅ |
| Phát nguyên gói chưa phân loại | ❌ không | ✅ (ghi mã gói) |

---

## 11. Leo thang: bỏ mức khẩn cấp

SRS v1.0 FR-13.1 có trường "mức khẩn cấp (thường/khẩn/rất khẩn)". Về nghiệp vụ thì mâu thuẫn: **hành động leo thang tự nó đã là tuyên bố "xã hết khả năng tự xử lý"**. Không có leo thang nào là "thường".

Thêm nữa, nhãn tự đánh giá không đáng tin: xã nào cũng sẽ chọn "rất khẩn" để được ưu tiên → nhãn mất ý nghĩa phân loại.

**Thay bằng khối số liệu hệ thống tự sinh, admin không sửa được:**

```
┌────────────────────────────────────────────────┐
│  CƠ SỞ LEO THANG — tự động tính lúc 09:52     │
├────────────────────────────────────────────────┤
│  SOS mức đỏ chưa có đội nhận      12          │
│  Thời gian chờ lâu nhất           1 giờ 47 phút│
│  Hộ mất liên lạc > 4 giờ          8           │
│  Đội khả dụng / tổng số           2 / 12      │
│  Mặt hàng dưới ngưỡng             2           │
│  Điểm sơ tán còn trống            155 chỗ     │
└────────────────────────────────────────────────┘
```

Cấp huyện nhìn số liệu khách quan để xếp ưu tiên giữa nhiều xã cùng leo thang — công bằng và nhanh hơn đọc nhãn tự gán.

**Giữ lại:** loại yêu cầu (nhân lực/vật tư/y tế/khác) + **số lượng cụ thể cần** + mô tả + ảnh.

---

## 12. Vật tư của đơn vị hỗ trợ

SRS v1.0 FR-09.2 có thu thập *"hàng hoá mang theo"*, FR-10.3 phân biệt hai nguồn khi phát hàng — **nhưng giao diện v1 chưa thể hiện chỗ nào**.

**(a) Form đăng ký MTQ** — bảng nhập dòng "Vật tư mang theo".

**(b) Màn chi tiết đội** — khối "Vật tư đang mang", phân biệt rõ nguồn:

| Hàng | Số lượng | Nguồn | Ghi chú |
|---|---|---|---|
| Áo phao | 20 | 🏛️ Kho xã | Phiếu xuất PX-0012 |
| Mì tôm | 50 thùng | 🤝 Đội tự mang | Không trừ tồn kho xã |

**(c) Dashboard admin** — chỉ số "Tổng vật tư khả dụng" (xem mục 7.2).

---

## 13. Chi tiết nhật ký

Mỗi dòng log cần: **ai** (tên + vai trò) · **lúc nào** (chính xác đến giây) · **từ đâu** (app/web, GPS, thiết bị) · **thay đổi gì** dạng `trước → sau` · **liên kết** tới đối tượng (SOS, hộ dân, đội, gói hàng) · **chuỗi sự kiện** liên quan trong cùng vòng đời.

---

## 14. Quét QR tại chốt

Một mã quét phục vụ **cả hai loại đội**, phân nhánh sau khi quét:

```
Quét mã QR
    ↓
├── Mã thuộc đội thường trực (DR-BL-DQ-PL01)
│     → Hiện thông tin đội + vật tư biên chế
│     → Chỉnh quân số hôm nay (7/8 người)
│     → [KÍCH HOẠT NGAY — KHÔNG CẦN DUYỆT]
│     → status = available, bắt đầu nhận SOS
│
└── Mã chốt / mã lạ (DR-BL-CHOT-01)
      → "Bạn là đơn vị đến chi viện?"
      → [ĐĂNG KÝ ĐỘI MỚI TẠI CHỐT]
      → Form ngắn + vật tư mang theo → chờ duyệt 2-3 phút
```

Cán bộ tại chốt không phải phân biệt trước đội nào thuộc loại nào — hệ thống tự nhận diện từ mã. Một chốt, một thao tác.

---

## 15. Tổng kết màn hình

**41 màn, 3 page, 123 kết nối prototype** — Figma `xzPK3vAmMICpIGEkzylKUo`.

### Nhóm A — Hộ dân (11 màn)
01 Splash · 02 Đăng nhập · 03 Chọn vai trò · 04 Trang chủ 3 tầng · 05 SOS 1 chạm · 06 Báo tin (B+C) · **06b Yêu cầu hỗ trợ sơ tán** · 07 Xác nhận an toàn · 08 Thông báo · 09 Đăng ký hộ dân · **24 Chi tiết thông báo**

### Nhóm B — Admin xã (21 màn)
10 Dashboard bản đồ · 11 Import dân cư · 12 Đối chiếu hộ dân · 13 Lực lượng (Thường trực/Vãng lai) · 14 Duyệt báo cáo · 15 Điểm sơ tán · 16 Phát lệnh sơ tán · 17 Kho cứu trợ · 18 Leo thang & Nhật ký · **25 Nhập hộ thủ công** · **26 Xử lý trùng lặp** · **27 Chi tiết đội** · **28 Chi tiết báo cáo xác minh** · **29 Điểm sơ tán + Check-in** · **30 Nhập kho** · **31 Xuất cho đội** · **32 Chi tiết gói cứu trợ** · **33 Chi tiết nhật ký** · **37 Chuẩn bị lực lượng thường trực** · **38 Tạo/sửa đội thường trực** · **41 Chi tiết hộ dân**

### Nhóm C — Đội cứu hộ & Công khai (10 màn)
19 Đăng ký MTQ (có vật tư mang theo) · 20 Danh sách nhiệm vụ · 21 Chi tiết SOS · 22 Báo cáo hoàn thành · 23 Situation Board · **34 Đổi trạng thái đội** · **35 Phát hàng + Biên nhận** · **36 Xác nhận hộ an toàn** · **39 Quét mã QR** · **40 Kết quả quét phân nhánh**

*(in đậm = màn bổ sung sau rà soát)*

### Ba sơ đồ luồng đã dựng
1. Đăng nhập & định tuyến vai trò
2. Vòng đời SOS & leo thang tự động
3. Vòng đời trạng thái an toàn với 5 nguồn xác nhận
