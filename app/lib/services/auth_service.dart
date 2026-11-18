import '../models/user.dart';
import 'api_client.dart';
import 'session.dart';

class AuthService {
  final ApiClient _api = ApiClient.instance;

  Future<User> register({
    required String fullName,
    required String email,
    required String password,
    String? businessName,
  }) async {
    final body = <String, dynamic>{
      'full_name': fullName,
      'email': email,
      'password': password,
    };
    if (businessName != null && businessName.isNotEmpty) body['business_name'] = businessName;
    final data = await _api.post('/auth/register', body: body, auth: false);
    return User.fromJson(data as Map<String, dynamic>);
  }

  /// Logs in and saves the token. The app then switches to the main screens.
  Future<void> login(String email, String password) async {
    final data = await _api.post(
      '/auth/login',
      body: {'email': email, 'password': password},
      auth: false,
    ) as Map<String, dynamic>;
    await Session.instance.signIn(
      User.fromJson(data['user'] as Map<String, dynamic>),
      data['access_token'] as String,
    );
  }

  Future<void> logout() => Session.instance.signOut();
}
