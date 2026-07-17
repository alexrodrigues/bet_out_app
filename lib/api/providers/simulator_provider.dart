import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/utils/asset_paths.dart';
import '../model/simulator_stats_dto.dart';
import '../model/spin_result_dto.dart';

@injectable
class SimulatorProvider {
  SimulatorProvider(this._prefs);

  static const startingBalance = 10000.0;
  static const defaultBet = 50.0;
  static const rtpPercent = 92.4;
  static const houseMarginPercent = 7.6;
  static const avgLossPerHour = 42.50;
  static const winMultiplier = 3.0;
  static const recentLimit = 5;

  /// With 3× payout, p ≈ 0.308 yields RTP ≈ 92.4%.
  static const winProbability = rtpPercent / (winMultiplier * 100);

  static const _balanceKey = 'simulator_balance';
  static const _outcomesKey = 'simulator_recent_outcomes';

  final SharedPreferences _prefs;
  Random _random = Random();

  @visibleForTesting
  set debugRandom(Random value) => _random = value;

  Future<double> getBalance() async {
    return _prefs.getDouble(_balanceKey) ?? startingBalance;
  }

  Future<List<bool>> getRecentOutcomes() async {
    final raw = _prefs.getString(_outcomesKey);
    if (raw == null || raw.isEmpty) return [];
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded.map((e) => e as bool).toList();
  }

  Future<SimulatorStatsDto> fetchStats() async {
    final outcomes = await getRecentOutcomes();
    final wins = outcomes.where((w) => w).length;
    return SimulatorStatsDto(
      balance: await getBalance(),
      rtpPercent: rtpPercent,
      houseMarginPercent: houseMarginPercent,
      avgLossPerHour: avgLossPerHour,
      recentWins: wins,
      recentOutcomes: outcomes,
    );
  }

  Future<SpinResultDto> spin({double betAmount = defaultBet}) async {
    final balance = await getBalance();
    if (balance < betAmount) {
      throw StateError('insufficient_balance');
    }

    final isWin = _random.nextDouble() < winProbability;
    final payout = isWin ? betAmount * winMultiplier : 0.0;
    final balanceAfter = balance - betAmount + payout;
    final symbols = _symbolsForOutcome(isWin);

    await _prefs.setDouble(_balanceKey, balanceAfter);
    await _appendOutcome(isWin);

    return SpinResultDto(
      symbolIndexes: symbols,
      isWin: isWin,
      payout: payout,
      balanceAfter: balanceAfter,
      betAmount: betAmount,
    );
  }

  List<int> _symbolsForOutcome(bool isWin) {
    final symbolCount = AssetPaths.reelSymbols.length;
    if (isWin) {
      final match = _random.nextInt(symbolCount);
      return [match, match, match];
    }

    final left = _random.nextInt(symbolCount);
    var center = _random.nextInt(symbolCount);
    if (center == left) {
      center = (center + 1) % symbolCount;
    }
    var right = _random.nextInt(symbolCount);
    while (right == left || right == center) {
      right = (right + 1) % symbolCount;
    }
    return [left, center, right];
  }

  Future<void> _appendOutcome(bool isWin) async {
    final outcomes = await getRecentOutcomes();
    outcomes.add(isWin);
    while (outcomes.length > recentLimit) {
      outcomes.removeAt(0);
    }
    await _prefs.setString(_outcomesKey, jsonEncode(outcomes));
  }
}
