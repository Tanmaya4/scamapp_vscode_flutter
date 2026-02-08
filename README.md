# scamapp_vscode_flutter

SafeCall Anti-Scam Application - Flutter Implementation

A complete Flutter/Dart conversion of the SafeCall Android app with Riverpod state management, GoRouter navigation, and native platform channels for Android integration.

## Features

- **Stranger Mode**: Activate protection mode with hold-to-confirm UI
- **Threat Detection**: 3-tier keyword analysis + 14 regex scam patterns
- **OTP Protection**: Monitor incoming messages for OTP and phishing attempts
- **Call Monitoring**: Real-time call state tracking with audio analysis
- **Biometric Exit**: LocalAuthentication integration for secure exit
- **Incident Reporting**: Direct integration with cybercrime.gov.in and Helpline 1930
- **Multi-language**: English and Hindi support
- **Material 3 UI**: Modern responsive design with dark mode

## Project Structure

```
lib/
├── core/              # Core constants, theme, models, widgets
├── data/              # Database and repositories
├── services/          # Business logic (threat detection, native bridge)
├── providers/         # Riverpod state management
├── navigation/        # GoRouter configuration
└── features/          # Feature screens (onboarding, home, settings, etc.)
```

## Tech Stack

- **Flutter 3.5+** / **Dart 3.5+**
- **Riverpod 2.5+** - State management
- **GoRouter 14.2+** - Navigation
- **sqflite 2.3+** - Local database
- **SharedPreferences 2.2+** - Settings storage
- **permission_handler 11.3+** - Permission management
- **local_auth 2.2+** - Biometric authentication

## Getting Started

1. Install Flutter: https://flutter.dev/docs/get-started/install
2. Clone repository and navigate to project:
   ```bash
   cd SafeCall_Flutter
   ```
3. Get dependencies:
   ```bash
   flutter pub get
   ```
4. Run on Android device/emulator:
   ```bash
   flutter run
   ```

## Android Requirements

- Minimum SDK: API 21 (Android 5.0)
- Target SDK: API 35 (Android 15)
- Permissions: READ_PHONE_STATE, RECORD_AUDIO, ANSWER_PHONE_CALLS, POST_NOTIFICATIONS, etc.

## Key Components

### Services
- **ThreatDetectionService**: Analyzes text for scam keywords and patterns
- **NativeBridgeService**: Platform channel communication with Android native APIs
- **StrangerModeService**: Orchestrates protection mode lifecycle

### Repositories
- **UserPreferencesRepository**: Settings and user preferences
- **ThreatEventRepository**: Store and retrieve threat events
- **SessionRepository**: Manage Stranger Mode sessions

### Models
- `ThreatEvent` - Detected scam threat with metadata
- `StrangerModeSession` - Active protection session
- `UserSettings` - User configuration
- `ScamKeywords` - 3-tier threat keywords (tier 1/2/3)

## Contributing

Created as part of the SafeCall Anti-Scam project initiative.

## License

See LICENSE file for details.
