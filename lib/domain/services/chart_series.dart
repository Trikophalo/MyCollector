import 'dart:math' as math;

import '../models/money.dart';
import '../models/portfolio_snapshot.dart';

/// Auswählbare Zeiträume des Portfolio-Charts (§5.4).
enum ChartRange {
  week('1W', 7),
  month('1M', 30),
  quarter('3M', 90),
  year('1J', 365),
  max('Max', null);

  const ChartRange(this.label, this.days);

  final String label;

  /// `null` bedeutet: gesamte vorhandene Historie.
  final int? days;
}

/// Ein Punkt der Wertkurve.
class SeriesPoint {
  const SeriesPoint({
    required this.date,
    required this.value,
    required this.invested,
  });

  final DateTime date;
  final Money value;
  final Money invested;
}

/// Die aufbereitete Zeitreihe für den Chart samt abgeleiteter Kennzahlen.
class ChartSeries {
  const ChartSeries({required this.points, required this.range});

  const ChartSeries.empty(this.range) : points = const [];

  final List<SeriesPoint> points;
  final ChartRange range;

  bool get isEmpty => points.isEmpty;

  /// Der Chart braucht mindestens zwei Punkte, um eine Linie zu zeigen.
  bool get hasLine => points.length >= 2;

  Money get first => points.first.value;

  Money get last => points.last.value;

  Money get minValue =>
      points.map((p) => p.value).reduce((a, b) => a <= b ? a : b);

  Money get maxValue =>
      points.map((p) => p.value).reduce((a, b) => a >= b ? a : b);

  /// Wertveränderung über den gesamten dargestellten Zeitraum.
  Money get change => hasLine ? last - first : const Money.zero();

  double? get changeRatio => hasLine ? Money.changeRatio(first, last) : null;

  bool get isUp => change.isPositive;

  bool get isDown => change.isNegative;
}

/// Baut aus Tagesabschlüssen die Zeitreihe für einen Zeitraum.
class ChartSeriesBuilder {
  const ChartSeriesBuilder();

  /// [maxPoints] begrenzt die Punktzahl, damit auch mehrjährige Historien
  /// flüssig gezeichnet werden (§5.4).
  ChartSeries build({
    required List<PortfolioSnapshot> snapshots,
    required ChartRange range,
    required DateTime now,
    int maxPoints = 180,
  }) {
    if (snapshots.isEmpty) return ChartSeries.empty(range);

    final sorted = List.of(snapshots)..sort((a, b) => a.date.compareTo(b.date));

    final days = range.days;
    final filtered = days == null
        ? sorted
        : () {
            final cutoff = PortfolioSnapshot.dateOnly(
              now.subtract(Duration(days: days - 1)),
            );
            return sorted.where((s) => !s.date.isBefore(cutoff)).toList();
          }();

    if (filtered.isEmpty) return ChartSeries.empty(range);

    final points = filtered
        .map(
          (s) => SeriesPoint(
            date: s.date,
            value: s.totalValue,
            invested: s.invested,
          ),
        )
        .toList();

    return ChartSeries(points: _downsample(points, maxPoints), range: range);
  }

  /// Largest-Triangle-Three-Buckets: reduziert die Punktzahl und erhält dabei
  /// die visuelle Form der Kurve — Ausreißer bleiben sichtbar, anders als bei
  /// einfachem Ausdünnen jedes n-ten Punkts.
  List<SeriesPoint> _downsample(List<SeriesPoint> data, int threshold) {
    if (threshold >= data.length || threshold < 3) return data;

    final sampled = <SeriesPoint>[data.first];
    final every = (data.length - 2) / (threshold - 2);
    var a = 0;

    for (var i = 0; i < threshold - 2; i++) {
      var avgRangeStart = (every * (i + 1)).floor() + 1;
      var avgRangeEnd = (every * (i + 2)).floor() + 1;
      avgRangeEnd = math.min(avgRangeEnd, data.length);
      avgRangeStart = math.min(avgRangeStart, avgRangeEnd);

      final avgLength = avgRangeEnd - avgRangeStart;
      var avgX = 0.0;
      var avgY = 0.0;
      if (avgLength > 0) {
        for (var j = avgRangeStart; j < avgRangeEnd; j++) {
          avgX += data[j].date.millisecondsSinceEpoch.toDouble();
          avgY += data[j].value.cents.toDouble();
        }
        avgX /= avgLength;
        avgY /= avgLength;
      }

      final rangeFrom = (every * i).floor() + 1;
      final rangeTo = math.min((every * (i + 1)).floor() + 1, data.length);

      final pointAx = data[a].date.millisecondsSinceEpoch.toDouble();
      final pointAy = data[a].value.cents.toDouble();

      var maxArea = -1.0;
      var nextA = rangeFrom;
      for (var j = rangeFrom; j < rangeTo; j++) {
        final area =
            ((pointAx - avgX) * (data[j].value.cents.toDouble() - pointAy) -
                    (pointAx - data[j].date.millisecondsSinceEpoch.toDouble()) *
                        (avgY - pointAy))
                .abs();
        if (area > maxArea) {
          maxArea = area;
          nextA = j;
        }
      }

      if (nextA < data.length) {
        sampled.add(data[nextA]);
        a = nextA;
      }
    }

    sampled.add(data.last);
    return sampled;
  }
}
