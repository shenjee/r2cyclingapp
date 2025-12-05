# R2 Cycling App — Technical Architecture

## Overview
- Flutter application with modular organization under `lib/` for UI, networking, storage, intercom, user and group management
- Entry point initializes services and routes; network base and secure storage configured at startup
- Key third-party packages: `http`, `agora_rtc_engine`, `flutter_secure_storage`, `shared_preferences`, `sqflite`, `permission_handler`, `flutter_reactive_ble`, `geolocator`, `image_picker`, `crypto`, `uuid`, `flutter_markdown`

## Entry Points
- App startup and error guards in `lib/main.dart:35-61`
- Service initialization (`appInit`) persists runtime config in secure storage `lib/main.dart:63-91`
- Routes configured in `lib/main.dart:141-153` (`/home`, `/register`, `/login`, `/bluetooth_pairing`, `/groupList`, `/intercom`, `/emergencyContact`, `/settings`, `/profile`)

## Directory Map
- `lib/screens` core UI screens
- `lib/login` authentication flows and base screen classes
- `lib/auth` authentication service orchestrating HTTP and storage
- `lib/usermanager` account, group, profile models and storage orchestration
- `lib/connection/http/openapi` HTTP client (`ApiClient`) and API wrappers (`CommonApi`)
- `lib/intercom` voice intercom engine wrapper around Agora SDK
- `lib/group` group list and intercom screen
- `lib/database` local persistence helpers: secure storage, DB helper
- `lib/connection/bt` BLE device models and commands
- `lib/emergency` SOS features
- `lib/settings` user settings and profile UI
- `lib/l10n` localization
- `assets/configs` runtime BLE device configs

## Networking Layer
- Base URL: `https://rock.r2cycling.com/api/` in `lib/connection/http/openapi/api_client.dart`.
- Requests send `Content-Type: application/x-www-form-urlencoded` and attach `apiToken` when present, handled by `ApiClient`.
- File uploads via `ApiClient` multipart helpers.
- Typed responses via `R2HttpResponse<T>` `lib/connection/http/openapi/api_client.dart:243-268`.

## Storage & Configuration
- Secure storage of JWT token (`authtoken`) in `lib/database/r2_storage.dart:32-42`
- Additional runtime config (e.g., `fileDomain`) saved in `appInit` and later used for static downloads (`lib/main.dart:63-91`, `lib/usermanager/r2_user_manager.dart:274-289`)

## Intercom Subsystem
- UI orchestration in `lib/group/group_intercom_screen.dart:101-163,247-277,465-467`
- Engine setup and lifecycle: `lib/intercom/r2_intercom_engine.dart:79-97,118-167,179-183`

## Authentication Subsystem
- `AuthService` centralizes login flows, sid generation, hashing, token storage, and expiry (`lib/auth/auth_service.dart`).
- Screens call `AuthService.loginWithPassword` and `AuthService.loginWithCode`; `AuthService.sendAuthCode` for SMS.
- Home guard checks token expiry via `AuthService.expiredToken`; redirects to registration when invalid (`lib/screens/home_screen.dart:105-115`).
- Profile retrieval and local cache population in `lib/usermanager/r2_user_manager.dart`.

## Platform Integration
- Android `MainActivity` for method channel (SMS) and manifest permissions
- iOS `Info.plist` for microphone and background usage declarations

## Architecture Diagram
```mermaid
flowchart TD
  A[Flutter UI] -->|Routes| B[Screens]
  B --> C[AuthService]
  C --> D[CommonApi]
  D --> E[ApiClient]
  E -->|apiToken| F[R2Cloud API]
  G[R2UserManager] --> H[(Secure Storage)]
  G --> I[Local DB]
  J[GroupIntercomScreen] --> K[R2IntercomEngine]
  K --> L[Agora RTC]
  G --> M[Avatar Download]
  M --> N[Static Host https://rock.r2cycling.com]
```
