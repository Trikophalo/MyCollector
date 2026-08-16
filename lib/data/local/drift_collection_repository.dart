import 'package:drift/drift.dart';

import '../../domain/models/catalog_item.dart';
import '../../domain/models/grading.dart';
import '../../domain/models/holding.dart';
import '../../domain/models/money.dart';
import '../../domain/models/portfolio_snapshot.dart';
import '../../domain/models/price_point.dart';
import '../../domain/repositories/collection_repository.dart';
import 'database.dart';

/// SQLite-gestützte Umsetzung des Sammlungs-Repositories.
///
/// Sämtliche Umrechnung zwischen Datenbankzeilen und Domänenobjekten passiert
/// hier — die Domäne kennt keine Drift-Typen.
class DriftCollectionRepository implements CollectionRepository {
  DriftCollectionRepository(this.db);

  final AppDatabase db;

  // ---------------------------------------------------------------- Bestand

  @override
  Stream<List<Holding>> watchHoldings(String portfolioId) {
    final query = db.select(db.holdingEntries)
      ..where((t) => t.portfolioId.equals(portfolioId))
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]);
    return query.watch().map((rows) => rows.map(_toHolding).toList());
  }

  @override
  Future<List<Holding>> holdings(String portfolioId) async {
    final query = db.select(db.holdingEntries)
      ..where((t) => t.portfolioId.equals(portfolioId))
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]);
    final rows = await query.get();
    return rows.map(_toHolding).toList();
  }

  @override
  Future<Holding?> holding(String id) async {
    final row = await (db.select(
      db.holdingEntries,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    return row == null ? null : _toHolding(row);
  }

  @override
  Future<void> saveHolding(Holding holding) async {
    await db
        .into(db.holdingEntries)
        .insertOnConflictUpdate(
          HoldingEntriesCompanion.insert(
            id: holding.id,
            portfolioId: holding.portfolioId,
            type: holding.type.code,
            catalogId: holding.catalogId,
            quantity: holding.quantity,
            variant: Value(holding.variant.code),
            condition: Value(holding.condition.code),
            graderCode: Value(holding.grading?.grader.code),
            grade: Value(holding.grading?.grade),
            certificateNumber: Value(holding.certificateNumber),
            purchasePriceCents: Value(holding.purchasePrice.cents),
            purchaseDate: holding.purchaseDate,
            priceMode: Value(holding.priceMode.code),
            manualPriceCents: Value(holding.manualPrice?.cents),
            manualPriceSetAt: Value(holding.manualPriceSetAt),
            note: Value(holding.note),
            createdAt: holding.createdAt,
          ),
        );
  }

  @override
  Future<void> deleteHolding(String id) async {
    await (db.delete(db.holdingEntries)..where((t) => t.id.equals(id))).go();
  }

  // ---------------------------------------------------------------- Katalog

  @override
  Future<Map<String, CatalogItem>> catalogItems(Iterable<String> ids) async {
    final wanted = ids.toSet();
    if (wanted.isEmpty) return {};

    final cards = await (db.select(
      db.cardEntries,
    )..where((t) => t.id.isIn(wanted))).get();
    final sealed = await (db.select(
      db.sealedEntries,
    )..where((t) => t.id.isIn(wanted))).get();

    return {
      for (final row in cards) row.id: _toCard(row),
      for (final row in sealed) row.id: _toSealed(row),
    };
  }

  @override
  Future<void> cacheCatalogItems(Iterable<CatalogItem> items) async {
    final now = DateTime.now();
    await db.batch((batch) {
      for (final item in items) {
        switch (item) {
          case CatalogCard card:
            batch.insert(
              db.cardEntries,
              CardEntriesCompanion.insert(
                id: card.id,
                setId: card.setId,
                setName: card.setName,
                localId: card.localId,
                nameEn: card.nameEn,
                nameDe: Value(card.nameDe),
                rarity: Value(card.rarity),
                imageBase: Value(card.imageBase),
                imageBaseEn: Value(card.imageBaseEn),
                setCardCount: Value(card.setCardCount),
                variants: Value(
                  card.availableVariants.map((v) => v.code).join(','),
                ),
                cachedAt: now,
              ),
              mode: InsertMode.insertOrReplace,
            );
          case SealedProduct product:
            batch.insert(
              db.sealedEntries,
              SealedEntriesCompanion.insert(
                id: product.id,
                name: product.name,
                type: product.type.code,
                setId: Value(product.setId),
                setName: Value(product.setName),
                language: Value(product.language),
                image: Value(product.image),
                isCustom: Value(product.isCustom),
                cachedAt: now,
              ),
              mode: InsertMode.insertOrReplace,
            );
        }
      }
    });
  }

  // ----------------------------------------------------------------- Preise

  @override
  Future<PriceBook> latestPrices() async {
    // In SQLite wählt MAX() in Verbindung mit GROUP BY die zugehörige Zeile
    // aus. Das ist deutlich günstiger, als das ganze Archiv zu laden und in
    // Dart zu filtern.
    final rows = await db
        .customSelect(
          'SELECT catalog_id, price_key, source, value_cents, currency, '
          'value_eur_cents, MAX(captured_at) AS captured_at '
          'FROM price_entries GROUP BY catalog_id, price_key',
          readsFrom: {db.priceEntries},
        )
        .get();

    return PriceBook(
      rows.map(
        (row) => PricePoint(
          catalogId: row.read<String>('catalog_id'),
          priceKey: PriceKey(row.read<String>('price_key')),
          source: _sourceFromName(row.read<String>('source')),
          value: Money(
            row.read<int>('value_cents'),
            currency: Currency.fromCode(row.read<String>('currency')),
          ),
          valueEur: Money(row.read<int>('value_eur_cents')),
          capturedAt: row.read<DateTime>('captured_at'),
        ),
      ),
    );
  }

  @override
  Future<void> recordPrices(Iterable<PricePoint> points) async {
    if (points.isEmpty) return;
    await db.batch((batch) {
      batch.insertAll(
        db.priceEntries,
        points.map(
          (point) => PriceEntriesCompanion.insert(
            catalogId: point.catalogId,
            priceKey: point.priceKey.value,
            source: point.source.name,
            valueCents: point.value.cents,
            currency: Value(point.value.currency.code),
            valueEurCents: point.valueEur.cents,
            capturedAt: point.capturedAt,
          ),
        ),
      );
    });
  }

  @override
  Future<List<PricePoint>> priceHistory(
    String catalogId,
    PriceKey priceKey,
  ) async {
    final query = db.select(db.priceEntries)
      ..where(
        (t) =>
            t.catalogId.equals(catalogId) & t.priceKey.equals(priceKey.value),
      )
      ..orderBy([(t) => OrderingTerm.asc(t.capturedAt)]);
    final rows = await query.get();

    return rows
        .map(
          (row) => PricePoint(
            catalogId: row.catalogId,
            priceKey: PriceKey(row.priceKey),
            source: _sourceFromName(row.source),
            value: Money(
              row.valueCents,
              currency: Currency.fromCode(row.currency),
            ),
            valueEur: Money(row.valueEurCents),
            capturedAt: row.capturedAt,
          ),
        )
        .toList();
  }

  // -------------------------------------------------------------- Snapshots

  @override
  Future<List<PortfolioSnapshot>> snapshots(String portfolioId) async {
    final query = db.select(db.snapshotEntries)
      ..where((t) => t.portfolioId.equals(portfolioId))
      ..orderBy([(t) => OrderingTerm.asc(t.date)]);
    final rows = await query.get();

    return rows
        .map(
          (row) => PortfolioSnapshot(
            portfolioId: row.portfolioId,
            date: row.date,
            totalValue: Money(row.totalCents),
            cardsValue: Money(row.cardsCents),
            sealedValue: Money(row.sealedCents),
            invested: Money(row.investedCents),
          ),
        )
        .toList();
  }

  @override
  Future<void> saveSnapshot(PortfolioSnapshot snapshot) async {
    await db
        .into(db.snapshotEntries)
        .insertOnConflictUpdate(
          SnapshotEntriesCompanion.insert(
            portfolioId: snapshot.portfolioId,
            date: snapshot.date,
            totalCents: snapshot.totalValue.cents,
            cardsCents: snapshot.cardsValue.cents,
            sealedCents: snapshot.sealedValue.cents,
            investedCents: snapshot.invested.cents,
          ),
        );
  }

  // ------------------------------------------------------------------ Export

  @override
  Future<Map<String, Object?>> exportAll(String portfolioId) async {
    final positions = await holdings(portfolioId);
    final catalog = await catalogItems(positions.map((h) => h.catalogId));
    final history = await snapshots(portfolioId);

    return {
      'formatVersion': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'portfolioId': portfolioId,
      'holdings': [
        for (final h in positions)
          {
            'id': h.id,
            'type': h.type.code,
            'catalogId': h.catalogId,
            'name': catalog[h.catalogId]?.displayName,
            'quantity': h.quantity,
            'variant': h.variant.code,
            'condition': h.condition.code,
            'grader': h.grading?.grader.code,
            'grade': h.grading?.grade,
            'certificateNumber': h.certificateNumber,
            'purchasePriceCents': h.purchasePrice.cents,
            'purchaseDate': h.purchaseDate.toIso8601String(),
            'priceMode': h.priceMode.code,
            'manualPriceCents': h.manualPrice?.cents,
            'note': h.note,
            'createdAt': h.createdAt.toIso8601String(),
          },
      ],
      'snapshots': [
        for (final s in history)
          {
            'date': s.date.toIso8601String(),
            'totalCents': s.totalValue.cents,
            'cardsCents': s.cardsValue.cents,
            'sealedCents': s.sealedValue.cents,
            'investedCents': s.invested.cents,
          },
      ],
    };
  }

  // ----------------------------------------------------------------- Mapper

  Holding _toHolding(HoldingEntry row) {
    final grader = Grader.fromCode(row.graderCode);
    final grade = row.grade;

    return Holding(
      id: row.id,
      portfolioId: row.portfolioId,
      type: HoldingType.fromCode(row.type),
      catalogId: row.catalogId,
      quantity: row.quantity,
      purchaseDate: row.purchaseDate,
      createdAt: row.createdAt,
      variant: CardVariant.fromCode(row.variant),
      condition: CardCondition.fromCode(row.condition),
      grading: grader != null && grade != null ? Grading(grader, grade) : null,
      certificateNumber: row.certificateNumber,
      purchasePrice: Money(row.purchasePriceCents),
      priceMode: PriceMode.fromCode(row.priceMode),
      manualPrice: row.manualPriceCents == null
          ? null
          : Money(row.manualPriceCents!),
      manualPriceSetAt: row.manualPriceSetAt,
      note: row.note,
    );
  }

  CatalogCard _toCard(CardEntry row) => CatalogCard(
    id: row.id,
    setId: row.setId,
    setName: row.setName,
    localId: row.localId,
    nameEn: row.nameEn,
    nameDe: row.nameDe,
    rarity: row.rarity,
    imageBase: row.imageBase,
    imageBaseEn: row.imageBaseEn,
    setCardCount: row.setCardCount,
    availableVariants: row.variants
        .split(',')
        .where((c) => c.isNotEmpty)
        .map(CardVariant.fromCode)
        .toList(),
  );

  SealedProduct _toSealed(SealedEntry row) => SealedProduct(
    id: row.id,
    name: row.name,
    type: SealedProductType.fromCode(row.type),
    setId: row.setId,
    setName: row.setName,
    language: row.language,
    image: row.image,
    isCustom: row.isCustom,
  );

  PriceSource _sourceFromName(String name) => PriceSource.values.firstWhere(
    (s) => s.name == name,
    orElse: () => PriceSource.manual,
  );
}
