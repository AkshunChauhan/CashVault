# CashVault

A private, offline-first cash tracking app built with Flutter. Designed for users who handle physical cash and want a fast, minimal, and secure way to track physical bills, income, debts, and expenses — without relying on the cloud.

**No account required. No internet needed. Your data stays on your device.**

---

## 🔥 How to Enable Firebase (Auth, Issue Reporting & Sync)

CashVault is written to be 100% offline-first. However, **the codebase comes pre-configured with Google Sign-In, Firebase Firestore, and Auth code.** It is simply commented out so the app can build offline out-of-the-box.

When you are ready to enable cloud backups, issue reporting, or authentication, follow these 6 exact steps:

### Step 1: Create the Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/) and click **Add project** -> Name it `CashVault`.
2. Click **Add app** -> Select **Android**.
3. Package name: `com.cashvault.cash_vault`
4. App nickname: `CashVault`
5. Get your SHA-1 fingerprint by running this in your terminal:
   ```bash
   cd android && ./gradlew signingReport
   ```
6. Click **Register app** and download the `google-services.json` file.
7. Place that file exactly here in your project:
   `android/app/google-services.json`

### Step 2: Enable Google Sign-In & Firestore in Console
1. In Firebase Console → **Authentication** → **Sign-in method** → Enable **Google**.
2. In Firebase Console → **Firestore Database** → **Create Database** (Start in Test Mode initially).

### Step 3: Uncomment Gradle Files
1. Open `android/settings.gradle.kts` and uncomment line 25:
   ```kotlin
   id("com.google.gms.google-services") version "4.4.2" apply false
   ```
2. Open `android/app/build.gradle.kts` and uncomment line 7:
   ```kotlin
   id("com.google.gms.google-services")
   ```

### Step 4: Uncomment Dependencies
Open `pubspec.yaml` and uncomment lines 23-28 in the dependencies:
```yaml
  firebase_core: ^3.8.1
  firebase_auth: ^5.4.1
  google_sign_in: ^6.2.2
  cloud_firestore: ^5.5.1
```
Then run: `flutter pub get`

### Step 5: Uncomment Application Code
1. **`lib/main.dart`**: Add this right below `WidgetsFlutterBinding.ensureInitialized();`
   ```dart
   await Firebase.initializeApp();
   ```
2. **`lib/services/auth_service.dart`**: Uncomment the import statements and the active `FirebaseAuth` / `GoogleSignIn` logic inside `signInWithGoogle()` and `signOut()`.
3. **`lib/services/report_issue_service.dart`**: Uncomment the `FIREBASE FIRESTORE IMPLEMENTATION` block to replace the local mock with actual cloud transmissions.

### Step 6: Implementing "Cloud Sync"
Once Auth is working, you can sync the data to Firestore. The `TransactionModel` already has a `toMap()` method built precisely for this! 
You just need to add a function in `TransactionService` that iterates over the Hive box and pushes `transaction.toMap()` to `FirebaseFirestore.instance.collection('users').doc(user.uid).collection('transactions')`.

---

## Features

- **Safe Inventory Tracker** — Dynamically tracks how many physical $100, $50, $20 bills you currently possess.
- **IOU Ledger & Reminders** — Track who you owe, and who owes you. Sets automated Push Notifications on the exact due dates.
- **Biometric App Lock** — Secures the app with FaceID / TouchID / Android PIN Native Lock screens upon open.
- **Offline-first Encrypted Database** — AES-256 Android Keystore protection. Data cannot be extracted.
- **Instant CSV Export** — One tap to export all transactions (including bill summaries) into a rich spreadsheet.
- **Report an Issue** — Ready-to-go feedback pipeline direct to developer.

---

## Project Structure

```
lib/
├── main.dart                        # Core bootstrap
├── app.dart                         # Layout scaffolding (Safe Tab vs Ledger Tab)
├── models/
│   ├── transaction_model.dart       # Hive definition for tracking Cash and Denominations
│   └── debt_model.dart              # Hive definition for IOU Loans
├── services/
│   ├── storage_service.dart         # Keystore Encrypted Keys
│   ├── transaction_service.dart     # Physical bills computing / CRUD
│   ├── debt_service.dart            # Loan tracker logic
│   ├── notification_service.dart    # Android/iOS Local Notification Alarm Scheduling
│   └── report_issue_service.dart    # User feedback system (Firestore ready)
├── screens/
│   ├── home_screen.dart             # Central Balance and Inventory UI
│   ├── add_transaction_screen.dart  # Ultra-fast cash denomination input grid
│   └── debts_screen.dart            # Pending IOUs + resolution list
└── theme/
    └── app_theme.dart               # Complete dark/light mode scaling aesthetic
```

---

## Build Automation

Generate the Play Store Production Release at any time:
```bash
flutter build apk --release
```
*(Signs using the `upload-keystore.jks` and `key.properties` auto-configured inside the `android/` directory).*

---

## Acknowledgments

- Built by **Akshun Chauhan**
- Designed for uncompromised privacy and blazing-fast entry.
