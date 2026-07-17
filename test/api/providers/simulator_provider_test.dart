import 'dart:math';

import 'package:bet_out_app/api/mappers/spin_result_mapper.dart';
import 'package:bet_out_app/api/model/spin_result_dto.dart';
import 'package:bet_out_app/api/providers/simulator_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Always returns 1.0 from [nextDouble], which is above winProbability → loss.
class _AlwaysLoseRandom implements Random {
  @override
  double nextDouble() => 1.0;

  @override
  bool nextBool() => false;

  @override
  int nextInt(int max) => 0;
}

/// Always returns 0.0 from [nextDouble], which is below winProbability → win.
class _AlwaysWinRandom implements Random {
  @override
  double nextDouble() => 0.0;

  @override
  bool nextBool() => true;

  @override
  int nextInt(int max) => 0;
}

void main() {
  group('SpinResultMapper', () {
    test('maps win result to win message key', () {
      const dto = SpinResultDto(
        symbolIndexes: [1, 1, 1],
        isWin: true,
        payout: 150,
        balanceAfter: 250,
        betAmount: 50,
      );

      final vo = SpinResultMapper().toViewObject(dto);

      expect(vo.isWin, isTrue);
      expect(vo.resultMessageKey, 'spinResultWin');
      expect(vo.symbolIndexes, [1, 1, 1]);
    });

    test('maps loss result to loss message key', () {
      const dto = SpinResultDto(
        symbolIndexes: [0, 1, 2],
        isWin: false,
        payout: 0,
        balanceAfter: 100,
        betAmount: 50,
      );

      final vo = SpinResultMapper().toViewObject(dto);

      expect(vo.isWin, isFalse);
      expect(vo.resultMessageKey, 'spinResultLoss');
    });
  });

  group('SimulatorProvider', () {
    test('starts with \$150 balance and zero live stats', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final provider = SimulatorProvider(prefs)..debugRandom = Random(1);

      final stats = await provider.fetchStats();

      expect(stats.balance, 150);
      expect(stats.rtpPercent, 0);
      expect(stats.houseMarginPercent, 15);
      expect(stats.totalLoss, 0);
      expect(stats.recentOutcomes, isEmpty);
    });

    test('spin deducts bet and updates live RTP on loss', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final provider = SimulatorProvider(prefs)..debugRandom = Random(42);

      final result = await provider.spin(betAmount: 50);
      final stats = await provider.fetchStats();

      expect(result.betAmount, 50);
      expect(result.symbolIndexes, hasLength(3));
      if (result.isWin) {
        expect(result.payout, 150);
        expect(result.balanceAfter, 250);
        // One 3× win ⇒ returned/wagered = 300% RTP for this sample.
        expect(stats.rtpPercent, 300);
        expect(stats.houseMarginPercent, 15);
        expect(stats.totalLoss, 0); // wins do not increase total loss
      } else {
        expect(result.payout, 0);
        expect(result.balanceAfter, 100);
        expect(stats.rtpPercent, 0);
        expect(stats.houseMarginPercent, 15);
        expect(stats.totalLoss, 50); // losing stake accumulated
      }
    });

    test('computes live RTP from wagered and returned', () async {
      SharedPreferences.setMockInitialValues({
        'simulator_balance_v2': 150.0,
        'simulator_total_wagered_v2': 100.0,
        'simulator_total_returned_v2': 50.0,
        'simulator_total_lost_v2': 50.0,
      });
      final prefs = await SharedPreferences.getInstance();
      final provider = SimulatorProvider(prefs)..debugRandom = Random(1);

      final stats = await provider.fetchStats();

      expect(stats.rtpPercent, 50);
      expect(stats.houseMarginPercent, 15);
      expect(stats.totalLoss, 50);
    });

    test('accumulates total loss only on losing spins', () async {
      SharedPreferences.setMockInitialValues({
        'simulator_balance_v2': 500.0,
      });
      final prefs = await SharedPreferences.getInstance();
      final provider = SimulatorProvider(prefs)..debugRandom = _AlwaysLoseRandom();

      final first = await provider.spin(betAmount: 50);
      expect(first.isWin, isFalse);
      expect((await provider.fetchStats()).totalLoss, 50);

      final second = await provider.spin(betAmount: 50);
      expect(second.isWin, isFalse);
      expect((await provider.fetchStats()).totalLoss, 100);

      provider.debugRandom = _AlwaysWinRandom();
      final win = await provider.spin(betAmount: 50);
      expect(win.isWin, isTrue);
      expect((await provider.fetchStats()).totalLoss, 100); // unchanged on win
    });

    test('throws when balance is insufficient', () async {
      SharedPreferences.setMockInitialValues({
        'simulator_balance_v2': 10.0,
      });
      final prefs = await SharedPreferences.getInstance();
      final provider = SimulatorProvider(prefs)..debugRandom = Random(1);

      expect(
        () => provider.spin(betAmount: 50),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            'insufficient_balance',
          ),
        ),
      );
    });
  });
}
