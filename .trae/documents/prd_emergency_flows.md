# Emergency Contacts — Product Flows

## Enable SOS Emergency

* User toggles `SOS Emergency` switch on the emergency screen (`lib/emergency/emergency_contact_screen.dart:83-112`)

* If enabled and no contacts exist, app prompts to add a contact (`lib/emergency/emergency_contact_screen.dart:62-64`)

* Server-side enablement synced (`member/switchContactEnabled`)

## Manage Contacts

* Add Contact: opens dialog to enter name and phone, saves remotely and locally; list supports up to 3 contacts (`lib/emergency/emergency_contact_screen.dart:229-258`)

* Edit Contact: open existing contact, change values, save remotely and locally

* Delete Contact: remove contact remotely and locally; if none remain, switch toggles off automatically (`lib/emergency/emergency_contact_screen.dart:73-81,175-182`)

## SOS Message Delivery

* When SOS is triggered, app reads current GPS location, requests a short link from server, composes a message, and sends SMS to all contacts (`lib/emergency/r2_sos_sender.dart:52-79`)

* SMS sending uses platform channel `r2_sms_channel` on Android; messages are standard text SMS

## User Flowchart

```mermaid
flowchart TD
  A[Open Emergency Screen] --> B{SOS Enabled?}
  B -- No --> C[Read description]
  C --> D[Toggle On]
  B -- Yes --> E[View Contacts]
  D --> F{Has Contacts?}
  F -- No --> G[Prompt Add Contact]
  F -- Yes --> E
  E --> H[Tap Contact to Edit/Delete]
  E --> I[Add New Contact (if u 3)]
  I --> E
  H --> E
  E --> J[SOS Trigger]
  J --> K[Get GPS]
  K --> L[Request Short Link]
  L --> M[Send SMS to Contacts]
```

## Screens & States

* Emergency screen: switch, description (when off), contact list (when on)

* Contact dialog: add/edit/delete actions, validation is minimal; relies on server and local DB feedback

* Error states surfaced implicitly via operation failures; consider adding explicit toasts for HTTP errors

