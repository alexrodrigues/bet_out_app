import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../design_system/widget/bo_theme.dart';

class IntentBanner extends StatelessWidget {
  const IntentBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: BoColors.infoBanner,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: BoColors.navy.withValues(alpha: 0.8)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              l10n.simulatorIntent,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: BoColors.navy,
                    height: 1.35,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
