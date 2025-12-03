# R2 Cycling App Engineering Constitution

## Scope
This constitution defines project-wide principles for code quality, testing standards, user experience consistency, and performance requirements across Android and iOS.

## Code Quality
- Keep `flutter analyze` clean; `analysis_options.yaml` governs lints.
- Use null-safety everywhere; avoid `dynamic` in public APIs.
- Favor composition and single-responsibility widgets; move business logic into `lib/service`, `lib/usermanager`, or dedicated classes.
- Prefer `final` fields and `const` constructors; default to immutability.
- Consistent naming: `PascalCase` for widgets/classes, `lowerCamelCase` for methods/fields, `SCREAMING_SNAKE_CASE` for constants (see `lib/constants.dart`).
- Explicit types in public interfaces; avoid implicit `var` for clarity.
- Centralize side-effects (I/O, BLE, HTTP) behind services; keep UI reactive and declarative.
- Handle errors explicitly; no silent catches. Surface user-facing errors via standard components (e.g., flash messages) and log technical details.
- Avoid `print`; use a lightweight logger or `dart:developer` with PII redaction. Never log secrets or tokens.
- Enforce code review on all changes; small PRs with clear descriptions.

## Testing Standards
- Unit tests for core logic (e.g., `lib/usermanager`, `lib/openapi`, `lib/service`). Target ≥80% coverage for critical modules.
- Widget tests for UI components and screens: layout, interactions, and state transitions.
- Integration tests for key flows (login, group intercom create/join, SOS). Use `integration_test` package and run on device/emulator.
- Golden tests for stable visual components to catch regressions.
- Test structure mirrors `lib/` packages under `test/` with descriptive names.
- Mock external dependencies (BLE, network, storage) in tests; deterministic seeds and time control.
- CI gates: run `flutter analyze` and `flutter test` on every PR; block merges on failures.

## User Experience Consistency
- Design tokens for spacing, typography, colors live in a central theme/constants; reuse across widgets.
- No hardcoded strings in UI; route all user-facing text through localization (`AppLocalizations`).
- Accessibility: minimum tap target 44dp, semantic labels for icons/controls, support dynamic text scaling, maintain contrast ≥4.5:1.
- Navigation behavior is consistent across platforms; honor back gestures/buttons and safe areas.
- Standard states: loading (`r2_loading_indicator`), error (flash/toast or inline), empty state patterns documented and reused.
- Forms use shared inputs (`r2_user_text_field`) with inline validation and helpful messages.
- Permission requests use a unified dialog flow (`lib/permission/permission_dialog.dart`) with clear rationale and recovery.

## Performance Requirements
- Smoothness: maintain 60fps; frame build time ≤16ms p95 on interactive screens.
- Startup: cold start ≤2.5s on mid-tier Android; first meaningful paint ≤1.5s.
- Memory: typical usage ≤256MB; dispose controllers/streams; avoid retained references.
- Rendering: minimize rebuilds; use `const` widgets, keys appropriately, and `ListView.builder`/`GridView.builder` for long lists.
- Networking: set reasonable timeouts and retry with backoff; avoid blocking the UI thread; cache where appropriate.
- BLE/Geolocation: throttle scanning/updates; choose appropriate accuracy levels to balance battery and precision.
- Media/RTC: optimize Agora profiles for voice; reduce CPU in background; handle audio focus correctly.
- Images/assets: prefer resolution-aware assets; `precacheImage` for critical visuals; avoid oversized bitmaps.

## Process & Governance
- Branching: feature branches with focused scope; merge via PR after review.
- Versioning: semantic versioning; update `pubspec.yaml` and changelog (`CHANGLOG.md`).
- Security: store secrets in secure storage; never commit sensitive data; validate inputs and sanitize outputs.
- Documentation: update `.trae/documents` when adding features or flows; keep architecture docs current.
- Release: smoke tests on physical Android and iOS devices; verify critical flows and permissions.

## Enforcement
- All PRs must pass analysis and tests and adhere to this constitution. Exceptions require explicit rationale and follow-up tasks.
