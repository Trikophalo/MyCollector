/// Grading-Unternehmen, deren Bewertungen im deutschsprachigen Raum
/// gehandelt werden.
enum Grader {
  psa('PSA', 'Professional Sports Authenticator'),
  bgs('BGS', 'Beckett Grading Services'),
  cgc('CGC', 'Certified Guaranty Company'),
  sgc('SGC', 'Sportscard Guaranty Corporation'),
  ace('ACE', 'ACE Grading'),
  tag('TAG', 'Technical Authentication & Grading');

  const Grader(this.code, this.fullName);

  final String code;
  final String fullName;

  /// Noten, die dieser Anbieter üblicherweise vergibt — absteigend, weil die
  /// hohen Noten die praktisch relevanten sind.
  List<double> get commonGrades => switch (this) {
        Grader.bgs => const [10, 9.5, 9, 8.5, 8, 7.5, 7, 6.5, 6, 5, 4, 3, 2, 1],
        Grader.cgc => const [10, 9.5, 9, 8.5, 8, 7.5, 7, 6.5, 6, 5, 4, 3, 2, 1],
        _ => const [10, 9, 8, 7, 6, 5, 4, 3, 2, 1],
      };

  static Grader? fromCode(String? code) {
    if (code == null || code.isEmpty) return null;
    for (final grader in Grader.values) {
      if (grader.code.toUpperCase() == code.toUpperCase()) return grader;
    }
    return null;
  }
}

/// Ein konkretes Grading, also Anbieter plus Note (z. B. „PSA 10", „BGS 9.5").
class Grading implements Comparable<Grading> {
  const Grading(this.grader, this.grade);

  final Grader grader;
  final double grade;

  /// „10" statt „10.0", aber „9.5" bleibt „9.5".
  String get gradeLabel => grade == grade.roundToDouble()
      ? grade.toStringAsFixed(0)
      : grade.toStringAsFixed(1);

  String get label => '${grader.code} $gradeLabel';

  /// Höchstnote des jeweiligen Anbieters — steuert die Hervorhebung im UI.
  bool get isTopGrade => grade >= 10;

  @override
  int compareTo(Grading other) {
    final byGrader = grader.index.compareTo(other.grader.index);
    if (byGrader != 0) return byGrader;
    return grade.compareTo(other.grade);
  }

  @override
  bool operator ==(Object other) =>
      other is Grading && other.grader == grader && other.grade == grade;

  @override
  int get hashCode => Object.hash(grader, grade);

  @override
  String toString() => label;
}

/// Erhaltungszustand einer ungegradeten Karte.
///
/// Die Preisreferenz bezieht sich laut §7 P-4 bewusst immer auf Near Mint;
/// der Zustand ist im MVP eine Information, kein Preisabschlag.
enum CardCondition {
  mint('M', 'Mint'),
  nearMint('NM', 'Near Mint'),
  excellent('EX', 'Excellent'),
  good('GD', 'Good'),
  lightPlayed('LP', 'Light Played'),
  played('PL', 'Played'),
  poor('PO', 'Poor');

  const CardCondition(this.code, this.label);

  final String code;
  final String label;

  static CardCondition fromCode(String? code) => CardCondition.values.firstWhere(
        (c) => c.code == code,
        orElse: () => CardCondition.nearMint,
      );
}

/// Druckvariante einer Karte. Bestimmt mit, welcher Marktpreis gilt.
enum CardVariant {
  normal('normal', 'Normal'),
  holo('holo', 'Holo'),
  reverseHolo('reverse', 'Reverse Holo'),
  firstEdition('first_edition', '1st Edition');

  const CardVariant(this.code, this.label);

  final String code;
  final String label;

  static CardVariant fromCode(String? code) => CardVariant.values.firstWhere(
        (v) => v.code == code,
        orElse: () => CardVariant.normal,
      );
}
