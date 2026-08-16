import 'money.dart';
import 'price_point.dart';

/// Stufe der Bewertungs-Kaskade, die für einen Wert gegriffen hat (§4.5).
///
/// Die Reihenfolge der Werte ist die Reihenfolge der Kaskade: Die erste
/// zutreffende Stufe gewinnt.
enum ValuationTier {
  /// Vom Sammler selbst gesetzter Preis.
  manualOverride('Eigener Preis'),

  /// Automatischer Preis für eine gegradete Karte.
  gradedMarket('Marktpreis gegradet'),

  /// Automatischer Marktpreis für Rohkarte oder versiegeltes Produkt.
  rawMarket('Marktpreis'),

  /// Letzter bekannter Preis, älter als das Aktualisierungsintervall.
  lastKnown('Letzter bekannter Preis'),

  /// Notwert: Es existiert kein Marktpreis, der Kaufpreis dient als Anhalt.
  purchasePrice('Kaufpreis'),

  /// Weder Markt- noch Kaufpreis vorhanden.
  unavailable('Kein Preis verfügbar');

  const ValuationTier(this.label);

  final String label;

  /// Stufen, bei denen der Wert im UI zurückhaltend dargestellt wird.
  bool get isFallback =>
      this == ValuationTier.lastKnown ||
      this == ValuationTier.purchasePrice ||
      this == ValuationTier.unavailable;
}

/// Ergebnis der Bewertung einer einzelnen Position — der Wert **je Stück**.
class Valuation {
  const Valuation({
    required this.unitValue,
    required this.tier,
    this.source,
    this.asOf,
    this.isStale = false,
  });

  const Valuation.unavailable()
      : unitValue = const Money.zero(),
        tier = ValuationTier.unavailable,
        source = null,
        asOf = null,
        isStale = false;

  /// Wert je Stück in EUR.
  final Money unitValue;

  final ValuationTier tier;
  final PriceSource? source;

  /// Zeitpunkt, auf den sich der Wert bezieht.
  final DateTime? asOf;

  /// Wahr, wenn der Preis älter ist als das erwartete Intervall — die UI
  /// zeigt dann ein „Stand"-Kennzeichen statt des Werts allein (L3).
  final bool isStale;

  bool get hasValue => tier != ValuationTier.unavailable;

  /// Kennzeichnet Werte, die aus einer US-Quelle umgerechnet wurden (§3.6).
  bool get isUsMarket => source?.isUsMarket ?? false;

  @override
  String toString() => 'Valuation($unitValue, ${tier.name})';
}
