import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'database.g.dart';

/// Zwischengespeicherte Katalogkarten.
///
/// Der Katalog ist reiner Cache: Er darf jederzeit gelöscht und neu geladen
/// werden. Nur die Bestandsdaten des Sammlers sind unersetzlich.
@DataClassName('CardEntry')
class CardEntries extends Table {
  TextColumn get id => text()();
  TextColumn get setId => text()();
  TextColumn get setName => text()();
  TextColumn get localId => text()();
  TextColumn get nameEn => text()();
  TextColumn get nameDe => text().nullable()();
  TextColumn get rarity => text().nullable()();
  TextColumn get imageBase => text().nullable()();
  TextColumn get imageBaseEn => text().nullable()();
  IntColumn get setCardCount => integer().nullable()();

  /// Kommaseparierte Variantencodes, z. B. `normal,reverse`.
  TextColumn get variants => text().withDefault(const Constant('normal'))();
  DateTimeColumn get cachedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Versiegelte Produkte — katalogisiert oder selbst angelegt.
@DataClassName('SealedEntry')
class SealedEntries extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get type => text()();
  TextColumn get setId => text().nullable()();
  TextColumn get setName => text().nullable()();
  TextColumn get language => text().withDefault(const Constant('DE'))();
  TextColumn get image => text().nullable()();
  BoolColumn get isCustom => boolean().withDefault(const Constant(false))();
  DateTimeColumn get cachedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Die Positionen des Sammlers. Diese Tabelle ist die einzige, deren Verlust
/// nicht durch einen erneuten Abruf heilbar wäre.
@DataClassName('HoldingEntry')
class HoldingEntries extends Table {
  TextColumn get id => text()();
  TextColumn get portfolioId => text()();
  TextColumn get type => text()();
  TextColumn get catalogId => text()();
  IntColumn get quantity => integer()();
  TextColumn get variant => text().withDefault(const Constant('normal'))();
  TextColumn get condition => text().withDefault(const Constant('NM'))();
  TextColumn get graderCode => text().nullable()();
  RealColumn get grade => real().nullable()();
  TextColumn get certificateNumber => text().nullable()();
  IntColumn get purchasePriceCents => integer().withDefault(const Constant(0))();
  DateTimeColumn get purchaseDate => dateTime()();
  TextColumn get priceMode => text().withDefault(const Constant('auto'))();
  IntColumn get manualPriceCents => integer().nullable()();
  DateTimeColumn get manualPriceSetAt => dateTime().nullable()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Preisarchiv. Wird nur angehängt — daraus entstehen Wertkurve,
/// „Stand"-Anzeige und ein späterer Backfill (§4.4).
@DataClassName('PriceEntry')
@TableIndex(name: 'price_lookup', columns: {#catalogId, #priceKey, #capturedAt})
class PriceEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get catalogId => text()();
  TextColumn get priceKey => text()();
  TextColumn get source => text()();
  IntColumn get valueCents => integer()();
  TextColumn get currency => text().withDefault(const Constant('EUR'))();
  IntColumn get valueEurCents => integer()();
  DateTimeColumn get capturedAt => dateTime()();
}

/// Tagesabschlüsse des Portfoliowerts.
@DataClassName('SnapshotEntry')
class SnapshotEntries extends Table {
  TextColumn get portfolioId => text()();
  DateTimeColumn get date => dateTime()();
  IntColumn get totalCents => integer()();
  IntColumn get cardsCents => integer()();
  IntColumn get sealedCents => integer()();
  IntColumn get investedCents => integer()();

  @override
  Set<Column<Object>> get primaryKey => {portfolioId, date};
}

@DriftDatabase(
  tables: [
    CardEntries,
    SealedEntries,
    HoldingEntries,
    PriceEntries,
    SnapshotEntries,
  ],
)
class AppDatabase extends _$AppDatabase {
  /// [executor] wird in Tests mit einer In-Memory-Datenbank belegt.
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? driftDatabase(name: 'mycollector'));

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async => m.createAll(),
        beforeOpen: (details) async {
          // Fremdschlüssel sind in SQLite standardmäßig aus.
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );
}
