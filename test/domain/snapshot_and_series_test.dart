import 'package:flutter_test/flutter_test.dart';
import 'package:mycollector/domain/models/money.dart';
import 'package:mycollector/domain/models/portfolio_snapshot.dart';
import 'package:mycollector/domain/services/chart_series.dart';
import 'package:mycollector/domain/services/snapshot_service.dart';

void main() {
  const snapshots = SnapshotService();
  const builder = ChartSeriesBuilder();
  final now = DateTime(2026, 8, 16, 12);

  PortfolioSnapshot snapshot(DateTime date, int cents, {int invested = 1000}) =>
      PortfolioSnapshot(
        portfolioId: 'p1',
        date: PortfolioSnapshot.dateOnly(date),
        totalValue: Money(cents),
        cardsValue: Money(cents),
        sealedValue: const Money.zero(),
        invested: Money(invested),
      );

  group('SnapshotService', () {
    test('erkennt, ob der heutige Abschluss noch fehlt', () {
      expect(
        snapshots.needsSnapshot(
          existing: [snapshot(DateTime(2026, 8, 15), 100)],
          now: now,
        ),
        isTrue,
      );
      expect(
        snapshots.needsSnapshot(
          existing: [snapshot(DateTime(2026, 8, 16), 100)],
          now: now,
        ),
        isFalse,
      );
    });

    test('ersetzt einen bestehenden Abschluss desselben Tages', () {
      final existing = [
        snapshot(DateTime(2026, 8, 15), 100),
        snapshot(DateTime(2026, 8, 16), 200),
      ];

      final result = snapshots.upsert(
        existing,
        snapshot(DateTime(2026, 8, 16), 250),
      );

      expect(result.length, 2);
      expect(result.last.totalValue, const Money(250));
    });

    test('hält die Liste chronologisch sortiert', () {
      final result = snapshots.upsert([
        snapshot(DateTime(2026, 8, 16), 200),
      ], snapshot(DateTime(2026, 8, 10), 100));

      expect(result.first.date, DateTime(2026, 8, 10));
      expect(result.last.date, DateTime(2026, 8, 16));
    });

    test('schreibt fehlende Tage mit dem letzten bekannten Wert fort', () {
      final result = snapshots.fillGaps([
        snapshot(DateTime(2026, 8, 10), 1000),
        snapshot(DateTime(2026, 8, 14), 1500),
      ]);

      expect(result.length, 5);
      expect(result[1].date, DateTime(2026, 8, 11));
      expect(
        result[1].totalValue,
        const Money(1000),
        reason: 'Lückentage tragen den letzten bekannten Wert',
      );
      expect(result.last.totalValue, const Money(1500));
    });

    test('lässt lückenlose Reihen unverändert', () {
      final input = [
        snapshot(DateTime(2026, 8, 14), 1000),
        snapshot(DateTime(2026, 8, 15), 1100),
        snapshot(DateTime(2026, 8, 16), 1200),
      ];

      expect(snapshots.fillGaps(input).length, 3);
    });
  });

  group('ChartSeriesBuilder', () {
    List<PortfolioSnapshot> series(int days) => List.generate(
      days,
      (i) =>
          snapshot(now.subtract(Duration(days: days - 1 - i)), 1000 + i * 10),
    );

    test('beschränkt die Reihe auf den gewählten Zeitraum', () {
      final result = builder.build(
        snapshots: series(365),
        range: ChartRange.week,
        now: now,
      );

      expect(result.points.length, 7);
      expect(result.points.last.date, PortfolioSnapshot.dateOnly(now));
    });

    test('Max nutzt die gesamte Historie', () {
      final result = builder.build(
        snapshots: series(45),
        range: ChartRange.max,
        now: now,
      );

      expect(result.points.length, 45);
    });

    test('rechnet die Veränderung über den sichtbaren Zeitraum', () {
      final result = builder.build(
        snapshots: series(30),
        range: ChartRange.month,
        now: now,
      );

      expect(result.first, const Money(1000));
      expect(result.last, const Money(1290));
      expect(result.change, const Money(290));
      expect(result.isUp, isTrue);
      expect(result.changeRatio, closeTo(0.29, 0.0001));
    });

    test('dünnt lange Reihen aus und behält Anfang und Ende', () {
      final input = series(1000);
      final result = builder.build(
        snapshots: input,
        range: ChartRange.max,
        now: now,
        maxPoints: 120,
      );

      expect(result.points.length, lessThanOrEqualTo(120));
      expect(result.points.first.value, const Money(1000));
      expect(result.points.last.value, const Money(1000 + 999 * 10));
    });

    test('behält Ausreißer beim Ausdünnen sichtbar', () {
      final input = series(500);
      input[250] = snapshot(input[250].date, 999999);

      final result = builder.build(
        snapshots: input,
        range: ChartRange.max,
        now: now,
        maxPoints: 60,
      );

      expect(
        result.points.any((p) => p.value == const Money(999999)),
        isTrue,
        reason: 'Ein Wertsprung darf durch Downsampling nicht verschwinden',
      );
    });

    test('liefert für eine leere Historie eine leere Reihe', () {
      final result = builder.build(
        snapshots: const [],
        range: ChartRange.month,
        now: now,
      );

      expect(result.isEmpty, isTrue);
      expect(result.hasLine, isFalse);
    });

    test('ein einzelner Punkt ergibt noch keine Linie', () {
      final result = builder.build(
        snapshots: series(1),
        range: ChartRange.week,
        now: now,
      );

      expect(result.points.length, 1);
      expect(
        result.hasLine,
        isFalse,
        reason: 'Die UI zeigt dann den Leerzustand statt einer Kurve',
      );
    });

    test('erkennt fallende Kurven', () {
      final falling = [
        snapshot(now.subtract(const Duration(days: 2)), 2000),
        snapshot(now.subtract(const Duration(days: 1)), 1800),
        snapshot(now, 1500),
      ];

      final result = builder.build(
        snapshots: falling,
        range: ChartRange.week,
        now: now,
      );

      expect(result.isDown, isTrue);
      expect(result.change, const Money(-500));
    });
  });

  group('Money', () {
    test('rechnet in Cent ohne Rundungsdrift', () {
      final values = List.generate(1000, (_) => const Money(1));
      expect(Money.sum(values), const Money(1000));
    });

    test('verweigert das Mischen von Währungen', () {
      expect(
        () => const Money(100) + const Money(100, currency: Currency.usd),
        throwsArgumentError,
      );
    });

    test('liefert keine Rendite auf einen Einstand von null', () {
      expect(Money.changeRatio(const Money.zero(), const Money(500)), isNull);
    });

    test('rundet Skalierungen kaufmännisch auf ganze Cent', () {
      expect(const Money(1000).scaled(0.9155), const Money(916));
    });
  });
}
