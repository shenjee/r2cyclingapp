# Refactor Plan — Priorities and Criteria

## 1. Remove Sensitive Logging

* Outcome: No credentials or hashes logged in production or debug builds

* Impacted files: `lib/login/user_login_screen.dart`

* Acceptance: Code references removed; CI lint prevents reintroduction

## 2. Network Layer Abstraction

* Outcome: Typed request/response, error kinds, retry/backoff, timeouts

* Impacted files: `lib/connection/http/*`, call sites in login, intercom, usermanager

* Acceptance: Unified API client with tests; improved failures surfaced to UI

### 2a. OpenAPI Alignment

* Outcome: Enforce `config/openapi.yaml` as source of truth; route all HTTP via `lib/openapi/api_client.dart` and `lib/openapi/common_api.dart`

* Impacted files: `lib/openapi/*`, call sites using `R2HttpRequest`

* Acceptance: No ad-hoc `http` outside `lib/openapi`; endpoints mirrored and typed; wrapper smoke tests

## 3. Auth Module Isolation

* Outcome: Dedicated auth service encapsulating login, token storage, renewal

* Impacted files: `lib/login/*`, `lib/usermanager/*`, `lib/database/r2_storage.dart`

* Acceptance: Single entry for auth flows; JWT lifecycle documented and tested

## 4. Intercom Engine Decoupling

* Outcome: Intercom engine injected via interface; UI listens to state; error handling added

* Impacted files: `lib/intercom/*`, `lib/group/group_intercom_screen.dart`

* Acceptance: Mockable engine for tests; graceful failure states

## 5. Configuration Management

* Outcome: Strongly-typed config model; validate `appInit` payload; staged rollout flags

* Impacted files: `lib/main.dart`, `lib/usermanager/r2_user_manager.dart`

* Acceptance: Config schema verified; missing keys handled safely

### 5a. ConfigService Extraction

* Outcome: Centralize `appInit` into a typed `ConfigService` consumed by managers and UI

* Impacted files: `lib/main.dart:63-91`, `lib/usermanager/r2_user_manager.dart`, new `lib/service/config_service.dart`

* Acceptance: Strong types for `fileDomain`, `updUrl`, `loggedIn`, `newToken`; null-safe defaults

## 6. Storage & Privacy

* Outcome: Evaluate `sid` sensitivity; move to secure storage if needed; clear data on logout

* Impacted files: `lib/login/*`, `lib/database/r2_storage.dart`

* Acceptance: Privacy checklist satisfied; data retention documented

## 7. Emergency Contacts Service Extraction

* Outcome: Move network CRUD and enable/disable logic from UI to a dedicated service/repository (e.g., `lib/emergency/emergency_contact_service.dart`)

* Impacted files: `lib/emergency/emergency_contact_screen.dart`, new `lib/emergency/*_service.dart`, `lib/database/r2_db_helper.dart`

* Acceptance: UI calls service methods; service encapsulates `switchContactEnabled`, `listEmergencyContact`, `saveEmergencyContact`, `deleteEmergencyContact`; unit tests cover service

## 8. Typed Models and DAO for Contacts

* Outcome: Introduce `EmergencyContact` model and typed DAO methods instead of `List<Map<String,dynamic>>`

* Impacted files: `lib/emergency/emergency_contact_screen.dart`, `lib/database/r2_db_helper.dart`

* Acceptance: Strongly-typed `saveContact/getContacts/deleteContact`; UI uses model; no raw `Map` in UI logic

## 9. HTTP Conventions and Error Handling

* Outcome: Normalize request bodies (send true booleans where supported), unify token retrieval, and surface errors to users via toasts

* Impacted files: `lib/emergency/emergency_contact_screen.dart`, `lib/connection/http/r2_http_request.dart`

* Acceptance: Consistent token access through one path; user-facing errors via `R2Flash` on failures; retry/backoff policy for transient errors

## 10. SOS Sender Security & Config

* Outcome: Use configurable HTTPS short-link host; add timeouts and error paths; rate-limit SMS bursts

* Impacted files: `lib/emergency/r2_sos_sender.dart`, `lib/main.dart` (config), `lib/database/r2_storage.dart`

* Acceptance: Short link host resolved from runtime config; HTTPS enforced; failures fall back to raw coordinates; basic throttling prevents repeated sends in short intervals

## 11. Cross-Platform SMS Abstraction

* Outcome: Abstract SMS sending with platform checks; provide iOS implementation or graceful fallback (copy message to clipboard/open Messages)

* Impacted files: `lib/emergency/r2_sms.dart`, iOS platform code, UI prompts

* Acceptance: iOS path documented and implemented or a clear fallback; method calls do not throw on unsupported platforms

## 12. UI/UX Resilience for Contacts

* Outcome: Optimistic UI updates with rollback on server error; consistent prompts and success/error toasts

* Impacted files: `lib/emergency/emergency_contact_screen.dart`

* Acceptance: Add/edit/delete show progress indicators, success notifications; failed operations revert local state

## 27. Localization Audit

* Outcome: Remove hardcoded strings; route all user-facing text via `AppLocalizations`; ensure EN/zh coverage

* Impacted files: UI in `lib/screens`, `lib/group/*`, `lib/emergency/*`, `lib/login/*`

* Acceptance: L10n keys added; golden tests pass for both locales; semantic labels present

## 28. Accessibility & Safe Areas

* Outcome: 44dp tap targets, semantic labels, text scaling; consistent safe-area handling

* Impacted files: shared controls in `lib/r2controls/*`, major screens

* Acceptance: Accessibility checks pass; no clipped or overlapped UI with large text

## 29. Performance Instrumentation

* Outcome: Add frame timing and startup metrics; optimize rebuilds and lists

* Impacted files: hot paths in `lib/group/group_intercom_screen.dart`, `lib/screens/*`

* Acceptance: p95 frame ≤16ms on interactive screens; cold start ≤2.5s; perf regressions detected in CI

## 30. BLE & Geolocation Battery Optimization

* Outcome: Throttle scanning/updates; stop scans on background; choose appropriate accuracy

* Impacted files: `lib/devicemanager/r2_device_manager.dart`, `lib/service/r2_background_service.dart`, `lib/emergency/r2_sos_sender.dart`

* Acceptance: Reduced battery impact; scans and location updates adhere to cadence; background-safe behavior

## 31. Audio Focus & Background Behavior (Intercom)

* Outcome: Handle audio focus changes; pause/resume properly; background constraints respected

* Impacted files: `lib/intercom/r2_intercom_engine.dart`, Android audio focus wiring

* Acceptance: No audio conflicts with calls/music; clear UX on focus loss

## 32. Assets & Image Optimization

* Outcome: Use resolution-aware assets; `precacheImage` for critical visuals; avoid oversized bitmaps

* Impacted files: `lib/group/group_intercom_screen.dart`, `lib/settings/user_profile_screen.dart`, assets pipeline

* Acceptance: Fewer jank on avatar renders; memory stable; images sized appropriately

## 33. CI Quality Gates

* Outcome: Enforce `flutter analyze`, tests, and format checks; block on failures

* Impacted files: CI config; project scripts

* Acceptance: PRs cannot merge with lint/test failures; coverage thresholds enforced for critical modules

## 34. Spec Conformance Tests

* Outcome: Add integration tests that validate acceptance criteria from spec (login, pairing, intercom, SOS)

* Impacted files: `test/` integration suites

* Acceptance: Green runs assert flows per `.trae/documents/speckit.specification.md`; failures highlight gaps

## 13. Config Management Service

* Outcome: Centralize `appInit` config into a typed `ConfigService` instead of raw key strings

* Impacted files: `lib/main.dart:63-91`, `lib/database/r2_storage.dart`

* Acceptance: Strongly-typed config model; `fileDomain`, `updUrl`, `loggedIn`, `newToken` handled consistently

## 14. Routing Guard Based on Auth

* Outcome: Determine initial route based on token presence/validity and `loggedIn`

* Impacted files: `lib/main.dart:141-153`

* Acceptance: Unauthenticated users are routed to `/login`; authenticated to `/home`

## 15. HTTP Client Enhancements

* Outcome: Add timeouts, retries, and typed errors; configurable base URL from config

* Impacted files: `lib/connection/http/r2_http_request.dart`, `lib/connection/http/r2_http_response.dart`

* Acceptance: Requests use a single configuration source; error kinds (network, server, parse) surfaced to UI

## 16. Response Typing and JSON Handling

* Outcome: Replace dynamic `result` with generics; fix `stackTracke` naming; remove implicit string-to-JSON coercion in callers

* Impacted files: `lib/connection/http/r2_http_response.dart`

* Acceptance: Compile-time typing for API payloads; clearer parsing errors

## 17. Logging & Redaction

* Outcome: Central logger; remove PII logging; standardize `debugPrint` usage

* Impacted files: `lib/login/user_login_screen.dart:120-123`, app-wide logging

* Acceptance: No sensitive data logs; logger supports levels and tags

## 18. UserManager Responsibilities Split

* Outcome: Separate token ops, profile retrieval, avatar caching into smaller services (AuthService, ProfileService, MediaService)

* Impacted files: `lib/usermanager/r2_user_manager.dart`

* Acceptance: Smaller classes with single responsibility; easier unit testing

## 19. Avatar Download and Cache Optimization

* Outcome: Use HTTP cache headers; avoid per-cell `FutureBuilder` calls; prefetch and reuse image providers

* Impacted files: `lib/usermanager/r2_user_manager.dart:253-329`, `lib/group/group_intercom_screen.dart:300-333`

* Acceptance: Reduced network calls; smoother grid rendering

## 20. Intercom Lifecycle & Permissions

* Outcome: Ensure engine release in `dispose`; handle microphone permission failure paths

* Impacted files: `lib/group/group_intercom_screen.dart` (add `dispose`), `lib/intercom/r2_intercom_engine.dart`

* Acceptance: No leaks; clear error messaging if permissions denied or join fails

## 21. Device Pairing State Management

* Outcome: Decouple BLE scanning/binding from UI; move to `R2DeviceManager` streams with lifecycle guards

* Impacted files: `lib/screens/device_pairing_screen.dart:64-92,97-137,339-341`, `lib/devicemanager/*`

* Acceptance: Scanning always stops on exit; animation controllers cleaned; testable manager

## 22. Database Migrations & DAOs

* Outcome: Introduce migration strategy beyond version `1`; typed DAOs for accounts, groups, devices, contacts, settings

* Impacted files: `lib/database/r2_db_helper.dart`

* Acceptance: Safe schema evolution; typed interfaces replace raw maps

## 23. iOS SMS Support or Fallback

* Outcome: Implement iOS-side SMS sending (if allowed) or provide fallback (open Messages or copy text)

* Impacted files: `lib/emergency/r2_sms.dart`, iOS platform code

* Acceptance: Graceful behavior on iOS without crashes

## 24. Permissions & Privacy Strings Audit

* Outcome: Audit Android/iOS permissions for Bluetooth, location, microphone, SMS; ensure user messaging and settings links

* Impacted files: `android/app/src/main/AndroidManifest.xml:18-36,24`, iOS `Info.plist`

* Acceptance: Clear, localized permission prompts; minimal necessary permissions

## 25. Crash Reporting and Analytics (Optional)

* Outcome: Integrate crash reporting and optional analytics with PII safeguards

* Impacted files: App entry and logger

* Acceptance: Crash traces captured; analytics events redacted and opt-in

## 26. Test Coverage

* Outcome: Add unit tests for HTTP client, services (auth/profile/emergency), intercom engine (mocked), device manager

* Impacted files: `lib/connection/http/*`, `lib/usermanager/*`, `lib/emergency/*`, `lib/intercom/*`, `lib/devicemanager/*`

* Acceptance: CI runs tests; critical flows covered
