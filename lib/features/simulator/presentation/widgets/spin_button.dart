import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../design_system/widget/bo_theme.dart';

class SpinButton extends StatelessWidget {
  const SpinButton({
    super.key,
    required this.onPressed,
    required this.enabled,
  });

  final VoidCallback? onPressed;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: LinearGradient(
                colors: enabled
                    ? const [BoColors.spinStart, BoColors.spinEnd]
                    : [
                        BoColors.spinStart.withValues(alpha: 0.45),
                        BoColors.spinEnd.withValues(alpha: 0.45),
                      ],
              ),
              boxShadow: enabled
                  ? [
                      BoxShadow(
                        color: BoColors.spinStart.withValues(alpha: 0.45),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ]
                  : null,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: enabled ? onPressed : null,
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, color: Colors.white),
                      const SizedBox(width: 8),
                      Text(
                        l10n.spinButton,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.spinCostHint,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade600,
              ),
        ),
      ],
    );
  }
}
