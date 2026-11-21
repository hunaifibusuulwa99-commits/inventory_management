/// Default address of the FastAPI backend.
///
/// - Android emulator:  http://10.0.2.2:8000   (default)
/// - iOS simulator:     http://127.0.0.1:8000
/// - Real phone:        http://<laptop-ip>:8000  (same Wi-Fi as the laptop)
///
/// The address can also be changed inside the app (gear icon on the login screen,
/// or More > Settings), so no rebuild is needed when the laptop's IP changes.
const String kDefaultBaseUrl = 'http://10.0.2.2:8000';

/// How long to wait for the server before showing the "server is off" state.
const Duration kRequestTimeout = Duration(seconds: 15);
