# DisasterRescue — Project Constitution

## 1. Product identity

- Tên: DisasterRescue
- Phạm vi demo: Quảng Ninh, gồm Bình Liêu/Hạ Long và các khu vực được SRS nêu
- Nền tảng: Flutter
- Backend: Firebase
- Bản đồ: OpenStreetMap
- Kiến trúc: Feature-first + Repository Pattern
- State management: Riverpod
- Local storage/offline queue: Hive
- Push: Firebase Cloud Messaging

Các ràng buộc trên lấy trực tiếp từ SRS v1.1.

## 2. Product principles

1. Offline-first cho các chức năng quan trọng.
2. SOS 1 chạm.
3. Hiển thị số tuyệt đối thay vì phần trăm.
4. Việt Nam là bối cảnh vận hành; hỗ trợ Việt + Tày cho các thông báo quan trọng.
5. Bảo vệ thông tin hộ dân.
6. Situation Board là chế độ xem công khai, không phải role.
7. Shared operational data phải có nguồn dữ liệu cloud.
8. Hive dùng cho local queue/cache, không thay thế backend shared state.

## 3. Critical product flows

### Flow A — Emergency rescue
Household → SOS → Firestore/queue → Admin realtime → assign team → Rescue team accepts → in progress → completed → household notification/status.

### Flow B — Evacuation
Admin → chọn vùng → chọn điểm sơ tán → phát lệnh → household receives → check-in hoặc báo không thể sơ tán → Admin theo dõi số tuyệt đối.

### Flow C — Public situation
Public → Situation Board → aggregated map/statistics/photos/relief needs, không lộ PII hoặc tọa độ nhà dân.

### Flow D — Relief
Import → warehouse/team/package → dispatch/delivery → ReliefReceipt → aggregated public summary.

## 4. Non-goals

Theo SRS:
- Dashboard tỉnh/huyện trong phạm vi chính
- Quản lý ca trực nhân sự
- Đánh giá thiệt hại nhà ở sau thiên tai
- Loa phát thanh tích hợp
- Tình nguyện viên cá nhân ngoài mô hình đội MTQ

## 5. Source of truth hierarchy

1. Approved SRS v1.1
2. Approved architecture/security/data decisions
3. Acceptance tests
4. Approved task specification
5. Code

Nếu code trái SRS/approved decision, code phải được sửa hoặc task bị BLOCKED.
