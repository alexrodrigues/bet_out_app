import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/localization/app_localizations.dart';
import 'core/services/navigation_service.dart';
import 'design_system/widget/bo_theme.dart';
import 'di/injection.dart';
import 'features/login/presentation/login_screen.dart';
import 'features/shell/presentation/app_shell_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await configureDependencies();
  runApp(const BetOutApp());
}

class BetOutApp extends StatelessWidget {
  const BetOutApp({super.key});

  @override
  Widget build(BuildContext context) {
    final navigation = getIt<NavigationService>();

    return MaterialApp(
      title: 'ForaDaBet',
      theme: BoTheme.light(),
      navigatorKey: navigation.navigatorKey,
      locale: const Locale('pt'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      initialRoute: AppShellScreen.routeName,
      routes: {
        AppShellScreen.routeName: (_) => const AppShellScreen(),
        LoginScreen.routeName: (_) => const LoginScreen(),
      },
    );
  }
}
