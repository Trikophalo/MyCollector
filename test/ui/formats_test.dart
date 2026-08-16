import 'package:flutter_test/flutter_test.dart';
import 'package:mycollector/domain/models/money.dart';
import 'package:mycollector/ui/format/formats.dart';

void main() {
  // Zwischen Betrag und Währungszeichen steht ein geschütztes Leerzeichen,
  // damit die Angabe nie über einen Zeilenumbruch zerrissen wird.
  const nbsp = ' ';

  group('Beträge', () {
    test('formatiert nach deutscher Konvention', () {
      expect(Formats.money(const Money(123456)), '1.234,56$nbsp€');
      expect(Formats.money(const Money(0)), '0,00$nbsp€');
    });

    test('setzt Vorzeichen mit typografischem Minus', () {
      expect(Formats.moneySigned(const Money(12430)), '+124,30$nbsp€');
      expect(Formats.moneySigned(const Money(-12430)), '−124,30$nbsp€');
      expect(Formats.moneySigned(const Money.zero()), '0,00$nbsp€');
    });
  });

  group('Prozentwerte', () {
    test('zeigt Vorzeichen und zwei Nachkommastellen', () {
      expect(Formats.percentSigned(0.0101), '+1,01 %');
      expect(Formats.percentSigned(-0.2534), '−25,34 %');
    });

    test('zeigt für unbekannte Werte einen Gedankenstrich statt null', () {
      expect(Formats.percentSigned(null), '—');
    });
  });

  group('Datumsangaben', () {
    final now = DateTime(2026, 8, 16, 14, 30);

    test('benennt heute und gestern', () {
      expect(Formats.asOf(DateTime(2026, 8, 16, 8, 12), now), 'heute, 08:12');
      expect(
        Formats.asOf(DateTime(2026, 8, 15, 19, 40), now),
        'gestern, 19:40',
      );
    });

    test('nennt Tage innerhalb der letzten Woche', () {
      expect(Formats.asOf(DateTime(2026, 8, 13, 9), now), 'vor 3 Tagen');
    });

    test('fällt darüber hinaus auf das Datum zurück', () {
      expect(Formats.asOf(DateTime(2026, 6, 2, 9), now), '2. Juni 2026');
    });

    test('schreibt lange Daten deutsch aus', () {
      expect(Formats.dateLong(DateTime(2026, 3, 7)), '7. März 2026');
      expect(Formats.dateShort(DateTime(2026, 3, 7)), '07.03.');
    });
  });

  group('Eingaben', () {
    test('akzeptiert Komma und Punkt als Dezimaltrenner', () {
      expect(Formats.parseMoney('12,50'), const Money(1250));
      expect(Formats.parseMoney('12.50'), const Money(1250));
    });

    test('verkraftet Tausenderpunkte und Währungszeichen', () {
      expect(Formats.parseMoney('1.234,56 €'), const Money(123456));
      expect(Formats.parseMoney('1.234,56$nbsp€'), const Money(123456));
    });

    test('erkennt den Punkt als Tausendertrenner ohne Nachkommastellen', () {
      expect(Formats.parseMoney('1.234'), const Money(123400));
      expect(Formats.parseMoney('1.234.567'), const Money(123456700));
    });

    test('versteht auch die englische Schreibweise', () {
      expect(Formats.parseMoney('1,234.56'), const Money(123456));
    });

    test('weist Unsinn zurück, statt still eine Null zu speichern', () {
      expect(Formats.parseMoney('abc'), isNull);
      expect(Formats.parseMoney(''), isNull);
      expect(Formats.parseMoney('-5'), isNull);
    });
  });
}
