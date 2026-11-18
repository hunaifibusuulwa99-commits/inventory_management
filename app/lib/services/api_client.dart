import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config.dart';

/// Any problem talking to the backend. [message] is safe to show to the user.
class ApiException implements Exception {
  ApiException(this.message, {this.statusCode, this.isNetwork = false});

  final String message;
  final int? statusCode;

  /// True when the server could not be reached at all (server off, wrong address, no Wi-Fi).
  final bool isNetwork;

  bool get isUnauthorized => statusCode == 401;

  @override
  String toString() => message;
}

/// One place that knows the server address, attaches the login token to every request,
/// and turns failures into [ApiException]s.
class ApiClient {
  ApiClient._();
  static final ApiClient instance = ApiClient._();

  static const _tokenKey = 'auth_token';
  static const _baseUrlKey = 'base_url';

  final http.Client _client = http.Client();
  late SharedPreferences _prefs;
  String _baseUrl = kDefaultBaseUrl;
  String? _token;

  /// Called after a 401 on a protected request (token missing, invalid or expired).
  void Function()? onUnauthorized;

  String get baseUrl => _baseUrl;
  String? get token => _token;
  bool get hasToken => _token != null && _token!.isNotEmpty;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _baseUrl = _prefs.getString(_baseUrlKey) ?? kDefaultBaseUrl;
    _token = _prefs.getString(_tokenKey);
  }

  static String normalizeBaseUrl(String input) {
    var url = input.trim();
    if (url.isEmpty) return kDefaultBaseUrl;
    if (!url.startsWith('http://') && !url.startsWith('https://')) url = 'http://$url';
    while (url.endsWith('/')) {
      url = url.substring(0, url.length - 1);
    }
    return url;
  }

  Future<void> setBaseUrl(String url) async {
    _baseUrl = normalizeBaseUrl(url);
    await _prefs.setString(_baseUrlKey, _baseUrl);
  }

  Future<void> saveToken(String token) async {
    _token = token;
    await _prefs.setString(_tokenKey, token);
  }

  /// Logging out = deleting the token from the phone.
  Future<void> clearToken() async {
    _token = null;
    await _prefs.remove(_tokenKey);
  }

  Future<dynamic> get(String path, {Map<String, dynamic>? query, bool auth = true}) =>
      _request('GET', path, query: query, auth: auth);

  Future<dynamic> post(String path, {Object? body, bool auth = true}) =>
      _request('POST', path, body: body, auth: auth);

  Future<dynamic> put(String path, {Object? body, bool auth = true}) =>
      _request('PUT', path, body: body, auth: auth);

  Future<dynamic> delete(String path, {bool auth = true}) =>
      _request('DELETE', path, auth: auth);

  Uri _buildUri(String path, Map<String, dynamic>? query) {
    final uri = Uri.parse('$_baseUrl$path');
    if (query == null) return uri;
    final params = <String, String>{};
    query.forEach((key, value) {
      if (value != null) params[key] = value.toString();
    });
    return params.isEmpty ? uri : uri.replace(queryParameters: params);
  }

  Future<dynamic> _request(
    String method,
    String path, {
    Map<String, dynamic>? query,
    Object? body,
    bool auth = true,
  }) async {
    final request = http.Request(method, _buildUri(path, query));
    request.headers['Accept'] = 'application/json';
    if (body != null) {
      request.headers['Content-Type'] = 'application/json';
      request.body = jsonEncode(body);
    }
    if (auth && hasToken) request.headers['Authorization'] = 'Bearer $_token';

    final http.Response response;
    try {
      final streamed = await _client.send(request).timeout(kRequestTimeout);
      response = await http.Response.fromStream(streamed);
    } on TimeoutException {
      throw ApiException(
        'The server took too long to respond. Check that it is running and try again.',
        isNetwork: true,
      );
    } catch (_) {
      // SocketException, ClientException, bad address, no connection ...
      throw ApiException(
        'Cannot reach the server. Check your connection and the server address, then try again.',
        isNetwork: true,
      );
    }

    dynamic data;
    final text = utf8.decode(response.bodyBytes, allowMalformed: true);
    if (text.isNotEmpty) {
      try {
        data = jsonDecode(text);
      } catch (_) {
        data = null;
      }
    }

    if (response.statusCode >= 200 && response.statusCode < 300) return data;

    if (response.statusCode == 401 && auth) {
      await clearToken();
      onUnauthorized?.call();
    }
    throw ApiException(_messageFrom(data, response.statusCode), statusCode: response.statusCode);
  }

  String _messageFrom(dynamic data, int status) {
    if (data is Map && data['detail'] != null) {
      final detail = data['detail'];
      if (detail is String) return detail;
      if (detail is List) {
        return detail
            .map((e) => e is Map ? (e['msg'] ?? e).toString() : e.toString())
            .join('; ');
      }
    }
    if (status == 401) return 'Please sign in again.';
    if (status == 404) return 'Not found.';
    if (status >= 500) return 'Server error ($status). Please try again.';
    return 'Request failed ($status).';
  }
}
