import 'package:bet_out_app/design_system/model/spin_result_view_object.dart';
import 'package:bet_out_app/features/simulator/domain/get_simulator_stats_usecase.dart';
import 'package:bet_out_app/features/simulator/domain/spin_simulator_usecase.dart';
import 'package:bet_out_app/features/simulator/presentation/bloc/simulator_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockSpinUsecase extends Mock implements SpinSimulatorUsecase {}

class _MockStatsUsecase extends Mock implements GetSimulatorStatsUsecase {}

void main() {
  late _MockSpinUsecase spinUsecase;
  late _MockStatsUsecase statsUsecase;

  const stats = SimulatorStatsViewObject(
    balance: 10000,
    rtpPercent: 92.4,
    houseMarginPercent: 7.6,
    avgLossPerHour: 42.5,
    winRatePercent: 0,
    recentOutcomes: [],
  );

  const spinResult = SpinResultViewObject(
    symbolIndexes: [0, 1, 2],
    isWin: false,
    payout: 0,
    balanceAfter: 9950,
    betAmount: 50,
    resultMessageKey: 'spinResultLoss',
  );

  const statsAfter = SimulatorStatsViewObject(
    balance: 9950,
    rtpPercent: 92.4,
    houseMarginPercent: 7.6,
    avgLossPerHour: 42.5,
    winRatePercent: 0,
    recentOutcomes: [false],
  );

  setUp(() {
    spinUsecase = _MockSpinUsecase();
    statsUsecase = _MockStatsUsecase();
  });

  blocTest<SimulatorBloc, SimulatorState>(
    'loads stats on start',
    build: () {
      when(() => statsUsecase.invoke()).thenAnswer((_) async => stats);
      return SimulatorBloc(spinUsecase, statsUsecase);
    },
    act: (bloc) => bloc.add(const SimulatorStarted()),
    expect: () => [
      const SimulatorLoading(),
      const SimulatorIdle(
        stats: stats,
        displayBalance: 10000,
      ),
    ],
  );

  blocTest<SimulatorBloc, SimulatorState>(
    'spin then animation complete updates balance',
    build: () {
      when(() => statsUsecase.invoke()).thenAnswer((_) async => stats);
      when(() => spinUsecase.invoke(betAmount: 50))
          .thenAnswer((_) async => spinResult);
      return SimulatorBloc(spinUsecase, statsUsecase);
    },
    seed: () => const SimulatorIdle(
      stats: stats,
      displayBalance: 10000,
    ),
    act: (bloc) async {
      bloc.add(const SpinPressed());
      await Future<void>.delayed(Duration.zero);
      when(() => statsUsecase.invoke()).thenAnswer((_) async => statsAfter);
      bloc.add(const SpinAnimationCompleted());
    },
    expect: () => [
      const SimulatorIdle(
        stats: stats,
        displayBalance: 10000,
        lastResult: spinResult,
        pendingResult: spinResult,
        isSpinning: true,
      ),
      const SimulatorIdle(
        stats: statsAfter,
        displayBalance: 9950,
        lastResult: spinResult,
      ),
    ],
  );
}
