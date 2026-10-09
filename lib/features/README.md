# Features

Each capability is organized as an independent feature module.

## Capabilities

### sales/
Business logic for recording and managing sales transactions

### inventory/
Manage product inventory, stock levels, and stock movements

### expenses/
Track and categorize business expenses

### receivables/
Manage customer receivables and payment tracking

## Feature Structure

Each feature contains:

```
feature/
├── presentation/     # UI layer (widgets, screens, state management)
├── domain/          # Business logic (entities, use cases)
└── data/            # Data access (repositories, models)
```

