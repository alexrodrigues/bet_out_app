import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../design_system/model/spin_result_view_object.dart';
import '../../../../design_system/widget/bo_theme.dart';

class StatsCard extends StatelessWidget {
  const StatsCard({super.key, required this.stats});

  final SimulatorStatsViewObject stats;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final winRate = stats.winRatePercent.clamp(0, 100) / 100;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.statisticalReality,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: BoColors.navy,
                ),
          ),
          const SizedBox(height: 12),
          _StatRow(
            label: l10n.houseMarginLabel,
            value: '${stats.houseMarginPercent.toStringAsFixed(1)}%',
            valueColor: BoColors.houseMargin,
          ),
          _StatRow(
            label: l10n.totalLossLabel,
            value: '\$ ${stats.totalLoss.toStringAsFixed(0)}',
          ),
          const SizedBox(height: 16),
          Text(
            l10n.lastFiveSessions,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: BoColors.navy,
                ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: winRate.toDouble(),
              minHeight: 8,
              backgroundColor: Colors.grey.shade300,
              color: BoColors.winRateFill,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.winLossRatio(stats.winRatePercent.toStringAsFixed(0)),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade700,
                ),
          ),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade700,
                  ),
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: valueColor ?? BoColors.navy,
                ),
          ),
        ],
      ),
    );
  }
}
