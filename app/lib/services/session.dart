import 'package:flutter/foundation.dart';

import '../models/user.dart';
import '../widgets/toast.dart';
import 'api_client.dart';
import 'app_keys.dart';

enum AuthStatus { checking, loggedOut, loggedIn, unreachable }

/// Who is logged in. The app shows the login screen or the main app based on [status].
class Session extends ChangeNotifier {
  Session._();
  static final Session instance = Session._();

  AuthStatus _status = AuthStatus.checking;
  User? _user;
  String? _error;

  AuthStatus get status => _status;
  User? get user => _user;
  String? get error => _error;

  void _set(AuthStatus status) {
    _status = status;
    notifyListeners();
  }

  void _popToRoot() => navigatorKey.currentState?.popUntil((route) => route.isFirst);

  /// Runs at app start: if a token is saved, check with the server that it still works.
  Future<void> bootstrap() async {
    final api = ApiClient.instance;
    if (!api.hasToken) {
      _user = null;
      _set(AuthStatus.loggedOut);
      return;
    }
    _error = null;
    _set(AuthStatus.checking);
    try {
      final data = await api.get('/auth/me') as Map<String, dynamic>;
      _user = User.fromJson(data);
      _set(AuthStatus.loggedIn);
    } on ApiException catch (e) {
      if (e.isUnauthorized) {
        await api.clearToken();
        _user = null;
        _set(AuthStatus.loggedOut);
      } else {
        _error = e.message;
        _set(AuthStatus.unreachable);
      }
    }
  }

  Future<void> signIn(User user, String token) async {
    await ApiClient.instance.saveToken(token);
    _user = user;
    _error = null;
    _popToRoot();
    _set(AuthStatus.loggedIn);
  }

  Future<void> signOut() async {
    await ApiClient.instance.clearToken();
    _user = null;
    _popToRoot();
    _set(AuthStatus.loggedOut);
  }

  /// The server said 401 (token missing, invalid or expired).
  void handleExpired() {
    if (_status == AuthStatus.loggedOut) return;
    _user = null;
    _popToRoot();
    _set(AuthStatus.loggedOut);
    showToast('Your session expired. Please sign in again.', error: true);
  }
}
