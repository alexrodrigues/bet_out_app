import 'package:bet_out_app/core/localization/app_localizations.dart';
import 'package:bet_out_app/di/injection.dart';
import 'package:bet_out_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await configureDependencies();
  });

  testWidgets('BetOutApp opens shell on simulator tab', (tester) async {
    await tester.pumpWidget(const BetOutApp());
    await tester.pumpAndSettle();

    expect(find.textContaining('RANDOMIZED'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.textContaining('SPIN'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('SPIN'), findsWidgets);
  });

  testWidgets('localization resolves brand', (tester) async {
    final en = await AppLocalizations.delegate.load(const Locale('en'));
    final pt = await AppLocalizations.delegate.load(const Locale('pt'));

    expect(en.appTitle, 'Bet Out');
    expect(pt.appTitle, 'ForaDaBet');
  });
}
