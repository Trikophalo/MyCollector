import '../models/holding.dart';
import '../models/price_point.dart';
import '../models/valuation.dart';

/// Ermittelt den Wert einer einzelnen Position nach der Kaskade aus §4.5.
///
/// Die Reihenfolge ist bewusst fest und nicht konfigurierbar: Sie ist die
/// fachliche Zusage der App, welcher Preis wann gilt. Die erste zutreffende
/// Stufe gewinnt:
///
/// 1. manuell gesetzter Preis
/// 2. Marktpreis für die gegradete Variante
/// 3. Marktpreis für Rohkarte bzw. versiegeltes Produkt
/// 4. letzter bekannter Preis (mit „Stand"-Kennzeichnung)
/// 5. Kaufpreis als Notwert
/// 6. kein Preis
class ValuationService {
  const ValuationService({this.freshFor = const Duration(hours: 48)});

  /// Wie lange ein abgerufener Preis als aktuell gilt.
  final Duration freshFor;

  Valuation valuate({
    required Holding holding,
    required PriceBook prices,
    required DateTime now,
  }) {
    // Stufe 1 — der Sammler hat selbst entschieden. Das schlägt jede API.
    if (holding.hasManualPrice) {
      return Valuation(
        unitValue: holding.manualPrice!,
        tier: ValuationTier.manualOverride,
        source: PriceSource.manual,
        asOf: holding.manualPriceSetAt,
      );
    }

    final point = prices.latest(holding.catalogId, holding.priceKey);

    if (point != null) {
      final isStale = point.ageAt(now) > freshFor;

      // Stufe 4 — vorhanden, aber veraltet.
      if (isStale) {
        return Valuation(
          unitValue: point.valueEur,
          tier: ValuationTier.lastKnown,
          source: point.source,
          asOf: point.capturedAt,
          isStale: true,
        );
      }

      // Stufen 2 und 3 — frischer Marktpreis.
      return Valuation(
        unitValue: point.valueEur,
        tier: holding.isGraded
            ? ValuationTier.gradedMarket
            : ValuationTier.rawMarket,
        source: point.source,
        asOf: point.capturedAt,
      );
    }

    // Stufe 5 — kein Marktpreis, aber ein bekannter Einstand.
    if (!holding.purchasePrice.isZero) {
      return Valuation(
        unitValue: holding.purchasePrice,
        tier: ValuationTier.purchasePrice,
        source: PriceSource.purchasePrice,
        asOf: holding.purchaseDate,
      );
    }

    // Stufe 6 — die UI zeigt „—", niemals „0 €" (§5.6).
    return const Valuation.unavailable();
  }
}
