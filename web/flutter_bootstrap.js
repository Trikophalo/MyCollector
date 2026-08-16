{{flutter_js}}
{{flutter_build_config}}
_flutter.loader.load({
  // Bewusst OHNE serviceWorkerSettings: Für die Web-Vorschau wird kein
  // Service Worker registriert. Der Standard-Service-Worker cached die App
  // so aggressiv, dass Besucher nach einem Deploy die alte Version sehen,
  // bis sie zweimal neu laden — für eine Vorschau nur verwirrend.
  config: {
    // Lädt den Grafik-Renderer aus dem mitgebauten "canvaskit/"-Ordner statt
    // von Googles CDN (www.gstatic.com). Das hält die App als statische
    // Auslieferung (z. B. GitHub Pages) frei von externen Laufzeit-
    // Abhängigkeiten — passend zum Local-first-Prinzip der App (PLANUNG.md L2).
    canvasKitBaseUrl: "canvaskit/"
  }
});
