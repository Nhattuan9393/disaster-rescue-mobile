# DisasterRescue — Phase 1 Three-Device Verification

## Purpose

Prove that the new architecture solves the failure mode identified during the previous demo: shared SOS data must synchronize through the cloud rather than remaining device-local.

## Devices

A — Household
B — Commune Admin
C — Rescue Team

## Test 1 — Online SOS

A:
1. Login as household.
2. Confirm GPS.
3. Press SOS.

Expected:
- SOS record appears in Firestore.
- A shows pending.
- B receives realtime update.
- B sees SOS marker.
- C receives eligible task/notification according to assignment rules.

## Test 2 — Assignment

B:
1. Open SOS.
2. Select an `available` rescue team.
3. Assign.

Expected:
- one team only.
- C receives notification.
- competing team cannot claim the same SOS.

## Test 3 — Rescue

C:
1. Open assignment.
2. Press “Tôi đi”.
3. Complete mission.

Expected:
- state changes are visible to B and A.
- event log records lifecycle.

## Test 4 — Offline household

A:
1. Disable network.
2. Press SOS.

Expected:
- Hive queue entry.
- local UUID.
- offline banner.
- reconnect triggers sync.
- B eventually receives the same SOS.

## Test 5 — Security

C before assignment:
- must not see household PII.

C after assignment:
- may see the information explicitly permitted by the SRS/security design.

Public Situation Board:
- no household PII.
- no household coordinates.

## Gate

Phase 1 is PASS only when all critical tests pass.
