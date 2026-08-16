import 'grading.dart';

/// Bildqualität. TCGdex liefert eine Basis-URL, an die Qualität und Format
/// angehängt werden (§3.3) — `low` für Listen, `high` für die Detailansicht.
enum ImageQuality {
  low('low'),
  high('high');

  const ImageQuality(this.value);

  final String value;
}

/// Basis des Bild-CDN von TCGdex.
///
/// Das Schema ist dokumentiert und stabil:
/// `{basis}/{sprache}/{serie}/{set}/{nummer}/{qualität}.{format}`
/// — für Set-Logos entfällt der Nummern-Abschnitt.
/// Es steht hier, weil daraus Rückfall-Adressen gebildet werden, wenn die API
/// für eine Sprache kein Bild kennt (siehe [CatalogCard.imageCandidates]).
const String kTcgdexAssets = 'https://assets.tcgdex.net';

/// Ein Objekt aus dem Katalog: entweder eine Einzelkarte oder ein
/// versiegeltes Produkt. Beides kann im Portfolio gehalten werden.
sealed class CatalogItem {
  const CatalogItem();

  String get id;

  /// Name in der Anzeigesprache, mit Rückfall auf Englisch.
  String get displayName;

  /// Vollständige Bezeichnung inklusive Set-Kürzel und Nummer,
  /// z. B. „Mega-Glurak X-ex (PFL 013)".
  String get fullLabel;

  /// Zweite Zeile im UI, z. B. „Fatale Flammen · 013/94".
  String get subtitle;

  /// Adressen, unter denen ein Bild versucht werden soll — in dieser
  /// Reihenfolge. Mehrere, weil nicht für jede Karte in jeder Sprache ein
  /// Scan existiert.
  List<String> imageCandidates({ImageQuality quality = ImageQuality.high});

  /// Erste Bildadresse oder `null`.
  String? imageUrl({ImageQuality quality = ImageQuality.high}) {
    final candidates = imageCandidates(quality: quality);
    return candidates.isEmpty ? null : candidates.first;
  }

  /// Prüft, ob das Objekt zu einem Suchbegriff passt. Deckt Name, Set,
  /// Set-Kürzel und Kartennummer ab, damit „PFL 013" genauso trifft wie
  /// „Glurak".
  bool matches(String query);
}

/// Eine Sammelkarte aus dem Katalog.
class CatalogCard extends CatalogItem {
  const CatalogCard({
    required this.id,
    required this.setId,
    required this.setName,
    required this.localId,
    required this.nameEn,
    this.serieId = '',
    this.setAbbreviation,
    this.nameDe,
    this.rarity,
    this.imageBase,
    this.setCardCount,
    this.availableVariants = const [CardVariant.normal],
  });

  @override
  final String id;

  final String setId;
  final String setName;

  /// Serie, zu der das Set gehört (z. B. `sv`, `swsh`, `me`).
  /// Teil des Bildpfads und deshalb nötig, um Rückfall-Adressen zu bilden.
  final String serieId;

  /// Offizielles Set-Kürzel, z. B. `PFL`. Kommt vom Set-Endpunkt der API;
  /// die Kartenantwort selbst enthält es nicht.
  final String? setAbbreviation;

  /// Nummer innerhalb des Sets, z. B. „013".
  final String localId;

  final String nameEn;

  /// Deutscher Name — für rund 87 % aller Karten vorhanden, in den modernen
  /// Ären für praktisch alle (§3.3).
  final String? nameDe;

  final String? rarity;

  /// Bildadresse, die die API für die abgefragte Sprache geliefert hat.
  /// Fehlt, wenn für diese Sprache kein Scan existiert.
  final String? imageBase;

  final int? setCardCount;

  final List<CardVariant> availableVariants;

  bool get hasGermanName => nameDe != null && nameDe!.isNotEmpty;

  @override
  String get displayName => hasGermanName ? nameDe! : nameEn;

  /// „PFL 013" — oder nur die Nummer, solange das Kürzel unbekannt ist.
  String get reference {
    final abbreviation = setAbbreviation;
    if (abbreviation == null || abbreviation.isEmpty) return localId;
    return '$abbreviation $localId';
  }

  @override
  String get fullLabel =>
      reference.isEmpty ? displayName : '$displayName ($reference)';

  @override
  String get subtitle {
    final number = setCardCount != null ? '$localId/$setCardCount' : localId;
    return '$setName · $number';
  }

  @override
  List<String> imageCandidates({ImageQuality quality = ImageQuality.high}) {
    final urls = <String>[];

    void add(String? base) {
      if (base == null || base.isEmpty) return;
      final url = '$base/${quality.value}.webp';
      if (!urls.contains(url)) urls.add(url);
    }

    // Was die API geliefert hat, zuerst.
    add(imageBase);

    // Danach selbst gebildete Adressen. Der englische Scan ist der eigentliche
    // Rückfall: Er existiert fast immer, der deutsche nicht.
    if (serieId.isNotEmpty && setId.isNotEmpty && localId.isNotEmpty) {
      add('$kTcgdexAssets/de/$serieId/$setId/$localId');
      add('$kTcgdexAssets/en/$serieId/$setId/$localId');
    }

    return urls;
  }

  @override
  bool matches(String query) {
    final needle = query.trim().toLowerCase();
    if (needle.isEmpty) return true;

    final haystack = [
      displayName,
      nameEn,
      setName,
      localId,
      setAbbreviation ?? '',
      reference,
      fullLabel,
    ].join(' ').toLowerCase();

    // Jedes Wort muss vorkommen — so trifft „glurak pfl" auch dann, wenn die
    // Wörter im Namen weit auseinanderliegen.
    return needle.split(RegExp(r'\s+')).every(haystack.contains);
  }

  CatalogCard copyWith({
    String? serieId,
    String? setAbbreviation,
    String? setName,
    int? setCardCount,
    String? imageBase,
  }) => CatalogCard(
    id: id,
    setId: setId,
    setName: setName ?? this.setName,
    localId: localId,
    nameEn: nameEn,
    serieId: serieId ?? this.serieId,
    setAbbreviation: setAbbreviation ?? this.setAbbreviation,
    nameDe: nameDe,
    rarity: rarity,
    imageBase: imageBase ?? this.imageBase,
    setCardCount: setCardCount ?? this.setCardCount,
    availableVariants: availableVariants,
  );
}

/// Produkttyp eines versiegelten Artikels.
enum SealedProductType {
  display('display', 'Display'),
  eliteTrainerBox('etb', 'Top-Trainer-Box'),
  boosterBundle('bundle', 'Booster Bundle'),
  tin('tin', 'Tin'),
  collectionBox('collection', 'Collection Box'),
  blister('blister', 'Blister'),
  boosterPack('pack', 'Booster'),
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
    this.serieId,
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

  /// Serie des zugehörigen Sets — erlaubt es, das offizielle Set-Logo als
  /// Produktbild zu zeigen.
  final String? serieId;

  final String? setName;
  final String language;
  final String? image;
  final bool isCustom;

  @override
  String get displayName => name;

  @override
  String get fullLabel => name;

  @override
  String get subtitle {
    final parts = <String>[type.label, language];
    if (setName != null && setName!.isNotEmpty) parts.insert(0, setName!);
    return parts.join(' · ');
  }

  @override
  List<String> imageCandidates({ImageQuality quality = ImageQuality.high}) {
    final urls = <String>[];
    if (image != null && image!.isNotEmpty) urls.add(image!);

    // Für versiegelte Produkte gibt es keine Produktfotos in den geprüften
    // Quellen (§3.5). Das offizielle Set-Logo ist die ehrlichste verfügbare
    // Darstellung — es zeigt, worum es geht, ohne etwas vorzutäuschen.
    final serie = serieId;
    final set = setId;
    if (serie != null &&
        set != null &&
        serie.isNotEmpty &&
        set.isNotEmpty) {
      urls
        ..add('$kTcgdexAssets/de/$serie/$set/logo.webp')
        ..add('$kTcgdexAssets/en/$serie/$set/logo.webp');
    }

    return urls;
  }

  /// Set-Logos sind breite Grafiken, keine hochkant stehenden Karten.
  bool get rendersAsLogo => image == null || image!.isEmpty;

  @override
  bool matches(String query) {
    final needle = query.trim().toLowerCase();
    if (needle.isEmpty) return true;

    final haystack = [
      name,
      type.label,
      setName ?? '',
      language,
    ].join(' ').toLowerCase();

    return needle.split(RegExp(r'\s+')).every(haystack.contains);
  }
}
