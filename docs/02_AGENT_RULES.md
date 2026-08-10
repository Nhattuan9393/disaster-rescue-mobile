# DisasterRescue — Agent Rules

## RULE-001 — Read before coding

Before coding, read:
- SRS
- Constitution
- Architecture contract
- Data/security contract
- UI contract
- Acceptance criteria for the task

## RULE-002 — No silent architecture decisions

STOP before changing:
- Firebase/backend architecture
- Firestore collections or field semantics
- Auth model
- roles/permissions
- Security Rules
- offline synchronization strategy
- navigation architecture
- state-management architecture
- production dependencies
- external services

## RULE-003 — No fake backend

Do not use hardcoded/mock/local-only data in a production flow unless the task is explicitly marked `PROTOTYPE_ONLY`.

## RULE-004 — Cloud/shared-state rule

Shared operational state must be represented in Firebase/Firestore according to the SRS data model.

Hive is for:
- offline queue
- local cache
- GPS cache
- local temporary state

## RULE-005 — UI separation

Presentation code must not call Firestore directly.

Expected direction:
Presentation → Riverpod/Application → Domain → Repository → Data Source.

## RULE-006 — Domain purity

Domain layer should remain Dart-only and contain:
- entities/models
- repository interfaces
- use cases
- business rules/calculators

## RULE-007 — Critical security

Do not rely on UI hiding for authorization. Backend authorization must enforce access.

Public Situation Board must not expose household names, phone numbers, addresses or household coordinates.

Unassigned rescue teams must not receive household PII.

## RULE-008 — SOS is critical

SOS implementation must account for:
- online submission
- offline queue
- retry
- GPS cache
- duplicate/debounce
- status transitions
- realtime admin visibility
- assignment concurrency

## RULE-009 — Assignment constraint

Only rescue teams whose operational status is `available` may receive new SOS according to FR-09.8.

## RULE-010 — No unrelated edits

Before coding, list files to modify. Do not refactor unrelated features.

## RULE-011 — Test before claiming DONE

Run relevant unit/widget/integration tests and the acceptance scenarios.

## RULE-012 — Multi-device proof

Realtime critical flows are not complete until the Resident/Admin/Rescue interaction is verified across multiple clients.

## RULE-013 — Completion report

Every task must report:
- status: PASS/PARTIAL/BLOCKED
- files changed
- tests
- data/schema changes
- security changes
- known limitations
- next recommended task

## RULE-014 — STOP conditions

STOP and ask for approval when:
- requirements conflict
- a required external service is unspecified
- security cannot be implemented safely
- acceptance criteria are impossible with current architecture
- a package is required that changes architecture
- a data migration is required

## RULE-015 — [Reserved]

## RULE-016 — [Reserved]

## RULE-017 — PROTOTYPE VERIFICATION BEFORE UI IMPLEMENTATION

Before implementing or modifying any production screen,
the agent MUST directly inspect the approved Prototype HTML.

The agent MUST identify:
- Prototype screen ID
- Screen name
- Role
- Layout structure
- Components
- Visual tokens
- Navigation
- UI states
- Interaction behavior
- Data visibility

The agent MUST NOT implement a screen based only on:
- SRS text
- existing Flutter code
- generic Material Design
- agent assumptions
- previous implementation

If the Prototype and SRS appear inconsistent,
the agent MUST STOP and report the conflict.

Before coding a production screen, the agent must provide:

PROTOTYPE SCREEN:
...

FLUTTER SCREEN:
...

COMPONENTS:
...

UI STATES:
...

NAVIGATION:
...

DATA:
...

SECURITY:
...

KNOWN DIFFERENCES:
...

If there are unresolved differences:
APPROVAL REQUIRED: YES

No production UI implementation may begin until
the prototype mapping is understood.

## RULE-018 — NO VISUAL GUESSING

The agent must never replace an approved prototype
with its own interpretation.

Statements such as:

"I used a standard Material layout."
"I simplified the screen."
"I created a basic UI for testing."
"I will refine the UI later."

are NOT acceptable reasons for deviating from the Prototype
when implementing a production screen.

If a temporary debug UI is required for a technical test,
it must be explicitly labeled:

TEMPORARY DEBUG UI

and must not be reported as production UI completion.
