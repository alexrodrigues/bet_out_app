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
    this.errorMessageKey,
  });

  final SimulatorStatsViewObject stats;
  final double displayBalance;
  final SpinResultViewObject? lastResult;
  final SpinResultViewObject? pendingResult;
  final bool isSpinning;
  final String? errorMessageKey;

  @override
  List<Object?> get props => [
        stats,
        displayBalance,
        lastResult,
        pendingResult,
        isSpinning,
        errorMessageKey,
      ];
}

final class SimulatorFailure extends SimulatorState {
  const SimulatorFailure({required this.messageKey});

  final String messageKey;

  @override
  List<Object?> get props => [messageKey];
}
