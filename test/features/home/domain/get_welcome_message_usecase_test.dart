import 'package:bet_out_app/api/mappers/welcome_mapper.dart';
import 'package:bet_out_app/api/model/welcome_dto.dart';
import 'package:bet_out_app/api/providers/welcome_provider.dart';
import 'package:bet_out_app/design_system/model/welcome_view_object.dart';
import 'package:bet_out_app/features/home/domain/get_welcome_message_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockWelcomeProvider extends Mock implements WelcomeProvider {}

class _MockWelcomeMapper extends Mock implements WelcomeMapper {}

void main() {
  group('GetWelcomeMessageUsecaseImpl', () {
    late _MockWelcomeProvider provider;
    late _MockWelcomeMapper mapper;
    late GetWelcomeMessageUsecaseImpl usecase;

    setUp(() {
      provider = _MockWelcomeProvider();
      mapper = _MockWelcomeMapper();
      usecase = GetWelcomeMessageUsecaseImpl(provider, mapper);
    });

    test('invokes provider and maps result', () async {
      const dto = WelcomeDto(message: 'Mapped welcome');
      const viewObject = WelcomeViewObject(message: 'Mapped welcome');

      when(() => provider.fetchWelcome()).thenAnswer((_) async => dto);
      when(() => mapper.toViewObject(dto)).thenReturn(viewObject);

      final result = await usecase.invoke();

      expect(result, viewObject);
      verify(() => provider.fetchWelcome()).called(1);
      verify(() => mapper.toViewObject(dto)).called(1);
    });
  });
}
