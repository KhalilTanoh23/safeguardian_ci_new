# 📊 Diagrams - Architecture & Schema Documentation

## 📋 Table of Contents

1. [Data Models](#01-data-models)
2. [BLoC Pattern](#02-bloc-pattern)
3. [Use Cases](#03-use-cases)
4. [Authentication Flow](#04-authentication-flow)
5. [Emergency Alert Flow](#05-emergency-alert-flow)
6. [Clean Architecture](#06-clean-architecture)
7. [Database Schema](#07-database-schema)

---

## 01. Data Models

### Core Models

```
User
├── id: String
├── email: String
├── phone: String
├── firstName: String
├── lastName: String
├── profileImage?: String
├── createdAt: DateTime
├── status: UserStatus (active, suspended, pending, blocked)
├── roles: List<UserRole>
├── settings: UserSettings
└── emergencyInfo: EmergencyInfo

UserSettings
├── notificationsEnabled: bool
├── communityAlertsEnabled: bool
├── communityRadius: int
├── language: String
├── darkMode: bool
├── biometricAuth: bool
├── emergencyTimeout: int
├── locationSharing: bool
├── autoConnectBracelet: bool
└── discreetMode: bool

EmergencyInfo
├── bloodType?: String
├── allergies?: List<String>
├── medicalConditions?: String
├── emergencyContactNote?: String
├── address?: String
├── workplace?: String
└── school?: String

Alert
├── id: Int
├── userId: Int
├── latitude: Double
├── longitude: Double
├── status: AlertStatus
├── timestamp: DateTime
├── message?: String
└── communityAlertSent: bool

EmergencyContact
├── id: Int
├── userId: Int
├── name: String
├── relationship?: String
├── phone: String
├── email?: String
├── priority: int (1-7)
├── isVerified: bool
├── canSeeLiveLocation: bool
├── lastAlert?: DateTime
└── responseTime?: String

Item
├── id: Int
├── userId: Int
├── name: String
├── description?: String
├── category: String
├── value?: Decimal
├── location?: String
├── isLost: bool
├── imageUrl?: String
└── updatedAt: DateTime

Document
├── id: Int
├── userId: Int
├── name: String
├── description?: String
├── filePath: String
├── fileType?: String
├── fileSize?: Int
├── isEncrypted: bool
└── updatedAt: DateTime
```

---

## 02. BLoC Pattern Architecture

### Presentation Layer - BLoC Pattern

```
Bloc<Event, State>
├── add(Event event)
├── mapEventToState(Event event)
└── close()

AuthBloc
├── Events
│   ├── AuthCheckStatus
│   ├── AuthLoginRequested (email, password)
│   ├── AuthRegisterRequested (email, password, fullName)
│   ├── AuthLogoutRequested
│   ├── AuthGoogleLoginRequested
│   ├── AuthAppleLoginRequested
│   └── AuthUpdateSettingsRequested

├── States
│   ├── AuthInitial
│   ├── AuthLoading
│   ├── AuthAuthenticated
│   ├── AuthUnauthenticated
│   ├── AuthError (message)
│   └── AuthSettingsUpdated

EmergencyBloc
├── Events
│   ├── EmergencyActivated (latitude, longitude)
│   ├── EmergencyDeactivated
│   ├── EmergencyContactAdded
│   ├── EmergencyContactRemoved
│   └── EmergencyHistoryFetched

├── States
│   ├── EmergencyInitial
│   ├── EmergencyActive (alert)
│   ├── EmergencyInactive
│   ├── EmergencyError (message)
│   └── EmergencyHistoryLoaded (alerts)

AlertsBloc
├── Events
│   ├── AlertsFetched
│   ├── AlertCreated
│   ├── AlertUpdated
│   └── AlertDeleted

├── States
│   ├── AlertsInitial
│   ├── AlertsLoading
│   ├── AlertsLoaded (alerts)
│   └── AlertsError (message)
```

---

## 03. Use Cases

### Main User Flows

```
1. AUTHENTICATION
   User → Login/Register → API → Database
   ↓
   Token Generated → Stored Locally
   ↓
   Access Granted

2. EMERGENCY ALERT
   User Press SOS → Activate Alert
   ↓
   Location Captured (GPS)
   ↓
   Emergency Contacts Notified
   ↓
   Community Alert Sent
   ↓
   Alert Status Tracked

3. MANAGE CONTACTS
   User → Add/Edit/Delete Contact
   ↓
   Contact Stored Locally & Online
   ↓
   Priority Set (1-7)
   ↓
   Verification Sent

4. MANAGE ITEMS
   User → Add Item (Lost/Found)
   ↓
   Item Stored with Image & Location
   ↓
   Available in Community
   ↓
   Match/Recovery

5. MANAGE DOCUMENTS
   User → Upload Secured Document
   ↓
   Encrypted if Needed
   ↓
   Can Share with Permissions
   ↓
   Access Control
```

---

## 04. Authentication Flow (Sequence Diagram)

```
User → App
  ↓
  Check Local Token
  ↓
  Token Valid?
  ├─ YES → Load Dashboard
  └─ NO → Show Login Screen

Login Screen:
  User → Enter Credentials
  ↓
  Email/Password → Backend API
  ↓
  Validate User
  ↓
  Valid?
  ├─ YES → Generate JWT Token
  │   ↓
  │   Token → Store Locally (Hive)
  │   ↓
  │   Emit AuthAuthenticated
  │   ↓
  │   Navigate to Dashboard
  │
  └─ NO → Emit AuthError
      ↓
      Show Error Message
      ↓
      User Retry

Alternative: OAuth (Google/Apple)
  User → Click "Google Login"
  ↓
  Google Auth Provider
  ↓
  Token Received
  ↓
  Send to Backend
  ↓
  Create/Update User
  ↓
  JWT Generated
  ↓
  Same flow as above
```

---

## 05. Emergency Alert Flow (Sequence Diagram)

```
User Press SOS Button
  ↓
  EmergencyBloc: EmergencyActivated Event
  ↓
  1. CAPTURE LOCATION
     ├─ Get GPS Coordinates
     ├─ Calculate Accuracy
     └─ Store Coordinates

  2. CREATE ALERT
     ├─ Create Alert Object
     ├─ Set Status: PENDING
     ├─ Store Locally (Hive)
     └─ Send to Backend API

  3. NOTIFY CONTACTS
     ├─ Get Emergency Contacts
     ├─ Sort by Priority (1-7)
     ├─ Send Notifications (SMS/Push)
     ├─ Send Live Location Link
     └─ Track Response

  4. COMMUNITY ALERT
     ├─ Send Community Alert
     ├─ Include Location & Details
     ├─ Available for Nearby Users
     └─ Track Community Response

  5. TRACK STATUS
     ├─ Wait for Contact Response
     ├─ Update Alert Status
     ├─ Allow User to Cancel
     └─ Generate Report

User Can:
  • Cancel Alert
  • Add Message
  • Share Additional Location
  • Track Responders on Map
  • Share Proof/Evidence
```

---

## 06. Clean Architecture Components

```
┌─────────────────────────────────────────────────────┐
│              PRESENTATION LAYER                     │
│  (Screens, Widgets, BLoC, Dialogs)                 │
├─────────────────────────────────────────────────────┤
│  UI/UX
│  ├── Screens (Dashboard, Emergency, Settings)
│  ├── Widgets (Cards, Buttons, Dialogs)
│  ├── Theme (Colors, Typography, Responsive)
│  └── BLoC (Business Logic, State Management)
└─────────────────────────────────────────────────────┘
                         ↕
┌─────────────────────────────────────────────────────┐
│              DATA LAYER                              │
│  (Repositories, Models, Services)                   │
├─────────────────────────────────────────────────────┤
│  Data Management
│  ├── Repositories (AlertRepository, ContactRepository)
│  ├── Models (User, Alert, Contact, Item, Document)
│  ├── Local Storage (Hive)
│  ├── Remote (API Service)
│  └── Cache Management
└─────────────────────────────────────────────────────┘
                         ↕
┌─────────────────────────────────────────────────────┐
│              CORE LAYER                              │
│  (Services, Utils, Constants)                       │
├─────────────────────────────────────────────────────┤
│  Infrastructure
│  ├── Services (API, Auth, Location, Notification)
│  ├── Constants (Routes, Colors, Strings)
│  ├── Utils (Helpers, Validators, Formatters)
│  ├── Theme (Responsive, Typography)
│  └── Mixins (Responsive, Helpers)
└─────────────────────────────────────────────────────┘
                         ↕
┌─────────────────────────────────────────────────────┐
│           EXTERNAL SERVICES                          │
│  (Firebase, APIs, Bluetooth, Location, Notifications)
└─────────────────────────────────────────────────────┘

Dependencies:
  Presentation → Data → Core → External
  (Unidirectional Flow)
```

---

## 07. Database Schema (ERD - Entity Relationship Diagram)

### Tables Relationships

```
users (1)
├─────────┬─────────┬─────────┬─────────────┐
│         │         │         │             │
(N) emergency_contacts
(N) alerts
(N) items
(N) documents
(N) activity_logs
(N) user_settings
(N) sessions
(1) security_audits

emergency_contacts (1)
└──────────────┬──────────────┐
               │              │
               (N)            (N)
        alert_notifications  activity_logs

alerts (1)
└──────────────┬──────────────┐
               │              │
               (N)            (N)
        alert_notifications  activity_logs

documents (1)
└──────────────┐
               (N)
        document_shares (N → N)
               ↓
        users (shared_with_user_id)

locations
├─ user_id → users (FK)
└─ timestamp index

places
├─ user_id → users (FK)
└─ coordinates index

sessions
└─ user_id → users (FK)
```

### Key Statistics

| Table               | Columns | Primary Key | Foreign Keys         | Indexes                          |
| ------------------- | ------- | ----------- | -------------------- | -------------------------------- |
| users               | 11      | id          | -                    | email, status                    |
| emergency_contacts  | 12      | id          | user_id              | user_id, priority                |
| alerts              | 8       | id          | user_id              | user_id, status, timestamp       |
| alert_notifications | 7       | id          | alert_id, contact_id | alert_id, contact_id, status     |
| items               | 10      | id          | user_id              | user_id, is_lost                 |
| documents           | 9       | id          | user_id              | user_id                          |
| document_shares     | 7       | id          | document_id, user_id | document_id, shared_with_user_id |
| locations           | 7       | id          | user_id              | user_id, timestamp               |
| places              | 9       | id          | user_id              | user_id, coordinates             |
| activity_logs       | 6       | id          | user_id              | user_id, created_at              |
| user_settings       | 10      | id          | user_id              | user_id                          |
| sessions            | 7       | id          | user_id              | user_id, last_activity           |
| security_audits     | 8       | id          | user_id              | user_id, event_type, created_at  |

---

## 📝 Summary

This documentation replaces PlantUML diagrams with **markdown-based architecture documentation**:

✅ **Easier to Read** - No special tools needed  
✅ **Version Control Friendly** - Git-compatible  
✅ **Searchable** - Full text search  
✅ **Maintainable** - Easy to update  
✅ **Comprehensive** - All architecture details in one file

---

**Generated:** 31 janvier 2026
