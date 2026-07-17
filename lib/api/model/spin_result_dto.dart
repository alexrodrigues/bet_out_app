class SpinResultDto {
  const SpinResultDto({
    required this.symbolIndexes,
    required this.isWin,
    required this.payout,
    required this.balanceAfter,
    required this.betAmount,
  });

  /// Three column stop indexes into [AssetPaths.reelSymbols].
  final List<int> symbolIndexes;
  final bool isWin;
  final double payout;
  final double balanceAfter;
  final double betAmount;

  Map<String, dynamic> toJson() => {
        'symbolIndexes': symbolIndexes,
        'isWin': isWin,
        'payout': payout,
        'balanceAfter': balanceAfter,
        'betAmount': betAmount,
      };

  factory SpinResultDto.fromJson(Map<String, dynamic> json) {
    return SpinResultDto(
      symbolIndexes: (json['symbolIndexes'] as List<dynamic>)
          .map((e) => e as int)
          .toList(),
      isWin: json['isWin'] as bool,
      payout: (json['payout'] as num).toDouble(),
      balanceAfter: (json['balanceAfter'] as num).toDouble(),
      betAmount: (json['betAmount'] as num).toDouble(),
    );
  }
}
