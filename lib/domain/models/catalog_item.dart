import 'grading.dart';

/// Bildqualität. TCGdex liefert eine Basis-URL, an die Qualität und Format
/// angehängt werden (§3.3) — `low` für Listen, `high` für die Detailansicht.
enum ImageQuality {
  low('low'),
  high('high');

  const ImageQuality(this.value);

  final String value;
}

/// Ein Objekt aus dem Katalog: entweder eine Einzelkarte oder ein
/// versiegeltes Produkt. Beides kann im Portfolio gehalten werden.
sealed class CatalogItem {
  const CatalogItem();

  String get id;

  /// Name in der Anzeigesprache, mit Rückfall auf Englisch.
  String get displayName;

  /// Zweite Zeile im UI, z. B. „Schwert & Schild · 136/202".
  String get subtitle;

  String? imageUrl({ImageQuality quality = ImageQuality.high});
}

/// Eine Sammelkarte aus dem Katalog.
class CatalogCard extends CatalogItem {
  const CatalogCard({
    required this.id,
    required this.setId,
    required this.setName,
    required this.localId,
    required this.nameEn,
    this.nameDe,
    this.rarity,
    this.imageBase,
    this.imageBaseEn,
    this.setCardCount,
    this.availableVariants = const [CardVariant.normal],
  });

  @override
  final String id;

  final String setId;
  final String setName;

  /// Nummer innerhalb des Sets, z. B. „136".
  final String localId;

  final String nameEn;

  /// Deutscher Name — für rund 87 % aller Karten vorhanden, in den modernen
  /// Ären für praktisch alle (§3.3).
  final String? nameDe;

  final String? rarity;

  /// Basis-URL des deutschen Kartenbilds, ohne Qualität und Dateiendung.
  final String? imageBase;

  /// Englisches Bild als Rückfall — ein deutscher Scan existiert nicht immer.
  final String? imageBaseEn;

  final int? setCardCount;

  final List<CardVariant> availableVariants;

  bool get hasGermanName => nameDe != null && nameDe!.isNotEmpty;

  @override
  String get displayName => hasGermanName ? nameDe! : nameEn;

  @override
  String get subtitle {
    final number = setCardCount != null ? '$localId/$setCardCount' : localId;
    return '$setName · $number';
  }

  @override
  String? imageUrl({ImageQuality quality = ImageQuality.high}) {
    final base = imageBase ?? imageBaseEn;
    if (base == null || base.isEmpty) return null;
    return '$base/${quality.value}.webp';
  }

  CatalogCard copyWith({String? nameDe, String? imageBase}) => CatalogCard(
        id: id,
        setId: setId,
        setName: setName,
        localId: localId,
        nameEn: nameEn,
        nameDe: nameDe ?? this.nameDe,
        rarity: rarity,
        imageBase: imageBase ?? this.imageBase,
        imageBaseEn: imageBaseEn,
        setCardCount: setCardCount,
        availableVariants: availableVariants,
      );
}

/// Produkttyp eines versiegelten Artikels.
enum SealedProductType {
  display('display', 'Display'),
  eliteTrainerBox('etb', 'Elite Trainer Box'),
  boosterBundle('bundle', 'Booster Bundle'),
  tin('tin', 'Tin'),
  collectionBox('collection', 'Collection Box'),
  blister('blister', 'Blister'),
  boosterPack('pack', 'Booster Pack'),
  other('other', 'Sonstiges');

  const SealedProductType(this.code, this.label);

  final String code;
  final String label;

  static SealedProductType fromCode(String? code) =>
      SealedProductType.values.firstWhere(
        (t) => t.code == code,
        orElse: () => SealedProductType.other,
      );
}

/// Ein versiegeltes Produkt.
///
/// [isCustom] markiert selbst angelegte Produkte. Da es im MVP keine
/// verlässliche Sealed-Preisquelle in EUR gibt (§3.5), ist das der Regelfall
/// und kein Notbehelf.
class SealedProduct extends CatalogItem {
  const SealedProduct({
    required this.id,
    required this.name,
    required this.type,
    this.setId,
    this.setName,
    this.language = 'DE',
    this.image,
    this.isCustom = false,
  });

  @override
  final String id;

  final String name;
  final SealedProductType type;
  final String? setId;
  final String? setName;
  final String language;
  final String? image;
  final bool isCustom;

  @override
  String get displayName => name;

  @override
  String get subtitle {
    final parts = <String>[type.label, language];
    if (setName != null && setName!.isNotEmpty) parts.insert(0, setName!);
    return parts.join(' · ');
  }

  @override
  String? imageUrl({ImageQuality quality = ImageQuality.high}) => image;
}
