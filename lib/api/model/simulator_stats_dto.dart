class SimulatorStatsDto {
  const SimulatorStatsDto({
    required this.balance,
    required this.rtpPercent,
    required this.houseMarginPercent,
    required this.totalLoss,
    required this.recentWins,
    required this.recentOutcomes,
  });

  final double balance;
  final double rtpPercent;
  final double houseMarginPercent;
  final double totalLoss;
  final int recentWins;
  final List<bool> recentOutcomes;

  double get winRatePercent {
    if (recentOutcomes.isEmpty) return 0;
    return (recentWins / recentOutcomes.length) * 100;
  }
}
