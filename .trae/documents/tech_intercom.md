# Intercom — Architecture and Flow

## Group Intercom UI

* Fetch current group and members `GET cyclingGroup/getMyGroup` `lib/group/group_intercom_screen.dart:101-116`

* Save group locally and display member list `lib/group/group_intercom_screen.dart:145-163`

* Press-and-hold button: down unmutes, up mutes, cancel stops engine `lib/group/group_intercom_screen.dart:247-277`

* Leave group `POST cyclingGroup/leaveGroup` and clean local cache `lib/group/group_intercom_screen.dart:176-216`

## Intercom Engine (Agora)

* Obtain RTC credentials `POST groupRoom/getVoiceToken` `lib/intercom/r2_intercom_engine.dart:79-97`

* Initialize engine and join channel `lib/intercom/r2_intercom_engine.dart:118-167,151-160`

* Event handlers for member lifecycle and active speaker `lib/intercom/r2_intercom_engine.dart:126-147`

* Mic permissions via `permission_handler` `lib/intercom/r2_intercom_engine.dart:103-105`

## Data & Identity

* Channel ID equals `cyclingGroupId`; `userAccount` equals local user ID `lib/intercom/r2_intercom_engine.dart:151-160`

## Sequence — Intercom Session

```mermaid
sequenceDiagram
  participant UI as GroupIntercomScreen
  participant M as R2UserManager
  participant HTTP as R2HttpRequest
  participant S as R2Cloud API
  participant E as R2IntercomEngine
  participant A as Agora RTC
  UI->>M: localAccount()
  UI->>HTTP: GET cyclingGroup/getMyGroup (apiToken)
  HTTP->>S: apiToken header
  S-->>HTTP: {group, memberList}
  UI->>E: getInstance(groupID,userID)
  E->>HTTP: POST groupRoom/getVoiceToken (apiToken)
  HTTP->>S: apiToken header
  S-->>HTTP: {appId, token}
  E->>A: initialize & join(channel=groupID, userAccount=userID)
  UI->>E: press & hold → mute=false
  UI->>E: release → mute=true
```

## Components
```mermaid
flowchart TD
  UI[GroupIntercomScreen] --> E[R2IntercomEngine]
  E --> HTTP[R2HttpRequest]
  HTTP --> S[R2Cloud Voice API]
  E --> A[Agora RTC]
  UI --> M[R2UserManager]
  M --> Storage[(Secure Storage)]
```

* <br />
