import 'package:dio/dio.dart';

import '../../domain/models/catalog_item.dart';
import '../../domain/models/grading.dart';
import '../../domain/models/money.dart';
import '../../domain/models/price_point.dart';
import 'catalog_source.dart';

/// Katalog- und Preisquelle auf Basis von TCGdex (§3.3, §3.4).
///
/// Gewählt, weil TCGdex als einzige geprüfte Quelle deutsche Kartennamen
/// liefert (86,9 % aller Karten, rund 99 % der modernen Ären), kostenlos und
/// ohne Schlüssel arbeitet, Bilder pro Sprache bereitstellt und seit Kurzem
/// Cardmarket-Preise in EUR mitliefert.
///
/// Zwei bekannte Eigenheiten der Quelle sind hier bewusst behandelt:
/// 1. Ein deutsches Kartenbild existiert nicht immer — deshalb wird die
///    englische Bild-URL als Rückfall mitgeführt.
/// 2. Für manche Karten fehlen Preise ganz (ältere EX-/Full-Art-Karten, sehr
///    neue Sets, Regionalexklusive). Fehlende Preise sind kein Fehlerfall,
///    sondern führen zur nächsten Stufe der Bewertungs-Kaskade.
class TcgdexSource implements CatalogSource {
  TcgdexSource({Dio? dio, this.language = 'de'})
      : _dio = dio ?? _defaultDio();

  static const String baseUrl = 'https://api.tcgdex.net/v2';

  final Dio _dio;

  /// Sprachcode des Katalogs. `de` liefert deutsche Namen und Bilder.
  final String language;

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

    return data
        .whereType<Map<String, dynamic>>()
        .map(_cardFromBrief)
        .whereType<CatalogCard>()
        .toList();
  }

  @override
  Future<CatalogCardResult?> cardDetails(String id) async {
    final data = await _get<Map<String, dynamic>>('/$language/cards/$id');
    final card = _cardFromDetail(data);
    if (card == null) return null;
    return CatalogCardResult(
      card: card,
      prices: _pricesFrom(data, card),
    );
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

  // --------------------------------------------------------------- Abbildung

  CatalogCard? _cardFromBrief(Map<String, dynamic> json) {
    final id = json['id'] as String?;
    final name = json['name'] as String?;
    if (id == null || name == null) return null;

    final image = json['image'] as String?;
    final setId = id.split('-').first;

    return CatalogCard(
      id: id,
      setId: setId,
      setName: (json['set'] as Map<String, dynamic>?)?['name'] as String? ?? '',
      localId: json['localId']?.toString() ?? '',
      nameEn: name,
      nameDe: language == 'de' ? name : null,
      imageBase: image,
      imageBaseEn: image == null ? null : _swapLanguage(image, 'en'),
    );
  }

  CatalogCard? _cardFromDetail(Map<String, dynamic> json) {
    final id = json['id'] as String?;
    final name = json['name'] as String?;
    if (id == null || name == null) return null;

    final set = json['set'] as Map<String, dynamic>?;
    final cardCount = set?['cardCount'] as Map<String, dynamic>?;
    final image = json['image'] as String?;

    return CatalogCard(
      id: id,
      setId: set?['id'] as String? ?? id.split('-').first,
      setName: set?['name'] as String? ?? '',
      localId: json['localId']?.toString() ?? '',
      nameEn: name,
      nameDe: language == 'de' ? name : null,
      rarity: json['rarity'] as String?,
      imageBase: image,
      imageBaseEn: image == null ? null : _swapLanguage(image, 'en'),
      setCardCount: (cardCount?['official'] ?? cardCount?['total']) as int?,
      availableVariants: _variantsFrom(json['variants']),
    );
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

  /// Ersetzt den Sprachabschnitt einer Bild-URL, um den englischen Scan als
  /// Rückfall zu erhalten.
  String _swapLanguage(String url, String target) =>
      url.replaceFirst(RegExp('/$language/'), '/$target/');

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
      throw CatalogSourceException(
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
  _RetryInterceptor(this._dio, {this.maxAttempts = 3});

  final Dio _dio;
  final int maxAttempts;

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
