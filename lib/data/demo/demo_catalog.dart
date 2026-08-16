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
///
/// Alle Karten, Set-Kennungen, Kürzel und deutschen Namen stammen unverändert
/// aus der TCGdex-Kartendatenbank. Dadurch stimmen auch die daraus gebildeten
/// Bildadressen — anders als bei erfundenen Beispieldaten, bei denen jedes
/// Bild ins Leere liefe.
class DemoCatalogSource implements CatalogSource {
  const DemoCatalogSource();

  @override
  String get attribution => 'Beispieldaten (TCGdex-Kartendaten)';

  static const List<CatalogCard> cards = [
    CatalogCard(
      id: 'me02-013',
      setId: 'me02',
      serieId: 'me',
      setName: 'Fatale Flammen',
      setAbbreviation: 'PFL',
      localId: '013',
      nameEn: 'Mega Charizard X ex',
      nameDe: 'Mega-Glurak X-ex',
      rarity: 'Double rare',
      setCardCount: 94,
      availableVariants: [CardVariant.holo],
    ),
    CatalogCard(
      id: 'sv03.5-006',
      setId: 'sv03.5',
      serieId: 'sv',
      setName: '151',
      setAbbreviation: 'MEW',
      localId: '006',
      nameEn: 'Charizard ex',
      nameDe: 'Glurak-ex',
      rarity: 'Double rare',
      setCardCount: 165,
      availableVariants: [CardVariant.holo],
    ),
    CatalogCard(
      id: 'sv03.5-151',
      setId: 'sv03.5',
      serieId: 'sv',
      setName: '151',
      setAbbreviation: 'MEW',
      localId: '151',
      nameEn: 'Mew ex',
      nameDe: 'Mew-ex',
      rarity: 'Double rare',
      setCardCount: 165,
      availableVariants: [CardVariant.holo],
    ),
    CatalogCard(
      id: 'swsh9-154',
      setId: 'swsh9',
      serieId: 'swsh',
      setName: 'Strahlende Sterne',
      setAbbreviation: 'BRS',
      localId: '154',
      nameEn: 'Charizard V',
      nameDe: 'Glurak V',
      rarity: 'Ultra Rare',
      setCardCount: 172,
      availableVariants: [CardVariant.holo],
    ),
    CatalogCard(
      id: 'swsh12.5-160',
      setId: 'swsh12.5',
      serieId: 'swsh',
      setName: 'Zenit der Könige',
      setAbbreviation: 'CRZ',
      localId: '160',
      nameEn: 'Pikachu',
      nameDe: 'Pikachu',
      rarity: 'Secret Rare',
      setCardCount: 159,
      availableVariants: [CardVariant.holo],
    ),
    CatalogCard(
      id: 'sv08-057',
      setId: 'sv08',
      serieId: 'sv',
      setName: 'Stürmische Funken',
      setAbbreviation: 'SSP',
      localId: '057',
      nameEn: 'Pikachu ex',
      nameDe: 'Pikachu-ex',
      rarity: 'Double rare',
      setCardCount: 191,
      availableVariants: [CardVariant.normal],
    ),
    CatalogCard(
      id: 'swsh7-215',
      setId: 'swsh7',
      serieId: 'swsh',
      setName: 'Drachenwandel',
      setAbbreviation: 'EVS',
      localId: '215',
      nameEn: 'Umbreon VMAX',
      nameDe: 'Nachtara VMAX',
      rarity: 'Secret Rare',
      setCardCount: 203,
      availableVariants: [CardVariant.holo],
    ),
    CatalogCard(
      id: 'sv04.5-091',
      setId: 'sv04.5',
      serieId: 'sv',
      setName: 'Paldeas Schicksale',
      setAbbreviation: 'PAF',
      localId: '091',
      nameEn: 'Ultra Ball',
      nameDe: 'Hyperball',
      rarity: 'Uncommon',
      setCardCount: 91,
      availableVariants: [CardVariant.normal, CardVariant.reverseHolo],
    ),
  ];

  static const List<SealedProduct> sealedProducts = [
    SealedProduct(
      id: 'sealed-sv03.5-display',
      name: '151 Display',
      type: SealedProductType.display,
      setId: 'sv03.5',
      serieId: 'sv',
      setName: '151',
    ),
    SealedProduct(
      id: 'sealed-sv04.5-etb',
      name: 'Paldeas Schicksale Top-Trainer-Box',
      type: SealedProductType.eliteTrainerBox,
      setId: 'sv04.5',
      serieId: 'sv',
      setName: 'Paldeas Schicksale',
    ),
    SealedProduct(
      id: 'sealed-swsh12.5-display',
      name: 'Zenit der Könige Display',
      type: SealedProductType.display,
      setId: 'swsh12.5',
      serieId: 'swsh',
      setName: 'Zenit der Könige',
    ),
  ];

  /// Referenzpreise je Katalog-ID und Preisschlüssel, in Cent.
  static const Map<String, Map<String, int>> _referencePrices = {
    'me02-013': {'raw:holo': 9800, 'PSA:10': 38000},
    'sv03.5-006': {'raw:holo': 4200, 'PSA:10': 19500, 'PSA:9': 7200},
    'sv03.5-151': {'raw:holo': 6800, 'PSA:10': 28000},
    'swsh9-154': {'raw:holo': 5400},
    'swsh12.5-160': {'raw:holo': 11500},
    'sv08-057': {'raw:normal': 1950},
    'swsh7-215': {'raw:holo': 32000, 'PSA:10': 145000},
    'sv04.5-091': {'raw:normal': 180, 'raw:reverse': 640},
    'sealed-sv03.5-display': {'sealed': 21900},
    'sealed-sv04.5-etb': {'sealed': 5490},
    'sealed-swsh12.5-display': {'sealed': 34900},
  };

  static List<CatalogItem> get allItems => [...cards, ...sealedProducts];

  @override
  Future<List<CatalogCard>> searchCards(String query, {int limit = 20}) async {
    if (query.trim().length < 2) return const [];
    return cards.where((card) => card.matches(query)).take(limit).toList();
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
      make(catalogId: 'me02-013', quantity: 1, purchaseCents: 7400, daysAgo: 90),
      make(
        catalogId: 'sv03.5-006',
        quantity: 3,
        purchaseCents: 3600,
        daysAgo: 300,
      ),
      make(
        catalogId: 'sv03.5-006',
        quantity: 1,
        purchaseCents: 15000,
        daysAgo: 120,
        grading: const Grading(Grader.psa, 10),
      ),
      make(
        catalogId: 'sv03.5-151',
        quantity: 2,
        purchaseCents: 5200,
        daysAgo: 210,
      ),
      make(
        catalogId: 'swsh12.5-160',
        quantity: 1,
        purchaseCents: 9800,
        daysAgo: 165,
      ),
      make(
        catalogId: 'sv08-057',
        quantity: 4,
        purchaseCents: 2100,
        daysAgo: 95,
        variant: CardVariant.normal,
      ),
      make(
        catalogId: 'swsh7-215',
        quantity: 1,
        purchaseCents: 120000,
        daysAgo: 420,
        grading: const Grading(Grader.psa, 10),
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
        catalogId: 'sv04.5-091',
        quantity: 12,
        purchaseCents: 150,
        daysAgo: 45,
        variant: CardVariant.reverseHolo,
      ),
      make(
        catalogId: 'sealed-sv03.5-display',
        quantity: 2,
        purchaseCents: 15900,
        daysAgo: 330,
        type: HoldingType.sealed,
      ),
      make(
        catalogId: 'sealed-sv04.5-etb',
        quantity: 3,
        purchaseCents: 4990,
        daysAgo: 150,
        type: HoldingType.sealed,
      ),
      make(
        catalogId: 'sealed-swsh12.5-display',
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
