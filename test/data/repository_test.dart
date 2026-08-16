import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mycollector/data/local/database.dart';
import 'package:mycollector/data/local/drift_collection_repository.dart';
import 'package:mycollector/domain/models/catalog_item.dart';
import 'package:mycollector/domain/models/grading.dart';
import 'package:mycollector/domain/models/holding.dart';
import 'package:mycollector/domain/models/money.dart';
import 'package:mycollector/domain/models/portfolio_snapshot.dart';
import 'package:mycollector/domain/models/price_point.dart';

void main() {
  late AppDatabase db;
  late DriftCollectionRepository repository;

  final now = DateTime(2026, 8, 16, 9);

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repository = DriftCollectionRepository(db);
  });

  tearDown(() async => db.close());

  Holding buildHolding({
    String id = 'h1',
    String catalogId = 'swsh3-020',
    int quantity = 1,
    Grading? grading,
    Money? manualPrice,
    HoldingType type = HoldingType.card,
  }) => Holding(
    id: id,
    portfolioId: 'p1',
    type: type,
    catalogId: catalogId,
    quantity: quantity,
    purchaseDate: DateTime(2026, 3, 1),
    createdAt: now,
    variant: CardVariant.holo,
    condition: CardCondition.nearMint,
    grading: grading,
    certificateNumber: grading == null ? null : '78412399',
    purchasePrice: const Money(6500),
    priceMode: manualPrice == null ? PriceMode.auto : PriceMode.manual,
    manualPrice: manualPrice,
    manualPriceSetAt: manualPrice == null ? null : now,
    note: 'Aus Sammelbestellung',
  );

  group('Bestand', () {
    test('speichert und liest eine Position verlustfrei', () async {
      await repository.saveHolding(
        buildHolding(grading: const Grading(Grader.bgs, 9.5)),
      );

      final loaded = await repository.holding('h1');

      expect(loaded, isNotNull);
      expect(loaded!.catalogId, 'swsh3-020');
      expect(loaded.quantity, 1);
      expect(loaded.variant, CardVariant.holo);
      expect(loaded.grading, const Grading(Grader.bgs, 9.5));
      expect(loaded.certificateNumber, '78412399');
      expect(loaded.purchasePrice, const Money(6500));
      expect(loaded.note, 'Aus Sammelbestellung');
    });

    test('behandelt gleiche Karte in zwei Käufen als getrennte Lots', () async {
      await repository.saveHolding(buildHolding(id: 'lot-1'));
      await repository.saveHolding(buildHolding(id: 'lot-2', quantity: 3));

      final all = await repository.holdings('p1');

      expect(all.length, 2);
      expect(all.map((h) => h.quantity).toSet(), {1, 3});
    });

    test('überschreibt beim erneuten Speichern derselben Kennung', () async {
      await repository.saveHolding(buildHolding());
      await repository.saveHolding(buildHolding(quantity: 7));

      final all = await repository.holdings('p1');

      expect(all.length, 1);
      expect(all.single.quantity, 7);
    });

    test('entfernt eine Position', () async {
      await repository.saveHolding(buildHolding());
      await repository.deleteHolding('h1');

      expect(await repository.holdings('p1'), isEmpty);
    });

    test('trennt Portfolios voneinander', () async {
      await repository.saveHolding(buildHolding());
      await repository.saveHolding(
        Holding(
          id: 'fremd',
          portfolioId: 'anderes',
          type: HoldingType.card,
          catalogId: 'sv2-091',
          quantity: 1,
          purchaseDate: now,
          createdAt: now,
        ),
      );

      expect((await repository.holdings('p1')).length, 1);
      expect((await repository.holdings('anderes')).length, 1);
    });

    test('meldet Änderungen über den Stream', () async {
      final stream = repository.watchHoldings('p1');
      final future = stream.firstWhere((list) => list.isNotEmpty);

      await repository.saveHolding(buildHolding());

      expect((await future).single.id, 'h1');
    });

    test('ein manuell gesetzter Preis übersteht den Neustart', () async {
      await repository.saveHolding(
        buildHolding(manualPrice: const Money(158000)),
      );

      final loaded = await repository.holding('h1');

      expect(loaded!.priceMode, PriceMode.manual);
      expect(loaded.manualPrice, const Money(158000));
      expect(loaded.hasManualPrice, isTrue);
    });
  });

  group('Katalog', () {
    test('legt Karten und versiegelte Produkte gemeinsam ab', () async {
      await repository.cacheCatalogItems(const [
        CatalogCard(
          id: 'swsh3-020',
          setId: 'swsh3',
          setName: 'Flammende Finsternis',
          localId: '020',
          nameEn: 'Charizard VMAX',
          nameDe: 'Glurak VMAX',
          setCardCount: 189,
          availableVariants: [CardVariant.holo, CardVariant.reverseHolo],
        ),
        SealedProduct(
          id: 'sealed-1',
          name: 'Zenit der Könige Display',
          type: SealedProductType.display,
          isCustom: true,
        ),
      ]);

      final items = await repository.catalogItems(['swsh3-020', 'sealed-1']);

      expect(items.length, 2);
      final card = items['swsh3-020']! as CatalogCard;
      expect(card.displayName, 'Glurak VMAX');
      expect(card.subtitle, 'Flammende Finsternis · 020/189');
      expect(card.availableVariants.length, 2);

      final sealed = items['sealed-1']! as SealedProduct;
      expect(sealed.isCustom, isTrue);
      expect(sealed.type, SealedProductType.display);
    });

    test('fragt nichts ab, wenn keine Kennungen übergeben werden', () async {
      expect(await repository.catalogItems(const []), isEmpty);
    });
  });

  group('Preisarchiv', () {
    PricePoint point(int cents, DateTime at, {String key = 'raw:holo'}) =>
        PricePoint.eur(
          catalogId: 'swsh3-020',
          priceKey: PriceKey(key),
          source: PriceSource.tcgdexCardmarket,
          value: Money(cents),
          capturedAt: at,
        );

    test('hängt Preise an, statt sie zu überschreiben', () async {
      await repository.recordPrices([
        point(8000, now.subtract(const Duration(days: 2))),
        point(8500, now.subtract(const Duration(days: 1))),
        point(8300, now),
      ]);

      final history = await repository.priceHistory(
        'swsh3-020',
        const PriceKey('raw:holo'),
      );

      expect(history.length, 3);
      expect(history.first.valueEur, const Money(8000));
      expect(history.last.valueEur, const Money(8300));
    });

    test('liefert je Schlüssel nur den jüngsten Preis zurück', () async {
      await repository.recordPrices([
        point(8000, now.subtract(const Duration(days: 2))),
        point(8300, now),
        point(42000, now, key: 'PSA:10'),
      ]);

      final book = await repository.latestPrices();

      expect(
        book.latest('swsh3-020', const PriceKey('raw:holo'))?.valueEur,
        const Money(8300),
      );
      expect(
        book.latest('swsh3-020', const PriceKey('PSA:10'))?.valueEur,
        const Money(42000),
      );
      expect(book.length, 2);
    });

    test('bewahrt Originalwährung und umgerechneten Wert getrennt', () async {
      await repository.recordPrices([
        PricePoint(
          catalogId: 'base1-004',
          priceKey: const PriceKey('PSA:10'),
          source: PriceSource.priceCharting,
          value: const Money(890000, currency: Currency.usd),
          valueEur: const Money(818000),
          capturedAt: now,
        ),
      ]);

      final stored = await repository.priceHistory(
        'base1-004',
        const PriceKey('PSA:10'),
      );

      expect(stored.single.value.currency, Currency.usd);
      expect(stored.single.value.cents, 890000);
      expect(stored.single.valueEur, const Money(818000));
      expect(stored.single.wasConverted, isTrue);
    });
  });

  group('Snapshots', () {
    test('speichert Tagesabschlüsse chronologisch', () async {
      for (var i = 3; i >= 1; i--) {
        await repository.saveSnapshot(
          PortfolioSnapshot(
            portfolioId: 'p1',
            date: DateTime(2026, 8, 16 - i),
            totalValue: Money(1000 * i),
            cardsValue: Money(600 * i),
            sealedValue: Money(400 * i),
            invested: const Money(5000),
          ),
        );
      }

      final all = await repository.snapshots('p1');

      expect(all.length, 3);
      expect(all.first.date, DateTime(2026, 8, 13));
      expect(all.last.date, DateTime(2026, 8, 15));
    });

    test('ersetzt einen Abschluss desselben Tages', () async {
      final snapshot = PortfolioSnapshot(
        portfolioId: 'p1',
        date: DateTime(2026, 8, 16),
        totalValue: const Money(1000),
        cardsValue: const Money(1000),
        sealedValue: const Money.zero(),
        invested: const Money(500),
      );

      await repository.saveSnapshot(snapshot);
      await repository.saveSnapshot(
        PortfolioSnapshot(
          portfolioId: 'p1',
          date: DateTime(2026, 8, 16),
          totalValue: const Money(1200),
          cardsValue: const Money(1200),
          sealedValue: const Money.zero(),
          invested: const Money(500),
        ),
      );

      final all = await repository.snapshots('p1');

      expect(all.length, 1);
      expect(all.single.totalValue, const Money(1200));
    });
  });

  group('Export', () {
    test('enthält Bestand, Namen und Historie', () async {
      await repository.cacheCatalogItems(const [
        CatalogCard(
          id: 'swsh3-020',
          setId: 'swsh3',
          setName: 'Flammende Finsternis',
          localId: '020',
          nameEn: 'Charizard VMAX',
          nameDe: 'Glurak VMAX',
        ),
      ]);
      await repository.saveHolding(
        buildHolding(grading: const Grading(Grader.psa, 10)),
      );
      await repository.saveSnapshot(
        PortfolioSnapshot(
          portfolioId: 'p1',
          date: DateTime(2026, 8, 15),
          totalValue: const Money(42000),
          cardsValue: const Money(42000),
          sealedValue: const Money.zero(),
          invested: const Money(6500),
        ),
      );

      final export = await repository.exportAll('p1');

      expect(export['formatVersion'], 1);
      final holdings = export['holdings']! as List<Object?>;
      final first = holdings.single! as Map<String, Object?>;
      expect(first['name'], 'Glurak VMAX (020)');
      expect(first['grader'], 'PSA');
      expect(first['grade'], 10.0);
      expect((export['snapshots']! as List<Object?>).length, 1);
    });
  });
}
