import '../models/catalog_item.dart';
import '../models/holding.dart';

/// Baut Verweise auf eBay.de für eine Position.
///
/// **Warum ein Verweis und keine API-Anbindung?**
/// Für tatsächlich erzielte Verkaufspreise gibt es bei eBay genau eine
/// offizielle Schnittstelle — die Marketplace Insights API. Sie ist als
/// „Limited Release" eingestuft und laut eBay für neue Nutzer geschlossen;
/// die frühere Finding API mit `findCompletedItems` wurde am 05.02.2025
/// abgeschaltet (§3.6). Ein Auslesen der Verkaufsseiten scheidet aus:
/// Es verstößt gegen die AGB und berührt in Deutschland zusätzlich das
/// Datenbankherstellerrecht (§§ 87a ff. UrhG, → R3).
///
/// Was bleibt, ist der ehrliche Weg: eBay mit einer passend vorbereiteten
/// Suche öffnen. Der Sammler sieht die echten Verkaufspreise auf eBay selbst
/// und kann den für ihn passenden Wert mit zwei Tipps als eigenen Preis
/// übernehmen. Das ist zulässig, kostenlos, braucht keinen Zugangsschlüssel
/// und liefert die Angabe, um die es geht.
abstract final class EbayLookup {
  /// Verkaufte Angebote, neueste zuerst.
  ///
  /// `LH_Sold` und `LH_Complete` beschränken auf abgeschlossene Verkäufe,
  /// `_sop=13` sortiert nach Verkaufsende absteigend — der oberste Treffer ist
  /// damit der zuletzt verkaufte.
  static Uri soldListings({
    required CatalogItem? item,
    required Holding holding,
  }) => _search(
    _queryFor(item: item, holding: holding),
    extra: const {'LH_Sold': '1', 'LH_Complete': '1', '_sop': '13'},
  );

  /// Aktuelle Angebote — Angebotspreise, keine Verkaufspreise.
  static Uri activeListings({
    required CatalogItem? item,
    required Holding holding,
  }) => _search(
    _queryFor(item: item, holding: holding),
    extra: const {'_sop': '15'},
  );

  /// Suchbegriff aus Kartenname, Set-Kürzel, Nummer und Grading.
  ///
  /// Bewusst knapp gehalten: Zu viele Begriffe führen bei eBay schnell zu
  /// null Treffern, weil Verkäufer ihre Angebote sehr unterschiedlich
  /// benennen.
  static String _queryFor({
    required CatalogItem? item,
    required Holding holding,
  }) {
    final parts = <String>[];

    switch (item) {
      case CatalogCard card:
        parts.add(card.displayName);
        if (card.localId.isNotEmpty) parts.add(card.localId);
      case SealedProduct product:
        parts.add(product.name);
      case null:
        parts.add(holding.catalogId);
    }

    final grading = holding.grading;
    if (grading != null) parts.add(grading.label);

    return parts.where((p) => p.trim().isNotEmpty).join(' ');
  }

  static Uri _search(String query, {Map<String, String> extra = const {}}) =>
      Uri.https('www.ebay.de', '/sch/i.html', {'_nkw': query, ...extra});
}
