import 'grading.dart';
import 'money.dart';

/// Woher ein Preis stammt. Jeder angezeigte Preis trägt seine Quelle (L3).
enum PriceSource {
  tcgdexCardmarket('Cardmarket', 'über TCGdex, EU-Markt'),
  cardTrader('CardTrader', 'EU-Marktplatz'),
  pokemonPriceTracker('PokemonPriceTracker', 'PSA-Verkäufe, US-Markt'),
  priceCharting('PriceCharting', 'eBay-Verkäufe, US-Markt'),
  ebayBrowse('eBay.de', 'aktuelle Angebote'),
  manual('Eigener Preis', 'manuell gesetzt'),
  purchasePrice('Kaufpreis', 'kein Marktpreis verfügbar');

  const PriceSource(this.label, this.hint);

  final String label;
  final String hint;

  /// Quellen, die den US-Markt abbilden, werden im UI gekennzeichnet (§3.6).
  bool get isUsMarket =>
      this == PriceSource.priceCharting ||
      this == PriceSource.pokemonPriceTracker;
}

/// Schlüssel, unter dem ein Preis für ein Katalogobjekt abgelegt wird.
///
/// Trennt Rohkarten-Preise nach Druckvariante und gegradete Preise nach
/// Anbieter und Note: `raw:holo`, `PSA:10`, `BGS:9.5`, `sealed`.
class PriceKey {
  const PriceKey(this.value);

  factory PriceKey.raw(CardVariant variant) => PriceKey('raw:${variant.code}');

  factory PriceKey.graded(Grading grading) =>
      PriceKey('${grading.grader.code}:${grading.gradeLabel}');

  static const PriceKey sealed = PriceKey('sealed');

  final String value;

  bool get isGraded => !value.startsWith('raw') && value != sealed.value;

  @override
  bool operator ==(Object other) => other is PriceKey && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}

/// Ein einzelner beobachteter Preis zu einem Zeitpunkt.
///
/// Preise werden ausschließlich angehängt, nie überschrieben (§4.4) — daraus
/// entstehen Wertkurve, „Stand"-Anzeige und späterer Backfill.
class PricePoint {
  const PricePoint({
    required this.catalogId,
    required this.priceKey,
    required this.source,
    required this.value,
    required this.valueEur,
    required this.capturedAt,
  });

  /// Preis, der bereits in EUR vorliegt und keine Umrechnung braucht.
  factory PricePoint.eur({
    required String catalogId,
    required PriceKey priceKey,
    required PriceSource source,
    required Money value,
    required DateTime capturedAt,
  }) {
    assert(value.currency == Currency.eur, 'PricePoint.eur erwartet EUR');
    return PricePoint(
      catalogId: catalogId,
      priceKey: priceKey,
      source: source,
      value: value,
      valueEur: value,
      capturedAt: capturedAt,
    );
  }

  final String catalogId;
  final PriceKey priceKey;
  final PriceSource source;

  /// Preis in der Originalwährung der Quelle.
  final Money value;

  /// Auf EUR umgerechneter Preis, eingefroren zum Abrufzeitpunkt (T7).
  final Money valueEur;

  final DateTime capturedAt;

  bool get wasConverted => value.currency != Currency.eur;

  Duration ageAt(DateTime now) => now.difference(capturedAt);

  @override
  String toString() =>
      'PricePoint($catalogId, $priceKey, $valueEur, ${source.label})';
}

/// Nachschlagewerk über die jeweils jüngsten Preise.
///
/// Bewusst eine eigene Struktur statt einer nackten Map: Die Bewertungslogik
/// soll nicht wissen, ob die Preise aus der Datenbank, aus dem Netz oder aus
/// einem Test stammen.
class PriceBook {
  PriceBook(Iterable<PricePoint> points) {
    for (final point in points) {
      final key = _key(point.catalogId, point.priceKey);
      final existing = _latest[key];
      if (existing == null || point.capturedAt.isAfter(existing.capturedAt)) {
        _latest[key] = point;
      }
    }
  }

  PriceBook.empty();

  final Map<String, PricePoint> _latest = {};

  PricePoint? latest(String catalogId, PriceKey priceKey) =>
      _latest[_key(catalogId, priceKey)];

  bool get isEmpty => _latest.isEmpty;

  int get length => _latest.length;

  static String _key(String catalogId, PriceKey priceKey) =>
      '$catalogId|${priceKey.value}';
}
