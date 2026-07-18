import 'package:injectable/injectable.dart';

import '../../../api/mappers/spin_result_mapper.dart';
import '../../../api/providers/simulator_provider.dart';
import '../../../design_system/model/spin_result_view_object.dart';

abstract class ResetSimulatorUsecase {
  Future<SimulatorStatsViewObject> invoke();
}

@Injectable(as: ResetSimulatorUsecase)
class ResetSimulatorUsecaseImpl implements ResetSimulatorUsecase {
  ResetSimulatorUsecaseImpl(this._provider, this._mapper);

  final SimulatorProvider _provider;
  final SpinResultMapper _mapper;

  @override
  Future<SimulatorStatsViewObject> invoke() async {
    await _provider.resetSession();
    final dto = await _provider.fetchStats();
    return _mapper.toStatsViewObject(dto);
  }
}
