# DisasterRescue — Acceptance & Definition of Done

## 1. Acceptance hierarchy

A task passes only if:
1. Functional requirement is implemented.
2. Acceptance criteria are met.
3. Security constraints are met.
4. Relevant non-functional requirements are met.
5. Tests pass.

## 2. Critical acceptance targets from SRS

### SOS online
- GPS acquisition target <2s in AC01-01
- Firestore submission <3s
- Admin push <5s
- Admin marker appears

### SOS offline
- saved to Hive
- local UUID
- visible offline status
- automatically syncs when connectivity returns

### GPS cache
- use cached location if live GPS unavailable
- clearly mark cached location
- retain up to 24h according to SRS

### SOS debounce
- repeated taps within 10 seconds produce one SOS

### Concurrent assignment
- two teams cannot claim the same SOS
- transaction/atomic locking behavior required

### Escalation
- red unassigned SOS:
  - 15m warning
  - 30m warning + sound
  - 60m warning + escalation suggestion

### Evacuation
- issued order
- target households receive notification
- absolute confirmation counts
- full evacuation point behavior

## 3. Definition of Done

[ ] Requirement mapped to task
[ ] Acceptance criteria listed
[ ] Domain logic implemented
[ ] Repository implemented
[ ] Remote/local data handling implemented
[ ] Security rules reviewed
[ ] Loading/empty/error/offline states implemented
[ ] Unit tests pass
[ ] Widget tests pass where applicable
[ ] Integration tests pass where applicable
[ ] Analyzer/linter clean
[ ] No unrelated changes
[ ] No unapproved dependency
[ ] No mock production path
[ ] Multi-device test completed for realtime critical features
[ ] Agent completion report produced

## 4. Status meanings

PASS = all required criteria met.

PARTIAL = implementation exists but one or more criteria remain.

BLOCKED = cannot safely continue without a product/architecture decision or external dependency.

Never use PASS for PARTIAL or BLOCKED.
