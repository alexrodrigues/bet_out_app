import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../design_system/widget/bo_theme.dart';

class HotlineBanner extends StatelessWidget {
  const HotlineBanner({super.key});

  static final Uri _safemindUri = Uri.parse('https://safemind.app.br/');

  Future<void> _openSafemind(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final opened = await launchUrl(
      _safemindUri,
      mode: LaunchMode.externalApplication,
    );
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.unableToOpenLink)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Secondary from purple seed (same approach as Safemind; not a separate brand color).
    final purpleScheme = ColorScheme.fromSeed(seedColor: Colors.purple);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: BoColors.helpBanner,
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
            onPressed: () => _openSafemind(context),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: purpleScheme.secondary,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Text(l10n.learnMore),
          ),
        ],
      ),
    );
  }
}
