[English](README.md) | [中文](README-zh.md)

# R2 Cycling App

R2 Cycling App is an open-source comprehensive Flutter-based mobile application designed for cycling enthusiasts, providing smart helmet integration and safety features for both Android and iOS platforms.

## Core Features:
🚴‍♂️ Smart Helmet Integration
- Bluetooth pairing with smart helmets (EH201 series)
- Device management and control (volume, lighting)
- Bluetooth telephone and music

📞 Group Communication
- Create and join cycling groups with 4-digit codes
- Real-time group intercom with voice using Agora RTC technology

🆘 Emergency Safety System
- SOS emergency contact management
- Automatic fall detection and location sharing
- SMS alerts to emergency contacts with location

👤 User Management
- User registration and authentication system

🌐 Multilingual Support
- Full internationalization (English and Chinese)
- Localized user interface and content

## Open Source Notice

This project R2 Cycling App is released under the Apache License 2.0.
The server-side implementation is not open-sourced; only the API specifications are published for developers and manufacturers to integrate.

✅ You are allowed to:
- Use the App source code in personal or commercial products;
- Modify, distribute, and redistribute the code;
- Integrate with the R2Cycling API (following the published documentation).

⚠️ You must:
- Retain the original copyright and license notice in redistributions;
- Record any code modifications in the NOTICE file;
- Not use the “R2Cycling” name or logo as trademarks without explicit permission;
- By contributing to this project, you grant the necessary patent rights as described in Apache-2.0.

❌ Not included:
- The server-side implementation is not part of this repository;
- This license does not grant any trademark rights;
- Production backend services must be self-hosted or use official offerings.

See [LICENSE](LICENSE) file for details.

## Quick Start Guide

### Prerequisites

Before you begin, ensure you have the following installed:
- **Flutter SDK** : [Install Flutter](https://docs.flutter.dev/get-started/install)
- **Dart SDK** (included with Flutter)
- **Android Studio** or **Xcode** (for iOS development)
- **Git** for version control

### 1. Download the Source Code

```bash
# Clone the repository
git clone https://github.com/shenjee/r2cyclingapp.git
cd r2cyclingapp
```

### 2. Set Up Development Environment

#### For Android Development:
- Install [Android Studio](https://developer.android.com/studio)
- Install Android SDK (API level 21 or higher)
- Set up an Android device or emulator

#### For iOS Development (macOS only):
- Install [Xcode](https://developer.apple.com/xcode/) from the App Store
- Install Xcode Command Line Tools: `xcode-select --install`
- Set up an iOS device or simulator

### 3. Install Required Packages

```bash
# Get Flutter dependencies
flutter pub get

# Verify Flutter installation
flutter doctor
```

### 4. Pre-compilation Setup

#### Configure Permissions (Important!):
This app requires several permissions for full functionality:

**Android**: Permissions are automatically handled via `android/app/src/main/AndroidManifest.xml`

**iOS**: Update `ios/Runner/Info.plist` with required permissions:
- Bluetooth usage
- Location access
- Microphone access
- SMS sending

#### API Configuration:
Update the API endpoints in `lib/constants.dart` to point to your backend services.

### 5. Build and Compile

#### For Android:
```bash
# Debug build
flutter run

# Release APK
flutter build apk --release

# Release App Bundle (recommended for Play Store)
flutter build appbundle --release
```

#### For iOS:
```bash
# Debug build
flutter run

# Release build
flutter build ios --release
```

### 6. Deploy to Device

#### Android Device:
1. Enable Developer Options and USB Debugging on your Android device
2. Connect via USB
3. Run: `flutter run` or install the APK from `build/app/outputs/flutter-apk/`

#### iPhone:
1. Connect your iPhone via USB
2. Trust the computer on your device
3. Open `ios/Runner.xcworkspace` in Xcode
4. Select your device and click "Run"
5. You may need to configure code signing in Xcode

### 7. Troubleshooting

**Common Issues:**
- **Flutter Doctor Issues**: Run `flutter doctor` and follow the suggestions
- **Dependency Conflicts**: Try `flutter clean && flutter pub get`
- **iOS Code Signing**: Ensure you have a valid Apple Developer account
- **Android Build Issues**: Check Android SDK and build tools versions

**Key Dependencies:**
- Agora RTC Engine (for voice communication)
- Flutter Reactive BLE (for Bluetooth connectivity)
- Geolocator (for location services)
- Permission Handler (for runtime permissions)

### 8. Development Tips

- Use `flutter run --hot-reload` for faster development
- Check `flutter logs` for debugging
- Test on both Android and iOS devices for best compatibility
- Ensure all required permissions are granted for full functionality

For more Flutter development resources, visit the [official documentation](https://docs.flutter.dev/).

# Tech Notes
## Repository directory tree

```
r2cyclingapp/                    # Project root
├── android/                     # Android platform configuration
│   ├── app/                     # Android app module
│   │   ├── build.gradle         # Android app build configuration
│   │   └── src/                 # Android source code
│   ├── build.gradle             # Android project build configuration
│   ├── gradle/                  # Gradle wrapper
│   ├── gradle.properties        # Gradle properties
│   └── settings.gradle          # Gradle settings
├── ios/                         # iOS platform configuration
│   ├── Flutter/                 # Flutter iOS configuration
│   ├── Runner/                  # iOS app target
│   │   ├── AppDelegate.swift    # iOS app delegate
│   │   ├── Assets.xcassets/     # iOS app assets
│   │   ├── Base.lproj/          # iOS localization
│   │   └── Info.plist           # iOS app info
│   ├── Runner.xcodeproj/        # Xcode project
│   └── RunnerTests/             # iOS unit tests
├── lib/                         # Flutter Dart source code
│   ├── connection/              # Network and Bluetooth connection
│   │   ├── bt/                  # Bluetooth connection modules
│   │   └── http/                # HTTP API connection modules
│   ├── database/                # Local database management
│   │   ├── r2_db_helper.dart    # SQLite database helper
│   │   └── r2_storage.dart      # Local storage utilities
│   ├── devicemanager/           # Smart helmet device management
│   │   ├── r2_device.dart       # Device model
│   │   └── r2_device_manager.dart # Device connection manager
│   ├── emergency/               # Emergency and SOS features
│   │   ├── contact_widget.dart  # Emergency contact UI
│   │   ├── emergency_contact_screen.dart # Emergency contacts screen
│   │   ├── r2_sms.dart          # SMS sending functionality
│   │   ├── r2_sos_sender.dart   # SOS message sender
│   │   └── sos_widget.dart      # SOS button UI
│   ├── group/                   # Group communication features
│   │   ├── create_group_screen.dart # Group creation screen
│   │   ├── group_intercom_screen.dart # Group intercom screen
│   │   ├── group_list_screen.dart # Group list screen
│   │   └── join_group_screen.dart # Group joining screen
│   ├── intercom/                # Real-time voice communication
│   │   └── r2_intercom_engine.dart # Agora RTC engine wrapper
│   ├── l10n/                    # Internationalization
│   │   └── app_localizations.dart # App localization strings
│   ├── login/                   # User authentication
│   │   ├── login_base_screen.dart # Base login screen
│   │   ├── password_recover_screen.dart # Password recovery
│   │   ├── password_setting_screen.dart # Password setting
│   │   ├── user_login_screen.dart # User login screen
│   │   ├── user_register_screen.dart # User registration screen
│   │   └── verification_screen.dart # Verification code screen
│   ├── permission/              # App permissions management
│   │   ├── permission_dialog.dart # Permission request dialogs
│   │   ├── r2_permission_manager.dart # Permission manager
│   │   └── r2_permission_model.dart # Permission models
│   ├── r2controls/              # Custom UI components
│   │   ├── r2_flash.dart        # Flash message component
│   │   ├── r2_flat_button.dart  # Custom button component
│   │   ├── r2_loading_indicator.dart # Loading indicator
│   │   └── r2_user_text_field.dart # Custom text field
│   ├── screens/                 # Main app screens
│   │   ├── device_pairing_screen.dart # Device pairing screen
│   │   ├── helmet_screen.dart   # Helmet management screen
│   │   ├── home_screen.dart     # Main home screen
│   │   └── splash_screen.dart   # App splash screen
│   ├── service/                 # Background services
│   │   └── r2_background_service.dart # Background task service
│   ├── settings/                # App settings and user profile
│   │   ├── image_cut_screen.dart # Image cropping screen
│   │   ├── settings_screen.dart # App settings screen
│   │   └── user_profile_screen.dart # User profile screen
│   ├── usermanager/             # User management
│   │   ├── r2_account.dart      # User account model
│   │   ├── r2_group.dart        # Group model
│   │   ├── r2_user_manager.dart # User management service
│   │   └── r2_user_profile.dart # User profile model
│   ├── constants.dart           # App constants
│   └── main.dart                # App entry point
├── assets/                      # Static assets
│   ├── icons/                   # App icons
│   └── images/                  # App images
├── test/                        # Unit tests
│   └── widget_test.dart         # Widget tests
├── .gitignore                   # Git ignore rules
├── .metadata                    # Flutter metadata
├── analysis_options.yaml        # Dart analysis options
├── pubspec.yaml                 # Flutter dependencies
├── pubspec.lock                 # Dependency lock file
├── LICENSE                      # Apache License 2.0
├── README.md                    # English documentation
└── README-zh.md                 # Chinese documentation
```

## How does the Bluetooth pairing workflow work in the R2 Cycling App?
The Bluetooth pairing follows a two-stage process: BLE discovery first, then Classic Bluetooth pairing for audio profiles.

### 1. Files for Bluetooth Pairing

**Core Implementation Files:**
- `lib/connection/bt/r2_bluetooth_model.dart` - Main Bluetooth model handling both BLE and Classic BT
- `lib/devicemanager/r2_device_manager.dart` - Device management and pairing orchestration
- `lib/screens/device_pairing_screen.dart` - UI for device scanning and selection
- `android/app/src/main/kotlin/com/rockroad/r2cyclingapp/MainActivity.kt` - Android native Bluetooth profiles
- `lib/permission/r2_permission_manager.dart` - Bluetooth permissions handling

### 2. Libraries and Documentation

**Primary Bluetooth Libraries:**
- **flutter_reactive_ble**: For BLE operations (scanning, connecting, data transfer)
  - Documentation: https://pub.dev/packages/flutter_reactive_ble
- **flutter_blue_classic**: For Classic Bluetooth operations (pairing, audio profiles)
  - Documentation: https://pub.dev/packages/flutter_blue_classic
- **permission_handler**: For runtime Bluetooth permissions
  - Documentation: https://pub.dev/packages/permission_handler

### 3. Pairing Workflow

**Step 1: BLE Discovery**
```
1. Request Bluetooth permissions
2. Start BLE scanning for devices with brand filter (e.g., 'EH201')
3. User selects discovered BLE device
4. Stop BLE scanning
```

**Step 2: Classic Bluetooth Pairing**
```
1. Extract device identifier from BLE name (last 6 characters)
2. Start Classic Bluetooth scanning
3. Look for device with name pattern 'Helmet-{identifier}'
4. Bond with Classic Bluetooth device
5. Enable A2DP and Headset audio profiles
6. Save device information to local database
```

### 4. Code Sample: Changing Product Model

**To change the product model from 'EH201' to another model:**

In `lib/screens/device_pairing_screen.dart`, line 89:
```dart
// Current code:
_scannedDevices = _btManager.scanDevices(brand: 'EH201');

// Change to new model (e.g., 'EH202'):
_scannedDevices = _btManager.scanDevices(brand: 'EH202');
```

In `lib/connection/bt/r2_bluetooth_model.dart`, line 169 (Classic BT pairing logic):
```dart
// Current code looks for:
if (device.name!.startsWith('Helmet-$lastPart')) {

// If helmet naming convention changes, modify the pattern:
if (device.name!.startsWith('NewHelmet-$lastPart')) {
```

**Key Points:**
- EH201 is the development board model for smart helmet
- Device names can be customized by customers (no strict format requirement)

## How does the realtime voice intercom technology work in the R2 Cycling App?

### 1. Files and Modules for Voice Intercom

The voice intercom functionality is primarily handled by these core files:
- <mcfile name="r2_intercom_engine.dart" path="/Users/jishen/development/r2cyclingapp/lib/intercom/r2_intercom_engine.dart"></mcfile> - Main Agora RTC engine wrapper and voice communication logic
- <mcfile name="group_intercom_screen.dart" path="/Users/jishen/development/r2cyclingapp/lib/group/group_intercom_screen.dart"></mcfile> - UI screen for group voice intercom with push-to-talk functionality
- <mcfile name="r2_http_request.dart" path="/Users/jishen/development/r2cyclingapp/lib/connection/http/r2_http_request.dart"></mcfile> - HTTP requests for obtaining RTC tokens from server

### 2. Agora RTC Engine

**Agora RTC Engine** is a real-time communication platform that provides voice and video calling capabilities. It's developed by Agora (声网) and offers:
- Ultra-low latency voice communication
- High-quality audio transmission
- Multi-platform support (iOS, Android, Web, etc.)
- Scalable group voice chat (up to thousands of participants)

**Developer Resources:**
- Official Website: [https://www.agora.io](https://www.agora.io)
- Documentation: [https://docs.agora.io](https://docs.agora.io)
- Flutter SDK Guide: [https://docs.agora.io/en/voice-calling/get-started/get-started-sdk?platform=flutter](https://docs.agora.io/en/voice-calling/get-started/get-started-sdk?platform=flutter)

### 3. Agora Configuration

**Current Version:** `agora_rtc_engine: ^6.3.2` (as specified in pubspec.yaml)

**App Key and Token Configuration:**
- **Hardcoded Configuration (Recommended):** Set `swAppId` and `swToken` constants in <mcfile name="r2_intercom_engine.dart" path="/Users/jishen/development/r2cyclingapp/lib/intercom/r2_intercom_engine.dart"></mcfile> (lines 10-11)
  ```dart
  const String swAppId = "your_agora_app_id_here";
  const String swToken = "your_agora_token_here";
  ```
- **Dynamic Configuration:** App automatically requests tokens from server through the `_requestRTCToken()` method which calls the backend API

**Important Note:** Developers and manufacturers are highly recommended to apply for their own Agora app key/token and test with hardcoded configuration. The server-based token requests are only for testing purposes and have very limited time availability for intercom functionality.

**Where to obtain Agora credentials:**
1. Register at [Agora Console](https://console.agora.io)
2. Create a new project to get your App ID
3. Generate temporary tokens for testing or implement token server for production
4. Configure the credentials in the constants at the top of `r2_intercom_engine.dart`

**Key Features:**
- Push-to-talk functionality (hold button to speak)
- Automatic microphone muting when not speaking
- Support for up to 8 members per group

## What are the current compilation configurations for Android and iOS?

With this configuration, the source code is successfully compiled and deployed on Android phones and iPhones.

### Android Configuration
The Android build configuration is defined in `android/app/build.gradle`:

- **Compile SDK**: 34
- **Minimum SDK**: 21 (Android 5.0 Lollipop)
- **Target SDK**: 34 (Android 14)
- **Namespace**: `com.rockroad.r2cycling`
- **Kotlin Version**: 1.7.10
- **Gradle Version**: 7.5
- **Android Gradle Plugin**: 7.3.0

### iOS Configuration
The iOS build configuration is defined in `ios/Runner.xcodeproj/project.pbxproj`:

- **Deployment Target**: ≥ iOS 12.0
- **Swift Version**: 5.0
- **Bundle Identifier**: `com.rockroad.r2cycling`
- **Supported Platforms**: iPhone and iPad (iphoneos, iphonesimulator)
- **Device Family**: Universal (iPhone and iPad)
- **Bitcode**: Disabled

### Flutter Configuration
The Flutter project configuration in `pubspec.yaml`:

- **Flutter SDK**: Latest stable version
- **Dart SDK**: '>=3.1.0 <4.0.0'
- **Key Dependencies**:
  - `agora_rtc_engine: ^6.3.2`
  - `flutter_reactive_ble: ^5.3.1`
  - `geolocator: ^10.1.0`
  - `permission_handler: ^11.3.1`

# Citation
If you use R2 Cycling App in your research or project, please cite:

```bibtex
@software{R2Cycling,
  author       = {Shen Ji and R2Cycling Contributors},
  title        = {R2Cycling: An Open Source Cycling App and Cloud API for Smart Helmets},
  year         = {2025},
  publisher    = {GitHub},
  url          = {https://github.com/shenjee/r2cyclingapp}
}
```