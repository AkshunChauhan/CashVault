# CashVault

A private, offline-first cash tracking app built with Flutter. Designed for users who handle physical cash and want a fast, minimal, and secure way to track income and expenses — without relying on the cloud.

**No account required. No internet needed. Your data stays on your device.**

---

## Features

- **Offline-first** — All data stored locally in an encrypted database
- **Fast entry** — Add a transaction in ≤ 2 taps
- **Balance at a glance** — Total balance, income, and expenses on the home screen
- **Category tagging** — Predefined categories for quick classification
- **Swipe to delete** — Remove transactions with a simple gesture
- **Dark mode** — Follows system theme automatically
- **Optional Google Sign-In** — Login only if you want cloud backup (future)
- **Encrypted storage** — AES-256 encryption with Android Keystore-backed keys

---

## Screenshots

> *Coming soon — run the app to see the UI.*

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Flutter 3.41+ / Dart 3.11+ |
| Local Database | Hive (encrypted) |
| State Management | Provider |
| Key Storage | flutter_secure_storage (Android Keystore) |
| Auth (optional) | Firebase Authentication (Google Sign-In) |
| Architecture | Clean separation — UI / Services / Models |

---

## Project Structure

```
lib/
├── main.dart                        # Entry point — Hive init, encryption, providers
├── app.dart                         # MaterialApp root with theme config
├── models/
│   ├── transaction_model.dart       # Hive data model with Firestore-ready serialization
│   ├── transaction_model.g.dart     # Generated Hive TypeAdapter
│   └── categories.dart              # Predefined income/expense categories
├── services/
│   ├── storage_service.dart         # Encryption key management via Keystore
│   ├── transaction_service.dart     # CRUD operations + balance computation
│   └── auth_service.dart            # Optional Google Sign-In (Firebase)
├── screens/
│   ├── home_screen.dart             # Balance card + transaction history
│   ├── add_transaction_screen.dart  # Fast transaction input form
│   └── settings_screen.dart         # Auth, sync, and security settings
├── widgets/
│   ├── balance_card.dart            # Total balance display widget
│   ├── transaction_tile.dart        # Single transaction list item
│   └── empty_state.dart             # Empty list placeholder
└── theme/
    └── app_theme.dart               # Light/dark theme system (neutral palette)
```

---

## Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) 3.2 or higher
- [Android Studio](https://developer.android.com/studio) with Android SDK 34+
- An Android device or emulator

### Run the App

```bash
# Clone the repo
git clone https://github.com/YOUR_USERNAME/cash-vault.git
cd cash-vault

# Install dependencies
flutter pub get

# Run on connected device or emulator
flutter run
```

### Build APK

```bash
# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release

# Split by architecture (smaller size)
flutter build apk --split-per-abi --release

# App Bundle (for Google Play Store)
flutter build appbundle --release
```

Output location:
- APK → `build/app/outputs/flutter-apk/`
- AAB → `build/app/outputs/bundle/release/`

---

## Firebase Setup (Optional)

> Firebase is **not required** to use the app. All core features work fully offline. Only set up Firebase if you want Google Sign-In and future cloud sync.

### Step 1 — Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click **Add project** → Name it `CashVault`
3. Disable Google Analytics (or enable if you want it)
4. Click **Create project**

### Step 2 — Register Android App

1. In your Firebase project, click **Add app** → select **Android**
2. Enter package name: `com.cashvault.cash_vault`
3. Enter app nickname: `CashVault`
4. Get your SHA-1 fingerprint:
   ```bash
   cd android && ./gradlew signingReport
   ```
   Copy the `SHA1` value from the `debug` variant.
5. Click **Register app**

### Step 3 — Download Config File

1. Download `google-services.json`
2. Place it in:
   ```
   android/app/google-services.json
   ```

### Step 4 — Enable Google Sign-In

1. In Firebase Console → **Authentication** → **Sign-in method**
2. Click **Google** → Enable it
3. Set your support email → **Save**

### Step 5 — Uncomment Firebase Code

Make these changes in 3 files:

**1. `android/settings.gradle.kts`** — Uncomment line 25:
```kotlin
id("com.google.gms.google-services") version "4.4.2" apply false
```

**2. `android/app/build.gradle.kts`** — Uncomment line 7:
```kotlin
id("com.google.gms.google-services")
```

**3. `pubspec.yaml`** — Uncomment the Firebase dependencies:
```yaml
firebase_core: ^3.8.1
firebase_auth: ^5.4.1
google_sign_in: ^6.2.2
```

**4. `lib/main.dart`** — Add Firebase initialization:
```dart
import 'package:firebase_core/firebase_core.dart';

// Add this line before runApp() in main():
await Firebase.initializeApp();
```

**5. `lib/services/auth_service.dart`** — Uncomment the Google Sign-In code blocks and add:
```dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
```

Then run:
```bash
flutter pub get
flutter run
```

---

## Security

| Feature | Implementation |
|---------|---------------|
| Database encryption | AES-256 via `HiveAesCipher` |
| Key storage | Android Keystore via `flutter_secure_storage` |
| Cloud backups | Disabled (`android:allowBackup="false"`) |
| Permissions | Only `INTERNET` (for optional auth) |
| App lock | Placeholder ready (PIN/biometric — coming soon) |

---

## Data Model

```
Transaction
├── id          (String)    — UUID v4
├── amount      (double)    — Always positive
├── type        (String)    — "add" or "expense"
├── category    (String)    — From predefined list
├── note        (String?)   — Optional description
└── createdAt   (DateTime)  — Auto-generated timestamp
```

---

## Roadmap

- [x] Core transaction tracking (add/expense)
- [x] Encrypted local storage
- [x] Balance + transaction history
- [x] Category tagging
- [x] Light/dark theme
- [x] Optional Google Sign-In structure
- [ ] Firebase cloud sync
- [ ] App lock (PIN / biometric)
- [ ] Export data (CSV)
- [ ] Monthly/weekly reports
- [ ] Custom categories
- [ ] Recurring transactions

---

## Contributing

1. Fork the repo
2. Create your branch (`git checkout -b feature/my-feature`)
3. Commit your changes (`git commit -m 'Add my feature'`)
4. Push to the branch (`git push origin feature/my-feature`)
5. Open a Pull Request

---

## License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.

---

## Acknowledgments

- [Hive](https://pub.dev/packages/hive) — Fast local database for Dart
- [Provider](https://pub.dev/packages/provider) — Simple state management
- [Flutter Secure Storage](https://pub.dev/packages/flutter_secure_storage) — Keystore integration
- [Firebase](https://firebase.google.com/) — Authentication platform

---

<p align="center">
  Built with privacy in mind. Your money, your data, your device.
</p>
