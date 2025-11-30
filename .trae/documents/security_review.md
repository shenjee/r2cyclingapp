# Security Review — Findings and Recommendations

## Findings
- Plaintext logging of `phone+password` combined string in password login `lib/login/user_login_screen.dart:120-121`
- Hash value logging of SHA-512 digest `lib/login/user_login_screen.dart:122-123`
- Mixed storage: `sid` stored in `SharedPreferences` (non-secure) while token in secure storage; assess sensitivity `lib/login/verification_screen.dart:73-79`
- Error handling returns generic messages; no retry/backoff or typed errors `lib/connection/http/r2_http_request.dart:58-64,102-108,162-168`
- Hardcoded RTC constants placeholders (`swAppId`, `swToken`) exist; ensure they remain empty in production and credentials only come from API `lib/intercom/r2_intercom_engine.dart:23-26,107-115`

## Recommendations
- Remove sensitive debug prints; never log credentials or their hashes
- Consider storing `sid` in secure storage if used for server-side correlation
- Introduce structured error types and retry policy for transient failures
- Add token refresh/renewal handling (e.g., consume `newToken` from `appInit` `lib/main.dart:82-85`)
- Consider TLS certificate pinning and HTTP timeouts
- Centralize logging with redaction; ensure PII-safe analytics if added

