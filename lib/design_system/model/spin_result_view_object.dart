import 'package:equatable/equatable.dart';

class SpinResultViewObject extends Equatable {
  const SpinResultViewObject({
    required this.symbolIndexes,
    required this.isWin,
    required this.payout,
    required this.balanceAfter,
    required this.betAmount,
    required this.resultMessageKey,
  });

  final List<int> symbolIndexes;
  final bool isWin;
  final double payout;
  final double balanceAfter;
  final double betAmount;

  /// Localization key resolved in the UI.
  final String resultMessageKey;

  @override
  List<Object?> get props => [
        symbolIndexes,
        isWin,
        payout,
        balanceAfter,
        betAmount,
        resultMessageKey,
      ];
}

class SimulatorStatsViewObject extends Equatable {
  const SimulatorStatsViewObject({
    required this.balance,
    required this.rtpPercent,
    required this.houseMarginPercent,
    required this.avgLossPerHour,
    required this.winRatePercent,
    required this.recentOutcomes,
  });

  final double balance;
  final double rtpPercent;
  final double houseMarginPercent;
  final double avgLossPerHour;
  final double winRatePercent;
  final List<bool> recentOutcomes;

  @override
  List<Object?> get props => [
        balance,
        rtpPercent,
        houseMarginPercent,
        avgLossPerHour,
        winRatePercent,
        recentOutcomes,
      ];
}
