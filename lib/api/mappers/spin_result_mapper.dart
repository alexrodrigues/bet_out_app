import 'package:injectable/injectable.dart';

import '../../design_system/model/spin_result_view_object.dart';
import '../model/simulator_stats_dto.dart';
import '../model/spin_result_dto.dart';

@injectable
class SpinResultMapper {
  SpinResultViewObject toViewObject(SpinResultDto dto) {
    return SpinResultViewObject(
      symbolIndexes: List<int>.from(dto.symbolIndexes),
      isWin: dto.isWin,
      payout: dto.payout,
      balanceAfter: dto.balanceAfter,
      betAmount: dto.betAmount,
      resultMessageKey: dto.isWin ? 'spinResultWin' : 'spinResultLoss',
    );
  }

  SimulatorStatsViewObject toStatsViewObject(SimulatorStatsDto dto) {
    return SimulatorStatsViewObject(
      balance: dto.balance,
      rtpPercent: dto.rtpPercent,
      houseMarginPercent: dto.houseMarginPercent,
      avgLossPerHour: dto.avgLossPerHour,
      winRatePercent: dto.winRatePercent,
      recentOutcomes: List<bool>.from(dto.recentOutcomes),
    );
  }
}
