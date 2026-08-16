import '../../domain/models/catalog_item.dart';
import '../../domain/models/price_point.dart';

/// Eine Katalogkarte samt der Preise, die die Quelle mitgeliefert hat.
class CatalogCardResult {
  const CatalogCardResult({required this.card, this.prices = const []});

  final CatalogCard card;
  final List<PricePoint> prices;
}

/// Vertrag für jede Katalog- und Preisquelle (L5).
///
/// Die App kennt ausschließlich diese Schnittstelle. Ein Anbieterwechsel —
/// und die Recherche in §3 zeigt, dass damit zu rechnen ist — bleibt dadurch
/// ein Austausch dieser einen Implementierung.
abstract class CatalogSource {
  /// Name der Quelle für die Attribution im UI (§7 R2).
  String get attribution;

  /// Sucht Karten nach Namensfragment. Deutsche und englische Namen sollen
  /// beide treffen.
  Future<List<CatalogCard>> searchCards(String query, {int limit = 20});

  /// Vollständige Karte inklusive aktueller Preise.
  Future<CatalogCardResult?> cardDetails(String id);

  /// Aktualisiert Preise für mehrere Karten in einem Rutsch.
  Future<List<PricePoint>> pricesFor(Iterable<String> cardIds);
}

/// Fehler beim Zugriff auf eine externe Quelle.
///
/// Wird von der UI in einen erklärten Zustand übersetzt, nie in einen
/// technischen Fehlertext (§5.6).
class CatalogSourceException implements Exception {
  const CatalogSourceException(this.message, {this.isNetworkIssue = false});

  final String message;
  final bool isNetworkIssue;

  @override
  String toString() => 'CatalogSourceException: $message';
}
