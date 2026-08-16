import 'grading.dart';
import 'money.dart';
import 'price_point.dart';

/// Art des gehaltenen Objekts.
enum HoldingType {
  card('card', 'Karte'),
  sealed('sealed', 'Versiegelt');

  const HoldingType(this.code, this.label);

  final String code;
  final String label;

  static HoldingType fromCode(String? code) => HoldingType.values.firstWhere(
    (t) => t.code == code,
    orElse: () => HoldingType.card,
  );
}

/// Bestimmt, ob der Wert automatisch ermittelt oder manuell gesetzt wird.
enum PriceMode {
  auto('auto'),
  manual('manual');

  const PriceMode(this.code);

  final String code;

  static PriceMode fromCode(String? code) => PriceMode.values.firstWhere(
    (m) => m.code == code,
    orElse: () => PriceMode.auto,
  );
}

/// Eine Position im Portfolio — ein einzelner Kauf („Lot").
///
/// Zweimal dieselbe Karte gekauft ergibt zwei Positionen mit eigenem
/// Kaufpreis und Kaufdatum (§4.4). Nur so bleiben Einstandsrendite und
/// spätere Teilverkäufe korrekt.
class Holding {
  const Holding({
    required this.id,
    required this.portfolioId,
    required this.type,
    required this.catalogId,
    required this.quantity,
    required this.purchaseDate,
    required this.createdAt,
    this.variant = CardVariant.normal,
    this.condition = CardCondition.nearMint,
    this.grading,
    this.certificateNumber,
    this.purchasePrice = const Money.zero(),
    this.priceMode = PriceMode.auto,
    this.manualPrice,
    this.manualPriceSetAt,
    this.note,
  }) : assert(quantity > 0, 'Eine Position braucht mindestens die Menge 1');

  final String id;
  final String portfolioId;
  final HoldingType type;

  /// Verweis auf [CatalogCard.id] bzw. [SealedProduct.id].
  final String catalogId;

  final int quantity;
  final DateTime purchaseDate;
  final DateTime createdAt;

  final CardVariant variant;
  final CardCondition condition;

  /// Gesetzt, wenn die Karte gegradet ist. Das Grading gehört zur Position,
  /// nicht zur Katalogkarte (§4.4).
  final Grading? grading;

  final String? certificateNumber;

  /// Kaufpreis je Stück.
  final Money purchasePrice;

  final PriceMode priceMode;

  /// Selbst gesetzter Wert je Stück; nur relevant bei [PriceMode.manual].
  final Money? manualPrice;

  /// Wann der eigene Preis gesetzt wurde — die UI zeigt ihn mit Datum an (L3).
  final DateTime? manualPriceSetAt;

  final String? note;

  bool get isGraded => grading != null;

  bool get isSealed => type == HoldingType.sealed;

  bool get hasManualPrice =>
      priceMode == PriceMode.manual && manualPrice != null;

  /// Gesamter Einstand dieser Position.
  Money get investedTotal => purchasePrice.times(quantity);

  /// Preisschlüssel, unter dem der Marktpreis für diese Position gesucht wird.
  PriceKey get priceKey {
    if (isSealed) return PriceKey.sealed;
    final grading = this.grading;
    if (grading != null) return PriceKey.graded(grading);
    return PriceKey.raw(variant);
  }

  /// Kurzbeschreibung der Ausprägung, z. B. „PSA 10" oder „Reverse Holo · NM".
  String get variantLabel {
    if (isSealed) return 'Versiegelt';
    final grading = this.grading;
    if (grading != null) return grading.label;
    return '${variant.label} · ${condition.code}';
  }

  Holding copyWith({
    int? quantity,
    DateTime? purchaseDate,
    CardVariant? variant,
    CardCondition? condition,
    Grading? grading,
    bool clearGrading = false,
    String? certificateNumber,
    Money? purchasePrice,
    PriceMode? priceMode,
    Money? manualPrice,
    DateTime? manualPriceSetAt,
    bool clearManualPrice = false,
    String? note,
  }) => Holding(
    id: id,
    portfolioId: portfolioId,
    type: type,
    catalogId: catalogId,
    quantity: quantity ?? this.quantity,
    purchaseDate: purchaseDate ?? this.purchaseDate,
    createdAt: createdAt,
    variant: variant ?? this.variant,
    condition: condition ?? this.condition,
    grading: clearGrading ? null : (grading ?? this.grading),
    certificateNumber: certificateNumber ?? this.certificateNumber,
    purchasePrice: purchasePrice ?? this.purchasePrice,
    priceMode: priceMode ?? this.priceMode,
    manualPrice: clearManualPrice ? null : (manualPrice ?? this.manualPrice),
    manualPriceSetAt: clearManualPrice
        ? null
        : (manualPriceSetAt ?? this.manualPriceSetAt),
    note: note ?? this.note,
  );

  @override
  String toString() => 'Holding($id, $catalogId, ${quantity}x, $variantLabel)';
}
