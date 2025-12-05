# R2 Cycling App — Implementation Tasks

## Refactor Tasks — Prioritized
- [x] T001 Remove sensitive logging in `lib/login/user_login_screen.dart`; add lint checks.
- [x] T002 Abstract network layer: typed requests/responses, retry/backoff/timeouts; route all HTTP via `lib/openapi/api_client.dart` and `lib/openapi/common_api.dart`.
- [x] T003 Align with OpenAPI: eliminate ad-hoc `http` usage; add wrapper smoke tests.
- [x] T004 Isolate authentication into `AuthService`: login, token storage, renewal; document JWT lifecycle.
- [ ] T005 Decouple Intercom engine behind interface; add error handling and mockable engine; update `lib/group/group_intercom_screen.dart`.
- [ ] T006 Configuration management: introduce typed `ConfigService`; validate `appInit` payload and staged flags.
- [ ] T007 Storage & privacy: evaluate `sid` sensitivity; move to secure storage if needed; clear data on logout.
- [ ] T008 Extract EmergencyContacts service: move CRUD/enable logic out of UI to `lib/emergency/emergency_contact_service.dart`.
- [ ] T009 Typed models/DAO for contacts: introduce `EmergencyContact` and DAO methods; remove raw `Map` usage.
- [ ] T010 Normalize HTTP conventions: true booleans where supported; unify token retrieval; surface errors via `R2Flash`.
- [ ] T011 Secure SOS sender: configurable HTTPS short-link host; add timeouts, error paths; rate-limit SMS bursts.
- [ ] T012 Cross-platform SMS abstraction: implement iOS or graceful fallback (open Messages/copy text).
- [ ] T013 UI/UX resilience: optimistic updates with rollback; consistent prompts and toasts.
- [ ] T014 Localization audit: remove hardcoded strings; route all text via `AppLocalizations`; EN/zh coverage.
- [ ] T015 Accessibility & safe areas: 44dp tap targets, semantic labels, text scaling; consistent safe-area handling.
- [ ] T016 Performance instrumentation: add frame/startup metrics; optimize rebuilds and lists.
- [ ] T017 BLE & geolocation battery optimization: throttle scans/updates; stop scans in background; choose accuracy.
- [ ] T018 Intercom audio focus: handle focus changes; pause/resume; respect background constraints.
- [ ] T019 Assets & image optimization: resolution-aware assets; `precacheImage` critical visuals; avoid oversized bitmaps.
- [ ] T020 CI quality gates: enforce `flutter analyze`, tests, format; block merges on failure; coverage thresholds.
- [ ] T021 Spec conformance tests: integration tests for login, pairing, intercom, SOS per spec.
- [ ] T022 Routing guard based on auth: initial route from token validity and `loggedIn`.
- [ ] T023 HTTP client enhancements: timeouts, retries, typed errors; base URL from config.
- [ ] T024 Response typing & JSON handling: generics in `R2HttpResponse`; fix naming; remove implicit coercion.
- [ ] T025 Central logging & redaction: levelled logger; remove PII; standardize `debugPrint` usage.
- [ ] T026 Split `R2UserManager` responsibilities into smaller services (Auth, Profile, Media).
- [ ] T027 Device pairing state management: decouple BLE scan/bind from UI; use manager streams with lifecycle guards.
- [ ] T028 Database migrations & DAOs: add migration strategy beyond v1; typed DAOs for accounts/groups/devices/contacts/settings.
- [ ] T029 iOS SMS support or fallback: ensure graceful behavior without crashes.
- [ ] T030 Permissions & privacy strings audit: Android/iOS declarations and user messaging.
- [ ] T031 Crash reporting/analytics (optional): integrate with PII safeguards and opt-in.
- [ ] T032 Test coverage: add unit tests for HTTP client, services, intercom engine (mocked), device manager.

## Authentication
- [ ] T033 Implement password login flow wiring hash + sid and token save (`lib/login/user_login_screen.dart:68-94,104-133`, `lib/usermanager/r2_user_manager.dart:80-86`).
- [ ] T034 Implement verification-code login request, input, exchange, navigate (`lib/login/verification_screen.dart:65-91,149-156,169-175`).
- [ ] T035 Enforce token expiry checks and re-auth redirect (`lib/usermanager/r2_user_manager.dart:92-115`).
- [ ] T036 Add unit tests: success, invalid credentials, expired token.

## Device Pairing & Management
- [ ] T037 Implement BLE scan UI and filters from config (`assets/config/bluetooth_devices.json`).
- [ ] T038 Implement Classic BT pairing following identifier mapping (`lib/devicemanager/r2_device_manager.dart`, `android/app/src/main/kotlin/com/rockroad/r2cyclingapp/MainActivity.kt`).
- [ ] T039 Persist paired device locally; auto-reconnect on app launch.
- [ ] T040 Add unit/integration tests for scan → select → pair → reconnect.

## Intercom
- [ ] T041 Fetch current group and members and render list (`lib/group/group_intercom_screen.dart:101-163`).
- [ ] T042 Request RTC credentials and join channel (`lib/connection/http/openapi/common_api.dart:219-228`, `lib/intercom/r2_intercom_engine.dart:118-167,151-160`).
- [ ] T043 Implement push-to-talk: press to unmute, release to mute (`lib/group/group_intercom_screen.dart:247-277`).
- [ ] T044 Implement leave group and cleanup (`lib/group/group_intercom_screen.dart:176-216`).
- [ ] T045 Add integration tests: join, speak, mute, leave.

## Emergency SOS
- [ ] T046 Implement toggle enable with prompt when contacts empty (`lib/emergency/emergency_contact_screen.dart:59-71`).
- [ ] T047 Implement add/edit/delete contacts with server sync (`lib/connection/http/openapi/common_api.dart:167-218`).
- [ ] T048 Implement SOS send: GPS → short link → SMS (`lib/emergency/r2_sos_sender.dart:28-79`, `android/app/src/main/kotlin/com/rockroad/r2cyclingapp/MainActivity.kt:32-77`).
- [ ] T049 Add integration tests: enable flow, CRUD contacts, SOS send with mocked SMS.

## User Profile & Settings
- [ ] T050 Implement avatar selection/crop/upload and nickname update (`lib/usermanager/r2_user_manager.dart:492-556`, `lib/settings/user_profile_screen.dart`).
- [ ] T051 Cache profile locally and invalidate on change (`lib/usermanager/r2_user_manager.dart:274-321`).
- [ ] T052 Add widget tests for profile UI and state.

## Localization & Accessibility
- [ ] T053 Route all strings via `AppLocalizations` (`lib/l10n/app_localizations.dart`).
- [ ] T054 Ensure 44dp touch targets, semantic labels, and scaling support.
- [ ] T055 Add golden tests for key components; verify Chinese and English locales.

## Permissions
- [ ] T056 Centralize permission flows for Bluetooth, Location, Microphone, SMS (`lib/permission/r2_permission_manager.dart`, `lib/permission/permission_dialog.dart`).
- [ ] T057 Verify platform privacy strings in iOS `Info.plist` and Android manifest.
- [ ] T058 Add tests for permission-denied states and recovery.

## Storage & Data
- [ ] T059 Secure token storage and retrieval (`lib/database/r2_storage.dart:32-42`).
- [ ] T060 SQLite schemas for contacts and settings (`lib/database/r2_db_helper.dart:45-59,184-246`).
- [ ] T061 Add unit tests for storage helpers.

## OpenAPI Alignment
- [ ] T062 Keep `config/openapi.yaml` as source of truth.
- [ ] T063 Ensure `lib/connection/http/openapi/api_client.dart:19-217` and `lib/connection/http/openapi/common_api.dart:18-279` cover all endpoints used.
- [ ] T064 Add smoke tests for client wrappers: success and error responses.

## Testing & CI
- [ ] T065 Unit test coverage ≥80% on critical modules (auth, intercom engine, sos sender).
- [ ] T066 Widget tests for screens: login, intercom, emergency, profile.
- [ ] T067 Integration tests on emulator/device for end-to-end flows.
- [ ] T068 CI: run `flutter analyze` and `flutter test` on PRs.

## Performance & Battery
- [ ] T069 Optimize rebuilds: const widgets, keys, builder lists.
- [ ] T070 Throttle BLE scanning and location updates; tune Agora profiles for voice.
- [ ] T071 Measure startup, frame timing; fix regressions.

## Release Checklist
- [ ] T072 Verify critical flows on physical Android and iOS devices.
- [ ] T073 Update version and changelog; confirm localization assets.

## Documentation
- [ ] T074 Keep `.trae/documents` tech docs and diagrams in sync with changes.
- [ ] T075 Link plan/spec/tasks from README Tech Notes for contributor onboarding.
