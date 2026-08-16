import 'package:flutter_test/flutter_test.dart';
import 'package:mycollector/domain/models/catalog_item.dart';
import 'package:mycollector/domain/models/grading.dart';
import 'package:mycollector/domain/models/holding.dart';
import 'package:mycollector/domain/services/ebay_lookup.dart';

void main() {
  // Echte Daten aus der TCGdex-Kartendatenbank.
  const megaCharizard = CatalogCard(
    id: 'me02-013',
    setId: 'me02',
    serieId: 'me',
    setName: 'Fatale Flammen',
    setAbbreviation: 'PFL',
    localId: '013',
    nameEn: 'Mega Charizard X ex',
    nameDe: 'Mega-Glurak X-ex',
    setCardCount: 94,
  );

  group('Bezeichnung', () {
    test('nennt Name, Set-Kürzel und Nummer', () {
      expect(megaCharizard.displayName, 'Mega-Glurak X-ex');
      expect(megaCharizard.reference, 'PFL 013');
      expect(megaCharizard.fullLabel, 'Mega-Glurak X-ex (PFL 013)');
      expect(megaCharizard.subtitle, 'Fatale Flammen · 013/94');
    });

    test('kommt ohne bekanntes Kürzel aus', () {
      const card = CatalogCard(
        id: 'xy1-001',
        setId: 'xy1',
        setName: 'XY',
        localId: '001',
        nameEn: 'Venusaur',
        nameDe: 'Bisaflor',
      );

      expect(card.reference, '001');
      expect(card.fullLabel, 'Bisaflor (001)');
    });

    test('fällt ohne deutschen Namen auf Englisch zurück', () {
      const card = CatalogCard(
        id: 'gym1-001',
        setId: 'gym1',
        setName: 'Gym Heroes',
        localId: '001',
        nameEn: 'Beedrill',
      );

      expect(card.displayName, 'Beedrill');
      expect(card.hasGermanName, isFalse);
    });
  });

  group('Bildadressen', () {
    test('bietet nach der API-Adresse deutsche und englische Rückfälle', () {
      const card = CatalogCard(
        id: 'me02-013',
        setId: 'me02',
        serieId: 'me',
        setName: 'Fatale Flammen',
        localId: '013',
        nameEn: 'Mega Charizard X ex',
        imageBase: 'https://assets.tcgdex.net/de/me/me02/013',
      );

      final urls = card.imageCandidates(quality: ImageQuality.high);

      expect(urls.first, 'https://assets.tcgdex.net/de/me/me02/013/high.webp');
      expect(urls, contains('https://assets.tcgdex.net/en/me/me02/013/high.webp'));
      expect(urls.toSet().length, urls.length, reason: 'keine Duplikate');
    });

    test(
      'liefert den englischen Rückfall auch ohne Bild aus der API',
      () {
        // Genau der Fall, in dem TCGdex gar kein Bildfeld schickt: Es gibt
        // keinen deutschen Scan. Der englische Scan existiert fast immer.
        final urls = megaCharizard.imageCandidates();

        expect(urls, isNotEmpty);
        expect(
          urls.last,
          'https://assets.tcgdex.net/en/me/me02/013/high.webp',
        );
      },
    );

    test('unterscheidet die Qualitätsstufen', () {
      expect(
        megaCharizard.imageCandidates(quality: ImageQuality.low).first,
        contains('/low.webp'),
      );
      expect(
        megaCharizard.imageCandidates(quality: ImageQuality.high).first,
        contains('/high.webp'),
      );
    });

    test('bleibt ohne Serie leer, statt eine falsche Adresse zu bilden', () {
      const card = CatalogCard(
        id: 'unbekannt-001',
        setId: '',
        setName: '',
        localId: '',
        nameEn: 'Testkarte',
      );

      expect(card.imageCandidates(), isEmpty);
      expect(card.imageUrl(), isNull);
    });

    test('nutzt für versiegelte Produkte das Set-Logo', () {
      const product = SealedProduct(
        id: 'sealed-sv03.5-display',
        name: '151 Display',
        type: SealedProductType.display,
        setId: 'sv03.5',
        serieId: 'sv',
        setName: '151',
      );

      expect(
        product.imageCandidates().first,
        'https://assets.tcgdex.net/de/sv/sv03.5/logo.webp',
      );
      expect(product.rendersAsLogo, isTrue);
    });

    test('ein frei angelegtes Produkt ohne Set hat kein Bild', () {
      const product = SealedProduct(
        id: 'custom-1',
        name: 'Eigene Box',
        type: SealedProductType.other,
        isCustom: true,
      );

      expect(product.imageCandidates(), isEmpty);
    });
  });

  group('Suche', () {
    test('trifft auf den deutschen Namen', () {
      expect(megaCharizard.matches('glurak'), isTrue);
      expect(megaCharizard.matches('GLURAK'), isTrue);
    });

    test('trifft auf den englischen Namen', () {
      expect(megaCharizard.matches('charizard'), isTrue);
    });

    test('trifft auf Set-Kürzel und Nummer', () {
      expect(megaCharizard.matches('PFL'), isTrue);
      expect(megaCharizard.matches('013'), isTrue);
      expect(megaCharizard.matches('PFL 013'), isTrue);
    });

    test('trifft auf den Set-Namen', () {
      expect(megaCharizard.matches('Fatale'), isTrue);
    });

    test('verlangt, dass alle Wörter vorkommen', () {
      expect(megaCharizard.matches('glurak pfl'), isTrue);
      expect(megaCharizard.matches('glurak mew'), isFalse);
    });

    test('lehnt Fremdbegriffe ab', () {
      expect(megaCharizard.matches('Pikachu'), isFalse);
    });
  });

  group('eBay-Verweise', () {
    Holding holdingFor({Grading? grading}) => Holding(
      id: 'h1',
      portfolioId: 'p1',
      type: HoldingType.card,
      catalogId: 'me02-013',
      quantity: 1,
      purchaseDate: DateTime(2026, 1, 1),
      createdAt: DateTime(2026, 1, 1),
      grading: grading,
    );

    test('sucht verkaufte Angebote auf der deutschen Seite', () {
      final url = EbayLookup.soldListings(
        item: megaCharizard,
        holding: holdingFor(),
      );

      expect(url.host, 'www.ebay.de');
      expect(url.queryParameters['LH_Sold'], '1');
      expect(url.queryParameters['LH_Complete'], '1');
      expect(
        url.queryParameters['_sop'],
        '13',
        reason: 'nach Verkaufsende sortiert — der oberste ist der letzte',
      );
      expect(url.queryParameters['_nkw'], 'Mega-Glurak X-ex 013');
    });

    test('nimmt die Bewertung mit in den Suchbegriff', () {
      final url = EbayLookup.soldListings(
        item: megaCharizard,
        holding: holdingFor(grading: const Grading(Grader.psa, 10)),
      );

      expect(url.queryParameters['_nkw'], 'Mega-Glurak X-ex 013 PSA 10');
    });

    test('unterscheidet aktuelle Angebote von Verkäufen', () {
      final active = EbayLookup.activeListings(
        item: megaCharizard,
        holding: holdingFor(),
      );

      expect(active.queryParameters.containsKey('LH_Sold'), isFalse);
    });

    test('funktioniert auch für versiegelte Produkte', () {
      const product = SealedProduct(
        id: 'sealed-1',
        name: '151 Display',
        type: SealedProductType.display,
      );
      final url = EbayLookup.soldListings(
        item: product,
        holding: holdingFor(),
      );

      expect(url.queryParameters['_nkw'], '151 Display');
    });
  });
}
