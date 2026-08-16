import '../models/catalog_item.dart';
import '../models/holding.dart';
import '../models/money.dart';
import '../models/portfolio_snapshot.dart';
import '../models/price_point.dart';
import '../models/valuation.dart';
import 'valuation_service.dart';

/// Eine bewertete Position: Bestand, Katalogobjekt und ermittelter Wert.
class PositionValuation {
  const PositionValuation({
    required this.holding,
    required this.valuation,
    this.item,
  });

  final Holding holding;
  final Valuation valuation;

  /// Kann fehlen, wenn der Katalogeintrag (noch) nicht lokal vorliegt.
  final CatalogItem? item;

  String get displayName => item?.displayName ?? 'Unbekanntes Objekt';

  /// Vollständige Bezeichnung inklusive Set-Kürzel, z. B.
  /// „Mega-Glurak X-ex (PFL 013)".
  String get fullLabel => item?.fullLabel ?? displayName;

  /// „PFL 013" — leer bei versiegelten Produkten.
  String get reference => switch (item) {
    CatalogCard(:final reference) => reference,
    _ => '',
  };

  String get subtitle => item?.subtitle ?? holding.catalogId;

  /// Sucht über Name, Set, Kürzel und Nummer.
  bool matches(String query) =>
      item?.matches(query) ??
      holding.catalogId.toLowerCase().contains(query.trim().toLowerCase());

  /// Gesamtwert dieser Position (Wert je Stück × Menge).
  Money get totalValue => valuation.unitValue.times(holding.quantity);

  Money get invested => holding.investedTotal;

  Money get absoluteReturn => totalValue - invested;

  /// Rendite gegenüber dem Einstand; `null`, wenn kein Kaufpreis erfasst ist.
  double? get returnRatio =>
      invested.isZero ? null : Money.changeRatio(invested, totalValue);

  bool get hasValue => valuation.hasValue;
}

/// Aufschlüsselung des Portfolios nach einer Dimension (Kategorie, Set).
class BreakdownEntry {
  const BreakdownEntry({
    required this.label,
    required this.value,
    required this.share,
    required this.positionCount,
  });

  final String label;
  final Money value;

  /// Anteil am Gesamtwert zwischen 0 und 1.
  final double share;

  final int positionCount;
}

/// Ergebnis der Portfoliobewertung zu einem Zeitpunkt.
class PortfolioSummary {
  const PortfolioSummary({
    required this.positions,
    required this.totalValue,
    required this.cardsValue,
    required this.sealedValue,
    required this.invested,
    this.dayChange,
    this.previousSnapshot,
  });

  final List<PositionValuation> positions;
  final Money totalValue;
  final Money cardsValue;
  final Money sealedValue;
  final Money invested;

  /// Veränderung gegenüber dem letzten Tagesabschluss; `null`, solange noch
  /// kein Vortagswert existiert (§5.4, Leerzustand).
  final Money? dayChange;

  final PortfolioSnapshot? previousSnapshot;

  bool get isEmpty => positions.isEmpty;

  double? get dayChangeRatio {
    final previous = previousSnapshot;
    if (previous == null || previous.totalValue.isZero) return null;
    return Money.changeRatio(previous.totalValue, totalValue);
  }

  Money get totalReturn => totalValue - invested;

  double? get totalReturnRatio =>
      invested.isZero ? null : Money.changeRatio(invested, totalValue);

  /// Positionen mit dem größten absoluten Gewinn, absteigend.
  List<PositionValuation> topGainers({int limit = 5}) {
    final gainers =
        positions
            .where((p) => p.hasValue && p.absoluteReturn.isPositive)
            .toList()
          ..sort((a, b) => b.absoluteReturn.compareTo(a.absoluteReturn));
    return gainers.take(limit).toList();
  }

  /// Positionen mit dem größten absoluten Verlust, absteigend nach Verlusthöhe.
  List<PositionValuation> topLosers({int limit = 5}) {
    final losers =
        positions
            .where((p) => p.hasValue && p.absoluteReturn.isNegative)
            .toList()
          ..sort((a, b) => a.absoluteReturn.compareTo(b.absoluteReturn));
    return losers.take(limit).toList();
  }

  /// Aufteilung in Karten und versiegelte Produkte.
  List<BreakdownEntry> byCategory() {
    final cards = positions.where((p) => !p.holding.isSealed).toList();
    final sealed = positions.where((p) => p.holding.isSealed).toList();
    return [
      if (cards.isNotEmpty)
        BreakdownEntry(
          label: 'Karten',
          value: cardsValue,
          share: _share(cardsValue),
          positionCount: cards.length,
        ),
      if (sealed.isNotEmpty)
        BreakdownEntry(
          label: 'Versiegelt',
          value: sealedValue,
          share: _share(sealedValue),
          positionCount: sealed.length,
        ),
    ];
  }

  /// Aufteilung nach Set, absteigend nach Wert.
  List<BreakdownEntry> bySet({int limit = 5}) {
    final totals = <String, Money>{};
    final counts = <String, int>{};

    for (final position in positions) {
      final item = position.item;
      final label = switch (item) {
        CatalogCard(:final setName) => setName,
        SealedProduct(:final setName?) => setName,
        _ => 'Ohne Set',
      };
      totals[label] =
          (totals[label] ?? const Money.zero()) + position.totalValue;
      counts[label] = (counts[label] ?? 0) + 1;
    }

    final entries =
        totals.entries
            .map(
              (e) => BreakdownEntry(
                label: e.key,
                value: e.value,
                share: _share(e.value),
                positionCount: counts[e.key] ?? 0,
              ),
            )
            .toList()
          ..sort((a, b) => b.value.compareTo(a.value));

    return entries.take(limit).toList();
  }

  double _share(Money part) =>
      totalValue.isZero ? 0 : part.cents / totalValue.cents;
}

/// Bewertet das gesamte Portfolio und leitet die Kennzahlen der Startseite ab.
class PortfolioService {
  const PortfolioService({this.valuationService = const ValuationService()});

  final ValuationService valuationService;

  PortfolioSummary evaluate({
    required List<Holding> holdings,
    required PriceBook prices,
    required DateTime now,
    Map<String, CatalogItem> catalog = const {},
    PortfolioSnapshot? previousSnapshot,
  }) {
    final positions = holdings
        .map(
          (holding) => PositionValuation(
            holding: holding,
            valuation: valuationService.valuate(
              holding: holding,
              prices: prices,
              now: now,
            ),
            item: catalog[holding.catalogId],
          ),
        )
        .toList();

    final cardsValue = Money.sum(
      positions.where((p) => !p.holding.isSealed).map((p) => p.totalValue),
    );
    final sealedValue = Money.sum(
      positions.where((p) => p.holding.isSealed).map((p) => p.totalValue),
    );
    final invested = Money.sum(positions.map((p) => p.invested));
    final totalValue = cardsValue + sealedValue;

    return PortfolioSummary(
      positions: positions,
      totalValue: totalValue,
      cardsValue: cardsValue,
      sealedValue: sealedValue,
      invested: invested,
      previousSnapshot: previousSnapshot,
      dayChange: previousSnapshot == null
          ? null
          : totalValue - previousSnapshot.totalValue,
    );
  }
}
