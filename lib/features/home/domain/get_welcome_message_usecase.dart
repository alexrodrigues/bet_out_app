import 'package:injectable/injectable.dart';

import '../../../api/mappers/welcome_mapper.dart';
import '../../../api/providers/welcome_provider.dart';
import '../../../design_system/model/welcome_view_object.dart';

abstract class GetWelcomeMessageUsecase {
  Future<WelcomeViewObject> invoke();
}

@Injectable(as: GetWelcomeMessageUsecase)
class GetWelcomeMessageUsecaseImpl implements GetWelcomeMessageUsecase {
  GetWelcomeMessageUsecaseImpl(this._provider, this._mapper);

  final WelcomeProvider _provider;
  final WelcomeMapper _mapper;

  @override
  Future<WelcomeViewObject> invoke() async {
    final dto = await _provider.fetchWelcome();
    return _mapper.toViewObject(dto);
  }
}
