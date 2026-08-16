import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../domain/models/catalog_item.dart';
import '../theme/app_theme.dart';

/// Zeigt das Bild eines Katalogobjekts und probiert dabei mehrere Adressen
/// nacheinander durch.
///
/// Nötig, weil TCGdex einen Scan nur dann ausliefert, wenn er für die
/// angefragte Sprache existiert — für deutsche Karten ist das oft nicht der
/// Fall (§3.3). Schlägt eine Adresse fehl, rückt das Widget zur nächsten
/// weiter; erst wenn alle scheitern, erscheint der gestaltete Platzhalter.
class CatalogImage extends StatefulWidget {
  const CatalogImage({
    required this.item,
    this.width = 44,
    this.quality = ImageQuality.low,
    this.borderRadius,
    super.key,
  });

  final CatalogItem? item;
  final double width;
  final ImageQuality quality;
  final BorderRadius? borderRadius;

  /// Seitenverhältnis einer Sammelkarte (Breite zu Höhe).
  static const double cardAspect = 1 / 1.4;

  @override
  State<CatalogImage> createState() => _CatalogImageState();
}

class _CatalogImageState extends State<CatalogImage> {
  int _index = 0;

  List<String> get _candidates =>
      widget.item?.imageCandidates(quality: widget.quality) ?? const [];

  @override
  void didUpdateWidget(covariant CatalogImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item?.id != widget.item?.id ||
        oldWidget.quality != widget.quality) {
      _index = 0;
    }
  }

  /// Rückt nach einem Fehlschlag auf die nächste Adresse.
  ///
  /// Der Wechsel passiert nach dem Bildaufbau, weil während des Bauens kein
  /// Zustand geändert werden darf.
  void _advance() {
    if (_index + 1 >= _candidates.length) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _index++);
    });
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final isLogo = item is SealedProduct && item.rendersAsLogo;
    final height = isLogo ? widget.width * 0.62 : widget.width / CatalogImage.cardAspect;
    final radius =
        widget.borderRadius ?? BorderRadius.circular(widget.width * 0.08);
    final candidates = _candidates;

    final placeholder = _Placeholder(
      item: item,
      width: widget.width,
      height: height,
      radius: radius,
    );

    if (candidates.isEmpty || _index >= candidates.length) return placeholder;

    return ClipRRect(
      borderRadius: radius,
      child: CachedNetworkImage(
        imageUrl: candidates[_index],
        width: widget.width,
        height: height,
        fit: isLogo ? BoxFit.contain : BoxFit.cover,
        fadeInDuration: const Duration(milliseconds: 180),
        placeholder: (_, _) => placeholder,
        errorWidget: (_, _, _) {
          _advance();
          return placeholder;
        },
      ),
    );
  }
}

/// Gestalteter Platzhalter — ein fehlendes Bild ist der Normalfall und soll
/// nicht wie ein Fehler aussehen.
class _Placeholder extends StatelessWidget {
  const _Placeholder({
    required this.item,
    required this.width,
    required this.height,
    required this.radius,
  });

  final CatalogItem? item;
  final double width;
  final double height;
  final BorderRadius radius;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final (label, icon) = switch (item) {
      CatalogCard(:final localId) => (localId, null),
      SealedProduct(:final type) => (null, _iconFor(type)),
      _ => (null, Icons.help_outline_rounded),
    };

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: radius,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors.accent.withValues(alpha: 0.20),
            colors.accent.withValues(alpha: 0.06),
          ],
        ),
        border: Border.all(color: colors.separator, width: 0.5),
      ),
      alignment: Alignment.center,
      child: icon != null
          ? Icon(icon, color: colors.accent, size: width * 0.34)
          : Text(
              label ?? '?',
              style: context.texts.labelSmall?.copyWith(
                color: colors.accent,
                fontWeight: FontWeight.w700,
                fontSize: width * 0.22,
              ),
            ),
    );
  }

  IconData _iconFor(SealedProductType type) => switch (type) {
    SealedProductType.display => Icons.inventory_2_rounded,
    SealedProductType.eliteTrainerBox => Icons.card_giftcard_rounded,
    SealedProductType.tin => Icons.takeout_dining_rounded,
    SealedProductType.boosterPack => Icons.style_rounded,
    SealedProductType.blister => Icons.dashboard_rounded,
    _ => Icons.inventory_rounded,
  };
}

/// Antippbares Bild, das die Karte formatfüllend öffnet.
class ZoomableCatalogImage extends StatelessWidget {
  const ZoomableCatalogImage({
    required this.item,
    required this.heroTag,
    this.width = 168,
    super.key,
  });

  final CatalogItem? item;
  final String heroTag;
  final double width;

  @override
  Widget build(BuildContext context) {
    final item = this.item;
    final hasImage = (item?.imageCandidates().isNotEmpty ?? false);

    return Semantics(
      button: hasImage,
      label: hasImage ? 'Bild vergrößern' : null,
      child: GestureDetector(
        onTap: hasImage && item != null
            ? () => Navigator.of(context).push(
                _FullscreenImageRoute(item: item, heroTag: heroTag),
              )
            : null,
        child: Hero(
          tag: heroTag,
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              CatalogImage(
                item: item,
                width: width,
                quality: ImageQuality.high,
                borderRadius: BorderRadius.circular(width * 0.06),
              ),
              if (hasImage)
                Padding(
                  padding: const EdgeInsets.all(Spacing.sm),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.45),
                      shape: BoxShape.circle,
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(5),
                      child: Icon(
                        Icons.zoom_in_rounded,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Vollbildansicht mit Zoom.
class _FullscreenImageRoute extends PageRouteBuilder<void> {
  _FullscreenImageRoute({required this.item, required this.heroTag})
    : super(
        opaque: false,
        barrierColor: Colors.black87,
        transitionDuration: const Duration(milliseconds: 260),
        reverseTransitionDuration: const Duration(milliseconds: 220),
        pageBuilder: (context, animation, _) => FadeTransition(
          opacity: animation,
          child: _FullscreenImage(item: item, heroTag: heroTag),
        ),
      );

  final CatalogItem item;
  final String heroTag;
}

class _FullscreenImage extends StatelessWidget {
  const _FullscreenImage({required this.item, required this.heroTag});

  final CatalogItem item;
  final String heroTag;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final maxWidth = size.width * 0.92;
    final maxHeight = size.height * 0.78;
    // Die Karte soll vollständig sichtbar sein, egal wie hoch das Fenster ist.
    final width = maxWidth / CatalogImage.cardAspect > maxHeight
        ? maxHeight * CatalogImage.cardAspect
        : maxWidth;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                minScale: 1,
                maxScale: 4,
                clipBehavior: Clip.none,
                child: Hero(
                  tag: heroTag,
                  child: CatalogImage(
                    item: item,
                    width: width,
                    quality: ImageQuality.high,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(Spacing.lg),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        item.fullLabel,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: Spacing.xs),
                      Text(
                        'Zum Zoomen ziehen · Tippen zum Schließen',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: SafeArea(
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded, color: Colors.white),
                  tooltip: 'Schließen',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
