# R2 Cycling App — Implementation Tasks

## Refactor Tasks — Prioritized
- Remove sensitive logging in `lib/login/user_login_screen.dart`; add lint checks.
- Abstract network layer: typed requests/responses, retry/backoff/timeouts; route all HTTP via `lib/openapi/api_client.dart` and `lib/openapi/common_api.dart`.
- Align with OpenAPI: eliminate ad-hoc `http` usage; add wrapper smoke tests.
- Isolate authentication into `AuthService`: login, token storage, renewal; document JWT lifecycle.
- Decouple Intercom engine behind interface; add error handling and mockable engine; update `lib/group/group_intercom_screen.dart`.
- Configuration management: introduce typed `ConfigService`; validate `appInit` payload and staged flags.
- Storage & privacy: evaluate `sid` sensitivity; move to secure storage if needed; clear data on logout.
- Extract EmergencyContacts service: move CRUD/enable logic out of UI to `lib/emergency/emergency_contact_service.dart`.
- Typed models/DAO for contacts: introduce `EmergencyContact` and DAO methods; remove raw `Map` usage.
- Normalize HTTP conventions: true booleans where supported; unify token retrieval; surface errors via `R2Flash`.
- Secure SOS sender: configurable HTTPS short-link host; add timeouts, error paths; rate-limit SMS bursts.
- Cross-platform SMS abstraction: implement iOS or graceful fallback (open Messages/copy text).
- UI/UX resilience: optimistic updates with rollback; consistent prompts and toasts.
- Localization audit: remove hardcoded strings; route all text via `AppLocalizations`; EN/zh coverage.
- Accessibility & safe areas: 44dp tap targets, semantic labels, text scaling; consistent safe-area handling.
- Performance instrumentation: add frame/startup metrics; optimize rebuilds and lists.
- BLE & geolocation battery optimization: throttle scans/updates; stop scans in background; choose accuracy.
- Intercom audio focus: handle focus changes; pause/resume; respect background constraints.
- Assets & image optimization: resolution-aware assets; `precacheImage` critical visuals; avoid oversized bitmaps.
- CI quality gates: enforce `flutter analyze`, tests, format; block merges on failure; coverage thresholds.
- Spec conformance tests: integration tests for login, pairing, intercom, SOS per spec.
- Routing guard based on auth: initial route from token validity and `loggedIn`.
- HTTP client enhancements: timeouts, retries, typed errors; base URL from config.
- Response typing & JSON handling: generics in `R2HttpResponse`; fix naming; remove implicit coercion.
- Central logging & redaction: levelled logger; remove PII; standardize `debugPrint` usage.
- Split `R2UserManager` responsibilities into smaller services (Auth, Profile, Media).
- Device pairing state management: decouple BLE scan/bind from UI; use manager streams with lifecycle guards.
- Database migrations & DAOs: add migration strategy beyond v1; typed DAOs for accounts/groups/devices/contacts/settings.
- iOS SMS support or fallback: ensure graceful behavior without crashes.
- Permissions & privacy strings audit: Android/iOS declarations and user messaging.
- Crash reporting/analytics (optional): integrate with PII safeguards and opt-in.
- Test coverage: add unit tests for HTTP client, services, intercom engine (mocked), device manager.

## Authentication
- Implement password login flow wiring hash + sid and token save (`lib/login/user_login_screen.dart:68-94,104-133`, `lib/usermanager/r2_user_manager.dart:80-86`).
- Implement verification-code login request, input, exchange, navigate (`lib/login/verification_screen.dart:65-91,149-156,169-175`).
- Enforce token expiry checks and re-auth redirect (`lib/usermanager/r2_user_manager.dart:92-115`).
- Add unit tests: success, invalid credentials, expired token.

## Device Pairing & Management
- Implement BLE scan UI and filters from config (`assets/config/bluetooth_devices.json`).
- Implement Classic BT pairing following identifier mapping (`lib/devicemanager/r2_device_manager.dart`, `android/app/src/main/kotlin/com/rockroad/r2cyclingapp/MainActivity.kt`).
- Persist paired device locally; auto-reconnect on app launch.
- Add unit/integration tests for scan → select → pair → reconnect.

## Intercom
- Fetch current group and members and render list (`lib/group/group_intercom_screen.dart:101-163`).
- Request RTC credentials and join channel (`lib/connection/http/openapi/common_api.dart:219-228`, `lib/intercom/r2_intercom_engine.dart:118-167,151-160`).
- Implement push-to-talk: press to unmute, release to mute (`lib/group/group_intercom_screen.dart:247-277`).
- Implement leave group and cleanup (`lib/group/group_intercom_screen.dart:176-216`).
- Add integration tests: join, speak, mute, leave.

## Emergency SOS
- Implement toggle enable with prompt when contacts empty (`lib/emergency/emergency_contact_screen.dart:59-71`).
- Implement add/edit/delete contacts with server sync (`lib/connection/http/openapi/common_api.dart:167-218`).
- Implement SOS send: GPS → short link → SMS (`lib/emergency/r2_sos_sender.dart:28-79`, `android/app/src/main/kotlin/com/rockroad/r2cyclingapp/MainActivity.kt:32-77`).
- Add integration tests: enable flow, CRUD contacts, SOS send with mocked SMS.

## User Profile & Settings
- Implement avatar selection/crop/upload and nickname update (`lib/usermanager/r2_user_manager.dart:492-556`, `lib/settings/user_profile_screen.dart`).
- Cache profile locally and invalidate on change (`lib/usermanager/r2_user_manager.dart:274-321`).
- Add widget tests for profile UI and state.

## Localization & Accessibility
- Route all strings via `AppLocalizations` (`lib/l10n/app_localizations.dart`).
- Ensure 44dp touch targets, semantic labels, and scaling support.
- Add golden tests for key components; verify Chinese and English locales.

## Permissions
- Centralize permission flows for Bluetooth, Location, Microphone, SMS (`lib/permission/r2_permission_manager.dart`, `lib/permission/permission_dialog.dart`).
- Verify platform privacy strings in iOS `Info.plist` and Android manifest.
- Add tests for permission-denied states and recovery.

## Storage & Data
- Secure token storage and retrieval (`lib/database/r2_storage.dart:32-42`).
- SQLite schemas for contacts and settings (`lib/database/r2_db_helper.dart:45-59,184-246`).
- Add unit tests for storage helpers.

## OpenAPI Alignment
- Keep `config/openapi.yaml` as source of truth.
- Ensure `lib/connection/http/openapi/api_client.dart:19-217` and `lib/connection/http/openapi/common_api.dart:18-279` cover all endpoints used.
- Add smoke tests for client wrappers: success and error responses.

## Testing & CI
- Unit test coverage ≥80% on critical modules (auth, intercom engine, sos sender).
- Widget tests for screens: login, intercom, emergency, profile.
- Integration tests on emulator/device for end-to-end flows.
- CI: run `flutter analyze` and `flutter test` on PRs.

## Performance & Battery
- Optimize rebuilds: const widgets, keys, builder lists.
- Throttle BLE scanning and location updates; tune Agora profiles for voice.
- Measure startup, frame timing; fix regressions.

## Release Checklist
- Verify critical flows on physical Android and iOS devices.
- Update version and changelog; confirm localization assets.

## Documentation
- Keep `.trae/documents` tech docs and diagrams in sync with changes.
- Link plan/spec/tasks from README Tech Notes for contributor onboarding.
