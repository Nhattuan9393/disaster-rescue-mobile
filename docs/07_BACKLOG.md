# DisasterRescue — Agent Backlog

## Phase 0 — Foundation

DR-001 Bootstrap Flutter project
DR-002 Configure Firebase environments
DR-003 Firebase Auth integration
DR-004 Firestore base configuration
DR-005 Riverpod dependency graph
DR-006 Hive/offline infrastructure
DR-007 Connectivity service
DR-008 GPS service + cache
DR-009 OSM/flutter_map base
DR-010 Theme/design tokens
DR-011 Routing/auth guard
DR-012 Logging/error model
DR-013 Firebase Emulator test setup

## Phase 1 — Critical Rescue Vertical Slice

DR-014 User/role domain
DR-015 Household model/repository
DR-016 SOS domain model
DR-017 SOS priority calculator
DR-018 SOS online create
DR-019 SOS offline queue
DR-020 SOS retry/sync
DR-021 SOS GPS cached location
DR-022 SOS debounce
DR-023 Admin realtime SOS stream
DR-024 Admin SOS map marker
DR-025 RescueTeam model/repository
DR-026 Available-team filtering
DR-027 Atomic SOS assignment
DR-028 Rescue “Tôi đi”
DR-029 Rescue completion
DR-030 Resident SOS status updates
DR-031 FCM notification baseline
DR-032 Event log for SOS lifecycle
DR-033 Security Rules for critical flow
DR-034 Three-client integration test

### Phase 1 release gate

Resident device:
SOS → Cloud

Admin device:
receives realtime SOS → assigns team

Rescue device:
receives assignment → accepts → completes

Resident:
receives status update

This gate MUST pass before moving to Phase 2.

## Phase 2 — Situation Awareness

DR-035 Report Flow B
DR-036 Report Flow C
DR-037 Report verification
DR-038 Cross-reference reports
DR-039 Missing contact
DR-040 Safety confirmation
DR-041 Safety source/confidence
DR-042 Situation Board
DR-043 Obstacles
DR-044 Weather alerts
DR-045 Evacuation points
DR-046 Evacuation orders
DR-047 Evacuation check-in
DR-048 AssistanceRequest

## Phase 3 — Force & Relief Operations

DR-049 Standing rescue teams
DR-050 Adhoc rescue registration
DR-051 QR check-in
DR-052 Team status/heartbeat
DR-053 Inventory
DR-054 Relief transactions
DR-055 Relief packages
DR-056 Relief receipts
DR-057 Supply source rules
DR-058 Low stock alerts
DR-059 Public relief needs

## Phase 4 — Administration & History

DR-060 Household import
DR-061 Manual household entry
DR-062 Duplicate resolution
DR-063 Event log UI
DR-064 Escalation evidence
DR-065 Automatic escalation
DR-066 Disaster event
DR-067 Event summary
DR-068 Multi-event history
DR-069 Tày critical notifications
DR-070 Final security audit
DR-071 Performance audit
DR-072 Release hardening

## Task rule

Each DR task must be split further if it cannot be completed and tested in one focused change.
