import 'dart:math' as math;

import '../../domain/models/catalog_item.dart';
import '../../domain/models/grading.dart';
import '../../domain/models/holding.dart';
import '../../domain/models/money.dart';
import '../../domain/models/portfolio_snapshot.dart';
import '../../domain/models/price_point.dart';
import '../remote/catalog_source.dart';

/// Beispieldaten für Entwicklung, Tests und den Probelauf ohne Netz.
///
/// Bewusst als eigene [CatalogSource] und nicht als versteckter Startbestand:
/// Beispieldaten werden nur geladen, wenn der Nutzer sie in den Einstellungen
/// ausdrücklich anfordert. Eine Sammlung, die sich von selbst füllt, wäre das
/// Gegenteil von Vertrauen (L3).
class DemoCatalogSource implements CatalogSource {
  const DemoCatalogSource();

  @override
  String get attribution => 'Beispieldaten (offline)';

  static const List<CatalogCard> cards = [
    CatalogCard(
      id: 'swsh3-020',
      setId: 'swsh3',
      setName: 'Flammende Finsternis',
      localId: '020',
      nameEn: 'Charizard VMAX',
      nameDe: 'Glurak VMAX',
      rarity: 'Rare Holo VMAX',
      setCardCount: 189,
      availableVariants: [CardVariant.holo],
    ),
    CatalogCard(
      id: 'swsh45-018',
      setId: 'swsh45',
      setName: 'Glänzendes Schicksal',
      localId: '018',
      nameEn: 'Pikachu V',
      nameDe: 'Pikachu V',
      rarity: 'Rare Holo V',
      setCardCount: 72,
      availableVariants: [CardVariant.holo, CardVariant.reverseHolo],
    ),
    CatalogCard(
      id: 'sv3pt5-006',
      setId: 'sv3pt5',
      setName: 'Karmesin & Purpur 151',
      localId: '006',
      nameEn: 'Charizard ex',
      nameDe: 'Glurak ex',
      rarity: 'Double Rare',
      setCardCount: 165,
      availableVariants: [CardVariant.holo],
    ),
    CatalogCard(
      id: 'sv3pt5-151',
      setId: 'sv3pt5',
      setName: 'Karmesin & Purpur 151',
      localId: '151',
      nameEn: 'Mew ex',
      nameDe: 'Mew ex',
      rarity: 'Double Rare',
      setCardCount: 165,
      availableVariants: [CardVariant.holo],
    ),
    CatalogCard(
      id: 'swsh12pt5-160',
      setId: 'swsh12pt5',
      setName: 'Zenit der Könige',
      localId: '160',
      nameEn: 'Giratina VSTAR',
      nameDe: 'Giratina VSTAR',
      rarity: 'Secret Rare',
      setCardCount: 159,
      availableVariants: [CardVariant.holo],
    ),
    CatalogCard(
      id: 'sv2-091',
      setId: 'sv2',
      setName: 'Paldeas Schicksale',
      localId: '091',
      nameEn: 'Miraidon ex',
      nameDe: 'Miraidon ex',
      rarity: 'Double Rare',
      setCardCount: 193,
      availableVariants: [CardVariant.holo, CardVariant.reverseHolo],
    ),
    CatalogCard(
      id: 'base1-004',
      setId: 'base1',
      setName: 'Basis-Set',
      localId: '004',
      nameEn: 'Charizard',
      nameDe: 'Glurak',
      rarity: 'Rare Holo',
      setCardCount: 102,
      availableVariants: [CardVariant.holo, CardVariant.firstEdition],
    ),
    CatalogCard(
      id: 'swsh9-154',
      setId: 'swsh9',
      setName: 'Strahlende Sterne',
      localId: '154',
      nameEn: 'Arceus VSTAR',
      nameDe: 'Arceus VSTAR',
      rarity: 'Secret Rare',
      setCardCount: 172,
      availableVariants: [CardVariant.holo],
    ),
  ];

  static const List<SealedProduct> sealedProducts = [
    SealedProduct(
      id: 'sealed-sv3pt5-display',
      name: 'Karmesin & Purpur 151 Display',
      type: SealedProductType.display,
      setId: 'sv3pt5',
      setName: 'Karmesin & Purpur 151',
    ),
    SealedProduct(
      id: 'sealed-sv2-etb',
      name: 'Paldeas Schicksale Top-Trainer-Box',
      type: SealedProductType.eliteTrainerBox,
      setId: 'sv2',
      setName: 'Paldeas Schicksale',
    ),
    SealedProduct(
      id: 'sealed-swsh12pt5-display',
      name: 'Zenit der Könige Display',
      type: SealedProductType.display,
      setId: 'swsh12pt5',
      setName: 'Zenit der Könige',
    ),
  ];

  /// Referenzpreise je Katalog-ID und Preisschlüssel, in Cent.
  static const Map<String, Map<String, int>> _referencePrices = {
    'swsh3-020': {'raw:holo': 8500, 'PSA:10': 42000, 'PSA:9': 14500},
    'swsh45-018': {'raw:holo': 1250, 'raw:reverse': 1800},
    'sv3pt5-006': {'raw:holo': 4200, 'PSA:10': 19500},
    'sv3pt5-151': {'raw:holo': 6800, 'PSA:10': 28000},
    'swsh12pt5-160': {'raw:holo': 11500},
    'sv2-091': {'raw:holo': 1950, 'raw:reverse': 2400},
    'base1-004': {'raw:holo': 32000, 'PSA:9': 145000, 'PSA:10': 890000},
    'swsh9-154': {'raw:holo': 5400},
    'sealed-sv3pt5-display': {'sealed': 21900},
    'sealed-sv2-etb': {'sealed': 5490},
    'sealed-swsh12pt5-display': {'sealed': 34900},
  };

  static List<CatalogItem> get allItems => [...cards, ...sealedProducts];

  @override
  Future<List<CatalogCard>> searchCards(String query, {int limit = 20}) async {
    final needle = query.trim().toLowerCase();
    if (needle.length < 2) return const [];

    return cards
        .where(
          (card) =>
              card.displayName.toLowerCase().contains(needle) ||
              card.nameEn.toLowerCase().contains(needle) ||
              card.setName.toLowerCase().contains(needle),
        )
        .take(limit)
        .toList();
  }

  @override
  Future<CatalogCardResult?> cardDetails(String id) async {
    final card = cards.where((c) => c.id == id).firstOrNull;
    if (card == null) return null;
    return CatalogCardResult(
      card: card,
      prices: _pricesForId(id, DateTime.now()),
    );
  }

  @override
  Future<List<PricePoint>> pricesFor(Iterable<String> cardIds) async {
    final now = DateTime.now();
    return [for (final id in cardIds) ..._pricesForId(id, now)];
  }

  static List<PricePoint> _pricesForId(String id, DateTime at) {
    final prices = _referencePrices[id];
    if (prices == null) return const [];

    return [
      for (final entry in prices.entries)
        PricePoint.eur(
          catalogId: id,
          priceKey: PriceKey(entry.key),
          source: entry.key.startsWith('PSA')
              ? PriceSource.pokemonPriceTracker
              : PriceSource.tcgdexCardmarket,
          value: Money(entry.value),
          capturedAt: at,
        ),
    ];
  }

  /// Ein vollständiger Beispielbestand mit Rohkarten, gegradeten Karten,
  /// versiegelten Produkten und einem manuell gesetzten Preis.
  static List<Holding> demoHoldings({required DateTime now}) {
    var counter = 0;
    Holding make({
      required String catalogId,
      required int quantity,
      required int purchaseCents,
      required int daysAgo,
      HoldingType type = HoldingType.card,
      CardVariant variant = CardVariant.holo,
      Grading? grading,
      Money? manualPrice,
    }) {
      counter++;
      final purchaseDate = now.subtract(Duration(days: daysAgo));
      return Holding(
        id: 'demo-$counter',
        portfolioId: 'demo',
        type: type,
        catalogId: catalogId,
        quantity: quantity,
        purchaseDate: purchaseDate,
        createdAt: purchaseDate,
        variant: variant,
        grading: grading,
        certificateNumber: grading == null ? null : '7${counter}482915',
        purchasePrice: Money(purchaseCents),
        priceMode: manualPrice == null ? PriceMode.auto : PriceMode.manual,
        manualPrice: manualPrice,
        manualPriceSetAt: manualPrice == null
            ? null
            : now.subtract(const Duration(days: 4)),
      );
    }

    return [
      make(
        catalogId: 'swsh3-020',
        quantity: 1,
        purchaseCents: 6500,
        daysAgo: 240,
      ),
      make(
        catalogId: 'swsh3-020',
        quantity: 1,
        purchaseCents: 32000,
        daysAgo: 120,
        grading: const Grading(Grader.psa, 10),
      ),
      make(
        catalogId: 'sv3pt5-006',
        quantity: 3,
        purchaseCents: 3600,
        daysAgo: 300,
      ),
      make(
        catalogId: 'sv3pt5-151',
        quantity: 2,
        purchaseCents: 5200,
        daysAgo: 210,
      ),
      make(
        catalogId: 'swsh12pt5-160',
        quantity: 1,
        purchaseCents: 9800,
        daysAgo: 165,
      ),
      make(
        catalogId: 'sv2-091',
        quantity: 4,
        purchaseCents: 2100,
        daysAgo: 95,
        variant: CardVariant.reverseHolo,
      ),
      make(
        catalogId: 'base1-004',
        quantity: 1,
        purchaseCents: 120000,
        daysAgo: 420,
        grading: const Grading(Grader.psa, 9),
        // Eigener Referenzpreis aus einem beobachteten Verkauf.
        manualPrice: const Money(158000),
      ),
      make(
        catalogId: 'swsh9-154',
        quantity: 2,
        purchaseCents: 4900,
        daysAgo: 60,
      ),
      make(
        catalogId: 'sealed-sv3pt5-display',
        quantity: 2,
        purchaseCents: 15900,
        daysAgo: 330,
        type: HoldingType.sealed,
      ),
      make(
        catalogId: 'sealed-sv2-etb',
        quantity: 3,
        purchaseCents: 4990,
        daysAgo: 150,
        type: HoldingType.sealed,
      ),
      make(
        catalogId: 'sealed-swsh12pt5-display',
        quantity: 1,
        purchaseCents: 24500,
        daysAgo: 275,
        type: HoldingType.sealed,
      ),
    ];
  }

  /// Erzeugt eine plausible Wertkurve für die Beispieldaten.
  ///
  /// Ohne Historie bliebe der Chart leer — für einen Probelauf wäre das
  /// korrekt, aber wenig aussagekräftig. Die Kurve ist deterministisch, damit
  /// Tests und Bildschirmfotos reproduzierbar bleiben.
  static List<PortfolioSnapshot> demoSnapshots({
    required DateTime now,
    int days = 400,
  }) {
    final random = math.Random(42);
    final snapshots = <PortfolioSnapshot>[];

    var value = 120000.0;
    var invested = 180000.0;

    for (var i = days - 1; i >= 0; i--) {
      final date = PortfolioSnapshot.dateOnly(now.subtract(Duration(days: i)));
      final progress = (days - i) / days;

      // Grundtrend plus Rauschen plus zwei Marktphasen.
      final drift = 900 * progress;
      final noise = (random.nextDouble() - 0.48) * 2600;
      final wave = math.sin(progress * math.pi * 3) * 9000;
      value = math.max(50000, value + drift * 0.35 + noise + wave * 0.02);

      if (i == 330 || i == 275 || i == 240 || i == 210 || i == 165) {
        invested += 18000;
        value += 16000;
      }

      snapshots.add(
        PortfolioSnapshot(
          portfolioId: 'demo',
          date: date,
          totalValue: Money(value.round()),
          cardsValue: Money((value * 0.62).round()),
          sealedValue: Money((value * 0.38).round()),
          invested: Money(invested.round()),
        ),
      );
    }

    return snapshots;
  }
}
