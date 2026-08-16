import 'package:flutter_test/flutter_test.dart';
import 'package:mycollector/domain/models/catalog_item.dart';
import 'package:mycollector/domain/models/grading.dart';
import 'package:mycollector/domain/models/holding.dart';
import 'package:mycollector/domain/models/money.dart';
import 'package:mycollector/domain/models/portfolio_snapshot.dart';
import 'package:mycollector/domain/models/price_point.dart';
import 'package:mycollector/domain/services/portfolio_service.dart';

void main() {
  final now = DateTime(2026, 8, 16, 12);
  const service = PortfolioService();

  const card = CatalogCard(
    id: 'swsh3-136',
    setId: 'swsh3',
    setName: 'Flammende Finsternis',
    localId: '136',
    nameEn: 'Charizard',
    nameDe: 'Glurak',
    setCardCount: 189,
  );

  const otherCard = CatalogCard(
    id: 'sv1-245',
    setId: 'sv1',
    setName: 'Karmesin & Purpur',
    localId: '245',
    nameEn: 'Miraidon ex',
    nameDe: 'Miraidon ex',
    setCardCount: 258,
  );

  const box = SealedProduct(
    id: 'sealed-sv1-display',
    name: 'Karmesin & Purpur Display',
    type: SealedProductType.display,
    setId: 'sv1',
    setName: 'Karmesin & Purpur',
  );

  Holding holding({
    required String id,
    required String catalogId,
    int quantity = 1,
    int purchaseCents = 1000,
    HoldingType type = HoldingType.card,
    Money? manualPrice,
  }) =>
      Holding(
        id: id,
        portfolioId: 'p1',
        type: type,
        catalogId: catalogId,
        quantity: quantity,
        purchaseDate: DateTime(2026, 1, 10),
        createdAt: DateTime(2026, 1, 10),
        purchasePrice: Money(purchaseCents),
        priceMode: manualPrice == null ? PriceMode.auto : PriceMode.manual,
        manualPrice: manualPrice,
        manualPriceSetAt: manualPrice == null ? null : now,
      );

  PriceBook pricesFor(Map<String, int> centsByCatalogId) => PriceBook([
        for (final entry in centsByCatalogId.entries)
          PricePoint.eur(
            catalogId: entry.key,
            priceKey: entry.key.startsWith('sealed')
                ? PriceKey.sealed
                : PriceKey.raw(CardVariant.normal),
            source: PriceSource.tcgdexCardmarket,
            value: Money(entry.value),
            capturedAt: now,
          ),
      ]);

  test('summiert Wert und Einstand über Mengen hinweg', () {
    final summary = service.evaluate(
      holdings: [
        holding(id: 'h1', catalogId: 'swsh3-136', quantity: 3, purchaseCents: 2000),
        holding(id: 'h2', catalogId: 'sv1-245', quantity: 2, purchaseCents: 500),
      ],
      prices: pricesFor({'swsh3-136': 5000, 'sv1-245': 800}),
      now: now,
      catalog: const {'swsh3-136': card, 'sv1-245': otherCard},
    );

    expect(summary.totalValue, const Money(16600));
    expect(summary.invested, const Money(7000));
    expect(summary.totalReturn, const Money(9600));
    expect(summary.totalReturnRatio, closeTo(9600 / 7000, 0.0001));
  });

  test('trennt Karten von versiegelten Produkten', () {
    final summary = service.evaluate(
      holdings: [
        holding(id: 'h1', catalogId: 'swsh3-136'),
        holding(
          id: 'h2',
          catalogId: 'sealed-sv1-display',
          type: HoldingType.sealed,
        ),
      ],
      prices: pricesFor({'swsh3-136': 5000, 'sealed-sv1-display': 15000}),
      now: now,
      catalog: const {'swsh3-136': card, 'sealed-sv1-display': box},
    );

    expect(summary.cardsValue, const Money(5000));
    expect(summary.sealedValue, const Money(15000));
    expect(summary.totalValue, const Money(20000));

    final categories = summary.byCategory();
    expect(categories.map((e) => e.label), ['Karten', 'Versiegelt']);
    expect(categories.last.share, closeTo(0.75, 0.0001));
  });

  test('berechnet die Tagesveränderung gegen den letzten Abschluss', () {
    final summary = service.evaluate(
      holdings: [holding(id: 'h1', catalogId: 'swsh3-136')],
      prices: pricesFor({'swsh3-136': 5000}),
      now: now,
      catalog: const {'swsh3-136': card},
      previousSnapshot: PortfolioSnapshot(
        portfolioId: 'p1',
        date: DateTime(2026, 8, 15),
        totalValue: const Money(4000),
        cardsValue: const Money(4000),
        sealedValue: const Money.zero(),
        invested: const Money(1000),
      ),
    );

    expect(summary.dayChange, const Money(1000));
    expect(summary.dayChangeRatio, closeTo(0.25, 0.0001));
  });

  test('ohne Vortagsabschluss bleibt die Tagesveränderung offen', () {
    final summary = service.evaluate(
      holdings: [holding(id: 'h1', catalogId: 'swsh3-136')],
      prices: pricesFor({'swsh3-136': 5000}),
      now: now,
    );

    expect(summary.dayChange, isNull,
        reason: 'Erfundene Nullveränderung wäre eine Falschaussage');
    expect(summary.dayChangeRatio, isNull);
  });

  test('sortiert Gewinner und Verlierer nach absolutem Ergebnis', () {
    final summary = service.evaluate(
      holdings: [
        holding(id: 'gewinner', catalogId: 'swsh3-136', purchaseCents: 1000),
        holding(id: 'verlierer', catalogId: 'sv1-245', purchaseCents: 9000),
      ],
      prices: pricesFor({'swsh3-136': 5000, 'sv1-245': 800}),
      now: now,
      catalog: const {'swsh3-136': card, 'sv1-245': otherCard},
    );

    expect(summary.topGainers().single.holding.id, 'gewinner');
    expect(summary.topGainers().single.absoluteReturn, const Money(4000));
    expect(summary.topLosers().single.holding.id, 'verlierer');
    expect(summary.topLosers().single.absoluteReturn, const Money(-8200));
  });

  test('gruppiert nach Set und sortiert absteigend nach Wert', () {
    final summary = service.evaluate(
      holdings: [
        holding(id: 'h1', catalogId: 'swsh3-136'),
        holding(id: 'h2', catalogId: 'sv1-245', quantity: 4),
      ],
      prices: pricesFor({'swsh3-136': 5000, 'sv1-245': 3000}),
      now: now,
      catalog: const {'swsh3-136': card, 'sv1-245': otherCard},
    );

    final sets = summary.bySet();
    expect(sets.first.label, 'Karmesin & Purpur');
    expect(sets.first.value, const Money(12000));
    expect(sets.last.label, 'Flammende Finsternis');
  });

  test('ein manueller Preis wirkt auf den Portfoliowert durch', () {
    final summary = service.evaluate(
      holdings: [
        holding(
          id: 'h1',
          catalogId: 'swsh3-136',
          quantity: 2,
          manualPrice: const Money(38000),
        ),
      ],
      prices: pricesFor({'swsh3-136': 5000}),
      now: now,
      catalog: const {'swsh3-136': card},
    );

    expect(summary.totalValue, const Money(76000));
  });

  test('Positionen ohne Kaufpreis liefern keine irreführende Rendite', () {
    final summary = service.evaluate(
      holdings: [holding(id: 'h1', catalogId: 'swsh3-136', purchaseCents: 0)],
      prices: pricesFor({'swsh3-136': 5000}),
      now: now,
      catalog: const {'swsh3-136': card},
    );

    expect(summary.positions.single.returnRatio, isNull);
    expect(summary.totalReturnRatio, isNull);
  });

  test('leeres Portfolio ist wertfrei, aber nicht fehlerhaft', () {
    final summary = service.evaluate(
      holdings: const [],
      prices: PriceBook.empty(),
      now: now,
    );

    expect(summary.isEmpty, isTrue);
    expect(summary.totalValue, const Money.zero());
    expect(summary.topGainers(), isEmpty);
    expect(summary.byCategory(), isEmpty);
  });
}
