# AURA — Virtual Health Companion

> **F29SO Software Engineering · Heriot-Watt University · Group 3**

AURA is a comprehensive mobile health companion application built with Flutter and Firebase. It allows users to track their daily health metrics, log activities and meals, monitor vitals, manage goals, interact with an AI-powered health companion, and connect with healthcare providers — all in one place.

---

## Table of Contents

1. [Project Overview](#1-project-overview)
2. [Features](#2-features)
3. [Tech Stack](#3-tech-stack)
4. [Architecture](#4-architecture)
5. [Firestore Data Model](#5-firestore-data-model)
6. [Prerequisites](#6-prerequisites)
7. [Setup Guide (Step by Step)](#7-setup-guide-step-by-step)
8. [Secret Files (Not in Git)](#8-secret-files-not-in-git)
9. [Running the App](#9-running-the-app)
10. [Project Structure](#10-project-structure)
11. [Screens Reference](#11-screens-reference)
12. [User Roles](#12-user-roles)
13. [Key Packages](#13-key-packages)
14. [Known Limitations](#14-known-limitations)
15. [Contributing](#15-contributing)

---

## 1. Project Overview

AURA stands for **Adaptive User-centred Record-based Assistant**. It is designed for everyday users who want to take control of their health data without needing a clinical background. The app bridges the gap between personal health tracking and professional healthcare by providing:

- A beautiful, intuitive daily dashboard
- Real-time data synced to the cloud
- An AI companion powered by Google Gemini that understands the user's personal health profile
- A dual-portal system — one experience for users, a separate one for healthcare providers

The app targets **Android** as its primary platform. Web is partially supported via Firebase but is not the main deployment target.

---

## 2. Features

### User Side

| Feature | Description |
|---|---|
| **Authentication** | Email/password sign-up and login via Firebase Auth |
| **Profile Setup** | 3-step onboarding — bio, body metrics, medical history |
| **Medical History** | Searchable list of 88+ conditions across 14 categories |
| **Dashboard** | Live metrics overview — steps, calories, water, sleep |
| **Activity Tracker** | Log workouts (Running, Cycling, Swimming, Weightlifting) with auto-estimated calories and steps |
| **Diet / Nutrition Log** | Log meals by type (Breakfast, Lunch, Dinner, Snacks) with calorie tracking |
| **Health Vitals** | Log heart rate, blood pressure, weight, blood glucose, SpO₂ |
| **Analytics** | 7-day and 30-day charts for all metrics using fl_chart |
| **Goals** | Set and track personal health goals (steps, water, calories, sleep, weight) |
| **AI Companion** | Real-time AI chat powered by Google Gemini 1.5 Flash, personalised to the user's profile |
| **Notifications** | In-app notification centre with mark-read and delete |
| **Appointments** | Book and manage appointments with partner doctors |
| **Healthcare Hub** | Connect with partnered specialists, chat with assigned provider, locate hospitals |
| **Menstrual Cycle Tracker** | Period tracking with symptom logging (visible only for female users) |
| **Family Circle** | Share health data with family members via QR code |
| **Health Reports** | View PDF reports uploaded by healthcare providers |
| **Settings** | Change password, notification preferences, feedback, about |
| **Smartwatch Connect** | Simulated device connection (demo mode) |

### Provider (Doctor) Side

| Feature | Description |
|---|---|
| **Provider Dashboard** | Overview of all assigned users |
| **User Detail** | View a User's health metrics and history |
| **Upload Reports** | Add health reports directly to a User's record |
| **User Chat** | Real-time messaging with assigned users |
| **Provider Registration** | Separate registration flow for healthcare providers |

---

## 3. Tech Stack

| Layer | Technology |
|---|---|
| **UI Framework** | Flutter 3.x (Dart 3.1+) |
| **Authentication** | Firebase Authentication |
| **Database** | Cloud Firestore (NoSQL, real-time) |
| **File Storage** | Firebase Storage |
| **AI** | Google Generative AI SDK (Gemini 1.5 Flash) |
| **State Management** | Provider + ChangeNotifier |
| **Navigation** | GoRouter (declarative, with redirect guards) |
| **Charts** | fl_chart |
| **Fonts** | Google Fonts (Poppins) |
| **Animations** | flutter_animate |
| **Design** | Custom design system — `AppColors` + `AppTheme` |

---

## 4. Architecture

```
┌──────────────────────────────────────────────────┐
│                   Flutter UI                      │
│   Screens → Widgets → Theme (AppColors/AppTheme)  │
└─────────────────────┬────────────────────────────┘
                      │ reads / writes
┌─────────────────────▼────────────────────────────┐
│               State Management                    │
│   AuthProvider          MetricsProvider           │
│   (Firebase Auth +      (Firestore streams —      │
│    UserProfile)          today + 30-day history)  │
└─────────────────────┬────────────────────────────┘
                      │ calls
┌─────────────────────▼────────────────────────────┐
│                  Services                         │
│   FirestoreService        AIService               │
│   (all Firestore reads    (Gemini chat session,   │
│    and writes)             plain-text mode)       │
└─────────────────────┬────────────────────────────┘
                      │
┌─────────────────────▼────────────────────────────┐
│                  Firebase                         │
│   Auth    Firestore    Storage                    │
└──────────────────────────────────────────────────┘
```

**Navigation** is handled by GoRouter with a `redirect` guard that automatically routes users based on their auth state, profile completion, and role (User vs provider). The guard runs on every route change — no screen can be accessed out of order.

**State** flows downward. `AuthProvider` is a `ChangeNotifier` at the top of the widget tree. `MetricsProvider` is a `ProxyProvider` that re-initialises its Firestore streams whenever the logged-in user changes. Both are provided at app root via `MultiProvider`.

---

## 5. Firestore Data Model

All user data lives under `users/{uid}`. The schema is:

```
users/
  {uid}/
    ← profile fields (username, email, role, gender, height, weight, etc.)
    metrics/
      {yyyy-MM-dd}/          ← one document per day
        steps                (int, cumulative)
        caloriesBurned       (int, cumulative — exercise only)
        caloriesConsumed     (int, cumulative — meals only)
        waterIntakeMl        (int, cumulative)
        sleepMinutes         (int, cumulative)
        activeMinutes        (int, cumulative)
        heartRate            (int, overwrite)
        weight               (double, overwrite)
        bloodPressureSystolic   (int, overwrite)
        bloodPressureDiastolic  (int, overwrite)
        bloodGlucose         (double, overwrite)
        oxygenSaturation     (double, overwrite)
        date                 (Timestamp)
    activities/
      {yyyy-MM-dd}/
        entries/
          {auto-id}/         ← one document per logged workout
            sportType, durationMinutes, caloriesBurned, stepsAdded, createdAt
    meals/
      {yyyy-MM-dd}/
        entries/
          {auto-id}/         ← one document per logged meal
            mealType, foodName, calories, createdAt
    goals/
      {auto-id}/             ← one document per goal
        name, metric, target, createdAt
    notifications/
      {auto-id}/
        title, body, isRead, createdAt
    appointments/
      {auto-id}/
        doctorName, dateTime, note, createdAt
    reports/
      {auto-id}/
        title, notes, providerName, dateUploaded

chats/
  {UserUid}_{providerUid}/
    messages/
      {auto-id}/             ← real-time chat between User and provider
        text, senderId, timestamp
```

**Important design notes:**
- Cumulative fields (steps, calories, water, sleep) use `FieldValue.increment()` so they safely accumulate throughout the day. Deleting an entry reverses it with a negative increment.
- Point-in-time fields (heart rate, weight, BP, etc.) always overwrite — logging twice replaces the old value.
- The `date` field on metrics uses `Timestamp.fromDate(DateTime.now())` — not `serverTimestamp()` — to avoid null casts on pending-write local snapshots.

---

## 6. Prerequisites

Before you set anything up, make sure you have all of these installed:

### Flutter SDK
Version **3.1.0 or higher** is required.

1. Go to https://docs.flutter.dev/get-started/install
2. Follow the guide for your OS (Windows / macOS / Linux)
3. After installing, run this to confirm everything is ready:
```bash
flutter doctor
```
All items should show a green tick. The important ones are Flutter, Android toolchain, and Android Studio (or VS Code).

### Android Studio
Download from https://developer.android.com/studio

During install, make sure these are checked:
- Android SDK
- Android SDK Platform
- Android Virtual Device (AVD)

After installing, open Android Studio → Virtual Device Manager → create an emulator. Recommended: **Pixel 6 / API 35** or any device with API 30+.

### VS Code (optional but recommended)
If you prefer VS Code over Android Studio:
1. Install VS Code from https://code.visualstudio.com
2. Install the **Flutter** extension (it also installs Dart automatically)

### Java (for Android builds)
Flutter's Android build requires Java 17. Android Studio bundles it, but if you need it standalone:
```bash
# macOS (Homebrew)
brew install openjdk@17

# Windows — download from https://adoptium.net
```

### Git
```bash
# Check if already installed
git --version

# macOS
brew install git

# Windows — download from https://git-scm.com
```

---

## 7. Setup Guide (Step by Step)

### Step 1 — Clone the repository

```bash
git clone https://github.com/sutin1215/aura-app.git
cd aura-app
```

### Step 2 — Add the secret files

These two files contain API keys and Firebase credentials. They are intentionally excluded from git. You must create them manually — **get the actual values from a teammate**.

#### File A: `android/app/google-services.json`

This file connects the Android app to the Firebase project. Without it, the app will crash immediately on launch.

To get it:
1. Go to https://console.firebase.google.com
2. Open the **aura-vhc** project
3. Click the gear icon → **Project Settings**
4. Scroll to **Your apps** → click the Android app (`com.aura.aura_app`)
5. Click **Download google-services.json**
6. Place the downloaded file at: `android/app/google-services.json`

Alternatively, ask a teammate to send you the file directly.

#### File B: `lib/config/app_config.dart`

This file holds the Gemini AI API key used by the Companion tab.

Create the file at `lib/config/app_config.dart` with this exact content:

```dart
class AppConfig {
  static const String geminiApiKey = 'PASTE_THE_KEY_HERE';
}
```

Ask a teammate for the actual key, or generate a new free one at https://aistudio.google.com/app/apikey (sign in with a Google account, click **Create API key**).

#### File C: `lib/firebase_options.dart`

This file is also gitignored. It is generated by the FlutterFire CLI and contains platform-specific Firebase configuration. Ask a teammate for this file, or regenerate it yourself:

```bash
# Install the FlutterFire CLI (one-time)
dart pub global activate flutterfire_cli

# Log in to Firebase
firebase login

# Run this inside the project folder
flutterfire configure --project=aura-vhc
```

Select Android (and Web if needed) when prompted. This regenerates `lib/firebase_options.dart` automatically.

### Step 3 — Install Flutter dependencies

```bash
flutter pub get
```

This downloads all packages listed in `pubspec.yaml`. You should see no errors.

### Step 4 — Verify your setup

```bash
flutter doctor -v
```

Check that:
- Flutter is on stable channel
- Android toolchain shows no issues  
- A connected device or emulator is listed

To list available devices:
```bash
flutter devices
```

To start the Android emulator from the terminal:
```bash
flutter emulators --launch <emulator_id>
# e.g. flutter emulators --launch Pixel_6_API_35
```

### Step 5 — Run the app

```bash
flutter run
```

If you have multiple devices connected, specify one:
```bash
flutter run -d emulator-5554
```

For a release build (faster, no debug banner):
```bash
flutter run --release
```

---

## 8. Secret Files (Not in Git)

This table summarises every file that is gitignored and what you need to do about each:

| File | Why excluded | What to do |
|---|---|---|
| `android/app/google-services.json` | Firebase credentials | Download from Firebase Console or get from teammate |
| `lib/firebase_options.dart` | Firebase platform config | Get from teammate or run `flutterfire configure` |
| `lib/config/app_config.dart` | Gemini API key | Create manually — get key from teammate or generate a new one |

> **Rule:** Never commit any of these files. The `.gitignore` already excludes them. If you accidentally stage one, run `git rm --cached <filename>` before committing.

---

## 9. Running the App

### Development (hot reload)
```bash
flutter run
```
Press `r` in the terminal to hot reload, `R` to hot restart, `q` to quit.

### On a physical Android device
1. Enable **Developer Options** on the phone: Settings → About Phone → tap Build Number 7 times
2. Enable **USB Debugging** in Developer Options
3. Connect the phone via USB
4. Accept the "Allow USB Debugging" prompt on the phone
5. Run `flutter devices` — your phone should appear
6. Run `flutter run`

### Common issues and fixes

**`google-services.json not found`**  
→ You missed Step 2A. Place the file at `android/app/google-services.json`.

**`firebase_options.dart not found`**  
→ You missed Step 2C. Get the file from a teammate or run `flutterfire configure`.

**`AppConfig is not defined`**  
→ You missed Step 2B. Create `lib/config/app_config.dart` with the Gemini key.

**`flutter pub get` fails with version conflicts**  
→ Run `flutter clean` then `flutter pub get` again.

**Build fails with Gradle error**  
→ Make sure you have Java 17. Run `java -version` to check. If using Android Studio, it bundles the right JDK — open `android/` in Android Studio and let it sync first.

**App crashes immediately on launch**  
→ Almost always a missing `google-services.json`. Double-check it exists at `android/app/google-services.json`.

**AI Companion shows "Connection failed"**  
→ Your Gemini API key is wrong or expired. Go to https://aistudio.google.com/app/apikey and generate a new one, then update `lib/config/app_config.dart`.

**Emulator is very slow**  
→ Enable Hardware Acceleration (HAXM on Intel, Hyper-V on AMD) in Android Studio settings. Alternatively, use a physical device — it's always faster.

---

## 10. Project Structure

```
aura-app/
├── android/                        ← Android native project
│   └── app/
│       ├── google-services.json    ← 🔒 gitignored — add manually
│       └── src/main/
│           └── AndroidManifest.xml
├── assets/
│   └── images/
│       └── logo.png
├── lib/
│   ├── config/
│   │   └── app_config.dart         ← 🔒 gitignored — add manually
│   ├── data/
│   │   └── partner_doctors.dart    ← hardcoded partner doctor roster
│   ├── models/
│   │   ├── activity_model.dart
│   │   ├── chat_message.dart
│   │   ├── goal_model.dart
│   │   ├── health_metrics.dart     ← HealthDay model (daily data)
│   │   ├── health_report.dart
│   │   ├── meal_model.dart
│   │   ├── notification_model.dart
│   │   └── user_profile.dart
│   ├── providers/
│   │   ├── auth_provider.dart      ← Firebase Auth + UserProfile state
│   │   └── metrics_provider.dart   ← live Firestore streams
│   ├── routes/
│   │   └── app_router.dart         ← GoRouter + all route definitions
│   ├── screens/
│   │   ├── activity/               ← workout logging
│   │   ├── ai/                     ← AI chat (full Markdown mode)
│   │   ├── analytics/              ← charts + reports list
│   │   ├── appointments/           ← appointment booking
│   │   ├── auth/                   ← login, register, forgot password
│   │   ├── companion/              ← AI companion tab (plain text mode)
│   │   ├── dashboard/              ← main home screen
│   │   ├── diet/                   ← meal logging
│   │   ├── family/                 ← family circle / QR sharing
│   │   ├── goals/                  ← goal setting and tracking
│   │   ├── health/                 ← vitals, hospital locator, specialist connect
│   │   ├── menstrual/              ← cycle tracker (female users only)
│   │   ├── notifications/          ← notification centre
│   │   ├── onboarding/             ← profile setup (3-step wizard)
│   │   ├── profile/                ← profile view and edit
│   │   ├── provider/               ← provider dashboard, User detail, chat
│   │   ├── settings/               ← settings, feedback, about
│   │   ├── share/                  ← share health data
│   │   ├── shell/                  ← bottom nav shell (MainShell)
│   │   ├── splash/                 ← animated splash screen
│   │   └── tracker/                ← tracker hub (entry point for activity/diet/vitals)
│   ├── services/
│   │   ├── ai_service.dart         ← Gemini AI session manager
│   │   └── firestore_service.dart  ← all Firestore reads and writes
│   ├── theme/
│   │   └── app_theme.dart          ← AppColors + AppTheme (single source of truth)
│   ├── utils/
│   │   ├── demo_data_generator.dart← populates realistic demo data for testing
│   │   └── health_calculator.dart  ← MET-based calorie + step estimation
│   ├── widgets/
│   │   ├── custom_text_field.dart
│   │   ├── gradient_scaffold.dart
│   │   ├── linear_progress_card.dart
│   │   └── metric_card.dart
│   ├── firebase_options.dart       ← 🔒 gitignored — add manually
│   └── main.dart                   ← app entry point
├── web/                            ← web platform files
├── .gitignore
├── pubspec.yaml                    ← dependencies
├── README.md                       ← you are here
└── SETUP.md                        ← quick-start for teammates
```

---

## 11. Screens Reference

| Route | Screen | Who sees it |
|---|---|---|
| `/splash` | Animated splash → redirects based on auth | Everyone |
| `/login` | Email/password login | Unauthenticated |
| `/register` | New account creation | Unauthenticated |
| `/forgot-password` | Password reset email | Unauthenticated |
| `/profile-setup` | 3-step onboarding wizard | New users |
| `/dashboard` | Home — metrics overview + quick actions | users |
| `/analytics` | Charts + health reports | users |
| `/tracker` | Hub linking to activity, diet, vitals, cycle | users |
| `/companion` | Real-time Gemini AI chat | users |
| `/profile` | Profile card + BMI + settings links | users |
| `/activity` | Log workouts | users |
| `/diet` | Log meals | users |
| `/health-data` | Log vitals (heart rate, BP, weight, etc.) | users |
| `/goals` | Set and track health goals | users |
| `/notifications` | In-app notification centre | users |
| `/settings` | App settings | users |
| `/appointments` | Book + view appointments | users |
| `/healthcare-interaction` | Hub for healthcare features | users |
| `/partner-specialists` | Browse + connect with partner doctors | users |
| `/connect-doctor` | Link to provider by code | users |
| `/chat-provider` | Chat with assigned provider | users |
| `/hospital-locator` | Opens Google Maps for nearby hospitals | users |
| `/menstrual-cycle` | Period tracker | Female users |
| `/family-circle` | QR code health sharing | users |
| `/share-health` | Generate shareable health summary | users |
| `/provider/dashboard` | Provider home — User list | Providers |
| `/provider/User/:uid` | Individual User detail view | Providers |
| `/provider/report/:uid` | Add health report to User record | Providers |
| `/provider/chat/:uid` | Chat with a specific User | Providers |

---

## 12. User Roles

The app has two distinct roles stored on the user's Firestore document as `role: 'User'` or `role: 'provider'`.

### User
- Created through the normal Register flow
- Must complete the 3-step profile setup before accessing the main app
- Gets the full User experience (dashboard, tracker, companion, etc.)
- Can link to a provider by entering a provider code

### Provider (Healthcare Professional)
- Created through a separate registration path in the Register screen (there is a "Register as Provider" option)
- Bypasses the User setup wizard
- Gets routed directly to the Provider Dashboard
- Cannot access User-facing screens
- Can view assigned users, upload reports, and chat with users

**Partner doctors** are a third concept — they are a hardcoded roster in `lib/data/partner_doctors.dart` representing pre-approved specialists. users can "connect" to them from the Partner Specialists screen, which writes their `hiddenUid` as the User's `assignedProviderId`.

---

## 13. Key Packages

| Package | Version | Purpose |
|---|---|---|
| `firebase_core` | ^3.1.0 | Firebase initialisation |
| `firebase_auth` | ^5.1.0 | Authentication |
| `cloud_firestore` | ^5.1.0 | Real-time database |
| `firebase_storage` | ^12.1.0 | File storage |
| `provider` | ^6.1.2 | State management |
| `go_router` | ^14.2.0 | Declarative navigation |
| `google_generative_ai` | ^0.4.7 | Gemini AI SDK |
| `fl_chart` | ^1.1.1 | Charts and graphs |
| `percent_indicator` | ^4.2.3 | Circular/linear progress |
| `flutter_animate` | ^4.5.2 | Animations |
| `google_fonts` | ^6.2.1 | Poppins font |
| `intl` | ^0.19.0 | Date formatting |
| `image_picker` | ^1.1.2 | Avatar photo upload |
| `qr_flutter` | ^4.1.0 | QR code generation |
| `url_launcher` | ^6.3.2 | Open external URLs (maps) |
| `shared_preferences` | ^2.2.3 | Local key-value storage |
| `uuid` | ^4.4.0 | Unique ID generation |

---

## 14. Known Limitations

These are intentional simplifications for the prototype scope:

- **Smartwatch sync is simulated.** The "Connect Smartwatch" feature shows a fake Bluetooth scan and writes mock biometric values. No real BLE connection is made.
- **iOS is not configured.** `firebase_options.dart` throws `UnsupportedError` on iOS. Only Android and Web targets are set up.
- **No push notifications.** The notification system is in-app only. No Firebase Cloud Messaging (FCM) is configured.
- **Feedback is not persisted.** The feedback form shows a success screen but does not write to Firestore.
- **AI has no memory across sessions.** Each time the Companion tab is opened, a new Gemini chat session starts. Previous conversations are not saved.
- **Activity deletion only works for today.** If an activity was logged yesterday, deleting it today would incorrectly decrement today's metric totals.
- **PDF uploads are text-only.** The `addReport` function saves a text note rather than an actual PDF file, though `firebase_storage` is in the dependency list for future use.

---

## 15. Contributing

### Branch naming
```
feature/short-description
fix/short-description
chore/short-description
```

### Before pushing
```bash
# Check for analysis errors
flutter analyze

# Format all files
dart format lib/
```

### Rules
- Never commit `google-services.json`, `firebase_options.dart`, or `lib/config/app_config.dart`
- All colours and text styles must use `AppColors` and `AppTheme` — no hardcoded values in screens
- Every new Firestore collection needs a corresponding method in `FirestoreService` — no direct `FirebaseFirestore.instance` calls in screens
- State that needs to survive widget rebuilds goes in a Provider, not `setState`

---

## Firebase Project Info

| Item | Value |
|---|---|
| Project ID | `aura-vhc` |
| Auth domain | `aura-vhc.firebaseapp.com` |
| Android package | `com.aura.aura_app` |
| Storage bucket | `aura-vhc.firebasestorage.app` |

---

*Built with Flutter · Powered by Firebase · AI by Google Gemini*  
*© 2025 AURA · Group 3 · F29SO · Heriot-Watt University*