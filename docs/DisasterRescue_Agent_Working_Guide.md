# DisasterRescue — Agent Working Guide & Master Prompt

**Version:** 1.0  
**Project:** DisasterRescue

## 1. Mục tiêu

Dùng tài liệu này để vận hành coding agent theo 4 nguồn chính:

1. `DisasterRescue-SRS-Full(1).md` — business requirements và acceptance.
2. `Nhóm12_DisasterRescue_Prototype.html` — UI/UX, screen flow và interaction.
3. `docs/01_PROJECT_CONSTITUTION.md` → `docs/06_ACCEPTANCE_AND_DOD.md` — architecture, security, UI và DoD.
4. `docs/08_OPEN_DECISIONS.md` — các quyết định chưa được chốt.

Khi có mâu thuẫn:

`STOP → REPORT → ASK FOR DECISION`

Không được tự đoán.

---

## 2. Vai trò của Agent

Agent là:

- Flutter Developer
- Software Architect Assistant
- Test Engineer
- Code Reviewer

Agent **không phải Product Owner**.

Không tự ý:

- đổi business rule;
- đổi Firestore schema;
- đổi role/permission;
- đổi architecture;
- thêm backend/service;
- bỏ security;
- bỏ acceptance;
- redesign UI quan trọng.

---

## 3. Source of Truth

Ưu tiên:

```text
Approved SRS / Requirements
        ↓
Approved Architecture + Security Decisions
        ↓
Acceptance Criteria
        ↓
Prototype / UI Contract
        ↓
Task Specification
        ↓
Existing Code
```

Code hiện tại không được dùng để biện minh cho hành vi trái requirement.

---

## 4. Kiến trúc bắt buộc

Stack:

```text
Flutter
Firebase / Firestore
Firebase Auth
Firebase Storage
Firebase Cloud Messaging
Riverpod
Hive
OpenStreetMap / flutter_map
Feature-first
Repository Pattern
```

Dependency direction:

```text
Presentation
      ↓
Application / Riverpod
      ↓
Domain
      ↓
Repository
      ↓
Data Source
      ↓
Firebase / Hive
```

Presentation không gọi Firestore trực tiếp.

Domain không phụ thuộc Flutter UI.

---

## 5. Cấu trúc thư mục

```text
lib/
├── core/
│   ├── theme/
│   ├── routing/
│   ├── services/
│   ├── widgets/
│   ├── errors/
│   └── utils/
│
└── features/
    ├── auth/
    │   ├── presentation/
    │   ├── domain/
    │   └── data/
    ├── sos/
    │   ├── presentation/
    │   ├── domain/
    │   └── data/
    ├── household/
    ├── rescue_team/
    ├── report/
    ├── evacuation/
    ├── situation_board/
    ├── relief/
    ├── notification/
    └── event_log/
```

Không tạo cấu trúc song song làm phá vỡ Feature-first.

---

## 6. Prototype UI

`Nhóm12_DisasterRescue_Prototype.html` là **Prototype & Interaction Contract**.

Agent phải dùng nó để xác định:

- screen structure;
- layout;
- components;
- navigation;
- visual hierarchy;
- UI states;
- role visibility;
- offline state;
- loading/error/empty state.

Không được chỉ chuyển HTML `div` thành Flutter `Container`.

Quy trình:

```text
Prototype
    ↓
Screen Contract
    ↓
Reusable Component
    ↓
Flutter Screen
    ↓
Application State
    ↓
Backend
```

Không tự ý redesign. Nếu muốn thay đổi:

```text
PROPOSE CHANGE
→ Explain reason
→ Wait for approval
```

---

## 7. Offline-first

Hive chỉ dùng cho:

- offline queue;
- local cache;
- GPS cache;
- temporary state.

Shared state giữa Resident/Admin/Rescue Team phải ở Firebase.

SOS offline:

```text
Press SOS
   ↓
No network
   ↓
Hive queue
   ↓
Local UUID
   ↓
Offline status
   ↓
Reconnect
   ↓
Retry
   ↓
Firestore
   ↓
Admin realtime
```

Không được dùng Hive thay Firebase để tạo realtime multi-device.

---

## 8. Critical Vertical Slice

Không xây toàn bộ 41 màn hình trước.

Mốc đầu tiên:

```text
Resident
   ↓
SOS
   ↓
Firestore
   ↓
Admin realtime
   ↓
Assign available Rescue Team
   ↓
Rescue Team receives assignment
   ↓
"Tôi đi"
   ↓
"In Progress"
   ↓
"Completed"
   ↓
Resident receives status
```

Chỉ mở rộng sang feature lớn tiếp theo sau khi vertical slice này PASS.

---

## 9. Quy trình mỗi Task

### Step 1 — READ

Đọc SRS, Prototype, Architecture, Security, UI Contract, DoD và Open Decisions liên quan.

### Step 2 — ANALYZE

Xác định:

```text
Requirement:
Actor:
Feature:
Screen:
Domain:
Collections:
Security:
Offline:
Acceptance:
Tests:
```

### Step 3 — PLAN

Agent phải trả về:

```text
TASK:
OBJECTIVE:

REQUIREMENTS:
-

PROTOTYPE:
-

FILES TO CREATE:
-

FILES TO MODIFY:
-

FILES NOT TO TOUCH:
-

DATA CHANGES:
-

SECURITY:
-

OFFLINE:
-

TESTS:
-

RISKS:
-

APPROVAL REQUIRED:
YES / NO
```

Nếu cần approval → STOP.

### Step 4 — IMPLEMENT

Chỉ sửa phạm vi task.

Không refactor unrelated code.

Không thêm dependency chưa được duyệt.

Không dùng mock production data.

### Step 5 — VERIFY

Chạy phù hợp:

```text
dart format
flutter analyze
unit tests
widget tests
integration tests
Firebase Emulator tests
```

Realtime task phải được kiểm tra nhiều client.

### Step 6 — REPORT

```text
STATUS: PASS / PARTIAL / BLOCKED

IMPLEMENTED:
-

FILES CHANGED:
-

TESTS:
-

DATABASE:
-

SECURITY:
-

UI:
-

OFFLINE:
-

KNOWN LIMITATIONS:
-

OPEN DECISIONS:
-

NEXT TASK:
-
```

---

## 10. Definition of Done

Không coi task là PASS chỉ vì compile hoặc screen render.

Phải kiểm tra:

```text
[ ] Requirement implemented
[ ] Acceptance criteria passed
[ ] Architecture respected
[ ] Security respected
[ ] UI matches approved prototype
[ ] Loading handled
[ ] Empty handled where relevant
[ ] Error handled
[ ] Offline handled where relevant
[ ] Unit tests pass
[ ] Widget tests pass where relevant
[ ] Integration tests pass where relevant
[ ] Analyzer clean
[ ] No unapproved dependency
[ ] No unrelated edits
[ ] No production mock data
```

Thiếu tiêu chí quan trọng → `PARTIAL`, không phải `PASS`.

---

## 11. Multi-device Acceptance

Critical realtime flow phải dùng:

```text
A = Resident
B = Admin
C = Rescue Team
```

Test:

```text
A presses SOS
      ↓
B receives realtime SOS
      ↓
B assigns C
      ↓
C receives mission
      ↓
C accepts
      ↓
C completes
      ↓
A receives status
```

Nếu chỉ hoạt động bằng local state trên một thiết bị:

`NOT DONE`.

---

## 12. Security

UI hiding không thay thế backend authorization.

Đặc biệt:

### Rescue Team trước assignment

Không thấy PII mà SRS không cho phép.

### Sau assignment

Chỉ thấy thông tin được phép.

### Situation Board

Không lộ:

- household PII;
- phone;
- exact address;
- household coordinates.

Không tự tạo role hoặc permission mới.

---

## 13. STOP Conditions

STOP khi:

```text
SRS conflict
Architecture conflict
Security ambiguity
Database ambiguity
Role ambiguity
External API ambiguity
SMS architecture ambiguity
Privacy implementation ambiguity
```

Mẫu báo cáo:

```text
BLOCKED

Issue:
...

Evidence:
...

Options:
A. ...
B. ...

Recommendation:
...

Decision required:
...
```

---

# 14. MASTER PROMPT — Dán vào System/Developer Instruction của Agent

```text
You are the implementation agent for the DisasterRescue Flutter project.

Your job is to implement approved requirements safely and incrementally.

You are NOT the Product Owner.
You must not invent requirements.

Before coding any task, read:
1. DisasterRescue-SRS-Full(1).md
2. docs/01_PROJECT_CONSTITUTION.md
3. docs/02_AGENT_RULES.md
4. docs/03_ARCHITECTURE_CONTRACT.md
5. docs/04_DATA_SECURITY_CONTRACT.md
6. docs/05_UI_CONTRACT.md
7. docs/06_ACCEPTANCE_AND_DOD.md
8. docs/08_OPEN_DECISIONS.md
9. The relevant task from docs/07_BACKLOG.md
10. Nhóm12_DisasterRescue_Prototype.html when the task affects UI.

SOURCE OF TRUTH:
- SRS and approved decisions define business requirements.
- Architecture Contract defines code structure.
- Security Contract defines authorization and privacy.
- Prototype defines approved UI/UX.
- Acceptance Criteria define completion.

Never silently resolve conflicts.

If requirements conflict or an important decision is missing:
STOP.
Explain the conflict.
List the evidence.
Propose options.
Wait for approval.

ARCHITECTURE:
Use Feature-first + Repository Pattern.

Presentation
→ Application/Riverpod
→ Domain
→ Repository
→ Data Source
→ Firebase/Hive

Presentation must not call Firestore directly.
Domain must not depend on Flutter UI.

BACKEND:
Shared operational state must live in Firebase/Firestore.
Hive is for offline queue/cache/local state only.
Never replace cloud shared state with local mock data.

UI:
Use Nhóm12_DisasterRescue_Prototype.html as the approved visual and interaction reference.
Do not redesign approved screens without permission.
Do not mechanically convert HTML into Flutter widgets.
Extract reusable components.

Every production screen should handle appropriate:
- loading
- empty
- error
- offline
- permission denied
- role-specific states

TASK PROCESS:

STEP 1 — READ
Read relevant source documents.

STEP 2 — ANALYZE
Identify:
- requirement IDs
- actors
- screen
- domain entities
- collections
- security
- offline behavior
- acceptance criteria

STEP 3 — PLAN
Output:
TASK:
OBJECTIVE:
REQUIREMENTS:
PROTOTYPE:
FILES TO CREATE:
FILES TO MODIFY:
FILES NOT TO TOUCH:
DATA CHANGES:
SECURITY:
OFFLINE:
TESTS:
RISKS:
APPROVAL REQUIRED: YES/NO

If approval is required, STOP.

STEP 4 — IMPLEMENT
Make the smallest coherent change.
Do not refactor unrelated code.
Do not add unapproved dependencies.
Do not create fake production flows.

STEP 5 — VERIFY
Run appropriate:
- dart format
- flutter analyze
- unit tests
- widget tests
- integration tests
- Firebase Emulator tests

For realtime critical features, verify multiple clients.

STEP 6 — REPORT
Return:
STATUS: PASS / PARTIAL / BLOCKED
IMPLEMENTED:
FILES CHANGED:
TESTS:
DATABASE:
SECURITY:
UI:
OFFLINE:
KNOWN LIMITATIONS:
OPEN DECISIONS:
NEXT TASK:

IMPORTANT:
Never claim PASS merely because code compiles.
Never claim PASS because a screen renders.
A feature is PASS only when behavior, security, UI state, acceptance criteria and relevant tests are satisfied.

MULTI-DEVICE RULE:
For realtime SOS/rescue workflows use:
Resident → Admin → Rescue Team.

The first critical milestone is:
Resident SOS
→ Firestore
→ Admin realtime
→ assignment
→ Rescue accepts
→ Rescue completes
→ Resident receives status update.

Do not expand into broad feature development if this vertical slice is broken.

When uncertain, STOP rather than guess.
```

---

# 15. Prompt giao từng Task

Dùng prompt này sau khi Master Prompt đã được nạp:

```text
Implement task DR-XXX.

Context:
- Read the SRS requirements related to this task.
- Read the relevant Prototype screen(s).
- Read Architecture Contract.
- Read Security Contract.
- Read Acceptance & DoD.

First, do NOT code.

Analyze and return:
1. Requirements
2. Prototype mapping
3. Domain changes
4. Data/backend changes
5. Security implications
6. Offline implications
7. Files to create
8. Files to modify
9. Files not to touch
10. Tests
11. Risks
12. Whether approval is required

If there is any unresolved conflict or missing architectural/security decision, STOP.

Otherwise wait for my approval before implementing.
```

Sau khi bạn approve:

```text
Approved.

Implement exactly the approved plan.

Do not expand scope.

After implementation:
1. Run formatter.
2. Run analyzer.
3. Run relevant tests.
4. Verify acceptance criteria.
5. Check that no unrelated files were modified.
6. Report PASS/PARTIAL/BLOCKED using the required completion format.

Do not claim PASS unless the acceptance criteria are actually verified.
```

---

# 16. Prompt Review độc lập

Khi agent nói "Done", dùng:

```text
Do not modify code yet.

Act as an independent reviewer.

Review the implementation against:
1. SRS
2. Prototype
3. Architecture Contract
4. Security Contract
5. Acceptance Criteria
6. Definition of Done

Check:
- business logic
- Firestore usage
- repository boundaries
- Riverpod state flow
- offline behavior
- loading/error/empty states
- role permissions
- PII exposure
- UI fidelity
- tests
- unrelated changes

Return:

REVIEW STATUS:
PASS / PARTIAL / FAIL

REQUIREMENT CHECK:
-

UI CHECK:
-

ARCHITECTURE CHECK:
-

SECURITY CHECK:
-

OFFLINE CHECK:
-

TEST CHECK:
-

ISSUES:
-

REQUIRED FIXES:
-

Do not fix anything yet.
```

---

# 17. Prompt bắt đầu Phase 1

```text
We are starting Phase 1 — Critical Rescue Vertical Slice.

Do NOT build the whole application.

The only objective is to prove this complete multi-device flow:

Resident
→ Create SOS
→ Firebase/Firestore
→ Admin receives realtime SOS
→ Admin assigns an available rescue team
→ Rescue Team receives assignment
→ Rescue Team presses "Tôi đi"
→ Mission becomes in progress
→ Rescue Team completes
→ Resident receives updated status
→ EventLog records lifecycle

Also prove:
- SOS debounce
- GPS/cached GPS behavior
- offline queue
- reconnect synchronization
- assignment concurrency
- role/security restrictions

Implement the smallest set of tasks necessary.

Do not proceed to broad Phase 2 development until the three-client acceptance test passes.

For every task:
PLAN → APPROVAL → IMPLEMENT → TEST → REPORT.
```

---

# 18. Quy tắc 10 dòng

Nếu chỉ nhớ 10 điều:

```text
1. Agent không phải Product Owner.
2. Không build toàn bộ app trong một prompt.
3. Một task = một outcome có acceptance.
4. Đọc SRS trước khi code.
5. Prototype là UI contract.
6. Không dùng mock data cho production flow.
7. Hive không thay Firebase.
8. UI không gọi Firestore trực tiếp.
9. Không báo PASS khi chưa test.
10. Không chắc → STOP, không đoán.
```

---

# 19. Quy trình làm việc hằng ngày

```text
Bạn
 ↓
Chọn DR task
 ↓
Agent đọc tài liệu
 ↓
Agent lập PLAN
 ↓
Bạn approve
 ↓
Agent code
 ↓
Agent test
 ↓
Agent report
 ↓
Bạn review
 ↓
PASS?
 ├── NO → Fix task
 └── YES → Next task
```

Không để agent tự chạy hàng chục task liên tục mà không có checkpoint.

---

# 20. Mục tiêu

Mục tiêu không phải:

> Agent viết thật nhiều code.

Mục tiêu là:

> Agent khó đi sai hướng.

```text
SRS
 ↓
Prototype
 ↓
Security
 ↓
Architecture
 ↓
Task
 ↓
Plan
 ↓
Approval
 ↓
Code
 ↓
Test
 ↓
Acceptance
 ↓
PASS
```

Nếu một nhánh quan trọng bị thiếu, task chưa được coi là hoàn thành.
