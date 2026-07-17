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

  /// Target long-run RTP ~92.4% with 3× payout ⇒ p ≈ 0.308.
  static const targetRtpPercent = 92.4;
  static const winProbability = targetRtpPercent / (winMultiplier * 100);

  static const _balanceKey = 'simulator_balance_v2';
  static const _outcomesKey = 'simulator_recent_outcomes_v2';
  static const _wageredKey = 'simulator_total_wagered_v2';
  static const _returnedKey = 'simulator_total_returned_v2';
  static const _sessionStartedKey = 'simulator_session_started_ms_v2';

  final SharedPreferences _prefs;
  Random _random = Random();

  @visibleForTesting
  set debugRandom(Random value) => _random = value;

  @visibleForTesting
  set debugNowMs(int? value) => _nowMsOverride = value;

  int? _nowMsOverride;

  int get _nowMs => _nowMsOverride ?? DateTime.now().millisecondsSinceEpoch;

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

  Future<SimulatorStatsDto> fetchStats() async {
    final outcomes = await getRecentOutcomes();
    final wins = outcomes.where((w) => w).length;
    final wagered = await getTotalWagered();
    final returned = await getTotalReturned();

    final rtpPercent = wagered <= 0 ? 0.0 : (returned / wagered) * 100;
    final houseMarginPercent = wagered <= 0 ? 0.0 : 100 - rtpPercent;
    final avgLossPerHour = await _avgLossPerHour(
      netLoss: wagered - returned,
    );

    return SimulatorStatsDto(
      balance: await getBalance(),
      rtpPercent: rtpPercent,
      houseMarginPercent: houseMarginPercent,
      avgLossPerHour: avgLossPerHour,
      recentWins: wins,
      recentOutcomes: outcomes,
    );
  }

  Future<double> _avgLossPerHour({required double netLoss}) async {
    final startedAt = _prefs.getInt(_sessionStartedKey);
    if (startedAt == null || netLoss <= 0) return 0;

    final elapsedMs = (_nowMs - startedAt).clamp(0, 1 << 62);
    // Use at least 1 minute so short demos don't explode the rate.
    final elapsedHours = max(elapsedMs / 3600000.0, 1 / 60.0);
    return netLoss / elapsedHours;
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
    await _appendOutcome(isWin);

    return SpinResultDto(
      symbolIndexes: symbols,
      isWin: isWin,
      payout: payout,
      balanceAfter: balanceAfter,
      betAmount: betAmount,
    );
  }

  Future<void> _ensureSessionStarted() async {
    if (_prefs.getInt(_sessionStartedKey) == null) {
      await _prefs.setInt(_sessionStartedKey, _nowMs);
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
