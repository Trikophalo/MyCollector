/// Währungen, die die App kennt. Anzeigewährung ist immer EUR (§4.5);
/// USD tritt nur als Originalwährung US-amerikanischer Preisquellen auf.
enum Currency {
  eur('EUR', '€'),
  usd('USD', r'$');

  const Currency(this.code, this.symbol);

  final String code;
  final String symbol;

  static Currency fromCode(String code) => Currency.values.firstWhere(
    (c) => c.code.toUpperCase() == code.toUpperCase(),
    orElse: () => Currency.eur,
  );
}

/// Geldbetrag in ganzzahligen Cent.
///
/// Beträge werden nie als [double] gespeichert oder gerechnet — Rundungsfehler
/// über hunderte Positionen hinweg würden den Portfoliowert verfälschen.
class Money implements Comparable<Money> {
  const Money(this.cents, {this.currency = Currency.eur});

  const Money.zero({this.currency = Currency.eur}) : cents = 0;

  /// Nur für Eingaben aus der UI und für Testdaten gedacht.
  factory Money.fromDouble(double amount, {Currency currency = Currency.eur}) =>
      Money((amount * 100).round(), currency: currency);

  final int cents;
  final Currency currency;

  double get amount => cents / 100;

  bool get isZero => cents == 0;

  bool get isPositive => cents > 0;

  bool get isNegative => cents < 0;

  Money operator +(Money other) {
    _requireSameCurrency(other);
    return Money(cents + other.cents, currency: currency);
  }

  Money operator -(Money other) {
    _requireSameCurrency(other);
    return Money(cents - other.cents, currency: currency);
  }

  Money operator -() => Money(-cents, currency: currency);

  /// Multiplikation mit einer Stückzahl.
  Money times(int factor) => Money(cents * factor, currency: currency);

  /// Skalierung, z. B. für Wechselkurse. Rundet kaufmännisch auf ganze Cent.
  Money scaled(double factor, {Currency? asCurrency}) =>
      Money((cents * factor).round(), currency: asCurrency ?? currency);

  /// Relative Veränderung von [from] nach [to].
  ///
  /// Gibt `null` zurück, wenn der Ausgangswert null ist — eine Rendite auf einen
  /// Einstand von 0 € ist nicht definiert und darf nicht als „+∞ %" erscheinen.
  static double? changeRatio(Money from, Money to) {
    if (from.cents == 0) return null;
    return (to.cents - from.cents) / from.cents.abs();
  }

  static Money sum(Iterable<Money> values, {Currency currency = Currency.eur}) {
    var total = 0;
    for (final value in values) {
      if (value.currency != currency) {
        throw ArgumentError(
          'Summe über gemischte Währungen: ${value.currency.code} in $currency',
        );
      }
      total += value.cents;
    }
    return Money(total, currency: currency);
  }

  void _requireSameCurrency(Money other) {
    if (other.currency != currency) {
      throw ArgumentError(
        'Währungen nicht kompatibel: ${currency.code} und ${other.currency.code}',
      );
    }
  }

  @override
  int compareTo(Money other) {
    _requireSameCurrency(other);
    return cents.compareTo(other.cents);
  }

  bool operator <(Money other) => compareTo(other) < 0;

  bool operator >(Money other) => compareTo(other) > 0;

  bool operator <=(Money other) => compareTo(other) <= 0;

  bool operator >=(Money other) => compareTo(other) >= 0;

  @override
  bool operator ==(Object other) =>
      other is Money && other.cents == cents && other.currency == currency;

  @override
  int get hashCode => Object.hash(cents, currency);

  @override
  String toString() => '${(cents / 100).toStringAsFixed(2)} ${currency.code}';
}
