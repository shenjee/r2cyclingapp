# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/).

---

## [Unreleased]
### Fixed
- [ ] Display member status during voice intercom, avatar and speaking indicator

---

## [1.2.0] - 2025-12-12
### Changed
- Refactor OpenAPI: unified `ApiClient`/`CommonApi`, typed responses and retry
- Refactor auth module: centralized into `AuthService` with token handling

### Added
- Spec-driven workflow assets: templates and scripts to standardize delivery
- Avatar upload: Synchronization of avatar between mobile app and helmet

---

## [1.1.0] - 2025-09-20
### Added
- JSON-based Bluetooth device configuration system
- Support for multiple device manufacturers
- Content of Privacy Policy and Terms of Service

### Changed
- Refactored Bluetooth connection handling for better maintainability
- Improved device scanning to support multiple device types

### Fixed
- Registration and login are not allowed until privacy policy and terms of service are agreed to

---

## [1.0.0] - 2025-08-27
### Added
- Account registration and login
- Multi-user voice intercom over the network
- SOS emergency contact notification (with location sharing)
- Bluetooth pairing with smart helmets
- Basic documentation: README, LICENSE
- Internationalization (English and Chinese)

### Changed
- Initial version of GitHub repository

### Fixed
- Workable on Android and iOS
