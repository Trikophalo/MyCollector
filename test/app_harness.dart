import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mycollector/app/app.dart';
import 'package:mycollector/app/providers.dart';
import 'package:mycollector/data/demo/demo_catalog.dart';
import 'package:mycollector/data/local/database.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Gemeinsamer Aufbau für Widget- und Bildvergleichstests.
///
/// Die App läuft dabei vollständig echt — eigene Datenbank im Arbeitsspeicher,
/// echte Bewertungslogik, echte Screens. Ersetzt wird nur die externe
/// Datenquelle, damit Tests ohne Netz und reproduzierbar laufen.
/// Beantwortet die Anfragen von `path_provider`.
///
/// Der Bild-Zwischenspeicher fragt beim ersten Laden nach einem
/// Verzeichnis. In der Testumgebung gibt es keine Plattformimplementierung,
/// weshalb der Aufruf sonst mit einer `MissingPluginException` abbricht —
/// und zwar erst, seit die Beispieldaten echte Bildadressen tragen.
void _stubPathProvider() {
  const channel = MethodChannel('plugins.flutter.io/path_provider');
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
        channel,
        (call) async => Directory.systemTemp.createTempSync('mycollector').path,
      );
}

Future<ProviderContainer> pumpApp(
  WidgetTester tester, {
  bool withDemoData = true,
  ThemeMode themeMode = ThemeMode.light,
  Size surfaceSize = const Size(414, 896),
  String? fontFamily,
}) async {
  _stubPathProvider();

  tester.view
    ..physicalSize = surfaceSize * 3
    ..devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  SharedPreferences.setMockInitialValues({
    'themeMode': switch (themeMode) {
      ThemeMode.dark => 'dark',
      ThemeMode.light => 'light',
      ThemeMode.system => 'system',
    },
  });
  final preferences = await SharedPreferences.getInstance();

  final database = AppDatabase(NativeDatabase.memory());
  addTearDown(database.close);

  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(preferences),
      databaseProvider.overrideWithValue(database),
      catalogSourceProvider.overrideWithValue(const DemoCatalogSource()),
    ],
  );
  addTearDown(container.dispose);

  if (withDemoData) {
    await container.read(collectionControllerProvider).loadDemoData();
  }

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MyCollectorApp(fontFamily: fontFamily),
    ),
  );
  await tester.pumpAndSettle();

  return container;
}

/// Name, unter dem die Testschrift registriert wird.
const String kTestFont = 'MyCollectorTestFont';

/// Lädt eine echte Schrift, damit Bildvergleiche lesbaren Text zeigen statt
/// der Platzhalterkästchen der Testumgebung.
Future<void> loadTestFonts() async {
  const regular = [
    '/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf',
    '/usr/share/fonts/truetype/liberation/LiberationSans-Regular.ttf',
  ];
  const bold = [
    '/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf',
    '/usr/share/fonts/truetype/liberation/LiberationSans-Bold.ttf',
  ];

  final loader = FontLoader(kTestFont);
  var found = false;

  for (final candidates in [regular, bold]) {
    final path = candidates.where((p) => File(p).existsSync()).firstOrNull;
    if (path == null) continue;
    loader.addFont(_readFont(path));
    found = true;
  }

  if (found) await loader.load();

  // Ohne die Icon-Schrift erschienen alle Symbole als leere Kästchen.
  const iconFont =
      '/opt/flutter/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf';
  if (File(iconFont).existsSync()) {
    await (FontLoader('MaterialIcons')..addFont(_readFont(iconFont))).load();
  }
}

Future<ByteData> _readFont(String path) async {
  final bytes = await File(path).readAsBytes();
  return ByteData.view(Uint8List.fromList(bytes).buffer);
}
