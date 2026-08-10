# DisasterRescue — Architecture Contract

## 1. Required stack

- Flutter
- Firebase Auth
- Firestore
- Firebase Storage
- FCM
- Firebase App Check
- Riverpod
- Hive
- OpenStreetMap / flutter_map

## 2. Layering

Presentation
→ Controller/Application (Riverpod)
→ Domain
→ Repository
→ Data Sources

### Presentation
`lib/features/*/presentation/`
- screens
- feature widgets
- shared widgets

Must not contain direct Firestore calls or core business rules.

### Controller/Application
Riverpod providers/controllers:
- StreamProvider for realtime Firestore streams
- FutureProvider for one-time loading
- Provider for dependency injection
- StateNotifier/Notifier for complex state

### Domain
`lib/features/*/domain/`
- models/entities
- use cases
- repository interfaces
- pure business rules

Must not import Flutter SDK.

### Data
`lib/features/*/data/`
- Firestore data sources
- Firebase Storage data sources
- Hive data sources
- DTOs
- repository implementations

## 3. Feature modules

Expected feature boundaries from SRS:
- auth
- sos
- report
- household
- rescue_team
- relief_store
- evacuation
- map
- situation_board
- event_log
- notification
- weather_alert
- escalation
- disaster_event

## 4. Offline architecture

Online:
Action → Firestore.

Offline:
Action → Hive queue/cache.

Reconnect:
Connectivity monitor → queue flush → retry with backoff.

SRS specifies:
- SOS first
- confirmations next
- retry 3x with backoff

GPS cache:
- foreground update every 5 minutes
- retain last 24 hours
- cached location must be visibly marked

## 5. Repository example

Conceptual contract:

```dart
abstract class ISosRepository {
  Stream<List<SosRequest>> watchSosRequests({String? sectorId});
  Future<String> createSosRequest(SosRequest request);
  Future<void> updateSosStatus(String sosId, SosStatus status);
  Future<void> assignRescueTeam(String sosId, String teamId);
  Future<List<SosRequest>> getPendingSosQueue();
  Future<void> flushOfflineQueue();
}
```

## 6. Realtime rule

Admin dashboards, rescue task lists and public Situation Board should consume Firestore realtime streams where the SRS specifies realtime behavior.

## 7. Concurrency

Assignment of a SOS must use a transaction/atomic mechanism so two rescue teams cannot successfully claim the same SOS.

## 8. Environment separation

Recommended operational separation:
- local/dev Firebase Emulator
- staging Firebase project
- production Firebase project

Do not test destructive security/schema changes directly against production.
