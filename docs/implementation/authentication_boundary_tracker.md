# AviaPOS Authentication Boundary — Implementation Tracker

## Purpose

Track the implementation, architectural decisions, validation evidence,
and outstanding work for the Flutter authentication boundary.

The backend remains the source of truth for authentication, authorization,
and merchant isolation.

## Architectural Constraints

- Preserve the existing networking architecture unless a verified
  requirement justifies a change.
- Derive request and response models from the backend contract.
- Do not duplicate backend authorization or merchant-isolation logic.
- Do not introduce Merchant Context before its planned phase.
- Do not introduce token storage or HTTP orchestration into data models.
- Validate each phase before proceeding to the next.
- Record every changed file and explain its purpose.
- Do not report unverified behavior as implemented.

## Lifecycle

| Phase | Component | Status | Evidence |
|---|---|---|---|
| B1 | AuthenticationCredentials | Complete | Tests passed; review completed |
| B2 | AuthenticationToken | Complete | Full suite: 23 tests passed; flutter analyze clean |
| B3 | AuthenticatedIdentity | Complete | Focused suite: 8 tests passed; full suite: 31 tests passed; flutter analyze clean |
| B4 | Authentication contract validation | Complete (Contract Validated) | Contract baseline verified against backend commit 0736b55; 36 tests passed; flutter analyze clean |
| C | Authentication service boundary | Complete (Service Boundary) | Focused suite: 5 tests passed; full suite: 36 tests passed; flutter analyze clean |
| D | Token lifecycle and storage boundary | Complete | Focused suite: 12 tests passed; full suite: 48 tests passed; flutter analyze clean |
| E | Authenticated networking | Pending | Not started |
| F | GET /auth/me integration | Pending | Not started |
| G | Authentication failure semantics | Pending | Not started |
| H | Merchant Context | Pending | Not started |

## B1 — AuthenticationCredentials

Status: Complete.

Purpose:
Represent the backend login request without implementing networking.

Contract fields:
- merchant_id
- username
- password

Validation:
- Credentials are stored correctly.
- Fields map to the backend request contract.
- Password is redacted from diagnostic output.

## B2 — AuthenticationToken

Status: Complete.

Purpose:
Represent the successful backend login response.

Contract fields:
- access_token
- token_type

Validation:
- Successful response parsing.
- Missing and empty access token rejection.
- Missing and empty token type rejection.
- Access token redaction in diagnostic output.
- Full Flutter test suite: 23 tests passed.
- flutter analyze: no issues found.
- git diff --check: no whitespace errors reported.

Scope boundary:
No token persistence, HTTP orchestration, or networking changes
were introduced in B2.

## B3 — AuthenticatedIdentity

Status: Complete.

Purpose:
Represent the authenticated identity returned by GET /auth/me.

Contract fields:
- user_id (String)
- merchant_id (String)
- username (String)
- role (String)
- branch_id (String?, nullable)
- active (bool)

Validation:
- Confirmed field types and branch_id nullability against backend contract (`GET /auth/me`).
- B3 focused model parsing and validation tests: 8 passed (`test/services/authentication/authenticated_identity_test.dart`).
- Full Flutter test suite: 31 tests passed.
- `flutter analyze`: no issues found.
- `git diff --check`: no whitespace errors reported.

Scope boundary:
No token persistence, HTTP orchestration, or networking changes
were introduced in B3.

## B4 — Authentication Contract Validation

Status: Complete.

Purpose:
Validate Flutter authentication request and response models against the canonical backend contract.

Contract reference:
`../AviaPOS-Module/docs/api/flutter_contract.md`

Contract metadata:
- Backend commit identifier: `0736b55ca2eb30d403b24043d843addb690911a8`
- Contract SHA-256 checksum: `7faace023272434addaacfd1ee6c8aaa9a26a96c0d49105137ee690562134b43`

Validation:
- Baseline API contract parsed and mapped to Flutter auth models (`AuthenticationCredentials`, `AuthenticationToken`, `AuthenticatedIdentity`).
- Verified `AuthenticationCredentials` against `POST /auth/login` request body contract (`merchant_id`, `username`, `password`).
- Verified `AuthenticationToken` against `POST /auth/login` response contract (`access_token`, `token_type`).
- Verified `AuthenticatedIdentity` against `GET /auth/me` response contract (`user_id`, `merchant_id`, `username`, `role`, `branch_id` nullable, `active`).
- Detailed review and regression checks completed.
- Full Flutter test suite: 36 passed.
- `flutter analyze`: no issues found.
- `git diff --check`: no whitespace errors reported.

## C — Authentication Service Boundary

Status: Complete (Service Boundary & Unit Tests; production transport and wiring pending).

Purpose:
Bridge authentication credentials and tokens to the `ApiClient` transport boundary.

Implementation details:
- Added `lib/services/authentication/authentication_service.dart`.
- Added `test/services/authentication/authentication_service_test.dart`.
- `AuthenticationService` receives the existing `ApiClient` through constructor injection.
- `login()` submits credentials to `POST /auth/login`.
- Request headers specify `application/json` for `Content-Type` and `Accept`.
- Credentials are mapped using `AuthenticationCredentials.toMap()`.
- Successful responses are parsed using `AuthenticationToken.fromMap()`.
- Unsuccessful HTTP responses produce `ApiException` with the HTTP status code.
- Non-map response bodies and malformed token responses are wrapped in `ApiException`.
- Transport exceptions are allowed to propagate.
- No token persistence, session management, navigation, role authorization, or new HTTP transport implementation was introduced.

Validation evidence (terminal results):
- `dart format`: 2 files formatted.
- Focused authentication service unit tests: 5 passed (`test/services/authentication/authentication_service_test.dart`).
- Full Flutter test suite: 36 passed.
- `flutter analyze`: No issues found.
- `git diff --check`: No whitespace errors reported.
- `git status --short`: `docs/`, `lib/services/authentication/`, and `test/services/authentication/` untracked.

Architectural limitations & pending items:
- Unit-test validation relied on `FakeAuthenticationAdapter`.
- Repository search confirmed no production `HttpAdapter` implementation (e.g., `http.Client` or `Dio` adapter) exists in the codebase.
- Search confirmed no production `ApiClient` construction point or wiring exists in the application.
- Production transport adapter implementation and application construction point remain explicitly pending.
- End-to-end authentication, token storage, session management, and navigation remain pending.

## D — Token Lifecycle and Storage Boundary

Status: Complete.

Purpose:
Provide a secure, testable boundary for persisting, retrieving, and clearing `AuthenticationToken`.

Implementation details:
- Added `flutter_secure_storage: ^9.2.4` to `pubspec.yaml` (Android minSdk API 24 and iOS deployment target 13.0 preserved).
- Enhanced `AuthenticationToken` (`lib/services/authentication/authentication_token.dart`) with `toMap()`.
- Added `AuthenticationTokenStore` abstract interface (`lib/services/authentication/authentication_token_store.dart`) exposing `save()`, `read()`, and `clear()`.
- Added `SecureAuthenticationTokenStore` (`lib/services/authentication/secure_authentication_token_store.dart`) implementing `AuthenticationTokenStore` backed by `FlutterSecureStorage` (injected via constructor).
- Uses stable private storage key `aviapos.auth.token`.
- Persists `access_token` and `token_type` together as JSON (`{"access_token":"...","token_type":"..."}`).
- Delegates validation to `AuthenticationToken.fromMap()`.
- Returns `null` when no token exists or when stored value is empty.
- Rejects malformed JSON and contract-violating stored token data with deterministic `FormatException` without exposing sensitive token strings in exception output.
- Token storage remains independent of `AuthenticationService` and `ApiClient`. No token storage logic or HTTP orchestration was added to data models or services.

Validation evidence (terminal results):
- `dart format`: 3 files formatted (`authentication_token.dart`, `secure_authentication_token_store.dart`, `secure_authentication_token_store_test.dart`).
- Focused token storage unit tests: 12 passed (`test/services/authentication/secure_authentication_token_store_test.dart`).
- Full Flutter test suite: 48 passed.
- `flutter analyze`: No issues found.
- `git diff --check`: No whitespace errors reported.
- `git status --short`: `pubspec.yaml` modified; `authentication_token_store.dart`, `secure_authentication_token_store.dart`, and `secure_authentication_token_store_test.dart` untracked.

Platform & security considerations:
- Backed by native platform secure hardware (Keychain on iOS/macOS, KeyStore/EncryptedSharedPreferences on Android, Secret Service on Linux, DPAPI on Windows).
- On Web targets, `flutter_secure_storage` uses Web Cryptography API which requires a Secure Context (HTTPS or localhost). Web browser origin storage does not provide hardware TEE/Keychain isolation comparable to mobile and desktop native OS Keychains.

## Change Log

### B1
- Added AuthenticationCredentials model (`lib/services/authentication/authentication_credentials.dart`) and its unit tests (`test/services/authentication/authentication_credentials_test.dart`).
- Validation reported successful by the developer.

### B2
- Added AuthenticationToken model (`lib/services/authentication/authentication_token.dart`) and its unit tests (`test/services/authentication/authentication_token_test.dart`).
- Full test suite passed with 23 tests.
- Static analysis reported no issues.

### B3
- Added AuthenticatedIdentity model (`lib/services/authentication/authenticated_identity.dart`) and unit tests (`test/services/authentication/authenticated_identity_test.dart`).
- Validated `user_id`, `merchant_id`, `username`, `role`, `branch_id` (nullable), and `active` (bool) against backend contract `GET /auth/me`.
- B3 focused test suite passed (8 tests).
- Full Flutter test suite passed with 31 tests.
- Static analysis (`flutter analyze`) reported no issues.
- `git diff --check` reported no whitespace errors.

### B4
- Marked Authentication contract validation as Complete.
- Registered canonical API contract path (`../AviaPOS-Module/docs/api/flutter_contract.md`), backend commit ID (`0736b55ca2eb30d403b24043d843addb690911a8`), and SHA-256 checksum (`7faace023272434addaacfd1ee6c8aaa9a26a96c0d49105137ee690562134b43`).
- Validated `AuthenticationCredentials`, `AuthenticationToken`, and `AuthenticatedIdentity` against canonical backend API contract specifications.
- Completed review and regression checks (36 tests passed, `flutter analyze` clean, `git diff --check` clean).

### C
- Added `AuthenticationService` (`lib/services/authentication/authentication_service.dart`) and unit tests (`test/services/authentication/authentication_service_test.dart`).
- Implemented `login()` over `ApiClient` submitting to `POST /auth/login`.
- Verified unit-test behavior with fake HTTP adapter (5 focused tests passed, 36 full suite tests passed, `flutter analyze` clean).
- Documented architectural limitations: production `HttpAdapter` implementation, application wiring, token storage, and live backend integration remain pending.

### D
- Added `flutter_secure_storage: ^9.2.4` dependency in `pubspec.yaml`.
- Enhanced `AuthenticationToken` (`lib/services/authentication/authentication_token.dart`) with `toMap()`.
- Added `AuthenticationTokenStore` interface (`lib/services/authentication/authentication_token_store.dart`) exposing `save()`, `read()`, and `clear()`.
- Added `SecureAuthenticationTokenStore` (`lib/services/authentication/secure_authentication_token_store.dart`) backed by `FlutterSecureStorage`.
- Added unit test suite (`test/services/authentication/secure_authentication_token_store_test.dart`) using `FakeFlutterSecureStorage` covering save, read, clear, missing token, malformed data rejection, failure propagation, and secret non-exposure (12 focused tests passed, 48 full suite tests passed, `flutter analyze` clean, `git diff --check` clean).
- Documented web secure-context requirements and platform security boundaries.



## E — Authenticated Networking

**Status: In progress — application integration review pending.**

### Implementation
- Added `lib/services/networking/authenticated_api_client.dart`.
- Added `lib/services/networking/package_http_adapter.dart`.
- Added `lib/core/bootstrap/stages/networking_bootstrap_stage.dart`.
- Updated networking abstractions and exports.
- Updated environment validation to require HTTPS for staging and production.
- Added networking, bootstrap, and environment regression tests.

### Validation
- Environment validator tests: 9 passed.
- Environment bootstrap tests: 1 passed.
- Networking bootstrap tests: 2 passed.
- Authentication tests: 34 passed.
- Networking tests: 18 passed.
- Total: 64 tests across five focused runs; full-suite status unverified.
- `flutter analyze`: no issues found.
- `git diff --check`: no whitespace errors reported.

### Outstanding
- Inspect `lib/main.dart` and confirm the networking stage is invoked by application startup.
- Confirm ownership and cleanup of `PackageHttpAdapter`.
- Verify application services use the authenticated request path.
- Run the full Flutter test suite before marking Phase E complete.
- Phases F, G, and H remain pending.

## File-by-File Implementation Ledger

| File | Purpose | Phase |
|---|---|---|
| `lib/services/authentication/authentication_credentials.dart` | Login request model; maps backend fields and redacts password. | B1 |
| `lib/services/authentication/authentication_token.dart` | Token response model, validation, redaction, and serialization. | B2, D |
| `lib/services/authentication/authenticated_identity.dart` | Model for the backend identity response. | B3 |
| `lib/services/authentication/authentication_service.dart` | Login service using injected `ApiClient`. | C |
| `lib/services/authentication/authentication_token_store.dart` | Token storage interface: save, read, clear. | D |
| `lib/services/authentication/secure_authentication_token_store.dart` | Secure token persistence using `FlutterSecureStorage`. | D |
| `lib/services/networking/api_exception.dart` | API error representation. | C, E |
| `lib/services/networking/http_adapter.dart` | HTTP transport abstraction. | E |
| `lib/services/networking/http_response.dart` | HTTP response representation. | E |
| `lib/services/networking/networking_exports.dart` | Networking exports. | E |
| `lib/services/networking/authenticated_api_client.dart` | Adds stored authorization credentials to requests. | E |
| `lib/services/networking/package_http_adapter.dart` | Production HTTP transport using `package:http`. | E |
| `lib/core/bootstrap/stages/networking_bootstrap_stage.dart` | Constructs and registers networking dependencies. | E |
| `lib/core/environment/validation/environment_config_validator.dart` | Validates environment configuration and HTTPS requirements. | E |
| `test/services/authentication/authentication_credentials_test.dart` | Credential model tests. | B1 |
| `test/services/authentication/authentication_token_test.dart` | Token model tests. | B2 |
| `test/services/authentication/authenticated_identity_test.dart` | Identity model tests. | B3 |
| `test/services/authentication/authentication_service_test.dart` | Login service tests. | C |
| `test/services/authentication/secure_authentication_token_store_test.dart` | Secure storage tests. | D |
| `test/services/networking/api_client_test.dart` | API client regression tests. | E |
| `test/services/networking/authenticated_api_client_test.dart` | Authenticated request tests. | E |
| `test/services/networking/package_http_adapter_test.dart` | Production adapter tests. | E |
| `test/core/networking_bootstrap_stage_test.dart` | Networking bootstrap tests. | E |
| `test/core/environment_config_validator_test.dart` | Environment validation tests. | E |
| `test/core/environment_bootstrap_stage_test.dart` | Environment bootstrap regression tests. | E |
| `pubspec.yaml` | Adds `flutter_secure_storage: ^9.2.4`. | D |
| `linux/flutter/generated_plugin_registrant.cc` | Generated Linux plugin registration. | D |
| `linux/flutter/generated_plugins.cmake` | Generated Linux plugin configuration. | D |
| `macos/Flutter/GeneratedPluginRegistrant.swift` | Generated macOS plugin registration. | D |
| `docs/implementation/authentication_boundary_tracker.md` | Authentication implementation tracker. | Documentation |

### Generated artifacts — do not commit as source

- `linux/flutter/ephemeral/.plugin_symlinks/flutter_secure_storage_linux`
- `linux/flutter/ephemeral/.plugin_symlinks/jni`
- `linux/flutter/ephemeral/.plugin_symlinks/path_provider_linux`

These are generated plugin symlinks. Verify ignore rules; do not include them as application source.

### Change Log — E

- Added authenticated networking, production transport, and bootstrap components with tests.
- Updated networking abstractions and environment validation.
- Recorded 64 passing tests across five focused runs; full-suite status remains unverified.
- Application bootstrap integration and adapter lifecycle ownership remain pending.
- No commit hash recorded because no verified implementation commit was provided.
