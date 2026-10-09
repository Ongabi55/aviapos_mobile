# AviaPOS Mobile

[![Flutter](https://img.shields.io/badge/Flutter-3.12%2B-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.0%2B-0175C2?logo=dart)](https://dart.dev)
[![Architecture](https://img.shields.io/badge/Architecture-Clean%20%2B%20Modular-green)](#architectural-constitution)
[![Offline First](https://img.shields.io/badge/Strategy-Offline--First-orange)](#offline-first--resilience-strategy)

**AviaPOS Mobile** is a high-reliability, offline-first Point-of-Sale (POS) and merchant management application engineered using Flutter. Built on Clean Architecture principles, AviaPOS provides merchant operational capabilities including sales checkout, stock inventory management, store expense logging, and customer debt/receivables tracking—built to operate flawlessly even in low or absent network connectivity conditions.

---

## Executive Overview & System Vision

AviaPOS Mobile serves as the frontend client in the Avia ecosystem (integrating with backend API platforms such as RailOne). It empowers retail and service merchants with zero-latency transaction processing by executing business rules locally and synchronizing seamlessly with central backends via queued background synchronization pipelines.

### Core Capabilities

* 🛒 **Sales Capability (`lib/features/sales`)**: High-speed checkout, itemized order handling, cart state management, discount processing, and payment settlement.
* 📦 **Inventory Capability (`lib/features/inventory`)**: Product catalog management, SKU tracking, real-time stock levels, adjustments, and movement audits.
* 💸 **Expenses Capability (`lib/features/expenses`)**: Merchant operational expense recording, categorizations, and store disbursement tracking.
* 📒 **Receivables Capability (`lib/features/receivables`)**: Customer ledger tracking, credit sales management, partial payment recording, and debt collection lifecycle.

---

## Architectural Constitution

The system strictly adheres to an architectural constitution designed to guarantee maintainability, testability, and fault isolation across the client application.

```text
┌────────────────────────────────────────────────────────────────────────┐
│                        Presentation / UI Layer                         │
│                    (Widgets, Screens, Controllers)                     │
└───────────────────────────────────┬────────────────────────────────────┘
                                    │
                                    ▼
┌────────────────────────────────────────────────────────────────────────┐
│                             Feature Layer                              │
│              (sales, inventory, expenses, receivables)                 │
└───────────────────────────────────┬────────────────────────────────────┘
                                    │
                                    ▼
┌────────────────────────────────────────────────────────────────────────┐
│                             Domain Layer                               │
│           (Entities, Value Objects, Repository Contracts)              │
│               * Pure Dart - Zero Framework Dependencies *               │
└───────────────────────────────────▲────────────────────────────────────┘
                                    │
                                    │ (Implements)
┌───────────────────────────────────┴────────────────────────────────────┐
│                              Data Layer                                │
│       (Repositories, Local SQLite Datasources, Remote API Clients)      │
└───────────────────────────────────┬────────────────────────────────────┘
                                    │
                                    ▼
┌────────────────────────────────────────────────────────────────────────┐
│                  Services & Core Infrastructure Layer                  │
│       (Networking, Bootstrapping, Environment, Runtime Health)         │
└────────────────────────────────────────────────────────────────────────┘
```

### Constitutional Laws

1. **Pure Domain Isolation**:
   The Domain layer (`lib/domain/`) represents core business rules and domain entities (e.g., `Product`, `Sale`, `Inventory`, `Money`). It must remain 100% pure Dart, strictly independent of Flutter, UI components, or external networking libraries.

2. **Unidirectional Dependency Flow**:
   Outer layers depend on inner layers. Presentation depends on Feature and Domain; Data layer implements Domain repository contracts. Cyclic dependencies are strictly prohibited.

3. **Offline-First Local Authority**:
   Local storage (SQLite/Local Data Sources) acts as the primary authority during merchant operations. Remote APIs receive queued data mutations asynchronously.

4. **Transport Agnosticism & Network Resilience**:
   All networking occurs behind transport abstractions (`HttpAdapter`, `ApiClient`). All state-mutating requests (`POST`, `PUT`, `PATCH`, `DELETE`) require idempotency headers (`Idempotency-Key`) to ensure safe execution during network reconnections and retries.

5. **Strict Runtime Health Isolation**:
   The runtime health subsystem (`RuntimeHealthService`, `RuntimeHealth`) monitors purely infrastructure state (`healthy`, `degraded`, `unhealthy`). It is constitutionally forbidden from containing merchant state, authentication tokens, payment state, or business logic.

---

## Directory Structure

```text
lib/
├── core/                       # Core platform infrastructure
│   ├── bootstrap/              # Pipeline-based startup lifecycle & stages
│   ├── environment/            # Multi-environment configurations & validation
│   └── runtime/                # Infrastructure health checks & monitoring
├── data/                       # Data layer implementations
│   ├── datasources/            # SQLite local storage & remote API implementations
│   ├── models/                 # Data transfer objects (DTOs) & serialization
│   └── repositories/          # Concrete repository implementations
├── domain/                     # Pure domain logic (Framework agnostic)
│   ├── entities/               # Core domain models (Sale, Product, etc.)
│   ├── repositories/          # Abstract repository contracts
│   └── value_objects/          # Immutable domain types (Money, Price, Quantity)
├── features/                   # Modular feature capabilities
│   ├── sales/                  # POS checkout & transaction management
│   ├── inventory/              # Product catalog & stock movement
│   ├── expenses/               # Merchant expense tracking
│   └── receivables/            # Customer debt & store credit tracking
├── services/                   # Cross-cutting platform services
│   ├── authentication/         # User auth & token session management
│   ├── networking/             # Transport-agnostic API client & HTTP adapters
│   ├── storage/                # Secure credential storage & key-value cache
│   └── synchronization/        # Background queue sync & conflict handling
└── shared/                     # Reusable components
    ├── constants/              # Global application constants
    ├── utils/                  # Common helper extensions
    └── widgets/                # Atomic UI widgets & shared design elements
```

---

## Application Lifecycle & Bootstrapping

Application initialization follows a deterministic, stage-driven pipeline (`BootstrapPipeline`). On startup, the pipeline executes ordered stages (`EnvironmentBootstrapStage`, etc.) within a isolated `BootstrapContext`.

### Environment Configuration & Validation

AviaPOS supports four runtime environments (`RuntimeEnvironment`):
* `development` (`http://localhost:8000`)
* `test` (`http://localhost:8000`)
* `staging` (`https://staging-api.avia.example`)
* `production` (`https://api.avia.example`)

Before the application boots, `EnvironmentConfigValidator` enforces strict environment guarantees:
* Application name must be non-empty.
* API Base URL must parse into a valid URI with explicit `http` or `https` scheme.

---

## Engineering & Development Workflow

### Prerequisites

* [Flutter SDK](https://docs.flutter.dev/get-started/install) (`^3.12.2`)
* [Dart SDK](https://dart.dev/get-sdk) (`^3.0.0`)

### Getting Started

1. **Clone the Repository**:
   ```bash
   git clone https://github.com/your-org/aviapos_mobile.git
   cd aviapos_mobile
   ```

2. **Install Dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run Verification & Unit Tests**:
   ```bash
   flutter test
   ```

4. **Launch Application**:
   ```bash
   flutter run
   ```

---

## Git Workflow & Team Collaboration Guidelines

To maintain code quality and prevent data loss, all team members must follow these strict Git rules:

### Branch Strategy
* **Main Branch Protection**: Direct commits to `main` are strictly forbidden.
* **Feature Branches**: Work must be conducted on feature branches created off `main`:
  ```bash
  git checkout -b feature/sales-domain
  ```

### Commit Standards
Use semantic prefixes for all commits:
* `feat:` New capability or architectural component.
* `fix:` Bug fix or error resolution.
* `docs:` Architectural decision records or documentation.
* `WIP:` Work-in-progress daily checkpoint commit before pushing to remote.

### Daily Checkpoint Routine
Always stage, commit, and push work at the end of each work session:
```bash
git add .
git commit -m "WIP: Daily checkpoint - [describe work completed]"
git push origin feature/<your-feature-branch>
```

---

## License

Copyright © Avia Technologies. All rights reserved. Proprietary and confidential.
