# DisasterRescue — UI Contract

## 1. Source

UI behavior follows SRS Part 7 and the Figma design referenced by the SRS.

Figma reference in SRS:
https://www.figma.com/design/xzPK3vAmMICpIGEkzylKUo

## 2. Design tokens from SRS

### Colors
- Primary/emergency red: #D32F2F
- Priority red: #D32F2F
- Priority orange: #F57C00
- Priority yellow: #F9A825
- Safe: #388E3C
- Rescuing: #1976D2
- Missing: #616161
- Pending: #F57C00
- Background: #F5F5F5
- Surface: #FFFFFF
- Text primary: #212121
- Text secondary: #757575
- Offline banner: #FFF8E1

### Typography
Font: Inter, Roboto fallback.
- h1 24/700
- h2 20/600
- h3 18/600
- bodyLarge 16/400
- bodyMedium 14/400
- caption 12/400
- label 12/600
- button 16/700
- SOS 28/900

### Spacing
4px grid:
4, 8, 12, 16, 24, 32, 48

### Radius
- card 8
- button 8
- chip 50
- SOS 16
- bottom sheet top 16

## 3. Critical UX

### Resident
Home is explicitly structured into three urgency tiers in FR-17.5:
1. SOS
2. evacuation assistance / safety confirmation
3. report for others / situation report

SOS button:
- 250px
- full width
- visually dominant
- no mandatory form before submission

### Offline
Sticky top banner when offline.

### Admin
Map dashboard is primary:
- SOS
- reports
- rescue teams
- affected area
- evacuation points
- obstacles
- field photos

### Rescue Team
Before accepting:
- limited SOS information
- no household name/phone/address

After “Tôi đi”:
- full operational household information

### Public
Situation Board:
- no login
- aggregated statistics
- public map
- no household PII

## 4. 41-screen inventory

SRS v1.1 states the inventory was expanded from 23 to 41 screens and grouped into:
- Household
- Commune Admin
- Rescue/Public

The agent must treat the SRS screen inventory as the authoritative screen list and implement screens incrementally rather than all at once.

## 5. UI completion rule

A screen is not complete merely because it visually renders.

It must include:
- loading state
- empty state where relevant
- error state
- offline state where relevant
- permission-denied state where relevant
- correct role visibility
- correct backend data
- acceptance test coverage
