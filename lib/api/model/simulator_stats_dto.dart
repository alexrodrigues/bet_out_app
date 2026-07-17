class SimulatorStatsDto {
  const SimulatorStatsDto({
    required this.balance,
    required this.rtpPercent,
    required this.houseMarginPercent,
    required this.avgLossPerHour,
    required this.recentWins,
    required this.recentOutcomes,
  });

  final double balance;
  final double rtpPercent;
  final double houseMarginPercent;
  final double avgLossPerHour;
  final int recentWins;
  final List<bool> recentOutcomes;

  double get winRatePercent {
    if (recentOutcomes.isEmpty) return 0;
    return (recentWins / recentOutcomes.length) * 100;
  }
}
