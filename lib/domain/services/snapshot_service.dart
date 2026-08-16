import '../models/portfolio_snapshot.dart';
import 'portfolio_service.dart';

/// Erzeugt und pflegt die täglichen Wertabschlüsse, aus denen die
/// Portfoliokurve entsteht (§4.5).
class SnapshotService {
  const SnapshotService();

  /// Baut den Tagesabschluss aus einer Bewertung.
  PortfolioSnapshot snapshotFrom({
    required PortfolioSummary summary,
    required String portfolioId,
    required DateTime date,
  }) =>
      PortfolioSnapshot(
        portfolioId: portfolioId,
        date: PortfolioSnapshot.dateOnly(date),
        totalValue: summary.totalValue,
        cardsValue: summary.cardsValue,
        sealedValue: summary.sealedValue,
        invested: summary.invested,
      );

  /// Wahr, wenn für [now] noch kein Abschluss existiert.
  bool needsSnapshot({
    required List<PortfolioSnapshot> existing,
    required DateTime now,
  }) {
    final today = PortfolioSnapshot.dateOnly(now);
    return !existing.any((s) => s.date == today);
  }

  /// Fügt einen Abschluss ein und ersetzt einen bereits vorhandenen desselben
  /// Tages. Mehrere Aktualisierungen am Tag sollen einen Punkt ergeben,
  /// nicht mehrere.
  List<PortfolioSnapshot> upsert(
    List<PortfolioSnapshot> existing,
    PortfolioSnapshot snapshot,
  ) {
    final result = existing.where((s) => s.date != snapshot.date).toList()
      ..add(snapshot)
      ..sort((a, b) => a.date.compareTo(b.date));
    return result;
  }

  /// Schließt Lücken zwischen Abschlüssen, indem der jeweils letzte bekannte
  /// Wert fortgeschrieben wird.
  ///
  /// Das ist bewusst eine Fortschreibung und keine Neubewertung: Für vergangene
  /// Tage liegen lokal keine historischen Preise vor. Ohne diese Ergänzung
  /// hätte die Kurve nach jeder Nutzungspause Sprünge, die wie Marktbewegungen
  /// aussähen, aber nur fehlende Messpunkte sind.
  List<PortfolioSnapshot> fillGaps(List<PortfolioSnapshot> snapshots) {
    if (snapshots.length < 2) return List.of(snapshots);

    final sorted = List.of(snapshots)..sort((a, b) => a.date.compareTo(b.date));
    final filled = <PortfolioSnapshot>[sorted.first];

    for (var i = 1; i < sorted.length; i++) {
      final previous = sorted[i - 1];
      final current = sorted[i];
      var cursor = previous.date.add(const Duration(days: 1));

      while (cursor.isBefore(current.date)) {
        filled.add(previous.copyWith(date: cursor));
        cursor = cursor.add(const Duration(days: 1));
      }
      filled.add(current);
    }

    return filled;
  }
}
