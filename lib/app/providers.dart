import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/demo/demo_catalog.dart';
import '../data/local/database.dart';
import '../data/local/drift_collection_repository.dart';
import '../data/remote/catalog_source.dart';
import '../data/remote/tcgdex_source.dart';
import '../domain/models/catalog_item.dart';
import '../domain/models/holding.dart';
import '../domain/models/portfolio_snapshot.dart';
import '../domain/models/price_point.dart';
import '../domain/repositories/collection_repository.dart';
import '../domain/services/chart_series.dart';
import '../domain/services/portfolio_service.dart';
import '../domain/services/snapshot_service.dart';

/// Im MVP gibt es genau ein Portfolio (§7 P-5). Das Datenmodell trägt bereits
/// mehrere, die Oberfläche noch nicht.
const String kPortfolioId = 'main';

/// Wird in `main()` mit der geladenen Instanz überschrieben.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('SharedPreferences nicht bereitgestellt'),
);

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final repositoryProvider = Provider<CollectionRepository>(
  (ref) => DriftCollectionRepository(ref.watch(databaseProvider)),
);

/// Katalog- und Preisquelle. Der Austausch eines Anbieters bleibt dadurch auf
/// diese eine Zeile beschränkt (L5).
final catalogSourceProvider = Provider<CatalogSource>((ref) => TcgdexSource());

/// Ohne Netz — etwa im Flugzeug oder wenn TCGdex ausfällt — dient die
/// Beispielquelle als Rückfall für die Suche.
final offlineCatalogSourceProvider = Provider<CatalogSource>(
  (ref) => const DemoCatalogSource(),
);

// ----------------------------------------------------------------- Einstellungen

enum PriceRefreshState { idle, running, failed }

class AppSettings {
  const AppSettings({this.themeMode = ThemeMode.system, this.lastRefresh});

  final ThemeMode themeMode;
  final DateTime? lastRefresh;

  AppSettings copyWith({ThemeMode? themeMode, DateTime? lastRefresh}) =>
      AppSettings(
        themeMode: themeMode ?? this.themeMode,
        lastRefresh: lastRefresh ?? this.lastRefresh,
      );
}

class SettingsNotifier extends Notifier<AppSettings> {
  static const _keyThemeMode = 'themeMode';
  static const _keyLastRefresh = 'lastRefresh';

  @override
  AppSettings build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final stored = prefs.getString(_keyThemeMode);
    final lastRefresh = prefs.getString(_keyLastRefresh);

    return AppSettings(
      themeMode: switch (stored) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      },
      lastRefresh: lastRefresh == null ? null : DateTime.tryParse(lastRefresh),
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    await ref.read(sharedPreferencesProvider).setString(
      _keyThemeMode,
      switch (mode) {
        ThemeMode.light => 'light',
        ThemeMode.dark => 'dark',
        ThemeMode.system => 'system',
      },
    );
  }

  Future<void> markRefreshed(DateTime moment) async {
    state = state.copyWith(lastRefresh: moment);
    await ref
        .read(sharedPreferencesProvider)
        .setString(_keyLastRefresh, moment.toIso8601String());
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, AppSettings>(
  SettingsNotifier.new,
);

// --------------------------------------------------------------------- Daten

final holdingsProvider = StreamProvider<List<Holding>>(
  (ref) => ref.watch(repositoryProvider).watchHoldings(kPortfolioId),
);

final snapshotsProvider = FutureProvider<List<PortfolioSnapshot>>((ref) async {
  // Neu laden, sobald sich der Bestand ändert.
  ref.watch(holdingsProvider);
  return ref.watch(repositoryProvider).snapshots(kPortfolioId);
});

/// Die vollständige Bewertung des Portfolios — Grundlage der Startseite.
final portfolioProvider = FutureProvider<PortfolioSummary>((ref) async {
  final holdings = await ref.watch(holdingsProvider.future);
  final repository = ref.watch(repositoryProvider);

  final catalog = await repository.catalogItems(
    holdings.map((h) => h.catalogId),
  );
  final prices = await repository.latestPrices();
  final snapshots = await ref.watch(snapshotsProvider.future);

  final today = PortfolioSnapshot.dateOnly(DateTime.now());
  final previous = snapshots.where((s) => s.date.isBefore(today)).lastOrNull;

  return const PortfolioService().evaluate(
    holdings: holdings,
    prices: prices,
    now: DateTime.now(),
    catalog: catalog,
    previousSnapshot: previous,
  );
});

final chartRangeProvider = StateProvider<ChartRange>((ref) => ChartRange.month);

final chartSeriesProvider = FutureProvider<ChartSeries>((ref) async {
  final snapshots = await ref.watch(snapshotsProvider.future);
  final range = ref.watch(chartRangeProvider);

  const service = SnapshotService();
  return const ChartSeriesBuilder().build(
    snapshots: service.fillGaps(snapshots),
    range: range,
    now: DateTime.now(),
  );
});

/// Katalogeinträge zu den eigenen Positionen.
final catalogForHoldingsProvider = FutureProvider<Map<String, CatalogItem>>((
  ref,
) async {
  final holdings = await ref.watch(holdingsProvider.future);
  return ref
      .watch(repositoryProvider)
      .catalogItems(holdings.map((h) => h.catalogId));
});

// ------------------------------------------------------------------- Aktionen

final refreshStateProvider = StateProvider<PriceRefreshState>(
  (ref) => PriceRefreshState.idle,
);

/// Bündelt alle schreibenden Vorgänge.
///
/// Die Screens rufen ausschließlich diese Methoden auf; sie kennen weder
/// Repository noch Preisquelle direkt.
class CollectionController {
  CollectionController(this._ref);

  final Ref _ref;

  CollectionRepository get _repository => _ref.read(repositoryProvider);

  Future<void> addHolding({
    required Holding holding,
    required CatalogItem item,
    List<PricePoint> prices = const [],
  }) async {
    await _repository.cacheCatalogItems([item]);
    await _repository.saveHolding(holding);
    if (prices.isNotEmpty) await _repository.recordPrices(prices);
    await _writeTodaysSnapshot();
    _invalidate();
  }

  Future<void> updateHolding(Holding holding) async {
    await _repository.saveHolding(holding);
    await _writeTodaysSnapshot();
    _invalidate();
  }

  Future<void> deleteHolding(String id) async {
    await _repository.deleteHolding(id);
    await _writeTodaysSnapshot();
    _invalidate();
  }

  /// Holt aktuelle Preise für alle gehaltenen Objekte.
  ///
  /// Bedarfsgetrieben: Abgefragt wird nur, was tatsächlich im Portfolio liegt
  /// (§4.5). Fällt die Quelle aus, bleiben die zuletzt bekannten Preise
  /// stehen — die App wird langsamer aktuell, aber nie unbrauchbar.
  Future<bool> refreshPrices() async {
    _ref.read(refreshStateProvider.notifier).state = PriceRefreshState.running;
    try {
      final holdings = await _repository.holdings(kPortfolioId);
      final cardIds = holdings
          .where((h) => !h.isSealed)
          .map((h) => h.catalogId)
          .toSet();

      if (cardIds.isNotEmpty) {
        final source = _ref.read(catalogSourceProvider);
        final prices = await source.pricesFor(cardIds);
        if (prices.isNotEmpty) await _repository.recordPrices(prices);
      }

      await _writeTodaysSnapshot();
      await _ref.read(settingsProvider.notifier).markRefreshed(DateTime.now());
      _ref.read(refreshStateProvider.notifier).state = PriceRefreshState.idle;
      _invalidate();
      return true;
    } on CatalogSourceException {
      _ref.read(refreshStateProvider.notifier).state = PriceRefreshState.failed;
      // Auch ohne neue Preise wird der Tagesabschluss geschrieben, damit die
      // Kurve keine Lücke bekommt.
      await _writeTodaysSnapshot();
      _invalidate();
      return false;
    }
  }

  /// Schreibt den Tagesabschluss auf Basis der aktuellen Bewertung.
  Future<void> _writeTodaysSnapshot() async {
    final holdings = await _repository.holdings(kPortfolioId);
    if (holdings.isEmpty) return;

    final catalog = await _repository.catalogItems(
      holdings.map((h) => h.catalogId),
    );
    final prices = await _repository.latestPrices();

    final summary = const PortfolioService().evaluate(
      holdings: holdings,
      prices: prices,
      now: DateTime.now(),
      catalog: catalog,
    );

    await _repository.saveSnapshot(
      const SnapshotService().snapshotFrom(
        summary: summary,
        portfolioId: kPortfolioId,
        date: DateTime.now(),
      ),
    );
  }

  /// Lädt den Beispielbestand — ausdrücklich vom Nutzer angefordert.
  Future<void> loadDemoData() async {
    final now = DateTime.now();
    await _repository.cacheCatalogItems(DemoCatalogSource.allItems);

    for (final holding in DemoCatalogSource.demoHoldings(now: now)) {
      await _repository.saveHolding(
        Holding(
          id: holding.id,
          portfolioId: kPortfolioId,
          type: holding.type,
          catalogId: holding.catalogId,
          quantity: holding.quantity,
          purchaseDate: holding.purchaseDate,
          createdAt: holding.createdAt,
          variant: holding.variant,
          condition: holding.condition,
          grading: holding.grading,
          certificateNumber: holding.certificateNumber,
          purchasePrice: holding.purchasePrice,
          priceMode: holding.priceMode,
          manualPrice: holding.manualPrice,
          manualPriceSetAt: holding.manualPriceSetAt,
          note: holding.note,
        ),
      );
    }

    await _repository.recordPrices(
      await const DemoCatalogSource().pricesFor(
        DemoCatalogSource.allItems.map((i) => i.id),
      ),
    );

    for (final snapshot in DemoCatalogSource.demoSnapshots(now: now)) {
      await _repository.saveSnapshot(
        PortfolioSnapshot(
          portfolioId: kPortfolioId,
          date: snapshot.date,
          totalValue: snapshot.totalValue,
          cardsValue: snapshot.cardsValue,
          sealedValue: snapshot.sealedValue,
          invested: snapshot.invested,
        ),
      );
    }

    _invalidate();
  }

  /// Entfernt alle Positionen des Portfolios.
  Future<void> clearCollection() async {
    final holdings = await _repository.holdings(kPortfolioId);
    for (final holding in holdings) {
      await _repository.deleteHolding(holding.id);
    }
    _invalidate();
  }

  Future<Map<String, Object?>> export() => _repository.exportAll(kPortfolioId);

  void _invalidate() {
    _ref.invalidate(snapshotsProvider);
    _ref.invalidate(portfolioProvider);
    _ref.invalidate(catalogForHoldingsProvider);
  }
}

final collectionControllerProvider = Provider<CollectionController>(
  CollectionController.new,
);

// ---------------------------------------------------------------------- Suche

final searchQueryProvider = StateProvider<String>((ref) => '');

/// Suchergebnisse mit stillem Rückfall auf die Offline-Quelle.
final searchResultsProvider = FutureProvider<List<CatalogCard>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  if (query.trim().length < 2) return const [];

  try {
    return await ref.watch(catalogSourceProvider).searchCards(query);
  } on CatalogSourceException {
    return ref.watch(offlineCatalogSourceProvider).searchCards(query);
  }
});
