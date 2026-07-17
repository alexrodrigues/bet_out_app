import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';

import '../../features/login/presentation/login_screen.dart';
import 'navigation_service.dart';
import 'token_storage_service.dart';

/// HTTP client that attaches Bearer tokens and clears session on 401/403.
@lazySingleton
class AuthenticatedHttpClient {
  AuthenticatedHttpClient(
    this._client,
    this._tokenStorage,
    this._navigation,
  );

  final http.Client _client;
  final TokenStorageService _tokenStorage;
  final NavigationService _navigation;

  Future<http.Response> get(Uri url, {Map<String, String>? headers}) {
    return _send(() => _client.get(url, headers: _withAuth(headers)));
  }

  Future<http.Response> post(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
  }) {
    return _send(
      () => _client.post(url, headers: _withAuth(headers), body: body),
    );
  }

  Future<http.Response> put(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
  }) {
    return _send(
      () => _client.put(url, headers: _withAuth(headers), body: body),
    );
  }

  Future<http.Response> delete(Uri url, {Map<String, String>? headers}) {
    return _send(() => _client.delete(url, headers: _withAuth(headers)));
  }

  Map<String, String> _withAuth(Map<String, String>? headers) {
    final merged = <String, String>{...?headers};
    final token = _tokenStorage.getToken();
    if (token != null && token.isNotEmpty) {
      merged['Authorization'] = 'Bearer $token';
    }
    return merged;
  }

  Future<http.Response> _send(Future<http.Response> Function() request) async {
    final response = await request();
    if (response.statusCode == 401 || response.statusCode == 403) {
      await _tokenStorage.clearToken();
      await _navigation.pushNamedAndRemoveUntil(LoginScreen.routeName);
    }
    return response;
  }
}
