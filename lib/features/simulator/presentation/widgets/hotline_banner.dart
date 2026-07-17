import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../design_system/widget/bo_theme.dart';

class HotlineBanner extends StatelessWidget {
  const HotlineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: BoColors.navy,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.shield_outlined, color: Colors.white),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              l10n.hotlineMessage,
              style: const TextStyle(
                color: Colors.white,
                height: 1.3,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 8),
          FilledButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.hotlineComingSoon)),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: BoColors.callNow,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Text(l10n.callNow),
          ),
        ],
      ),
    );
  }
}
