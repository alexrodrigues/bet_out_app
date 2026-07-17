import 'package:bet_out_app/api/mappers/welcome_mapper.dart';
import 'package:bet_out_app/api/model/welcome_dto.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WelcomeMapper', () {
    test('maps dto message to view object', () {
      const dto = WelcomeDto(message: 'Hello Bet Out');
      final result = WelcomeMapper().toViewObject(dto);

      expect(result.message, 'Hello Bet Out');
    });
  });
}
