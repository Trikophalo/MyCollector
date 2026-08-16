import 'package:dio/dio.dart';

import '../../domain/models/catalog_item.dart';
import '../../domain/models/grading.dart';
import '../../domain/models/money.dart';
import '../../domain/models/price_point.dart';
import 'catalog_source.dart';

/// Beschreibung eines Sets, wie sie nur der Set-Endpunkt liefert.
///
/// Die Kartenantwort enthält weder das offizielle Kürzel noch die Serie —
/// beides wird aber gebraucht: das Kürzel für die Bezeichnung „(PFL 013)",
/// die Serie für den Bildpfad.
class TcgdexSetInfo {
  const TcgdexSetInfo({
    required this.id,
    required this.name,
    this.serieId = '',
    this.abbreviation,
    this.cardCount,
  });

  final String id;
  final String name;
  final String serieId;
  final String? abbreviation;
  final int? cardCount;
}

/// Katalog- und Preisquelle auf Basis von TCGdex (§3.3, §3.4).
///
/// Gewählt, weil TCGdex als einzige geprüfte Quelle deutsche Kartennamen
/// liefert (86,9 % aller Karten, rund 99 % der modernen Ären), kostenlos und
/// ohne Schlüssel arbeitet, Bilder pro Sprache bereitstellt und seit Kurzem
/// Cardmarket-Preise in EUR mitliefert.
///
/// Drei Eigenheiten der Quelle sind hier bewusst behandelt:
/// 1. Ein Bild wird nur ausgeliefert, wenn für die abgefragte Sprache ein Scan
///    existiert. Fehlt der deutsche, liefert die API **kein** Feld — die
///    Rückfall-Adresse muss daher selbst gebildet werden, wofür die Serie
///    nötig ist (siehe [TcgdexSetInfo]).
/// 2. Die Trefferliste der Suche enthält nur Kennung, Nummer, Name und Bild —
///    kein Set. Set-Angaben werden über die Kennung nachgeladen.
/// 3. Für manche Karten fehlen Preise ganz (ältere EX-/Full-Art-Karten, sehr
///    neue Sets, Regionalexklusive). Das ist kein Fehlerfall, sondern führt
///    zur nächsten Stufe der Bewertungs-Kaskade.
class TcgdexSource implements CatalogSource {
  TcgdexSource({Dio? dio, this.language = 'de'}) : _dio = dio ?? _defaultDio();

  static const String baseUrl = 'https://api.tcgdex.net/v2';

  final Dio _dio;

  /// Sprachcode des Katalogs. `de` liefert deutsche Namen und Bilder.
  final String language;

  /// Set-Angaben ändern sich nach Erscheinen nicht mehr und werden deshalb für
  /// die Dauer der Sitzung behalten.
  final Map<String, TcgdexSetInfo?> _setCache = {};

  @override
  String get attribution => 'Kartendaten & Preise: TCGdex (Cardmarket)';

  static Dio _defaultDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
        headers: const {'Accept': 'application/json'},
      ),
    );
    dio.interceptors.add(_RetryInterceptor(dio));
    return dio;
  }

  @override
  Future<List<CatalogCard>> searchCards(String query, {int limit = 20}) async {
    final trimmed = query.trim();
    if (trimmed.length < 2) return const [];

    final data = await _get<List<dynamic>>(
      '/$language/cards',
      queryParameters: {
        'name': 'like:$trimmed',
        'pagination:page': 1,
        'pagination:itemsPerPage': limit,
      },
    );

    final briefs = data.whereType<Map<String, dynamic>>().toList();

    // Set-Angaben einmal je vorkommendem Set nachladen, nicht je Karte.
    final setIds = briefs
        .map((json) => _setIdFrom(json))
        .whereType<String>()
        .toSet();
    final sets = <String, TcgdexSetInfo?>{};
    for (final setId in setIds) {
      sets[setId] = await _setInfo(setId);
    }

    return briefs
        .map((json) => _cardFromBrief(json, sets))
        .whereType<CatalogCard>()
        .toList();
  }

  @override
  Future<CatalogCardResult?> cardDetails(String id) async {
    final data = await _get<Map<String, dynamic>>('/$language/cards/$id');

    final setId = (data['set'] as Map<String, dynamic>?)?['id'] as String?;
    final info = setId == null ? null : await _setInfo(setId);

    final card = _cardFromDetail(data, info);
    if (card == null) return null;

    return CatalogCardResult(card: card, prices: _pricesFrom(data, card));
  }

  @override
  Future<List<PricePoint>> pricesFor(Iterable<String> cardIds) async {
    final points = <PricePoint>[];
    // TCGdex bietet keinen Sammelabruf für Preise; die Anfragen laufen daher
    // einzeln, aber nur für Karten, die tatsächlich im Portfolio liegen
    // (bedarfsgetrieben, §4.5).
    for (final id in cardIds) {
      try {
        final result = await cardDetails(id);
        if (result != null) points.addAll(result.prices);
      } on CatalogSourceException {
        // Eine einzelne fehlgeschlagene Karte darf den Gesamtabruf nicht
        // abbrechen — die Kaskade fängt fehlende Preise auf.
        continue;
      }
    }
    return points;
  }

  /// Lädt Set-Angaben inklusive Kürzel und Serie.
  Future<TcgdexSetInfo?> _setInfo(String setId) async {
    if (_setCache.containsKey(setId)) return _setCache[setId];

    try {
      final data = await _get<Map<String, dynamic>>('/$language/sets/$setId');
      final abbreviation = data['abbreviation'] as Map<String, dynamic>?;
      final cardCount = data['cardCount'] as Map<String, dynamic>?;
      final serie = data['serie'] as Map<String, dynamic>?;

      final info = TcgdexSetInfo(
        id: data['id'] as String? ?? setId,
        name: data['name'] as String? ?? '',
        serieId: serie?['id'] as String? ?? '',
        abbreviation:
            abbreviation?['official'] as String? ??
            abbreviation?['localized'] as String?,
        cardCount: (cardCount?['official'] ?? cardCount?['total']) as int?,
      );
      _setCache[setId] = info;
      return info;
    } on CatalogSourceException {
      // Ohne Set-Angaben bleibt die Karte nutzbar, nur ohne Kürzel.
      _setCache[setId] = null;
      return null;
    }
  }

  /// Leitet die Set-Kennung aus der Kartenkennung ab: `me02-013` → `me02`.
  ///
  /// Kann nicht einfach am ersten Bindestrich getrennt werden, weil
  /// Set-Kennungen selbst welche enthalten dürfen.
  String? _setIdFrom(Map<String, dynamic> json) {
    final id = json['id'] as String?;
    final localId = json['localId']?.toString();
    if (id == null) return null;
    if (localId != null && id.endsWith('-$localId')) {
      return id.substring(0, id.length - localId.length - 1);
    }
    final index = id.lastIndexOf('-');
    return index > 0 ? id.substring(0, index) : null;
  }

  // --------------------------------------------------------------- Abbildung

  CatalogCard? _cardFromBrief(
    Map<String, dynamic> json,
    Map<String, TcgdexSetInfo?> sets,
  ) {
    final id = json['id'] as String?;
    final name = json['name'] as String?;
    if (id == null || name == null) return null;

    final setId = _setIdFrom(json) ?? '';
    final info = sets[setId];

    return CatalogCard(
      id: id,
      setId: setId,
      setName: info?.name ?? '',
      localId: json['localId']?.toString() ?? '',
      nameEn: name,
      nameDe: language == 'de' ? name : null,
      serieId: info?.serieId ?? '',
      setAbbreviation: info?.abbreviation,
      setCardCount: info?.cardCount,
      imageBase: json['image'] as String?,
    );
  }

  CatalogCard? _cardFromDetail(
    Map<String, dynamic> json,
    TcgdexSetInfo? info,
  ) {
    final id = json['id'] as String?;
    final name = json['name'] as String?;
    if (id == null || name == null) return null;

    final set = json['set'] as Map<String, dynamic>?;
    final cardCount = set?['cardCount'] as Map<String, dynamic>?;

    return CatalogCard(
      id: id,
      setId: set?['id'] as String? ?? info?.id ?? '',
      setName: set?['name'] as String? ?? info?.name ?? '',
      localId: json['localId']?.toString() ?? '',
      nameEn: name,
      nameDe: language == 'de' ? name : null,
      serieId: info?.serieId ?? _serieFromLogo(set?['logo'] as String?) ?? '',
      setAbbreviation: info?.abbreviation,
      rarity: json['rarity'] as String?,
      imageBase: json['image'] as String?,
      setCardCount:
          (cardCount?['official'] ?? cardCount?['total']) as int? ??
          info?.cardCount,
      availableVariants: _variantsFrom(json['variants']),
    );
  }

  /// Zweiter Weg zur Serie: Sie steckt im Pfad des Set-Logos
  /// (`.../de/{serie}/{set}/logo`). Greift, falls der Set-Endpunkt scheitert.
  String? _serieFromLogo(String? logoUrl) {
    if (logoUrl == null || logoUrl.isEmpty) return null;
    final parts = Uri.tryParse(logoUrl)?.pathSegments;
    // Erwartet: [sprache, serie, set, 'logo']
    if (parts == null || parts.length < 4) return null;
    return parts[parts.length - 3];
  }

  List<CardVariant> _variantsFrom(Object? raw) {
    if (raw is! Map<String, dynamic>) return const [CardVariant.normal];

    final variants = <CardVariant>[
      if (raw['normal'] == true) CardVariant.normal,
      if (raw['holo'] == true) CardVariant.holo,
      if (raw['reverse'] == true) CardVariant.reverseHolo,
      if (raw['firstEdition'] == true) CardVariant.firstEdition,
    ];
    return variants.isEmpty ? const [CardVariant.normal] : variants;
  }

  /// Liest den Cardmarket-Block aus und erzeugt Preispunkte je Druckvariante.
  ///
  /// Cardmarket-Preise sind bereits in EUR — der für den deutschsprachigen
  /// Raum relevante Markt (L1). Es wird der Trendpreis bevorzugt und auf den
  /// Durchschnitt zurückgefallen.
  List<PricePoint> _pricesFrom(Map<String, dynamic> json, CatalogCard card) {
    final pricing = json['pricing'] as Map<String, dynamic>?;
    final cardmarket = pricing?['cardmarket'] as Map<String, dynamic>?;
    if (cardmarket == null) return const [];

    final capturedAt =
        DateTime.tryParse(cardmarket['updated']?.toString() ?? '') ??
        DateTime.now();

    final points = <PricePoint>[];

    void add(CardVariant variant, List<String> keys) {
      final cents = _firstPrice(cardmarket, keys);
      if (cents == null) return;
      points.add(
        PricePoint.eur(
          catalogId: card.id,
          priceKey: PriceKey.raw(variant),
          source: PriceSource.tcgdexCardmarket,
          value: Money(cents),
          capturedAt: capturedAt,
        ),
      );
    }

    add(CardVariant.normal, const ['trend', 'avg', 'avg7', 'low']);
    add(CardVariant.holo, const ['trend-holo', 'avg-holo', 'avg7-holo']);
    // Cardmarket führt Reverse Holo nicht als eigenes Feld; der Holo-Preis
    // ist die nächstliegende Referenz und wird als solche gekennzeichnet.
    add(CardVariant.reverseHolo, const ['trend-holo', 'avg-holo']);

    return points;
  }

  int? _firstPrice(Map<String, dynamic> source, List<String> keys) {
    for (final key in keys) {
      final raw = source[key];
      if (raw is num && raw > 0) return (raw * 100).round();
    }
    return null;
  }

  // ------------------------------------------------------------------- HTTP

  Future<T> _get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        path,
        queryParameters: queryParameters,
      );
      final data = response.data;
      if (data is T) return data;
      throw CatalogSourceException(
        'Unerwartetes Antwortformat von TCGdex für $path',
      );
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        throw const CatalogSourceException('Nicht im Katalog gefunden');
      }
      throw const CatalogSourceException(
        'TCGdex nicht erreichbar',
        isNetworkIssue: true,
      );
    }
  }
}

/// Wiederholt fehlgeschlagene Anfragen mit wachsendem Abstand (§4.5).
///
/// Netzwerkfehler und 5xx werden erneut versucht; 4xx nicht — ein nicht
/// gefundener Datensatz wird durch Wiederholen nicht besser.
class _RetryInterceptor extends Interceptor {
  _RetryInterceptor(this._dio);

  final Dio _dio;

  int get maxAttempts => _backoff.length;

  static const List<Duration> _backoff = [
    Duration(seconds: 2),
    Duration(seconds: 4),
    Duration(seconds: 8),
  ];

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final attempt = (err.requestOptions.extra['retryAttempt'] as int? ?? 0) + 1;
    final status = err.response?.statusCode;
    final isRetryable = status == null || status >= 500;

    if (!isRetryable || attempt >= maxAttempts) {
      return handler.next(err);
    }

    await Future<void>.delayed(_backoff[attempt - 1]);
    err.requestOptions.extra['retryAttempt'] = attempt;

    try {
      final response = await _dio.fetch<dynamic>(err.requestOptions);
      return handler.resolve(response);
    } on DioException catch (retryError) {
      return handler.next(retryError);
    }
  }
}
