import 'package:intl/intl.dart';

import '../../domain/models/money.dart';

/// Einheitliche Formatierung aller Zahlen, Beträge und Daten.
///
/// Deutsche Konventionen sind hier zentral verankert: Komma als Dezimaltrenner,
/// Punkt als Tausendertrenner, Währungssymbol hinten. Die Formatierung liegt
/// bewusst nicht in den Views, damit Beträge überall identisch aussehen.
abstract final class Formats {
  static final NumberFormat _currency = NumberFormat.currency(
    locale: 'de_DE',
    symbol: '€',
    decimalDigits: 2,
  );

  static final NumberFormat _currencyCompact = NumberFormat.currency(
    locale: 'de_DE',
    symbol: '€',
    decimalDigits: 0,
  );

  static final NumberFormat _percent = NumberFormat.decimalPattern('de_DE')
    ..minimumFractionDigits = 2
    ..maximumFractionDigits = 2;

  static const List<String> _months = [
    'Januar',
    'Februar',
    'März',
    'April',
    'Mai',
    'Juni',
    'Juli',
    'August',
    'September',
    'Oktober',
    'November',
    'Dezember',
  ];

  static const List<String> _monthsShort = [
    'Jan.',
    'Feb.',
    'März',
    'Apr.',
    'Mai',
    'Juni',
    'Juli',
    'Aug.',
    'Sep.',
    'Okt.',
    'Nov.',
    'Dez.',
  ];

  static const List<String> _weekdays = [
    'Montag',
    'Dienstag',
    'Mittwoch',
    'Donnerstag',
    'Freitag',
    'Samstag',
    'Sonntag',
  ];

  /// „1.234,56 €"
  static String money(Money value) => _currency.format(value.amount);

  /// „1.235 €" — für enge Stellen wie Diagrammachsen.
  static String moneyCompact(Money value) =>
      _currencyCompact.format(value.amount);

  /// „+124,30 €" bzw. „−124,30 €".
  ///
  /// Nutzt das typografische Minuszeichen, das in Tabellenziffern dieselbe
  /// Breite wie das Plus hat — sonst springt die Zeile beim Vorzeichenwechsel.
  static String moneySigned(Money value) {
    if (value.isZero) return money(value);
    final formatted = _currency.format(value.amount.abs());
    return '${value.isNegative ? '−' : '+'}$formatted';
  }

  /// „+1,01 %"; `null` wird zu „—".
  static String percentSigned(double? ratio) {
    if (ratio == null) return '—';
    final formatted = _percent.format((ratio * 100).abs());
    final sign = ratio == 0
        ? ''
        : ratio < 0
        ? '−'
        : '+';
    return '$sign$formatted %';
  }

  /// „68,4 %" ohne Vorzeichen — für Anteile.
  static String share(double ratio) =>
      '${(ratio * 100).toStringAsFixed(1).replaceAll('.', ',')} %';

  /// „16. August 2026"
  static String dateLong(DateTime date) =>
      '${date.day}. ${_months[date.month - 1]} ${date.year}';

  /// „16. Aug. 2026"
  static String dateMedium(DateTime date) =>
      '${date.day}. ${_monthsShort[date.month - 1]} ${date.year}';

  /// „16.08."
  static String dateShort(DateTime date) =>
      '${_two(date.day)}.${_two(date.month)}.';

  /// „Sonntag, 16. August"
  static String dateWithWeekday(DateTime date) =>
      '${_weekdays[date.weekday - 1]}, ${date.day}. ${_months[date.month - 1]}';

  /// „08:12"
  static String time(DateTime moment) =>
      '${_two(moment.hour)}:${_two(moment.minute)}';

  /// Zeitangabe für die „Stand"-Kennzeichnung (L3): „heute, 08:12",
  /// „gestern, 19:40", sonst das Datum.
  static String asOf(DateTime moment, DateTime now) {
    final day = DateTime(moment.year, moment.month, moment.day);
    final today = DateTime(now.year, now.month, now.day);
    final difference = today.difference(day).inDays;

    return switch (difference) {
      0 => 'heute, ${time(moment)}',
      1 => 'gestern, ${time(moment)}',
      < 7 => 'vor $difference Tagen',
      _ => dateMedium(moment),
    };
  }

  /// Wandelt eine Betragseingabe in [Money] um.
  ///
  /// Muss beide Schreibweisen verkraften, die Sammler tatsächlich eintippen:
  /// deutsch „1.234,56" und englisch „1,234.56" — und dazu den Sonderfall
  /// „12.50", bei dem der Punkt als Dezimaltrenner gemeint ist. Ein pauschales
  /// Entfernen aller Punkte würde daraus 1250 € machen.
  static Money? parseMoney(String input) {
    var text = input
        .replaceAll('€', '')
        .replaceAll(' ', '')
        .replaceAll(' ', '')
        .trim();
    if (text.isEmpty) return null;

    final lastComma = text.lastIndexOf(',');
    final lastDot = text.lastIndexOf('.');

    if (lastComma >= 0 && lastDot >= 0) {
      // Beide Zeichen vorhanden: das hintere ist der Dezimaltrenner.
      if (lastComma > lastDot) {
        text = text.replaceAll('.', '').replaceFirst(',', '.');
      } else {
        text = text.replaceAll(',', '');
      }
    } else if (lastComma >= 0) {
      // Nur Komma — im deutschen Sprachraum der Dezimaltrenner.
      text = text.replaceFirst(',', '.');
    } else if (lastDot >= 0) {
      // Nur Punkt: Drei Nachkommastellen sprechen für einen Tausendertrenner
      // („1.234"), alles andere für einen Dezimaltrenner („12.50").
      final decimals = text.length - lastDot - 1;
      final hasSingleDot = text.indexOf('.') == lastDot;
      if (decimals == 3 && (!hasSingleDot || lastDot > 0)) {
        text = text.replaceAll('.', '');
      }
    }

    final parsed = double.tryParse(text);
    if (parsed == null || parsed.isNaN || parsed < 0) return null;
    return Money.fromDouble(parsed);
  }

  static String _two(int value) => value.toString().padLeft(2, '0');
}
