# R2 Cycling App — Helmet User Specification

## Overview
Flutter mobile app for smart helmet users on Android and iOS. Provides Bluetooth pairing and device control, group voice intercom, emergency SOS messaging, and user management with localization.

## Personas
- Helmet Rider: pairs helmet, joins groups, uses intercom, configures SOS.
- Group Leader: creates groups, manages members, ensures communication quality.
- New User: registers, learns core flows quickly.

## Platforms
- Android ≥ API 21; iOS ≥ 12.0.

## Feature Summary
- Smart Helmet Integration: BLE discovery + Classic Bluetooth pairing; volume/lighting controls; telephony/music passthrough.
- Group Intercom: create/join groups; push-to-talk voice via Agora; leave group.
- Emergency Safety: SOS contacts; GPS location + short link; SMS alerts.
- User Management: registration, login by password or verification code; profile and avatar management.
- Localization: English and Chinese.

## Detailed Requirements & Acceptance Criteria

### 1. Registration & Login
- Methods: verification code and password.
- Success navigates to Home.
- Persist tokens securely; auto-login on next launch.
- Acceptance:
  - Request and validate 6-digit code; error on invalid/expired.
  - Password login validates credentials; displays errors on failure.
  - Token stored in secure storage via `AuthService`; profile fetched and cached.
  - Home guard checks token on launch; redirects to registration when missing/expired.
  - References: `lib/auth/auth_service.dart`, `lib/login/verification_screen.dart`, `lib/login/user_login_screen.dart`, `lib/screens/home_screen.dart:105-115`, `lib/usermanager/r2_user_manager.dart`.

### 2. Smart Helmet Pairing & Device Management
- Two-stage pairing: BLE discovery, then Classic BT pairing for audio profiles.
- Device info loaded from JSON config; support multiple manufacturers.
- Controls for volume, lighting where supported.
- Acceptance:
  - BLE scan lists devices filtered by configured name prefixes.
  - Selecting a BLE device triggers Classic BT scan, bonds matching helmet, enables A2DP/Headset.
  - Device details saved locally; reconnect on app start.
  - References: `lib/connection/bt/r2_bluetooth_model.dart`, `lib/devicemanager/r2_device_manager.dart`, `lib/screens/device_pairing_screen.dart`, `lib/permission/r2_permission_manager.dart`, `android/app/src/main/kotlin/com/rockroad/r2cyclingapp/MainActivity.kt`.
  - Config: `assets/config/bluetooth_devices.json`.

### 3. Group Voice Intercom
- Join or create groups with 4-digit codes; show member list.
- Push-to-talk: hold to speak; release to mute.
- Room stability and audio quality prioritized.
- Acceptance:
  - Enter group loads members; UI shows current membership.
  - Press-and-hold unmutes mic and transmits; releasing mutes.
  - Leave group from app bar; engine cleans up.
  - References: `lib/group/group_intercom_screen.dart:101-163,404-449`, `lib/intercom/r2_intercom_engine.dart`.
  - Agora: `agora_rtc_engine: ^6.3.2`.

### 4. Emergency SOS
- Configure up to 3 contacts; enable/disable SOS flow.
- On trigger, read GPS, request short link, send SMS to contacts.
- Acceptance:
  - Toggle enables SOS; prompt to add contact if none.
  - Add/edit/delete contacts updates remote and local; off toggles when none exist.
  - Trigger sends SMS containing short link to location for all contacts.
  - References: `lib/emergency/emergency_contact_screen.dart:62-64,73-81,83-112,175-182,229-258`, `lib/emergency/r2_sos_sender.dart:52-79`.

### 5. Settings & Profile
- Update nickname and avatar; local cache and server sync.
- Acceptance:
  - Avatar selection and crop, upload success reflected in UI.
  - Profile persisted locally and on server; cache invalidation on change.
  - References: `lib/settings/user_profile_screen.dart`, `lib/usermanager/r2_user_manager.dart:492-522,524-556`.

### 6. Localization & Accessibility
- All user-facing text routed via `AppLocalizations`.
- Accessibility targets: 44dp touch, semantic labels, dynamic text scaling, contrast ≥4.5:1.
- Acceptance:
  - English and Chinese strings available; UI respects locale changes.
  - Icons and buttons have labels; layouts scale without truncation beyond ellipsis where appropriate.
  - References: `lib/l10n/app_localizations.dart`.

## Navigation & Routing
- Primary routes: `lib/main.dart:141-153`.
- Back behavior consistent across platforms; safe-area aware.

## Permissions
- Bluetooth, Location, Microphone, SMS.
- Android manifest configured; iOS `Info.plist` includes usage descriptions.
- References: README “Pre-compilation Setup”, `lib/permission/permission_dialog.dart`, `lib/permission/r2_permission_manager.dart`.

## Performance & Battery
- 60fps target; ≤16ms p95 frame build time.
- Cold start ≤2.5s on mid-tier Android; FMP ≤1.5s.
- Throttle BLE scanning and location updates; optimize Agora profiles for voice.
- Dispose controllers/streams; avoid leaks.

## Error Handling
- Standardize toast/flash for user-facing errors; log technical details without PII.
- Network timeouts and retries with backoff; offline-safe for critical UI.

## Data & Storage
- Secure token storage; preferences for lightweight settings.
- SQLite for device info and contact cache via `r2_db_helper.dart` and `r2_storage.dart`.

## API Integration
- OpenAPI reference: `config/openapi.yaml`.
- HTTP client layering: `ApiClient` (transport, typed responses) and `CommonApi` (endpoint wrappers).
- RTC tokens: server-backed; support hardcoded credentials for testing in `lib/intercom/r2_intercom_engine.dart:10-11`.

## Testing Strategy
- Unit: user manager, device manager, SOS sender; ≥80% coverage on critical paths.
- Widget: login screens, intercom screen, emergency screens; interaction and layout.
- Integration: flows for login, pairing, intercom join/talk/leave, SOS trigger; run on emulator/device.
- Golden tests for stable components.
- CI: `flutter analyze` and `flutter test` gates.

## Release Criteria
- All acceptance criteria met; analysis/test passing.
- Smoke tests on physical Android/iOS for login, pairing, intercom, SOS.
- Versioning and changelog updated; localized assets verified.

## Assumptions
- Agora credentials available for production; testing may use temporary tokens.
- Helmet models follow configured naming and UUIDs in JSON config.
