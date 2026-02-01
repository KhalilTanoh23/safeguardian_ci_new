# SafeGuardian CI - Architecture & Design Diagrams

This directory contains comprehensive architecture diagrams and documentation for the SafeGuardian CI project. All diagrams are now in **Markdown format** for better version control, searchability, and maintainability.

## 📋 Documentation Files

### 1. **ARCHITECTURE.md** (Main Documentation)

Complete architecture documentation including:

| Section                  | Content                                                      |
| ------------------------ | ------------------------------------------------------------ |
| **Data Models**          | All core models (User, Alert, Contact, Item, Document, etc.) |
| **BLoC Pattern**         | Presentation layer with Events and States                    |
| **Use Cases**            | Main user flows and workflows                                |
| **Authentication Flow**  | Complete login/register/OAuth sequence                       |
| **Emergency Alert Flow** | SOS activation and notification process                      |
| **Clean Architecture**   | Layered architecture with dependencies                       |
| **Database Schema**      | ER diagrams and table relationships                          |

### 2. **README.md** (This File)

Quick reference and project overview

## 🎯 Key Architecture Components

### Layers

```
Presentation Layer (Screens, BLoC, Widgets)
        ↕
Data Layer (Repositories, Models, Storage)
        ↕
Core Layer (Services, Utils, Constants)
        ↕
External Services (Firebase, APIs, Bluetooth, Location)
```

### Data Models

- **User** - User account and profile
- **EmergencyContact** - Contact information with priority
- **Alert** - Emergency alert with location
- **Item** - Lost/found items
- **Document** - Encrypted documents

### BLoC Architecture

- **AuthBloc** - Authentication and authorization
- **EmergencyBloc** - Emergency alert management
- **AlertsBloc** - Alert history and tracking
- **ContactsBloc** - Contact management
- **ItemsBloc** - Item management

### Workflows

1. **Authentication** - Login, register, OAuth
2. **Emergency Alert** - SOS activation, location sharing, notifications
3. **Contact Management** - Add, edit, delete contacts
4. **Item Management** - Track lost/found items
5. **Document Management** - Store and share documents

### 4. Sequence Diagram - Authentication (`04_sequence_diagram_authentication.puml`)

- **Purpose**: Shows the login/authentication flow
- **Participants**: User, LoginScreen, AuthBloc, ApiService, StorageService
- **Flows**: Login process, token validation, error handling

### 5. Sequence Diagram - Emergency Alert (`05_sequence_diagram_emergency_alert.puml`)

- **Purpose**: Details the emergency alert triggering and response process
- **Participants**: User, EmergencyBloc, LocationService, ApiService, NotificationService
- **Flows**: SOS trigger, contact notifications, community alerts, resolution

### 6. Component Diagram - Clean Architecture (`06_component_diagram_clean_architecture.puml`)

- **Purpose**: Shows the layered architecture following Clean Architecture principles
- **Layers**:
  - Presentation Layer (UI, BLoC)
  - Domain Layer (Use Cases, Entities)
  - Data Layer (Repositories, Models)
  - Infrastructure Layer (Services, Utils)
- **Dependencies**: Directional dependencies between layers

### 7. Database Schema Diagram (`07_database_schema_diagram.puml`)

- **Purpose**: Visual representation of the MySQL database structure
- **Entities**: 11 main tables with relationships
- **Key Features**: Primary keys, foreign keys, data types, constraints

## 🛠️ How to View Diagrams

### Online PlantUML Viewer

1. Copy the content of any `.puml` file
2. Paste into an online PlantUML viewer:
   - [PlantUML Online Server](https://www.plantuml.com/plantuml/uml/)
   - [PlantUML Web Server](https://plantuml.com/)

### VS Code Extension

1. Install the "PlantUML" extension in VS Code
2. Open any `.puml` file
3. Use `Alt+D` to preview the diagram

### Command Line

```bash
# Install PlantUML
# Then generate PNG/SVG
plantuml diagram.puml
```

## Architecture Summary

### Clean Architecture Implementation

- **Presentation Layer**: Flutter widgets, BLoC pattern, responsive UI
- **Domain Layer**: Business logic, use cases, repository interfaces
- **Data Layer**: Repository implementations, data models, API calls
- **Infrastructure Layer**: Services, utilities, external integrations

### Key Technologies

- **Frontend**: Flutter, Dart, BLoC Pattern
- **Backend**: PHP, RESTful API, MySQL
- **State Management**: Reactive BLoC pattern
- **Local Storage**: Hive database
- **Authentication**: JWT tokens
- **Real-time**: WebSocket connections
- **IoT**: Bluetooth Low Energy

### Main Features

- Emergency alert system with GPS tracking
- Contact management with priority levels
- Valuable items tracking with QR codes
- Document management with encryption
- IoT device integration (bracelets, watches)
- Community alert system
- Multi-platform support (Android, iOS, Web, Desktop)

## Reading the Diagrams

### Class Diagrams

- **Solid lines**: Associations/dependencies
- **Diamonds**: Composition/aggregation
- **Triangles**: Inheritance
- **Notes**: Additional context and explanations

### Sequence Diagrams

- **Vertical lines**: Lifelines (participants)
- **Horizontal arrows**: Messages/method calls
- **Activation boxes**: Execution periods
- **Notes**: Explanations of complex interactions

### Component Diagrams

- **Rectangles**: Components/modules
- **Arrows**: Dependencies/interfaces
- **Packages**: Logical groupings

### Database Schema

- **Bold fields**: Primary keys
- **Italic fields**: Foreign keys
- **Underlined**: Unique constraints
- **Crow's feet**: Relationships (one-to-many, etc.)

## Notes

- All diagrams are created based on the actual codebase analysis
- PlantUML syntax allows for easy maintenance and version control
- Diagrams follow UML 2.5 standards where applicable
- Color coding and notes provide additional context
- Some simplifications made for readability while maintaining accuracy

## Maintenance

When the codebase changes:

1. Update the corresponding diagram files
2. Regenerate visual diagrams
3. Update this README if new diagrams are added
4. Commit changes with descriptive messages

---
