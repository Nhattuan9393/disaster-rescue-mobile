# DisasterRescue — Data & Security Contract

## 1. Firestore collections from SRS

- users
- households
- sos_requests
- assistance_requests
- reports
- rescue_teams
- relief_items
- relief_packages
- relief_transactions
- relief_receipts
- evacuation_points
- evacuation_orders
- sectors
- event_logs
- weather_alerts
- obstacles
- disaster_events

## 2. Core entities

### User
SRS fields include:
- userId
- displayName
- phoneNumber
- email
- role
- communeId
- sectorId
- householdId
- rescueTeamId
- status
- preferredLanguage
- fcmToken
- createdAt
- updatedAt
- createdBy

### Household
Includes:
- communeId / sectorId
- headName / phoneNumber
- location / address
- memberCount / houseType
- vulnerablePersons
- safetyStatus with source, verifier, confidence and note
- lastSignalAt
- linkedUserId
- importSource
- duplicateResolvedFrom

### SosRequest
Includes:
- location and locationAccuracy
- household/reporter
- disasterType
- situationChips
- memberCount
- waterLevel
- photos
- priorityScore/priorityLevel
- status
- assignedTeamId
- escalationLevel
- anonymous/offline metadata
- disasterEventId
- timestamps

### AssistanceRequest
Separate from SOS:
- its own queue
- SLA in hours
- no SOS 15/30/60 escalation timer

### RescueTeam
Includes:
- teamType: standing/adhoc
- assigned sectors
- QR
- equipment/capabilities
- standingEquipment
- broughtSupplies
- dispatchedSupplies
- status
- heartbeat/location
- registration/approval data

## 3. SOS status

`pending → verified → assigned → in_progress → completed`

Alternative:
- rejected
- cancelled

Reports waiting for admin verification may use `pending_verification` as specified.

## 4. Priority score

SRS defines:
- children +15
- elderly +15
- serious illness +20
- disabled +10
- first-floor flooding +15
- medication +10
- roof-level water +20
- chest-level water +10
- level-4 house +10
- >5 people +5

Classification:
- >=70 red
- 40–69 orange
- <40 yellow

Implement this as a domain use case/calculator and test it independently.

## 5. Safety source

SRS defines:
- rescueTeam = 100
- evacuationCheckin = 95
- selfApp = 90
- adminManual = 70
- neighborReport = 40

UI must distinguish:
- missing_contact due to device silence
- safe confirmed indirectly

## 6. Security requirements

SRS requires:
- household PII only for authorized admin and assigned rescue team
- unassigned rescue team cannot see household PII
- Situation Board has aggregated data only
- admin accounts are provisioned, not self-registered
- Firestore Security Rules enforce authorization

## 7. Important implementation note

Firestore Rules do not provide a safe substitute for field-level redaction by merely “hiding fields” in the UI. If the same document contains sensitive and non-sensitive fields, the implementation must be designed so unauthorized clients cannot read sensitive data.

This is an implementation recommendation derived from the SRS security requirement; the SRS itself does not fully specify the exact field-splitting strategy.

## 8. Custom claims

SRS describes Firebase Custom Claims carrying role and geographic scope such as:
- role
- communeId
- sectorId

Do not invent a different authorization model without approval.

## 9. Auditability

Important operational actions must create EventLog entries:
- SOS lifecycle
- evacuation
- team actions
- relief operations
- escalation
- household status changes
- obstacles
