import 'package:injectable/injectable.dart';

import '../../../api/mappers/spin_result_mapper.dart';
import '../../../api/providers/simulator_provider.dart';
import '../../../design_system/model/spin_result_view_object.dart';

abstract class SpinSimulatorUsecase {
  Future<SpinResultViewObject> invoke({double betAmount});
}

@Injectable(as: SpinSimulatorUsecase)
class SpinSimulatorUsecaseImpl implements SpinSimulatorUsecase {
  SpinSimulatorUsecaseImpl(this._provider, this._mapper);

  final SimulatorProvider _provider;
  final SpinResultMapper _mapper;

  @override
  Future<SpinResultViewObject> invoke({
    double betAmount = SimulatorProvider.defaultBet,
  }) async {
    final dto = await _provider.spin(betAmount: betAmount);
    return _mapper.toViewObject(dto);
  }
}
