import '../models/catalog_item.dart';
import '../models/holding.dart';
import '../models/portfolio_snapshot.dart';
import '../models/portfolio_snapshot.dart' show PortfolioSnapshot;
import '../models/price_point.dart';

/// Zugriff auf die lokale Sammlung.
///
/// Die Schnittstelle liegt bewusst in der Domänenschicht: Die Anwendungslogik
/// kennt nur diesen Vertrag, nicht SQLite. Das hält die Bestandsdaten
/// austauschbar und die Logik testbar (L2, L5).
abstract class CollectionRepository {
  /// Bestand des Portfolios, reaktiv — die UI aktualisiert sich selbst,
  /// sobald eine Position hinzukommt oder verschwindet.
  Stream<List<Holding>> watchHoldings(String portfolioId);

  Future<List<Holding>> holdings(String portfolioId);

  Future<Holding?> holding(String id);

  Future<void> saveHolding(Holding holding);

  Future<void> deleteHolding(String id);

  /// Katalogobjekte aus dem lokalen Zwischenspeicher.
  Future<Map<String, CatalogItem>> catalogItems(Iterable<String> ids);

  Future<void> cacheCatalogItems(Iterable<CatalogItem> items);

  /// Der jeweils jüngste Preis je Katalogobjekt und Preisschlüssel.
  Future<PriceBook> latestPrices();

  /// Preise werden immer angehängt, nie überschrieben (§4.4).
  Future<void> recordPrices(Iterable<PricePoint> points);

  Future<List<PricePoint>> priceHistory(String catalogId, PriceKey priceKey);

  Future<List<PortfolioSnapshot>> snapshots(String portfolioId);

  Future<void> saveSnapshot(PortfolioSnapshot snapshot);

  /// Vollständiger Export als JSON-taugliche Struktur (§2.1, Backup).
  Future<Map<String, Object?>> exportAll(String portfolioId);
}
