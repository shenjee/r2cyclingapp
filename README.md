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
	•	Use the App source code in personal or commercial products;
	•	Modify, distribute, and redistribute the code;
	•	Integrate with the R2Cycling API (following the published documentation).

⚠️ You must:
	•	Retain the original copyright and license notice in redistributions;
	•	Record any code modifications in the NOTICE file;
	•	Not use the “R2Cycling” name or logo as trademarks without explicit permission;
	•	By contributing to this project, you grant the necessary patent rights as described in Apache-2.0.

❌ Not included:
	•	The server-side implementation is not part of this repository;
	•	This license does not grant any trademark rights;
	•	Production backend services must be self-hosted or use official offerings.

See LICENSE file for details.

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
