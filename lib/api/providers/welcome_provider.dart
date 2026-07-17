import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/welcome_dto.dart';

/// Local data source for the home welcome message.
/// Replace with HTTP via [AuthenticatedHttpClient] when a backend exists.
@injectable
class WelcomeProvider {
  WelcomeProvider(this._prefs);

  static const _messageKey = 'welcome_message';
  static const _defaultMessage = 'Welcome to Bet Out';

  final SharedPreferences _prefs;

  Future<WelcomeDto> fetchWelcome() async {
    final message = _prefs.getString(_messageKey) ?? _defaultMessage;
    return WelcomeDto(message: message);
  }

  Future<void> saveWelcome(String message) async {
    await _prefs.setString(_messageKey, message);
  }
}
