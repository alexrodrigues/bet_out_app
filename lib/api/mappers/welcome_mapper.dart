import 'package:injectable/injectable.dart';

import '../../design_system/model/welcome_view_object.dart';
import '../model/welcome_dto.dart';

@injectable
class WelcomeMapper {
  WelcomeViewObject toViewObject(WelcomeDto dto) {
    return WelcomeViewObject(message: dto.message);
  }
}
