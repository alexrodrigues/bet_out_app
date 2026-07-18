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

  static const startingBalance = 150.0;
  static const defaultBet = 50.0;
  static const winMultiplier = 3.0;
  static const recentLimit = 5;

  /// Displayed house margin (fixed educational figure).
  static const houseMarginPercent = 15.0;

  /// Target long-run RTP = 100 − house margin, with 3× payout.
  static const targetRtpPercent = 100.0 - houseMarginPercent;
  static const winProbability = targetRtpPercent / (winMultiplier * 100);

  static const _balanceKey = 'simulator_balance_v2';
  static const _outcomesKey = 'simulator_recent_outcomes_v2';
  static const _wageredKey = 'simulator_total_wagered_v2';
  static const _returnedKey = 'simulator_total_returned_v2';
  static const _totalLostKey = 'simulator_total_lost_v2';
  static const _sessionStartedKey = 'simulator_session_started_ms_v2';

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

  Future<double> getTotalWagered() async {
    return _prefs.getDouble(_wageredKey) ?? 0;
  }

  Future<double> getTotalReturned() async {
    return _prefs.getDouble(_returnedKey) ?? 0;
  }

  Future<double> getTotalLost() async {
    return _prefs.getDouble(_totalLostKey) ?? 0;
  }

  Future<SimulatorStatsDto> fetchStats() async {
    final outcomes = await getRecentOutcomes();
    final wins = outcomes.where((w) => w).length;
    final wagered = await getTotalWagered();
    final returned = await getTotalReturned();

    final rtpPercent = wagered <= 0 ? 0.0 : (returned / wagered) * 100;
    // Cumulative stake lost on losing spins only (never decreases on wins).
    final totalLoss = await getTotalLost();

    return SimulatorStatsDto(
      balance: await getBalance(),
      rtpPercent: rtpPercent,
      houseMarginPercent: houseMarginPercent,
      totalLoss: totalLoss,
      recentWins: wins,
      recentOutcomes: outcomes,
    );
  }

  Future<SpinResultDto> spin({double betAmount = defaultBet}) async {
    final balance = await getBalance();
    if (balance < betAmount) {
      throw StateError('insufficient_balance');
    }

    await _ensureSessionStarted();

    final isWin = _random.nextDouble() < winProbability;
    final payout = isWin ? betAmount * winMultiplier : 0.0;
    final balanceAfter = balance - betAmount + payout;
    final symbols = _symbolsForOutcome(isWin);

    await _prefs.setDouble(_balanceKey, balanceAfter);
    await _prefs.setDouble(
      _wageredKey,
      (await getTotalWagered()) + betAmount,
    );
    await _prefs.setDouble(
      _returnedKey,
      (await getTotalReturned()) + payout,
    );
    if (!isWin) {
      await _prefs.setDouble(
        _totalLostKey,
        (await getTotalLost()) + betAmount,
      );
    }
    await _appendOutcome(isWin);

    return SpinResultDto(
      symbolIndexes: symbols,
      isWin: isWin,
      payout: payout,
      balanceAfter: balanceAfter,
      betAmount: betAmount,
    );
  }

  /// Restores starting balance and clears all session counters.
  Future<void> resetSession() async {
    await _prefs.setDouble(_balanceKey, startingBalance);
    await _prefs.remove(_outcomesKey);
    await _prefs.remove(_wageredKey);
    await _prefs.remove(_returnedKey);
    await _prefs.remove(_totalLostKey);
    await _prefs.remove(_sessionStartedKey);
  }

  Future<void> _ensureSessionStarted() async {
    if (_prefs.getInt(_sessionStartedKey) == null) {
      await _prefs.setInt(
        _sessionStartedKey,
        DateTime.now().millisecondsSinceEpoch,
      );
    }
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
