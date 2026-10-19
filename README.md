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
- **Account:** sign in with username, email, or registered mobile number; register; reset a password with the server's email code; sign out. JWTs are stored in OS-backed secure storage.
- **Admin:** inventory listing, price edit, and read-only access records. The server remains the authority for every permission and business rule.

The UI is built with Flutter Material 3, reusable widgets, feature folders, typed API models, and controllers. `lib/core` holds shared HTTP/configuration and `lib/shared/widgets` holds common presentation pieces. Features live in `lib/features`.

## Checks

```powershell
flutter analyze
flutter test
flutter build apk --debug
```

Android APK output is under `build/app/outputs/flutter-apk/`. A successful static build does not establish that the API is reachable; launch the server before testing flows on a device.

## Current scope

This client implements core reader workflows and a compact administrator view. The web client remains the full management surface for media uploads, creator and country editing, imports/exports, bulk actions, role and group changes, and richer reporting. Mobile push notifications, offline synchronization, and production payment integration are outside this build. The server sandbox checkout is for demonstrations only.
