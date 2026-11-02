import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kannada_plaza/l10n/generated/app_localizations.dart';
import 'package:kannada_plaza/l10n/language_option.dart';
import 'package:kannada_plaza/screens/setup.dart';

void main() {
  testWidgets('shows all supported languages and continues on NEXT', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1000, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    var didContinue = false;
    Locale selectedLocale = const Locale('en');
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: LanguageSelectScreen(
          selectedLocale: selectedLocale,
          onLocaleSelected: (locale) => selectedLocale = locale,
          onNext: () => didContinue = true,
          onUserInteraction: () {},
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('SELECT YOUR PREFERRED LANGUAGE'), findsOneWidget);
    for (final option in LanguageOption.all) {
      expect(find.text(option.displayName), findsOneWidget);
    }

    await tester.tap(find.text('Tamil (தமிழ்)'));
    await tester.pump();
    expect(selectedLocale, const Locale('ta', 'IN'));

    await tester.tap(find.text('NEXT'));
    expect(didContinue, isTrue);
  });

  testWidgets('name entry accepts only letters before continuing', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1000, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    String? submittedName;
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: NameEntryScreen(
          onNext: (name) => submittedName = name,
          onUserInteraction: () {},
        ),
      ),
    );

    expect(find.text('ENTER YOUR NAME:'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Riya123!');
    await tester.pump();
    await tester.tap(find.text('NEXT'));

    expect(submittedName, 'Riya');
  });
}
