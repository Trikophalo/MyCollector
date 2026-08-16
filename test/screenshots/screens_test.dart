@Tags(['screenshots'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../app_harness.dart';

/// Nimmt Bildschirmfotos der wichtigsten Screens auf.
///
/// Mit `flutter test --update-goldens test/screenshots` werden die Bilder neu
/// erzeugt; ohne den Schalter prüfen sie, dass sich die Darstellung nicht
/// unbeabsichtigt verändert hat.
void main() {
  setUpAll(loadTestFonts);

  /// Zeichnet für die Dauer eines Tests echte Schatten.
  ///
  /// Die Testumgebung stellt Schatten sonst als harte Rechtecke dar. Das Flag
  /// muss innerhalb des Testkörpers zurückgesetzt werden — Flutter prüft nach
  /// jedem Test, dass keine Zeichen-Debugflags gesetzt blieben.
  void screenshotTest(
    String description,
    Future<void> Function(WidgetTester) body,
  ) {
    testWidgets(description, (tester) async {
      debugDisableShadows = false;
      try {
        await body(tester);
      } finally {
        debugDisableShadows = true;
      }
    });
  }

  Future<void> scrollTo(WidgetTester tester, Finder finder) async {
    await tester.scrollUntilVisible(
      finder,
      260,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
  }

  Future<void> capture(WidgetTester tester, String name) => expectLater(
    find.byType(MaterialApp),
    matchesGoldenFile('goldens/$name.png'),
  );

  screenshotTest('Portfolio hell', (tester) async {
    await pumpApp(tester, fontFamily: kTestFont);
    await capture(tester, '01_portfolio_hell');
  });

  screenshotTest('Portfolio dunkel', (tester) async {
    await pumpApp(tester, themeMode: ThemeMode.dark, fontFamily: kTestFont);
    await capture(tester, '02_portfolio_dunkel');
  });

  screenshotTest('Portfolio Kennzahlen und Aufteilung', (tester) async {
    await pumpApp(tester, fontFamily: kTestFont);
    await scrollTo(tester, find.text('Aufteilung'));
    await capture(tester, '03_portfolio_aufteilung');
  });

  screenshotTest('Sammlung', (tester) async {
    await pumpApp(tester, fontFamily: kTestFont);
    await tester.tap(find.byIcon(Icons.style_outlined));
    await tester.pumpAndSettle();
    await capture(tester, '04_sammlung');
  });

  screenshotTest('Sammlung als Raster dunkel', (tester) async {
    await pumpApp(tester, themeMode: ThemeMode.dark, fontFamily: kTestFont);
    await tester.tap(find.byIcon(Icons.style_outlined));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.grid_view_rounded));
    await tester.pumpAndSettle();
    await capture(tester, '05_sammlung_raster');
  });

  screenshotTest('Position hinzufügen', (tester) async {
    await pumpApp(tester, withDemoData: false, fontFamily: kTestFont);
    await tester.tap(find.text('Erste Position hinzufügen'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'Glurak');
    await tester.pumpAndSettle();
    await capture(tester, '06_hinzufuegen_suche');

    await tester.tap(find.text('Glurak VMAX').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Gegradet'));
    await tester.pumpAndSettle();
    await capture(tester, '07_hinzufuegen_gegradet');
  });

  screenshotTest('Produktdetail', (tester) async {
    await pumpApp(tester, fontFamily: kTestFont);
    await tester.tap(find.byIcon(Icons.style_outlined));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilterChip, 'Gegradet'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Glurak VMAX').first);
    await tester.pumpAndSettle();
    await capture(tester, '08_produktdetail');
  });

  screenshotTest('Einstellungen dunkel', (tester) async {
    await pumpApp(tester, themeMode: ThemeMode.dark, fontFamily: kTestFont);
    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();
    await capture(tester, '09_einstellungen');
  });

  screenshotTest('Desktop mit Seitenleiste', (tester) async {
    await pumpApp(
      tester,
      surfaceSize: const Size(1280, 860),
      fontFamily: kTestFont,
    );
    await capture(tester, '10_desktop');
  });

  screenshotTest('Leerzustand', (tester) async {
    await pumpApp(tester, withDemoData: false, fontFamily: kTestFont);
    await capture(tester, '11_leerzustand');
  });
}
