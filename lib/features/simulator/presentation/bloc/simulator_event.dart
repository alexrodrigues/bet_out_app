part of 'simulator_bloc.dart';

sealed class SimulatorEvent extends Equatable {
  const SimulatorEvent();

  @override
  List<Object?> get props => [];
}

final class SimulatorStarted extends SimulatorEvent {
  const SimulatorStarted();
}

final class SpinPressed extends SimulatorEvent {
  const SpinPressed();
}

final class SpinAnimationCompleted extends SimulatorEvent {
  const SpinAnimationCompleted();
}
