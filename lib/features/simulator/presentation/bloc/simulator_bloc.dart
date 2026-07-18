import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../api/providers/simulator_provider.dart';
import '../../../../design_system/model/spin_result_view_object.dart';
import '../../domain/get_simulator_stats_usecase.dart';
import '../../domain/reset_simulator_usecase.dart';
import '../../domain/spin_simulator_usecase.dart';

part 'simulator_event.dart';
part 'simulator_state.dart';

@injectable
class SimulatorBloc extends Bloc<SimulatorEvent, SimulatorState> {
  SimulatorBloc(
    this._spinSimulator,
    this._getStats,
    this._resetSimulator,
  ) : super(const SimulatorInitial()) {
    on<SimulatorStarted>(_onStarted);
    on<SpinPressed>(_onSpinPressed);
    on<SpinAnimationCompleted>(_onSpinAnimationCompleted);
    on<BalanceAlarmDismissed>(_onBalanceAlarmDismissed);
    on<RechargePressed>(_onRechargePressed);
  }

  final SpinSimulatorUsecase _spinSimulator;
  final GetSimulatorStatsUsecase _getStats;
  final ResetSimulatorUsecase _resetSimulator;

  Future<void> _onStarted(
    SimulatorStarted event,
    Emitter<SimulatorState> emit,
  ) async {
    emit(const SimulatorLoading());
    try {
      final stats = await _getStats.invoke();
      emit(
        SimulatorIdle(
          stats: stats,
          lastResult: null,
          displayBalance: stats.balance,
          showBalanceAlarm: stats.balance < SimulatorProvider.defaultBet,
        ),
      );
    } catch (_) {
      emit(const SimulatorFailure(messageKey: 'simulatorLoadError'));
    }
  }

  Future<void> _onSpinPressed(
    SpinPressed event,
    Emitter<SimulatorState> emit,
  ) async {
    final current = state;
    if (current is! SimulatorIdle || current.isSpinning) return;

    try {
      final result = await _spinSimulator.invoke(
        betAmount: SimulatorProvider.defaultBet,
      );
      // Refresh stats immediately so "Perda total" updates without waiting
      // for the reel animation to finish.
      final stats = await _getStats.invoke();
      emit(
        SimulatorIdle(
          stats: stats,
          lastResult: result,
          displayBalance: current.displayBalance,
          isSpinning: true,
          pendingResult: result,
        ),
      );
    } on StateError catch (e) {
      if (e.message == 'insufficient_balance') {
        emit(
          SimulatorIdle(
            stats: current.stats,
            lastResult: current.lastResult,
            displayBalance: current.displayBalance,
            showBalanceAlarm: true,
          ),
        );
      } else {
        emit(const SimulatorFailure(messageKey: 'simulatorSpinError'));
      }
    } catch (_) {
      emit(const SimulatorFailure(messageKey: 'simulatorSpinError'));
    }
  }

  Future<void> _onSpinAnimationCompleted(
    SpinAnimationCompleted event,
    Emitter<SimulatorState> emit,
  ) async {
    final current = state;
    if (current is! SimulatorIdle || current.pendingResult == null) return;

    final pending = current.pendingResult!;
    final broke =
        pending.balanceAfter < SimulatorProvider.defaultBet;

    try {
      final stats = await _getStats.invoke();
      emit(
        SimulatorIdle(
          stats: stats,
          lastResult: pending,
          displayBalance: stats.balance,
          showBalanceAlarm: broke,
        ),
      );
    } catch (_) {
      emit(
        SimulatorIdle(
          stats: current.stats,
          lastResult: pending,
          displayBalance: pending.balanceAfter,
          showBalanceAlarm: broke,
        ),
      );
    }
  }

  void _onBalanceAlarmDismissed(
    BalanceAlarmDismissed event,
    Emitter<SimulatorState> emit,
  ) {
    final current = state;
    if (current is! SimulatorIdle || !current.showBalanceAlarm) return;
    emit(
      SimulatorIdle(
        stats: current.stats,
        displayBalance: current.displayBalance,
        lastResult: current.lastResult,
      ),
    );
  }

  Future<void> _onRechargePressed(
    RechargePressed event,
    Emitter<SimulatorState> emit,
  ) async {
    final current = state;
    if (current is! SimulatorIdle) return;

    try {
      final stats = await _resetSimulator.invoke();
      emit(
        SimulatorIdle(
          stats: stats,
          displayBalance: stats.balance,
          lastResult: null,
          pendingResult: null,
          showBalanceAlarm: false,
        ),
      );
    } catch (_) {
      emit(const SimulatorFailure(messageKey: 'simulatorLoadError'));
    }
  }
}
