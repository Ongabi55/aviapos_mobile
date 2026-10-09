# Data Layer

Implements repositories and handles data access from various sources.

## Subdirectories

### datasources/
- Local data sources (SQLite, shared preferences)
- Remote data sources (API clients)
- Abstract datasource interfaces

### repositories/
- Concrete repository implementations
- Coordinate between datasources
- Handle offline-first synchronization

### models/
- DTOs (Data Transfer Objects)
- Serialization/deserialization
- API response models

