import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../design_system/widget/bo_theme.dart';
import '../../../di/injection.dart';
import 'bloc/simulator_bloc.dart';
import 'widgets/hotline_banner.dart';
import 'widgets/intent_banner.dart';
import 'widgets/simulator_reels.dart';
import 'widgets/spin_button.dart';
import 'widgets/stats_card.dart';
import 'widgets/zero_balance_dialog.dart';

class SimulatorScreen extends StatelessWidget {
  const SimulatorScreen({super.key});

  static const routeName = '/simulator';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<SimulatorBloc>()..add(const SimulatorStarted()),
      child: const _SimulatorView(),
    );
  }
}

class _SimulatorView extends StatelessWidget {
  const _SimulatorView();

  String _resolveMessage(AppLocalizations l10n, String? key) {
    return switch (key) {
      'spinResultWin' => l10n.spinResultWin,
      'spinResultLoss' => l10n.spinResultLoss,
      'insufficientBalance' => l10n.insufficientBalance,
      'simulatorLoadError' => l10n.simulatorLoadError,
      'simulatorSpinError' => l10n.simulatorSpinError,
      _ => '',
    };
  }

  String _formatBalance(double value) {
    return '\$ ${value.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SafeArea(
      child: BlocConsumer<SimulatorBloc, SimulatorState>(
        listenWhen: (previous, current) {
          final wasShowing = previous is SimulatorIdle && previous.showBalanceAlarm;
          final isShowing = current is SimulatorIdle && current.showBalanceAlarm;
          return isShowing && !wasShowing;
        },
        listener: (context, state) {
          if (state is! SimulatorIdle || !state.showBalanceAlarm) return;
          showDialog<void>(
            context: context,
            barrierDismissible: false,
            barrierColor: Colors.black54,
            builder: (dialogContext) {
              return ZeroBalanceDialog(
                onRecharge: () {
                  Navigator.of(dialogContext).pop();
                  context
                      .read<SimulatorBloc>()
                      .add(const RechargePressed());
                },
              );
            },
          );
        },
        builder: (context, state) {
          if (state is SimulatorLoading || state is SimulatorInitial) {
            return Center(child: Text(l10n.loading));
          }

          if (state is SimulatorFailure) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_resolveMessage(l10n, state.messageKey)),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () {
                      context
                          .read<SimulatorBloc>()
                          .add(const SimulatorStarted());
                    },
                    child: Text(l10n.retry),
                  ),
                ],
              ),
            );
          }

          if (state is! SimulatorIdle) {
            return const SizedBox.shrink();
          }

          final resultMessage = state.isSpinning
              ? l10n.spinningMessage
              : _resolveMessage(
                  l10n,
                  state.lastResult?.resultMessageKey,
                );

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Row(
                  children: [
                    Icon(Icons.bar_chart, color: BoColors.navy, size: 22),
                    const SizedBox(width: 6),
                    Text(
                      l10n.appTitle,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: BoColors.navy,
                          ),
                    ),
                    const Spacer(),
                    Text(
                      '${l10n.balanceLabel} ${_formatBalance(state.displayBalance)}',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: BoColors.navy,
                          ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 88),
                  children: [
                    const IntentBanner(),
                    const SizedBox(height: 16),
                    StatsCard(stats: state.stats),
                    const SizedBox(height: 16),
                    Text(
                      l10n.outcomeGridTitle,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            letterSpacing: 1.1,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey.shade700,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: SimulatorReels(
                        targetSymbols: state.pendingResult?.symbolIndexes ??
                            state.lastResult?.symbolIndexes,
                        isSpinning: state.isSpinning,
                        onSpinComplete: () {
                          context
                              .read<SimulatorBloc>()
                              .add(const SpinAnimationCompleted());
                        },
                      ),
                    ),
                    if (resultMessage.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: BoColors.infoBanner,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          resultMessage,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: BoColors.navy, height: 1.35),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    const HotlineBanner(),
                    const SizedBox(height: 16),
                    SpinButton(
                      enabled: !state.isSpinning &&
                          state.displayBalance >= 50,
                      onPressed: () {
                        context
                            .read<SimulatorBloc>()
                            .add(const SpinPressed());
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
