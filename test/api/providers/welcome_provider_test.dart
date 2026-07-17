import 'package:bet_out_app/api/model/welcome_dto.dart';
import 'package:bet_out_app/api/providers/welcome_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('WelcomeProvider', () {
    test('returns default message when unset', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final provider = WelcomeProvider(prefs);

      final dto = await provider.fetchWelcome();

      expect(dto.message, 'Welcome to Bet Out');
    });

    test('returns persisted message', () async {
      SharedPreferences.setMockInitialValues({
        'welcome_message': 'Custom welcome',
      });
      final prefs = await SharedPreferences.getInstance();
      final provider = WelcomeProvider(prefs);

      final dto = await provider.fetchWelcome();

      expect(dto, isA<WelcomeDto>());
      expect(dto.message, 'Custom welcome');
    });
  });
}
