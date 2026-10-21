# Books Build Minds — Flutter mobile client

Mobile companion to the [server](https://github.com/HussainALAradi5/books_build_minds_server) and [web client](https://github.com/HussainALAradi5/books_build_minds_client_side). The [documentation repository](https://github.com/HussainALAradi5/books_build_minds_documentation) contains the mobile plan, API contracts, workflows, and security notes.

## Run locally

1. Start the server and load the demo accounts using the [server setup](https://github.com/HussainALAradi5/books_build_minds_server/blob/main/README.md). The mobile app reads catalog and account data from that API; it contains no duplicate seed data.
2. Install Flutter 3.47 or newer with Dart 3.13, Android SDK, and a running Android emulator or device.
3. In this folder run:

   ```powershell
   flutter pub get
   flutter run --dart-define=API_BASE_URL=http://10.0.2.2:5000
   ```

`10.0.2.2` points from the Android emulator to the host machine. On a physical device, use the host's reachable LAN address for a debug build, or a trusted HTTPS URL. Release builds require `https://` for `API_BASE_URL`. The Android debug manifest permits local HTTP testing; release does not. Set the API origin without `/api` because the shared client adds API routes.

### Android release signing

The Android application ID is `com.booksbuildminds.mobile`. Debug builds use the Android debug key. Release builds never use that key. To make an installable release, create your own keystore, copy `android/key.properties.example` to `android/key.properties`, and replace all example values with the local keystore path and credentials. Both the properties file and keystore files in `android/app` are ignored by Git. Back up the keystore securely; future updates must use the same key.

Build the signed app bundle with an HTTPS API origin:

```powershell
flutter build appbundle --release --dart-define=API_BASE_URL=https://your-api.example
```

Check the app ID and signing key against your store account before its first upload. The debug APK in `build/app/outputs/flutter-apk` is for local testing only.

### HONOR Magic7 Pro

HONOR lists a **1280 × 2800** display and MagicOS 9 based on Android 15 for the [Magic7 Pro](https://www.honor.com/lk/phones/honor-magic7-pro/spec/). The app also has a 3×, approximately 427 dp wide layout preview for that display. Actual display and font scaling can vary in the phone's settings, so installation and interaction still need a device check.

For USB debugging with a local server running on port 5000:

```powershell
adb devices
adb reverse tcp:5000 tcp:5000
flutter run -d <device-id> --dart-define=API_BASE_URL=http://127.0.0.1:5000
```

`adb reverse` lets the phone reach the computer's local server through USB. Keep the device connected while testing. For a release build, use an HTTPS server URL instead.

| Role | Username | Password | Example access |
| --- | --- | --- | --- |
| Administrator | `demo_admin` | `LibraryAdmin2026!` | Inventory prices and access overview |
| Employee | `demo_employee` | `LibraryStaff2026!` | Member library workflows |
| Client | `demo_client` | `LibraryReader2026!` | Borrow, rent, return, buy, and review eligible books |

Demo credentials work after `flask --app app seed-demo --test-accounts` in a nonproduction server environment. Never use these passwords in production.

## Mobile flows

- **Explore:** searchable, filtered, paginated grid or list from the server; condition colors and book detail.
- **Book detail:** description, stock, creator information, printable PDF, three-step borrow flow, rent and purchase checkout, and purchase-gated reviews. Checkout uses the server's sandbox flow; the app verifies the resulting transaction through the API.
- **Library:** loans, owned books, transactions, and activity in separate tabs.
- **Account:** sign in with username, email, or registered mobile number; register with an optional international mobile number; reset a password with the server's email code; sign out. JWTs are stored in OS-backed secure storage.
- **Admin:** inventory listing, price edit, and read-only access records. The server remains the authority for every permission and business rule.

### Switch light and dark mode

The app starts with your phone's light or dark setting. On the Explore, Library, or Account screen, tap the moon icon in the top right to switch to dark mode, or the sun icon to switch to light mode. The icon's tooltip names the action. If you are on a sign-in, registration, password reset, or book detail screen, go back to the main screen to reach the theme button. The manual choice lasts while the app is open; a fresh launch follows the phone setting again.

For quicker catalog use, submit a search from the keyboard, tap the clear icon inside the search field, and tap outside the field to dismiss the keyboard. Filters open as a bottom sheet, and the list/grid button changes the book layout.

The UI is built with Flutter Material 3. `lib` has one parent folder per concern: `apis`, `services`, `dtos`, `interfaces`, `models`, `enums`, `filters`, `middleware`, `widgets`, `screens`, `controllers`, `utils`, and `shared`. Each parent has domain subfolders. `apis` contains endpoint calls, `services` maps them to typed app models, and `dtos` serializes server request bodies. `interfaces/network` defines the transport and middleware contracts. `widgets/shared` holds presentation reused across domains; `shared` holds network and configuration code.

## Mobile screenshots

These Flutter renders show the current mobile UI with deterministic sample API responses. The layout checks cover 320 × 700, 360 × 780, and 390 × 844 logical pixels; the Magic7 Pro preview uses 1280 × 2800 physical pixels at 3× scaling (about 427 dp wide). Transaction and activity records are sample responses; the borrow and checkout previews stop before submission. They are layout previews, not evidence of a live server session or a device installation. Regenerate them with `flutter test --update-goldens tool/capture_mobile_previews.dart` and `flutter test --update-goldens tool/capture_operation_previews.dart` while `FLUTTER_ROOT` points to the Flutter SDK.

| Catalog · light | Catalog · dark |
| --- | --- |
| ![Flutter catalog in light mode](screenshots/mobile/catalog-light.png) | ![Flutter catalog in dark mode](screenshots/mobile/catalog-dark.png) |
| Catalog · list | Filters · dark |
| ![Flutter catalog in list mode](screenshots/mobile/catalog-list-light.png) | ![Flutter filters in dark mode](screenshots/mobile/filters-dark.png) |
| Book detail · light | Book detail · dark |
| ![Flutter book detail in light mode](screenshots/mobile/book-detail-light.png) | ![Flutter book detail in dark mode](screenshots/mobile/book-detail.png) |
| Sign in · dark | Magic7 Pro sized catalog preview |
| ![Flutter sign-in screen in dark mode](screenshots/mobile/sign-in.png) | ![Flutter catalog at Honor Magic7 Pro screen proportions](screenshots/mobile/honor-magic7-pro-catalog.png) |
| Register · dark | Password recovery · dark |
| ![Flutter registration screen](screenshots/mobile/register.png) | ![Flutter password recovery request screen](screenshots/mobile/password-reset.png) |
| Password reset code · dark | Signed-in profile |
| ![Flutter password reset code screen](screenshots/mobile/password-reset-code.png) | ![Flutter signed-in client profile](screenshots/mobile/profile-signed-in.png) |
| Active loan | Owned books |
| ![Flutter active loan screen](screenshots/mobile/loans-signed-in.png) | ![Flutter owned books screen](screenshots/mobile/owned-books.png) |
| Small Android width · light | Standard Android width · light |
| ![Flutter catalog at 320 dp wide](screenshots/mobile/catalog-small-android.png) | ![Flutter catalog at 360 dp wide](screenshots/mobile/catalog-standard-android.png) |
| Filters · light | Magic7 Pro proportions · dark |
| ![Flutter filters in light mode](screenshots/mobile/filters-light.png) | ![Flutter catalog in dark mode at Magic7 Pro screen proportions](screenshots/mobile/honor-magic7-pro-dark.png) |
| Sign in · light | Register · light |
| ![Flutter sign-in screen in light mode](screenshots/mobile/sign-in-light.png) | ![Flutter registration screen in light mode](screenshots/mobile/register-light.png) |
| Password recovery · light | Signed-in profile · dark |
| ![Flutter password recovery screen in light mode](screenshots/mobile/password-reset-light.png) | ![Flutter signed-in client profile in dark mode](screenshots/mobile/profile-signed-in-dark.png) |
| Active loan · dark | |
| ![Flutter active loan screen in dark mode](screenshots/mobile/loans-signed-in-dark.png) | |
| Transactions · light | Transactions · dark |
| ![Sample purchase and rental transactions in light mode](screenshots/mobile/transactions-light.png) | ![Sample purchase and rental transactions in dark mode](screenshots/mobile/transactions-dark.png) |
| Library activity | Borrow · terms |
| ![Sample library activity](screenshots/mobile/activity-light.png) | ![First step of borrowing a book](screenshots/mobile/borrow-terms-light.png) |
| Borrow · review | Borrow · confirmation |
| ![Borrow period and availability review](screenshots/mobile/borrow-review-light.png) | ![Final borrow confirmation step](screenshots/mobile/borrow-confirm-light.png) |
| Purchase checkout | Rental checkout |
| ![Purchase checkout preview before submission](screenshots/mobile/purchase-checkout-light.png) | ![Rental checkout preview before submission](screenshots/mobile/rental-checkout-light.png) |

## Checks

```powershell
flutter analyze
flutter test
flutter build apk --debug
```

Android APK output is under `build/app/outputs/flutter-apk/`. A successful static build does not establish that the API is reachable; launch the server before testing flows on a device.

## Current scope

This client implements core reader workflows and a compact administrator view. The web client remains the full management surface for media uploads, creator and country editing, imports/exports, bulk actions, role and group changes, and richer reporting. Mobile push notifications, offline synchronization, and production payment integration are outside this build. The server sandbox checkout is for demonstrations only.
