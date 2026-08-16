import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../domain/models/catalog_item.dart';
import '../../domain/models/grading.dart';
import '../../domain/models/money.dart';
import '../../domain/models/valuation.dart';
import '../format/formats.dart';
import '../theme/app_theme.dart';

/// Ein abgesetzter Inhaltsblock mit optionaler Überschrift.
class SectionCard extends StatelessWidget {
  const SectionCard({
    required this.child,
    this.title,
    this.trailing,
    this.padding = const EdgeInsets.all(Spacing.lg),
    super.key,
  });

  final Widget child;
  final String? title;
  final Widget? trailing;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null)
          Padding(
            padding: const EdgeInsets.only(
              left: Spacing.xs,
              right: Spacing.xs,
              bottom: Spacing.sm,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title!,
                    style: context.texts.titleMedium?.copyWith(
                      color: colors.labelSecondary,
                    ),
                  ),
                ),
                ?trailing,
              ],
            ),
          ),
        // Schatten und Fläche sind getrennt: Der Schatten liegt in einer
        // farblosen Box, die Fläche selbst ist ein Material. Andernfalls
        // verdeckte die eingefärbte Box die Tipp-Effekte enthaltener
        // ListTiles — Flutter meldet das zu Recht als Fehler.
        DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Spacing.radiusLarge),
            boxShadow: [
              BoxShadow(
                color: colors.shadow,
                blurRadius: 18,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: colors.surface,
            borderRadius: BorderRadius.circular(Spacing.radiusLarge),
            clipBehavior: Clip.antiAlias,
            child: Padding(
              padding: padding,
              child: SizedBox(width: double.infinity, child: child),
            ),
          ),
        ),
      ],
    );
  }
}

/// Farbige Kapsel für eine Wertveränderung, z. B. „+124,30 € · +1,01 %".
///
/// Zeigt immer ein Vorzeichen, damit die Aussage auch ohne Farbwahrnehmung
/// lesbar bleibt (§5.1).
class ChangePill extends StatelessWidget {
  const ChangePill({
    required this.change,
    this.ratio,
    this.suffix,
    this.compact = false,
    super.key,
  });

  final Money? change;
  final double? ratio;
  final String? suffix;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final change = this.change;

    if (change == null) {
      return Text(
        'Noch keine Vortagsdaten',
        style: context.texts.bodySmall?.copyWith(color: colors.labelSecondary),
      );
    }

    final color = colors.forChange(change.cents);
    final parts = <String>[
      Formats.moneySigned(change),
      if (ratio != null) Formats.percentSigned(ratio),
      ?suffix,
    ];

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? Spacing.sm : Spacing.md,
        vertical: compact ? 3 : 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(Spacing.radiusSmall),
      ),
      child: Text(
        parts.join(' · '),
        style: (compact ? context.texts.labelSmall : context.texts.bodyMedium)
            ?.copyWith(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}

/// Kennzeichnung einer gegradeten Karte in Slab-Optik.
class GradingBadge extends StatelessWidget {
  const GradingBadge({required this.grading, this.compact = false, super.key});

  final Grading grading;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isTop = grading.isTopGrade;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? Spacing.sm : Spacing.md,
        vertical: compact ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: isTop
            ? colors.accent.withValues(alpha: 0.14)
            : colors.labelSecondary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isTop
              ? colors.accent.withValues(alpha: 0.35)
              : colors.separator,
          width: 0.8,
        ),
      ),
      child: Text(
        grading.label,
        style: context.texts.labelSmall?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
          color: isTop ? colors.accent : colors.labelSecondary,
        ),
      ),
    );
  }
}

/// Kartenbild mit Platzhalter.
///
/// Ein fehlendes Bild ist der Normalfall und kein Fehler: Nicht für jede Karte
/// existiert ein deutscher Scan (§3.3). Der Platzhalter ist deshalb gestaltet,
/// nicht bloß leer.
class CatalogThumbnail extends StatelessWidget {
  const CatalogThumbnail({
    required this.item,
    this.width = 44,
    this.quality = ImageQuality.low,
    super.key,
  });

  final CatalogItem? item;
  final double width;
  final ImageQuality quality;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final height = width * 1.4;
    final url = item?.imageUrl(quality: quality);
    final radius = BorderRadius.circular(width * 0.12);

    Widget placeholder() {
      final label = switch (item) {
        CatalogCard(:final localId) => localId,
        SealedProduct(:final type) => type.label.substring(0, 1),
        _ => '?',
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
        child: Text(
          label,
          style: context.texts.labelSmall?.copyWith(
            color: colors.accent,
            fontWeight: FontWeight.w700,
            fontSize: width * 0.22,
          ),
        ),
      );
    }

    if (url == null) return placeholder();

    return ClipRRect(
      borderRadius: radius,
      child: CachedNetworkImage(
        imageUrl: url,
        width: width,
        height: height,
        fit: BoxFit.cover,
        placeholder: (_, _) => placeholder(),
        errorWidget: (_, _, _) => placeholder(),
      ),
    );
  }
}

/// Herkunftszeile eines Preises: Quelle, Stand und gegebenenfalls der Hinweis
/// auf eine Fremdwährung (L3).
class PriceSourceNote extends StatelessWidget {
  const PriceSourceNote({
    required this.valuation,
    required this.now,
    this.dense = false,
    super.key,
  });

  final Valuation valuation;
  final DateTime now;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final source = valuation.source;
    final asOf = valuation.asOf;

    final parts = <String>[
      if (source != null) source.label,
      if (asOf != null) 'Stand: ${Formats.asOf(asOf, now)}',
    ];

    if (parts.isEmpty) parts.add(valuation.tier.label);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (valuation.isStale)
          Padding(
            padding: const EdgeInsets.only(right: Spacing.xs),
            child: Icon(
              Icons.schedule_rounded,
              size: dense ? 12 : 14,
              color: colors.warning,
            ),
          ),
        Flexible(
          child: Text(
            parts.join(' · '),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.texts.labelSmall?.copyWith(
              color: valuation.isStale ? colors.warning : colors.labelSecondary,
            ),
          ),
        ),
        if (valuation.isUsMarket)
          Padding(
            padding: const EdgeInsets.only(left: Spacing.xs),
            child: Tooltip(
              message: 'US-Marktpreis, in Euro umgerechnet',
              child: Text(
                'US',
                style: context.texts.labelSmall?.copyWith(
                  color: colors.labelTertiary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Freundlicher Leerzustand mit Handlungsaufforderung.
class EmptyState extends StatelessWidget {
  const EmptyState({
    required this.icon,
    required this.title,
    required this.message,
    this.action,
    super.key,
  });

  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: colors.accent.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: colors.accent),
            ),
            const SizedBox(height: Spacing.lg),
            Text(
              title,
              style: context.texts.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Spacing.sm),
            Text(
              message,
              style: context.texts.bodyMedium?.copyWith(
                color: colors.labelSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (action != null) ...[
              const SizedBox(height: Spacing.xl),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
