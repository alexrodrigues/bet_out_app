part of 'simulator_bloc.dart';

sealed class SimulatorState extends Equatable {
  const SimulatorState();

  @override
  List<Object?> get props => [];
}

final class SimulatorInitial extends SimulatorState {
  const SimulatorInitial();
}

final class SimulatorLoading extends SimulatorState {
  const SimulatorLoading();
}

final class SimulatorIdle extends SimulatorState {
  const SimulatorIdle({
    required this.stats,
    required this.displayBalance,
    this.lastResult,
    this.pendingResult,
    this.isSpinning = false,
    this.showBalanceAlarm = false,
  });

  final SimulatorStatsViewObject stats;
  final double displayBalance;
  final SpinResultViewObject? lastResult;
  final SpinResultViewObject? pendingResult;
  final bool isSpinning;
  final bool showBalanceAlarm;

  @override
  List<Object?> get props => [
        stats,
        displayBalance,
        lastResult,
        pendingResult,
        isSpinning,
        showBalanceAlarm,
      ];
}

final class SimulatorFailure extends SimulatorState {
  const SimulatorFailure({required this.messageKey});

  final String messageKey;

  @override
  List<Object?> get props => [messageKey];
}
