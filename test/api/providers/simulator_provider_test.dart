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
        balanceAfter: 10100,
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
        balanceAfter: 9950,
        betAmount: 50,
      );

      final vo = SpinResultMapper().toViewObject(dto);

      expect(vo.isWin, isFalse);
      expect(vo.resultMessageKey, 'spinResultLoss');
    });
  });

  group('SimulatorProvider', () {
    test('starts with default balance and stats', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final provider = SimulatorProvider(prefs)..debugRandom = Random(1);

      final stats = await provider.fetchStats();

      expect(stats.balance, SimulatorProvider.startingBalance);
      expect(stats.rtpPercent, 92.4);
      expect(stats.houseMarginPercent, 7.6);
      expect(stats.recentOutcomes, isEmpty);
    });

    test('spin deducts bet and updates balance', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final provider = SimulatorProvider(prefs)..debugRandom = Random(42);

      final result = await provider.spin(betAmount: 50);

      expect(result.betAmount, 50);
      expect(result.symbolIndexes, hasLength(3));
      if (result.isWin) {
        expect(result.payout, 150);
        expect(result.balanceAfter, 10100);
        expect(result.symbolIndexes.toSet(), hasLength(1));
      } else {
        expect(result.payout, 0);
        expect(result.balanceAfter, 9950);
        expect(result.symbolIndexes.toSet().length, greaterThan(1));
      }
    });

    test('throws when balance is insufficient', () async {
      SharedPreferences.setMockInitialValues({
        'simulator_balance': 10.0,
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
