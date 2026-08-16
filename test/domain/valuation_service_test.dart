import 'package:flutter_test/flutter_test.dart';
import 'package:mycollector/domain/models/grading.dart';
import 'package:mycollector/domain/models/holding.dart';
import 'package:mycollector/domain/models/money.dart';
import 'package:mycollector/domain/models/price_point.dart';
import 'package:mycollector/domain/models/valuation.dart';
import 'package:mycollector/domain/services/valuation_service.dart';

void main() {
  final now = DateTime(2026, 8, 16, 12);
  const service = ValuationService();

  Holding buildHolding({
    Grading? grading,
    PriceMode priceMode = PriceMode.auto,
    Money? manualPrice,
    Money purchasePrice = const Money(1000),
    CardVariant variant = CardVariant.normal,
    HoldingType type = HoldingType.card,
  }) => Holding(
    id: 'h1',
    portfolioId: 'p1',
    type: type,
    catalogId: 'swsh3-136',
    quantity: 1,
    purchaseDate: DateTime(2026, 1, 10),
    createdAt: DateTime(2026, 1, 10),
    variant: variant,
    grading: grading,
    purchasePrice: purchasePrice,
    priceMode: priceMode,
    manualPrice: manualPrice,
    manualPriceSetAt: manualPrice == null ? null : DateTime(2026, 8, 12),
  );

  PricePoint buildPrice({
    required PriceKey key,
    required int cents,
    required DateTime capturedAt,
    PriceSource source = PriceSource.tcgdexCardmarket,
  }) => PricePoint.eur(
    catalogId: 'swsh3-136',
    priceKey: key,
    source: source,
    value: Money(cents),
    capturedAt: capturedAt,
  );

  group('Stufe 1 — manueller Preis', () {
    test('schlägt jeden vorhandenen Marktpreis', () {
      final holding = buildHolding(
        priceMode: PriceMode.manual,
        manualPrice: const Money(38000),
      );
      final prices = PriceBook([
        buildPrice(
          key: PriceKey.raw(CardVariant.normal),
          cents: 4210,
          capturedAt: now,
        ),
      ]);

      final result = service.valuate(
        holding: holding,
        prices: prices,
        now: now,
      );

      expect(result.tier, ValuationTier.manualOverride);
      expect(result.unitValue, const Money(38000));
      expect(result.source, PriceSource.manual);
      expect(result.asOf, DateTime(2026, 8, 12));
    });

    test('greift nicht, wenn der Modus auf automatisch steht', () {
      final holding = buildHolding(manualPrice: const Money(38000));
      final prices = PriceBook([
        buildPrice(
          key: PriceKey.raw(CardVariant.normal),
          cents: 4210,
          capturedAt: now,
        ),
      ]);

      final result = service.valuate(
        holding: holding,
        prices: prices,
        now: now,
      );

      expect(result.tier, ValuationTier.rawMarket);
      expect(result.unitValue, const Money(4210));
    });
  });

  group('Stufen 2 und 3 — Marktpreise', () {
    test('gegradete Karte zieht den Preis ihres Grading-Schlüssels', () {
      final holding = buildHolding(grading: const Grading(Grader.psa, 10));
      final prices = PriceBook([
        buildPrice(
          key: PriceKey.raw(CardVariant.normal),
          cents: 4210,
          capturedAt: now,
        ),
        buildPrice(
          key: PriceKey.graded(const Grading(Grader.psa, 10)),
          cents: 120000,
          capturedAt: now,
          source: PriceSource.pokemonPriceTracker,
        ),
      ]);

      final result = service.valuate(
        holding: holding,
        prices: prices,
        now: now,
      );

      expect(result.tier, ValuationTier.gradedMarket);
      expect(result.unitValue, const Money(120000));
      expect(
        result.isUsMarket,
        isTrue,
        reason: 'US-Quellen müssen im UI gekennzeichnet werden',
      );
    });

    test('unterscheidet Druckvarianten', () {
      final holding = buildHolding(variant: CardVariant.reverseHolo);
      final prices = PriceBook([
        buildPrice(
          key: PriceKey.raw(CardVariant.normal),
          cents: 4210,
          capturedAt: now,
        ),
        buildPrice(
          key: PriceKey.raw(CardVariant.reverseHolo),
          cents: 7350,
          capturedAt: now,
        ),
      ]);

      final result = service.valuate(
        holding: holding,
        prices: prices,
        now: now,
      );

      expect(result.unitValue, const Money(7350));
    });

    test('PSA 9 fällt nicht auf den PSA-10-Preis zurück', () {
      final holding = buildHolding(grading: const Grading(Grader.psa, 9));
      final prices = PriceBook([
        buildPrice(
          key: PriceKey.graded(const Grading(Grader.psa, 10)),
          cents: 120000,
          capturedAt: now,
        ),
      ]);

      final result = service.valuate(
        holding: holding,
        prices: prices,
        now: now,
      );

      expect(
        result.tier,
        ValuationTier.purchasePrice,
        reason: 'Ohne eigenen PSA-9-Preis darf kein fremder Grade gelten',
      );
    });
  });

  group('Stufe 4 — letzter bekannter Preis', () {
    test('markiert Preise jenseits des Frischefensters als veraltet', () {
      final holding = buildHolding();
      final prices = PriceBook([
        buildPrice(
          key: PriceKey.raw(CardVariant.normal),
          cents: 4210,
          capturedAt: now.subtract(const Duration(days: 5)),
        ),
      ]);

      final result = service.valuate(
        holding: holding,
        prices: prices,
        now: now,
      );

      expect(result.tier, ValuationTier.lastKnown);
      expect(result.isStale, isTrue);
      expect(result.unitValue, const Money(4210));
      expect(result.asOf, now.subtract(const Duration(days: 5)));
    });

    test('ein Preis innerhalb des Fensters gilt als frisch', () {
      final holding = buildHolding();
      final prices = PriceBook([
        buildPrice(
          key: PriceKey.raw(CardVariant.normal),
          cents: 4210,
          capturedAt: now.subtract(const Duration(hours: 30)),
        ),
      ]);

      final result = service.valuate(
        holding: holding,
        prices: prices,
        now: now,
      );

      expect(result.tier, ValuationTier.rawMarket);
      expect(result.isStale, isFalse);
    });
  });

  group('Stufen 5 und 6 — Notwerte', () {
    test('ohne Marktpreis dient der Kaufpreis als Anhalt', () {
      final holding = buildHolding(purchasePrice: const Money(2500));

      final result = service.valuate(
        holding: holding,
        prices: PriceBook.empty(),
        now: now,
      );

      expect(result.tier, ValuationTier.purchasePrice);
      expect(result.unitValue, const Money(2500));
    });

    test('ohne Markt- und Kaufpreis gibt es keinen Wert statt null Euro', () {
      final holding = buildHolding(purchasePrice: const Money.zero());

      final result = service.valuate(
        holding: holding,
        prices: PriceBook.empty(),
        now: now,
      );

      expect(result.tier, ValuationTier.unavailable);
      expect(result.hasValue, isFalse);
    });
  });

  group('PriceBook', () {
    test('behält je Schlüssel den jüngsten Preis', () {
      final book = PriceBook([
        buildPrice(
          key: PriceKey.raw(CardVariant.normal),
          cents: 4000,
          capturedAt: now.subtract(const Duration(days: 2)),
        ),
        buildPrice(
          key: PriceKey.raw(CardVariant.normal),
          cents: 4500,
          capturedAt: now,
        ),
        buildPrice(
          key: PriceKey.raw(CardVariant.normal),
          cents: 4200,
          capturedAt: now.subtract(const Duration(days: 1)),
        ),
      ]);

      expect(
        book.latest('swsh3-136', PriceKey.raw(CardVariant.normal))?.valueEur,
        const Money(4500),
      );
      expect(book.length, 1);
    });
  });

  group('Umrechnung aus Fremdwährung', () {
    test(
      'bewertet mit dem eingefrorenen EUR-Wert, nicht mit dem USD-Betrag',
      () {
        final holding = buildHolding(grading: const Grading(Grader.bgs, 9.5));
        final prices = PriceBook([
          PricePoint(
            catalogId: 'swsh3-136',
            priceKey: PriceKey.graded(const Grading(Grader.bgs, 9.5)),
            source: PriceSource.priceCharting,
            value: const Money(50000, currency: Currency.usd),
            valueEur: const Money(46000),
            capturedAt: now,
          ),
        ]);

        final result = service.valuate(
          holding: holding,
          prices: prices,
          now: now,
        );

        expect(result.unitValue, const Money(46000));
        expect(result.unitValue.currency, Currency.eur);
      },
    );
  });
}
