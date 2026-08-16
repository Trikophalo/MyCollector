{{flutter_js}}
{{flutter_build_config}}
_flutter.loader.load({
  serviceWorkerSettings: {
    serviceWorkerVersion: {{flutter_service_worker_version}}
  },
  config: {
    // Lädt den Grafik-Renderer aus dem mitgebauten "canvaskit/"-Ordner statt
    // von Googles CDN (www.gstatic.com). Das hält die App als statische
    // Auslieferung (z. B. GitHub Pages) frei von externen Laufzeit-
    // Abhängigkeiten — passend zum Local-first-Prinzip der App (PLANUNG.md L2).
    canvasKitBaseUrl: "canvaskit/"
  }
});
