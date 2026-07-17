import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

@lazySingleton
class TokenStorageService {
  TokenStorageService(this._prefs);

  static const _tokenKey = 'auth_token';

  final SharedPreferences _prefs;

  Future<void> saveToken(String token) async {
    await _prefs.setString(_tokenKey, token);
  }

  String? getToken() => _prefs.getString(_tokenKey);

  Future<void> clearToken() async {
    await _prefs.remove(_tokenKey);
  }

  bool get hasToken => getToken()?.isNotEmpty ?? false;
}
