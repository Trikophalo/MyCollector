import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../domain/models/catalog_item.dart';
import '../../domain/models/holding.dart';
import '../../domain/models/money.dart';
import '../../domain/models/price_point.dart';
import '../../domain/models/valuation.dart';
import '../../domain/services/portfolio_service.dart';
import '../../ui/format/formats.dart';
import '../../ui/theme/app_theme.dart';
import '../../ui/widgets/common.dart';

/// Preisverlauf einer einzelnen Position.
final priceHistoryProvider =
    FutureProvider.family<List<PricePoint>, ({String catalogId, String key})>(
      (ref, args) => ref
          .watch(repositoryProvider)
          .priceHistory(args.catalogId, PriceKey(args.key)),
    );

/// Produktdetail (§5.3, Screen 4).
class HoldingDetailScreen extends ConsumerWidget {
  const HoldingDetailScreen({required this.holdingId, super.key});

  final String holdingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final portfolio = ref.watch(portfolioProvider);
    final now = DateTime.now();

    return Scaffold(
      appBar: AppBar(title: const Text('Position')),
      body: portfolio.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => EmptyState(
          icon: Icons.error_outline_rounded,
          title: 'Nicht ladbar',
          message: '$error',
        ),
        data: (summary) {
          final position = summary.positions
              .where((p) => p.holding.id == holdingId)
              .firstOrNull;

          if (position == null) {
            return const EmptyState(
              icon: Icons.search_off_rounded,
              title: 'Position nicht gefunden',
              message: 'Sie wurde vermutlich gerade gelöscht.',
            );
          }

          return _DetailBody(position: position, now: now);
        },
      ),
    );
  }
}

class _DetailBody extends ConsumerWidget {
  const _DetailBody({required this.position, required this.now});

  final PositionValuation position;
  final DateTime now;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final holding = position.holding;
    final valuation = position.valuation;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        Spacing.lg,
        Spacing.sm,
        Spacing.lg,
        Spacing.xxl,
      ),
      children: [
        Center(
          child: Hero(
            tag: 'holding-${holding.id}',
            child: CatalogThumbnail(
              item: position.item,
              width: 168,
              quality: ImageQuality.high,
            ),
          ),
        ),
        const SizedBox(height: Spacing.xl),
        Text(
          position.displayName,
          textAlign: TextAlign.center,
          style: context.texts.headlineLarge,
        ),
        const SizedBox(height: Spacing.xs),
        Text(
          position.subtitle,
          textAlign: TextAlign.center,
          style: context.texts.bodyMedium?.copyWith(
            color: colors.labelSecondary,
          ),
        ),
        if (holding.grading != null) ...[
          const SizedBox(height: Spacing.md),
          Center(child: GradingBadge(grading: holding.grading!)),
        ],
        const SizedBox(height: Spacing.xl),

        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                position.hasValue
                    ? Formats.money(position.totalValue)
                    : 'Kein Wert verfügbar',
                style: context.texts.headlineLarge,
              ),
              const SizedBox(height: Spacing.xs),
              Row(
                children: [
                  if (holding.quantity > 1)
                    Text(
                      '${holding.quantity} × '
                      '${Formats.money(valuation.unitValue)}  ·  ',
                      style: context.texts.bodySmall?.copyWith(
                        color: colors.labelSecondary,
                      ),
                    ),
                  Expanded(
                    child: PriceSourceNote(valuation: valuation, now: now),
                  ),
                ],
              ),
              if (valuation.tier.isFallback) ...[
                const SizedBox(height: Spacing.md),
                _FallbackHint(tier: valuation.tier),
              ],
              const SizedBox(height: Spacing.lg),
              Row(
                children: [
                  Expanded(
                    child: _Figure(
                      label: 'Einstand',
                      value: Formats.money(position.invested),
                    ),
                  ),
                  Expanded(
                    child: _Figure(
                      label: 'Rendite',
                      value: Formats.moneySigned(position.absoluteReturn),
                      valueColor: colors.forChange(
                        position.absoluteReturn.cents,
                      ),
                      caption: Formats.percentSigned(position.returnRatio),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: Spacing.lg),

        _PriceHistoryCard(position: position),
        const SizedBox(height: Spacing.lg),

        SectionCard(
          title: 'Bestand',
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.lg,
            vertical: Spacing.sm,
          ),
          child: Column(
            children: [
              _Row(label: 'Menge', value: '${holding.quantity}'),
              _Row(
                label: 'Kaufpreis je Stück',
                value: Formats.money(holding.purchasePrice),
              ),
              _Row(
                label: 'Kaufdatum',
                value: Formats.dateLong(holding.purchaseDate),
              ),
              _Row(label: 'Ausprägung', value: holding.variantLabel),
              if (holding.certificateNumber != null)
                _Row(label: 'Zertifikat', value: holding.certificateNumber!),
              if (holding.note != null)
                _Row(label: 'Notiz', value: holding.note!),
            ],
          ),
        ),
        const SizedBox(height: Spacing.xl),

        FilledButton.tonal(
          onPressed: () => _editPrice(context, ref, holding),
          child: Text(
            holding.hasManualPrice
                ? 'Eigenen Preis ändern'
                : 'Eigenen Preis setzen',
          ),
        ),
        if (holding.hasManualPrice) ...[
          const SizedBox(height: Spacing.sm),
          TextButton(
            onPressed: () => _clearManualPrice(ref, holding),
            child: const Text('Zurück zum Marktpreis'),
          ),
        ],
        const SizedBox(height: Spacing.sm),
        TextButton(
          onPressed: () => _delete(context, ref, holding),
          style: TextButton.styleFrom(foregroundColor: colors.negative),
          child: const Text('Position löschen'),
        ),
      ],
    );
  }

  Future<void> _editPrice(
    BuildContext context,
    WidgetRef ref,
    Holding holding,
  ) async {
    final controller = TextEditingController(
      text: holding.manualPrice == null
          ? ''
          : (holding.manualPrice!.amount)
                .toStringAsFixed(2)
                .replaceAll('.', ','),
    );

    final result = await showDialog<Money?>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eigener Preis'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Wert je Stück. Nützlich, wenn du einen realistischeren '
              'Referenzwert kennst als die API liefert — etwa aus einem '
              'beobachteten Verkauf.',
              style: context.texts.bodySmall?.copyWith(
                color: context.colors.labelSecondary,
              ),
            ),
            const SizedBox(height: Spacing.lg),
            TextField(
              controller: controller,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                hintText: '0,00',
                suffixText: '€',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () =>
                Navigator.of(context).pop(Formats.parseMoney(controller.text)),
            child: const Text('Übernehmen'),
          ),
        ],
      ),
    );

    if (result != null) {
      await ref
          .read(collectionControllerProvider)
          .updateHolding(
            holding.copyWith(
              priceMode: PriceMode.manual,
              manualPrice: result,
              manualPriceSetAt: DateTime.now(),
            ),
          );
      HapticFeedback.selectionClick();
    }
  }

  Future<void> _clearManualPrice(WidgetRef ref, Holding holding) async {
    await ref
        .read(collectionControllerProvider)
        .updateHolding(
          holding.copyWith(priceMode: PriceMode.auto, clearManualPrice: true),
        );
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    Holding holding,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Position löschen?'),
        content: const Text(
          'Die Position wird entfernt. Vergangene Tageswerte der '
          'Portfoliokurve bleiben unverändert.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Löschen'),
          ),
        ],
      ),
    );

    if ((confirmed ?? false) && context.mounted) {
      await ref.read(collectionControllerProvider).deleteHolding(holding.id);
      if (context.mounted) Navigator.of(context).pop();
    }
  }
}

class _FallbackHint extends StatelessWidget {
  const _FallbackHint({required this.tier});

  final ValuationTier tier;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final message = switch (tier) {
      ValuationTier.lastKnown =>
        'Dieser Preis ist älter als zwei Tage. Zum Aktualisieren auf der '
            'Startseite nach unten ziehen.',
      ValuationTier.purchasePrice =>
        'Für diese Ausprägung liefert keine Quelle einen Marktpreis. '
            'Angezeigt wird dein Kaufpreis.',
      ValuationTier.unavailable =>
        'Weder Markt- noch Kaufpreis bekannt. Setze einen eigenen Wert.',
      _ => '',
    };

    if (message.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(Spacing.md),
      decoration: BoxDecoration(
        color: colors.warning.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(Spacing.radiusSmall),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, size: 16, color: colors.warning),
          const SizedBox(width: Spacing.sm),
          Expanded(
            child: Text(
              message,
              style: context.texts.bodySmall?.copyWith(color: colors.warning),
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceHistoryCard extends ConsumerWidget {
  const _PriceHistoryCard({required this.position});

  final PositionValuation position;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final history = ref.watch(
      priceHistoryProvider((
        catalogId: position.holding.catalogId,
        key: position.holding.priceKey.value,
      )),
    );

    return SectionCard(
      title: 'Preisverlauf',
      child: history.when(
        loading: () => const SizedBox(
          height: 60,
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (_, _) => Text(
          'Verlauf nicht lesbar.',
          style: context.texts.bodySmall?.copyWith(
            color: colors.labelSecondary,
          ),
        ),
        data: (points) {
          if (points.length < 2) {
            return Text(
              'Noch kein Verlauf — ab dem zweiten Preisabruf entsteht hier '
              'eine Kurve.',
              style: context.texts.bodySmall?.copyWith(
                color: colors.labelSecondary,
              ),
            );
          }

          final first = points.first.valueEur;
          final last = points.last.valueEur;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 60,
                child: CustomPaint(
                  size: const Size(double.infinity, 60),
                  painter: _SparklinePainter(
                    values: points.map((p) => p.valueEur.cents).toList(),
                    color: colors.forChange((last - first).cents),
                  ),
                ),
              ),
              const SizedBox(height: Spacing.md),
              Row(
                children: [
                  Text(
                    Formats.dateShort(points.first.capturedAt),
                    style: context.texts.labelSmall?.copyWith(
                      color: colors.labelTertiary,
                    ),
                  ),
                  const Spacer(),
                  ChangePill(
                    change: last - first,
                    ratio: Money.changeRatio(first, last),
                    compact: true,
                  ),
                  const Spacer(),
                  Text(
                    Formats.dateShort(points.last.capturedAt),
                    style: context.texts.labelSmall?.copyWith(
                      color: colors.labelTertiary,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  const _SparklinePainter({required this.values, required this.color});

  final List<int> values;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;

    final min = values.reduce((a, b) => a < b ? a : b).toDouble();
    final max = values.reduce((a, b) => a > b ? a : b).toDouble();
    final span = (max - min).abs() < 1 ? 1.0 : max - min;

    final path = Path();
    for (var i = 0; i < values.length; i++) {
      final x = size.width * i / (values.length - 1);
      final y =
          size.height * (1 - (values[i] - min) / span) * 0.85 +
          size.height * 0.075;
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }

    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter old) =>
      old.values != values || old.color != color;
}

class _Figure extends StatelessWidget {
  const _Figure({
    required this.label,
    required this.value,
    this.valueColor,
    this.caption,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final String? caption;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: context.texts.bodySmall?.copyWith(
            color: colors.labelSecondary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: context.texts.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: valueColor,
          ),
        ),
        if (caption != null)
          Text(
            caption!,
            style: context.texts.labelSmall?.copyWith(color: valueColor),
          ),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Spacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: context.texts.bodyMedium?.copyWith(
                color: colors.labelSecondary,
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: context.texts.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
