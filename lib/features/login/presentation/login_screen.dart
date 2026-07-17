import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  static const routeName = '/login';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.loginTitle)),
      body: Center(
        child: Text(l10n.loginPlaceholder),
      ),
    );
  }
}
