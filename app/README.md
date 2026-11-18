# Stockwise: Flutter app

Mobile app for the Inventory Management capstone. It talks to the FastAPI backend in `../backend`.

**Screens:** Splash, Login, Register, Home (dashboard), Products, Activity, More, Categories,
Suppliers, Profile, plus bottom-sheet forms for products, stock, categories and suppliers.
Full list with the endpoint each screen uses: [`../docs/SCREENS.md`](../docs/SCREENS.md).

## 1. Prerequisites
- Flutter SDK 3.22 or newer (`flutter --version`), with the Android toolchain (`flutter doctor`)
- VS Code with the **Flutter** and **Dart** extensions
- The backend running (see `../backend/README.md`)

## 2. First-time setup (once)

This folder contains the app code (`lib/`, `pubspec.yaml`, `test/`). Flutter still has to
generate the Android/iOS platform folders. Open a terminal **in this `app/` folder**:

```bash
flutter create --platforms=android,ios --project-name stockwise .
flutter pub get
```

> `flutter create .` keeps the existing `lib/` and `pubspec.yaml`. If it replaced `lib/main.dart`
> with the default counter app, copy `main.dart` from the zip again. Also delete the generated
> `test/widget_test.dart` (it tests the counter app and will fail).

**Allow the app to reach the backend over http** (needed for local development).
Open `android/app/src/main/AndroidManifest.xml` and:

1. Add this line just above `<application`:
   ```xml
   <uses-permission android:name="android.permission.INTERNET"/>
   ```
2. Add `android:usesCleartextTraffic="true"` inside the `<application ...>` tag:
   ```xml
   <application
       android:label="stockwise"
       android:usesCleartextTraffic="true"
       ...>
   ```

## 3. Run it

1. Start the backend from `backend/`:
   ```bash
   uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
   ```
2. Start an Android emulator (or plug in a phone with USB debugging), then in `app/`:
   ```bash
   flutter run
   ```
   In VS Code: open the `app` folder, pick a device at the bottom right, press **F5**.

### Server address
| Where the app runs | Address |
|--------------------|---------|
| Android emulator (default) | `http://10.0.2.2:8000` |
| iOS simulator | `http://127.0.0.1:8000` |
| Real phone on the same Wi-Fi | `http://<laptop-ip>:8000` (find the IP with `ipconfig`) |

You do **not** need to rebuild to change it. On the login screen tap the gear icon (or
**More > Settings**), type the address, tap **Test connection**, then **Save**.
The default lives in `lib/config.dart`.

On a real phone, Windows Firewall may ask to allow Python. Choose **Allow** for private networks.

### Demo login
After `python seed.py` in the backend: `demo@example.com` / `Demo12345`.
Or tap **Create one** on the login screen and register.

## 4. Project structure (as required by the capstone)

```
lib/
  main.dart            app start
  config.dart          default server address, timeout
  theme.dart           colours and styles
  models/              User, Product, Category, Supplier, StockMovement, DashboardSummary
  services/            api_client (token, errors, 401), session, one service per resource
  screens/             one file per screen; screens/sheets/ holds the bottom-sheet forms
  widgets/             reusable parts: data_loader, state_views (loading/error/empty), cards, fields
  utils/               formatting helpers (UGX money, dates)
test/                  unit tests
```

## 5. How it meets the capstone requirements

| Requirement | Where |
|-------------|-------|
| 4+ screens with navigation | 4 tabs + Categories, Suppliers, Profile, Login, Register |
| All data from the backend | Every list is loaded through `services/`; nothing is hard-coded |
| Create, view, edit, delete | Products, categories and suppliers (add / edit / delete); stock movements (create / list) |
| Loading and error states, server off | `widgets/data_loader.dart` + `widgets/state_views.dart`: spinner, "Can't reach the server" with Retry |
| Form validation | Every form uses `Form` validators with the same limits as the API |
| Folders models / services / screens / widgets | see structure above |
| Register and log in, login screen | `screens/login_screen.dart`, `register_screen.dart` |
| Token sent with every request | `services/api_client.dart` adds `Authorization: Bearer <token>` |
| 401 handling | `ApiClient` clears the token and `Session` returns to the login screen |
| Logout clears the token | `Session.signOut()` deletes it from the phone |

## 6. Run the tests
```bash
flutter test
```

## 7. Troubleshooting
| Problem | Fix |
|---------|-----|
| "Can't reach the server" | Is uvicorn running with `--host 0.0.0.0`? Is the address right? Use the gear icon > Test connection. On a real phone use the laptop IP, not `10.0.2.2` |
| Works on emulator but not on a phone | Same Wi-Fi? Firewall allowed? Cleartext/INTERNET lines added to the manifest? |
| Login says "Incorrect email or password" | Run `python seed.py` in `backend/`, or register a new account |
| Compile error mentioning `InputDecorationTheme` | Your Flutter is very new: in `lib/theme.dart` rename `InputDecorationTheme(` to `InputDecorationThemeData(` |
| Dropdown or other deprecation warnings | Warnings only; the app still runs. `flutter upgrade` is not required |
