import 'money.dart';

/// Tagesabschluss des Portfoliowerts.
///
/// Snapshots werden nur angehängt, nie rückwirkend verändert (§4.4): Ein Kauf
/// heute verändert den Wert von gestern nicht — die Kurve verhält sich wie ein
/// Depot bei einer Einzahlung.
class PortfolioSnapshot {
  const PortfolioSnapshot({
    required this.portfolioId,
    required this.date,
    required this.totalValue,
    required this.cardsValue,
    required this.sealedValue,
    required this.invested,
  });

  final String portfolioId;

  /// Auf Mitternacht normalisierter Tag (Zeitzone des Geräts).
  final DateTime date;

  final Money totalValue;
  final Money cardsValue;
  final Money sealedValue;

  /// Eingesetztes Kapital an diesem Tag — erlaubt die zweite Linie im Chart
  /// und macht Wertsprünge durch Zukäufe erklärbar (§5.4).
  final Money invested;

  Money get absoluteReturn => totalValue - invested;

  double? get returnRatio => Money.changeRatio(invested, totalValue);

  /// Normalisiert einen Zeitpunkt auf den Tagesbeginn.
  static DateTime dateOnly(DateTime moment) =>
      DateTime(moment.year, moment.month, moment.day);

  PortfolioSnapshot copyWith({DateTime? date}) => PortfolioSnapshot(
    portfolioId: portfolioId,
    date: date ?? this.date,
    totalValue: totalValue,
    cardsValue: cardsValue,
    sealedValue: sealedValue,
    invested: invested,
  );

  @override
  String toString() =>
      'PortfolioSnapshot(${date.toIso8601String().substring(0, 10)}, $totalValue)';
}
