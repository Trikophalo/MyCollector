import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mycollector/app/providers.dart';
import 'package:mycollector/domain/services/chart_series.dart';
import 'package:mycollector/features/collection/add_holding_screen.dart';
import 'package:mycollector/features/collection/collection_screen.dart';
import 'package:mycollector/features/collection/holding_detail_screen.dart';
import 'package:mycollector/features/portfolio/widgets/portfolio_chart.dart';
import 'package:mycollector/features/settings/settings_screen.dart';
import 'package:mycollector/ui/widgets/common.dart';

import '../app_harness.dart';

/// Scrollt, bis das gesuchte Element gebaut und sichtbar ist.
///
/// Notwendig, weil Slivers nur den sichtbaren Bereich aufbauen — was weiter
/// unten liegt, existiert im Widgetbaum schlicht noch nicht.
Future<void> scrollTo(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(
    finder,
    260,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
}

void main() {
  group('Portfolio-Startseite', () {
    testWidgets('zeigt Wert, Chart und Aufteilung mit Bestand', (tester) async {
      await pumpApp(tester);

      expect(find.text('Portfolio'), findsWidgets);
      expect(find.byType(PortfolioChart), findsOneWidget);
      expect(find.byType(ChartRangeSelector), findsOneWidget);

      // Der Gesamtwert erscheint als formatierter Euro-Betrag.
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Text &&
              (widget.data?.contains('€') ?? false) &&
              (widget.style?.fontSize ?? 0) > 40,
        ),
        findsOneWidget,
      );

      await scrollTo(tester, find.text('Größte Bewegungen'));
      expect(find.text('Größte Bewegungen'), findsOneWidget);

      await scrollTo(tester, find.text('Aufteilung'));
      expect(find.text('Aufteilung'), findsOneWidget);
      expect(find.text('Nach Set'), findsOneWidget);
      // „Karten" und „Versiegelt" erscheinen zusätzlich als Ausprägung
      // einzelner Positionen, daher findsWidgets statt findsOneWidget.
      expect(find.text('Karten'), findsWidgets);
      expect(find.text('Versiegelt'), findsWidgets);
    });

    testWidgets('führt ohne Bestand zum Einstieg statt zu leeren Zahlen', (
      tester,
    ) async {
      await pumpApp(tester, withDemoData: false);

      expect(find.text('Deine Sammlung ist noch leer'), findsOneWidget);
      expect(find.text('Erste Position hinzufügen'), findsOneWidget);
      expect(find.byType(PortfolioChart), findsNothing);
    });

    testWidgets('wechselt den Chart-Zeitraum', (tester) async {
      final container = await pumpApp(tester);

      expect(container.read(chartRangeProvider), ChartRange.month);

      await tester.tap(find.text('1W'));
      await tester.pumpAndSettle();

      expect(container.read(chartRangeProvider), ChartRange.week);
    });

    testWidgets('blendet die Einstandslinie ein', (tester) async {
      await pumpApp(tester);

      final chartBefore = tester.widget<PortfolioChart>(
        find.byType(PortfolioChart),
      );
      expect(chartBefore.showInvested, isFalse);

      await tester.tap(find.text('Einstand einblenden'));
      await tester.pumpAndSettle();

      final chartAfter = tester.widget<PortfolioChart>(
        find.byType(PortfolioChart),
      );
      expect(chartAfter.showInvested, isTrue);
    });
  });

  group('Sammlung', () {
    Future<void> openCollection(WidgetTester tester) async {
      await tester.tap(find.byIcon(Icons.style_outlined));
      await tester.pumpAndSettle();
    }

    testWidgets('listet die Positionen auf', (tester) async {
      await pumpApp(tester);
      await openCollection(tester);

      expect(find.byType(CollectionScreen), findsOneWidget);
      // Listentitel nennen jetzt Set-Kürzel und Nummer mit.
      expect(find.textContaining('Glurak-ex (MEW 006)'), findsWidgets);
    });

    testWidgets('filtert auf gegradete Karten', (tester) async {
      await pumpApp(tester);
      await openCollection(tester);

      await tester.tap(find.widgetWithText(FilterChip, 'Gegradet'));
      await tester.pumpAndSettle();

      // Im Beispielbestand sind genau zwei Positionen gegradet.
      expect(find.byType(GradingBadge), findsNWidgets(2));
    });

    testWidgets('filtert auf versiegelte Produkte', (tester) async {
      await pumpApp(tester);
      await openCollection(tester);

      await tester.tap(find.widgetWithText(FilterChip, 'Versiegelt'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Display'), findsWidgets);
      expect(find.text('Glurak VMAX'), findsNothing);
    });

    testWidgets('sucht innerhalb der Sammlung', (tester) async {
      await pumpApp(tester);
      await openCollection(tester);

      await tester.enterText(
        find.widgetWithText(TextField, 'In der Sammlung suchen'),
        'Nachtara',
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Nachtara VMAX'), findsWidgets);
      expect(find.textContaining('Glurak-ex'), findsNothing);
    });

    testWidgets('findet Karten über das Set-Kürzel', (tester) async {
      await pumpApp(tester);
      await openCollection(tester);

      // Glurak-ex und Mew-ex stammen beide aus dem Set mit dem Kürzel MEW.
      await tester.enterText(
        find.widgetWithText(TextField, 'In der Sammlung suchen'),
        'MEW',
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('(MEW '), findsWidgets);
      expect(find.textContaining('Nachtara'), findsNothing);
    });

    testWidgets('findet eine Karte über Kürzel und Nummer', (tester) async {
      await pumpApp(tester);
      await openCollection(tester);

      await tester.enterText(
        find.widgetWithText(TextField, 'In der Sammlung suchen'),
        'PFL 013',
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Mega-Glurak X-ex (PFL 013)'), findsWidgets);
      expect(find.textContaining('Mew-ex'), findsNothing);
    });

    testWidgets('erklärt einen Suchtreffer ohne Ergebnis', (tester) async {
      await pumpApp(tester);
      await openCollection(tester);

      await tester.enterText(
        find.widgetWithText(TextField, 'In der Sammlung suchen'),
        'Zapdos',
      );
      await tester.pumpAndSettle();

      expect(find.text('Keine Treffer'), findsOneWidget);
    });

    testWidgets('öffnet das Detail einer Position', (tester) async {
      await pumpApp(tester);
      await openCollection(tester);

      await tester.tap(find.textContaining('Glurak-ex').first);
      await tester.pumpAndSettle();

      expect(find.byType(HoldingDetailScreen), findsOneWidget);
      expect(find.text('Bestand'), findsOneWidget);
      expect(find.text('Preisverlauf'), findsOneWidget);
    });
  });

  group('Position hinzufügen', () {
    testWidgets('führt von der Suche zur Konfiguration', (tester) async {
      await pumpApp(tester, withDemoData: false);

      await tester.tap(find.text('Erste Position hinzufügen'));
      await tester.pumpAndSettle();

      expect(find.byType(AddHoldingScreen), findsOneWidget);
      expect(find.text('Was hast du?'), findsOneWidget);

      await tester.enterText(find.byType(TextField).first, 'Glurak-ex');
      await tester.pumpAndSettle();

      expect(find.textContaining('Glurak-ex (MEW 006)'), findsWidgets);

      await tester.tap(find.textContaining('Glurak-ex (MEW 006)').first);
      await tester.pumpAndSettle();

      expect(find.text('Details'), findsOneWidget);
      expect(find.text('Rohkarte'), findsOneWidget);
      expect(find.text('Gegradet'), findsOneWidget);
      expect(find.text('Zur Sammlung hinzufügen'), findsOneWidget);
    });

    testWidgets('bietet bei Gegradet die Notenauswahl an', (tester) async {
      await pumpApp(tester, withDemoData: false);

      await tester.tap(find.text('Erste Position hinzufügen'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).first, 'Glurak-ex');
      await tester.pumpAndSettle();
      await tester.tap(find.textContaining('Glurak-ex (MEW 006)').first);
      await tester.pumpAndSettle();

      expect(find.text('Anbieter'), findsNothing);

      await tester.tap(find.text('Gegradet'));
      await tester.pumpAndSettle();

      expect(find.text('Anbieter'), findsOneWidget);
      expect(find.text('Note'), findsOneWidget);
    });

    testWidgets('speichert eine Position und zeigt sie im Portfolio', (
      tester,
    ) async {
      final container = await pumpApp(tester, withDemoData: false);

      await tester.tap(find.text('Erste Position hinzufügen'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).first, 'Pikachu-ex');
      await tester.pumpAndSettle();
      await tester.tap(find.textContaining('Pikachu-ex (SSP 057)').first);
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextField, '0,00').first,
        '19,50',
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Zur Sammlung hinzufügen'));
      await tester.pumpAndSettle();

      final summary = await container.read(portfolioProvider.future);
      expect(summary.positions.length, 1);
      expect(summary.positions.single.holding.purchasePrice.cents, 1950);
      expect(summary.invested.cents, 1950);
    });
  });

  group('Einstellungen', () {
    Future<void> openSettings(WidgetTester tester) async {
      await tester.tap(find.byIcon(Icons.settings_outlined));
      await tester.pumpAndSettle();
    }

    testWidgets('schaltet zwischen hell und dunkel um', (tester) async {
      final container = await pumpApp(tester);
      await openSettings(tester);

      expect(find.byType(SettingsScreen), findsOneWidget);
      expect(container.read(settingsProvider).themeMode, ThemeMode.light);

      await tester.tap(find.text('Dunkel'));
      await tester.pumpAndSettle();

      expect(container.read(settingsProvider).themeMode, ThemeMode.dark);

      final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(app.themeMode, ThemeMode.dark);
    });

    testWidgets('nennt die Datenquelle und den Haftungshinweis', (
      tester,
    ) async {
      await pumpApp(tester);
      await openSettings(tester);

      await scrollTo(tester, find.textContaining('keine Anlageberatung'));

      expect(find.textContaining('keine Anlageberatung'), findsOneWidget);
      expect(find.textContaining('Inoffizielles Fanprojekt'), findsOneWidget);
    });

    testWidgets('leert die Sammlung nach Rückfrage', (tester) async {
      final container = await pumpApp(tester);
      await openSettings(tester);

      await scrollTo(tester, find.text('Sammlung leeren'));
      await tester.tap(find.text('Sammlung leeren'));
      await tester.pumpAndSettle();

      expect(find.text('Sammlung leeren?'), findsOneWidget);

      await tester.tap(find.widgetWithText(TextButton, 'Leeren'));
      await tester.pumpAndSettle();

      final summary = await container.read(portfolioProvider.future);
      expect(summary.isEmpty, isTrue);
    });
  });

  group('Desktop-Anordnung', () {
    testWidgets('nutzt ab großer Breite eine Seitenleiste', (tester) async {
      await pumpApp(tester, surfaceSize: const Size(1280, 900));

      expect(find.byType(NavigationRail), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
    });

    testWidgets('nutzt auf dem Telefon die Tab-Leiste', (tester) async {
      await pumpApp(tester);

      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.byType(NavigationRail), findsNothing);
    });
  });
}
