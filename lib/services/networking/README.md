# Avia Networking Service

The networking service provides the transport boundary between the Avia mobile application and the Avia backend.

## Architecture

```text
Application / Features
        │
        ▼
    ApiClient
        │
        ▼
   HttpAdapter
        │
        ▼
 HTTP Transport
        │
        ▼
   Avia Backend
