# DisasterRescue — Agent Operating Kit

Bộ điều hành agent này được xây dựng dựa trên `DisasterRescue-SRS-Full(1).md`, phiên bản 1.1 ngày 2026-08-02.

## Mục tiêu

Biến SRS thành một hệ thống điều khiển coding agent có:
- Source of truth rõ ràng
- Architecture contract
- Database/security contract
- Backlog theo task nhỏ
- Acceptance criteria
- Definition of Done
- Quy trình plan → implement → verify → report
- Cơ chế STOP khi gặp quyết định chưa được phê duyệt

## Thứ tự đọc bắt buộc của agent

1. `01_PROJECT_CONSTITUTION.md`
2. `02_AGENT_RULES.md`
3. `03_ARCHITECTURE_CONTRACT.md`
4. `04_DATA_SECURITY_CONTRACT.md`
5. `05_UI_CONTRACT.md`
6. `06_ACCEPTANCE_AND_DOD.md`
7. `07_BACKLOG.md`
8. `08_OPEN_DECISIONS.md`
9. `09_MASTER_AGENT_PROMPT.md`

SRS gốc vẫn là nguồn yêu cầu nghiệp vụ cao nhất: `DisasterRescue-SRS-Full(1).md`.

## Quy tắc

Agent không được tự ý sửa SRS, architecture, schema, security, role model hoặc thêm dependency quan trọng. Nếu gặp mâu thuẫn/thiếu thông tin: STOP → báo cáo → chờ quyết định.
