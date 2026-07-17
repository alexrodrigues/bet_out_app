import 'dart:math';

import 'package:bet_out_app/api/mappers/spin_result_mapper.dart';
import 'package:bet_out_app/api/model/spin_result_dto.dart';
import 'package:bet_out_app/api/providers/simulator_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      expect(stats.houseMarginPercent, 0);
      expect(stats.avgLossPerHour, 0);
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
        expect(stats.houseMarginPercent, -200);
      } else {
        expect(result.payout, 0);
        expect(result.balanceAfter, 100);
        expect(stats.rtpPercent, 0);
        expect(stats.houseMarginPercent, 100);
        expect(stats.avgLossPerHour, greaterThan(0));
      }
    });

    test('computes live RTP from wagered and returned', () async {
      SharedPreferences.setMockInitialValues({
        'simulator_balance_v2': 150.0,
        'simulator_total_wagered_v2': 100.0,
        'simulator_total_returned_v2': 50.0,
        'simulator_session_started_ms_v2': 0,
      });
      final prefs = await SharedPreferences.getInstance();
      final provider = SimulatorProvider(prefs)
        ..debugRandom = Random(1)
        ..debugNowMs = 3600000; // 1 hour later

      final stats = await provider.fetchStats();

      expect(stats.rtpPercent, 50);
      expect(stats.houseMarginPercent, 50);
      expect(stats.avgLossPerHour, 50);
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
