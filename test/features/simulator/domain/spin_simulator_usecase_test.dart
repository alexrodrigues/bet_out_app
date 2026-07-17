import 'package:bet_out_app/api/mappers/spin_result_mapper.dart';
import 'package:bet_out_app/api/model/simulator_stats_dto.dart';
import 'package:bet_out_app/api/model/spin_result_dto.dart';
import 'package:bet_out_app/api/providers/simulator_provider.dart';
import 'package:bet_out_app/design_system/model/spin_result_view_object.dart';
import 'package:bet_out_app/features/simulator/domain/get_simulator_stats_usecase.dart';
import 'package:bet_out_app/features/simulator/domain/spin_simulator_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockSimulatorProvider extends Mock implements SimulatorProvider {}

class _MockSpinResultMapper extends Mock implements SpinResultMapper {}

void main() {
  group('SpinSimulatorUsecaseImpl', () {
    late _MockSimulatorProvider provider;
    late _MockSpinResultMapper mapper;
    late SpinSimulatorUsecaseImpl usecase;

    setUp(() {
      provider = _MockSimulatorProvider();
      mapper = _MockSpinResultMapper();
      usecase = SpinSimulatorUsecaseImpl(provider, mapper);
    });

    test('invokes provider and maps result', () async {
      const dto = SpinResultDto(
        symbolIndexes: [2, 2, 2],
        isWin: true,
        payout: 150,
        balanceAfter: 10100,
        betAmount: 50,
      );
      const view = SpinResultViewObject(
        symbolIndexes: [2, 2, 2],
        isWin: true,
        payout: 150,
        balanceAfter: 10100,
        betAmount: 50,
        resultMessageKey: 'spinResultWin',
      );

      when(() => provider.spin(betAmount: 50)).thenAnswer((_) async => dto);
      when(() => mapper.toViewObject(dto)).thenReturn(view);

      final result = await usecase.invoke(betAmount: 50);

      expect(result, view);
      verify(() => provider.spin(betAmount: 50)).called(1);
      verify(() => mapper.toViewObject(dto)).called(1);
    });
  });

  group('GetSimulatorStatsUsecaseImpl', () {
    late _MockSimulatorProvider provider;
    late _MockSpinResultMapper mapper;
    late GetSimulatorStatsUsecaseImpl usecase;

    setUp(() {
      provider = _MockSimulatorProvider();
      mapper = _MockSpinResultMapper();
      usecase = GetSimulatorStatsUsecaseImpl(provider, mapper);
    });

    test('invokes provider and maps stats', () async {
      const dto = SimulatorStatsDto(
        balance: 10000,
        rtpPercent: 92.4,
        houseMarginPercent: 15,
        totalLoss: 42.5,
        recentWins: 1,
        recentOutcomes: [true, false, false, false, false],
      );
      const view = SimulatorStatsViewObject(
        balance: 10000,
        rtpPercent: 92.4,
        houseMarginPercent: 15,
        totalLoss: 42.5,
        winRatePercent: 20,
        recentOutcomes: [true, false, false, false, false],
      );

      when(() => provider.fetchStats()).thenAnswer((_) async => dto);
      when(() => mapper.toStatsViewObject(dto)).thenReturn(view);

      final result = await usecase.invoke();

      expect(result, view);
      verify(() => provider.fetchStats()).called(1);
    });
  });
}
