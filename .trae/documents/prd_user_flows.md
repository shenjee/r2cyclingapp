# Product Flows — Key User Journeys

## Registration & Login
- Register/login via verification code: request code, enter 6-digit code, obtain token; navigate to Home `lib/login/verification_screen.dart:65-91,129-175,317-323`
- Password login: enter phone and password, authenticate, fetch profile, go Home `lib/login/user_login_screen.dart:96-160,345-358`

## Group Intercom
- Enter Intercom: fetch current group; show members; press-and-hold to talk; leave group from app bar `lib/group/group_intercom_screen.dart:101-163,404-449`

## Settings & Profile
- Update nickname and avatar; avatar upload and sync flows with local cache `lib/usermanager/r2_user_manager.dart:237-250,342-391,492-522,524-556`

## Routing
- Primary routes configured in `lib/main.dart:141-153`

## Flowchart — Login and Intercom
```mermaid
flowchart TD
  A[Launch App] --> B{Logged In?}
  B -- No --> C[Go to Login]
  C --> D{Choose Method}
  D -- Password --> E[Enter Phone+Password]
  E --> F[Authenticate -> Token]
  D -- V-Code --> G[Request SMS Code]
  G --> H[Enter 6-digit Code]
  H --> F
  F --> I[Fetch Profile]
  I --> J[Home Screen]
  J --> K[Open Intercom]
  K --> L[Fetch My Group]
  L --> M[Show Members]
  M --> N{Press & Hold?}
  N -- Yes --> O[Unmute & Talk]
  N -- No --> P[Mute]
  K --> Q[Leave Group]
```
