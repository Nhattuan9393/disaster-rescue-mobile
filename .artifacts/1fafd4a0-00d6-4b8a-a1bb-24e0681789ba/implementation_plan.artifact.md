# Kế hoạch tích hợp màn hình và cập nhật Routing

Bổ sung các route còn thiếu cho các màn hình mới merge từ Minh và Cường vào `app_router.dart`, đồng thời cập nhật `main_shell.dart` để hiển thị đầy đủ các chức năng chính theo vai trò.

## User Review Required

> [!IMPORTANT]
> - **Thay thế Home của Đội cứu hộ**: Hiện tại `/` của Đội cứu hộ đang trỏ vào `TeamMissionsScreen`. Tuy nhiên `MissionListScreen` (màn 19) có bản đồ và đầy đủ tính năng hơn. Tôi đề xuất đổi `/` của Đội cứu hộ sang `MissionListScreen`.
> - **Tab mới cho Đội cứu hộ**: Bổ sung tab "Trạng thái" (trỏ vào `/team-status`) vào Bottom Navigation để đội trưởng có thể nhanh chóng đổi trạng thái sang Tạm nghỉ hoặc Kết thúc ca.

## Proposed Changes

### 1. Router & Shell

#### [MODIFY] [app_router.dart](file:///G:/Tài liệu/TLU/37. PTƯDDĐ/DisasterRescue/src/dr-tuan/lib/core/router/app_router.dart)
- Thêm imports cho tất cả màn hình mới.
- Thêm routes cho Mission: `/missions`, `/missions/:id`, `/missions/:id/complete`.
- Thêm routes cho Rescue Team: `/admin-teams`, `/admin-teams/preparation`, `/admin-teams/form`, `/admin-teams/:id`, `/team-register`, `/team-status`, `/qr-scanner`, `/qr-result`.
- Thêm routes cho Safety: `/safety-verify`.
- Thêm routes cho Relief: `/relief-distribution`.
- Truyền tham số (params/extra) cho các màn hình yêu cầu dữ liệu.

#### [MODIFY] [main_shell.dart](file:///G:/Tài liệu/TLU/37. PTƯDDĐ/DisasterRescue/src/dr-tuan/lib/shared/widgets/main_shell.dart)
- Thêm tab "Lực lượng" cho Admin (trỏ vào `/admin-teams`).
- Thêm tab "Trạng thái" cho Rescue Team (trỏ vào `/team-status`).
- Đổi tab "Nhiệm vụ" cho Rescue Team (trỏ vào `/missions` thay vì `/`).

### 2. Fix Lỗi & Kiểm thử
- Chạy `flutter analyze` để phát hiện lỗi import hoặc sai kiểu dữ liệu tham số.
- Chạy `flutter test` để đảm bảo việc thay đổi router không làm hỏng các test case hiện có.

## Verification Plan

### Automated Tests
- `flutter analyze`: Đảm bảo không có lỗi static analysis.
- `flutter test`: Chạy toàn bộ suite test của dự án.

### Manual Verification
- Kiểm tra Bottom Navigation Bar của từng vai trò (Household, Admin, Rescue Team) xem có đủ tab chưa.
- Thử điều hướng vào các màn hình mới thông qua link hoặc nút bấm giả lập.
