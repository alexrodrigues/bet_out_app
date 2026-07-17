import 'package:bet_out_app/api/providers/simulator_provider.dart';
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
    balance: 150,
    rtpPercent: 0,
    houseMarginPercent: 15,
    totalLoss: 0,
    winRatePercent: 0,
    recentOutcomes: [],
  );

  const spinResult = SpinResultViewObject(
    symbolIndexes: [0, 1, 2],
    isWin: false,
    payout: 0,
    balanceAfter: 100,
    betAmount: 50,
    resultMessageKey: 'spinResultLoss',
  );

  const statsAfter = SimulatorStatsViewObject(
    balance: 100,
    rtpPercent: 0,
    houseMarginPercent: 15,
    totalLoss: 50,
    winRatePercent: 0,
    recentOutcomes: [false],
  );

  const brokeResult = SpinResultViewObject(
    symbolIndexes: [0, 1, 2],
    isWin: false,
    payout: 0,
    balanceAfter: 0,
    betAmount: 50,
    resultMessageKey: 'spinResultLoss',
  );

  const brokeStats = SimulatorStatsViewObject(
    balance: 0,
    rtpPercent: 0,
    houseMarginPercent: 15,
    totalLoss: 150,
    winRatePercent: 0,
    recentOutcomes: [false, false, false],
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
        displayBalance: 150,
      ),
    ],
  );

  blocTest<SimulatorBloc, SimulatorState>(
    'spin then animation complete updates balance',
    build: () {
      when(() => statsUsecase.invoke()).thenAnswer((_) async => statsAfter);
      when(() => spinUsecase.invoke(betAmount: 50))
          .thenAnswer((_) async => spinResult);
      return SimulatorBloc(spinUsecase, statsUsecase);
    },
    seed: () => const SimulatorIdle(
      stats: stats,
      displayBalance: 150,
    ),
    act: (bloc) async {
      bloc.add(const SpinPressed());
      await Future<void>.delayed(Duration.zero);
      when(() => statsUsecase.invoke()).thenAnswer((_) async => statsAfter);
      bloc.add(const SpinAnimationCompleted());
    },
    expect: () => [
      const SimulatorIdle(
        stats: statsAfter,
        displayBalance: 150,
        lastResult: spinResult,
        pendingResult: spinResult,
        isSpinning: true,
      ),
      const SimulatorIdle(
        stats: statsAfter,
        displayBalance: 100,
        lastResult: spinResult,
      ),
    ],
  );

  blocTest<SimulatorBloc, SimulatorState>(
    'shows balance alarm when animation ends below bet',
    build: () {
      when(() => spinUsecase.invoke(betAmount: 50))
          .thenAnswer((_) async => brokeResult);
      when(() => statsUsecase.invoke()).thenAnswer((_) async => brokeStats);
      return SimulatorBloc(spinUsecase, statsUsecase);
    },
    seed: () => const SimulatorIdle(
      stats: stats,
      displayBalance: 50,
      lastResult: brokeResult,
      pendingResult: brokeResult,
      isSpinning: true,
    ),
    act: (bloc) => bloc.add(const SpinAnimationCompleted()),
    expect: () => [
      const SimulatorIdle(
        stats: brokeStats,
        displayBalance: 0,
        lastResult: brokeResult,
        showBalanceAlarm: true,
      ),
    ],
  );

  blocTest<SimulatorBloc, SimulatorState>(
    'insufficient balance sets alarm flag',
    build: () {
      when(() => spinUsecase.invoke(betAmount: SimulatorProvider.defaultBet))
          .thenThrow(StateError('insufficient_balance'));
      return SimulatorBloc(spinUsecase, statsUsecase);
    },
    seed: () => const SimulatorIdle(
      stats: brokeStats,
      displayBalance: 0,
    ),
    act: (bloc) => bloc.add(const SpinPressed()),
    expect: () => [
      const SimulatorIdle(
        stats: brokeStats,
        displayBalance: 0,
        showBalanceAlarm: true,
      ),
    ],
  );
}
